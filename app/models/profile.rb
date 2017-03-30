class Profile < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_restore :restore_relationships

  belongs_to :user
  belongs_to :organization

  has_many :degreeholderships, inverse_of: :profile
  has_many :degrees, through: :degreeholderships, dependent: :destroy

  private

  def restore_relationships
    # Iterate through all associated relationship records that were deleted when we called #destroy
    deleted_relationship_associations = self.class.reflect_on_all_associations.select do |association|
      association.options[:dependent] == :destroy
    end

    deleted_relationship_associations.each do |association|
      restore_with_paper_trail(association)
    end
  end

  # Use PaperTrail to restore the associations.
  #
  # Only restore things that were deleted within 2 minutes of the original object destruction.
  # If user was very active and added and removed associations frequently within 2 minutes of
  # object destruction then we need to catch the resulting ActiveRecord::RecordNotUnique
  # exception and move continue.
  def restore_with_paper_trail(association)
    time_object_destroyed = get_object_destruction_time
    relationship_resource = association.options[:through].to_s.singularize.capitalize
    PaperTrail::Version.where(event: 'destroy', item_type: relationship_resource).\
      where('item_id not in (?)', relationship_resource.constantize.all.pluck(:id)).\
      where('created_at > ?', time_object_destroyed - 2.minutes).\
      order(id: :desc).each do |deleted_version|
      if deleted_version.reify
        begin
          deleted_version.reify.save!
        rescue ActiveRecord::RecordNotUnique => e
          next
        end
      end
    end
  end

  def get_object_destruction_time
    PaperTrail::Version.where(event: 'destroy', item_type: self.class.name, item_id: self.id).last.created_at
  end
end
