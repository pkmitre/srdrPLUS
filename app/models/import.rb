# == Schema Information
#
# Table name: imported_files
#
# t.integer "import_type_id"
# t.integer "projects_user_id"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
#

class Import < ApplicationRecord
  after_create_commit :start_import_job

  belongs_to :import_type
  belongs_to :projects_user
  has_many :imported_files, dependent: :destroy

  delegate :user, to: :projects_user
  delegate :project, to: :projects_user

  accepts_nested_attributes_for :imported_files

  def start_import_job
    if self.import_type.name == "Distiller"
      DistillerImportJob.perform_later(self.id)
      return
    end

    for imported_file in self.imported_files
      case self.import_type
        when "Citation"
          case imported_file.file_type.name
            when ".ris"
              RisImportJob.perform_later(imported_file.id)

            when ".csv"
              CsvImportJob.perform_later(imported_file.id)
            when ".enl"
              EnlImportJob.perform_later(imported_file.id)
            when "PubMed"
              PubmedImportJob.perform_later(imported_file.id)
            else
              ## NOT SUPPORTED, WHAT TO DO?
          end
        when "Project"
          case imported_file.file_type.name
            when ".json"
              JsonImportJob.perform_later(imported_file.id)
            else
              ## NOT SUPPORTED, WHAT TO DO?
          end
      end
    end
  end
end
