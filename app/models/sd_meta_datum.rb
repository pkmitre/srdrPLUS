# == Schema Information
#
# Table name: sd_meta_data
#
#  id                                          :integer          not null, primary key
#  project_id                                  :integer
#  report_title                                :string(255)
#  date_of_last_search                         :datetime
#  date_of_publication_to_srdr                 :datetime
#  date_of_publication_full_report             :datetime
#  stakeholder_involvement_extent              :text(65535)
#  authors_conflict_of_interest_of_full_report :text(65535)
#  stakeholders_conflict_of_interest           :text(65535)
#  protocol_link                               :text(65535)
#  full_report_link                            :text(65535)
#  structured_abstract_link                    :text(65535)
#  key_messages_link                           :text(65535)
#  abstract_summary_link                       :text(65535)
#  evidence_summary_link                       :text(65535)
#  evs_introduction_link                       :text(65535)
#  evs_methods_link                            :text(65535)
#  evs_results_link                            :text(65535)
#  evs_discussion_link                         :text(65535)
#  evs_conclusions_link                        :text(65535)
#  evs_tables_figures_link                     :text(65535)
#  disposition_of_comments_link                :text(65535)
#  srdr_data_link                              :text(65535)
#  most_previous_version_srdr_link             :text(65535)
#  most_previous_version_full_report_link      :text(65535)
#  overall_purpose_of_review                   :text(65535)
#  review_type_id                              :integer
#  data_analysis_level_id                      :integer
#  state                                       :string(255)      default("DRAFT"), not null
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  section_flag_0                              :boolean          default(FALSE), not null
#  section_flag_1                              :boolean          default(FALSE), not null
#  section_flag_2                              :boolean          default(FALSE), not null
#  section_flag_3                              :boolean          default(FALSE), not null
#  section_flag_4                              :boolean          default(FALSE), not null
#  section_flag_5                              :boolean          default(FALSE), not null
#  section_flag_6                              :boolean          default(FALSE), not null
#  report_accession_id                         :integer
#  authors                                     :text(65535)
#  section_flag_7                              :boolean          default(FALSE), not null
#

class SdMetaDatum < ApplicationRecord
  include SharedProcessTokenMethods

  after_create :set_report_title

  attr_accessor :kqp_ids

  SECTIONS = [
    "Title, Funding Sources, and Dates",
    "Authors and Stakeholders",
    "URL Links",
    "Purpose and Key Questions",
    "PICODS",
    "Key Question Mapping",
    "Search Strategy and Evidence Summary",
    "Study Results"
  ].freeze

  default_scope { order(id: :desc) }

  belongs_to :project, inverse_of: :sd_meta_data, optional: true
  belongs_to :review_type, inverse_of: :sd_meta_data, optional: true
  belongs_to :data_analysis_level, inverse_of: :sd_meta_data, optional: true

  has_many :sd_key_questions, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :key_questions, -> { distinct }, through: :sd_key_questions

  has_many :sd_result_items
  has_many :sd_narrative_results, through: :sd_result_items
  has_many :sd_evidence_tables, inverse_of: :sd_meta_datum
  has_many :sd_network_meta_analysis_results, through: :sd_result_items
  has_many :sd_pairwise_meta_analytic_results, through: :sd_result_items
  has_many :sd_meta_regression_analysis_results, through: :sd_result_items
  
  has_many :sd_key_questions_projects, through: :sd_key_questions, inverse_of: :sd_meta_datum
  has_many :project_key_questions, through: :sd_key_questions_projects, source: :key_question

  has_many :sd_key_questions_sd_picods, through: :sd_key_questions, dependent: :destroy

  has_many :sd_journal_article_urls,
    -> { ordered },  
    inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_other_items,
    -> { ordered },  
    inverse_of: :sd_meta_datum, dependent: :destroy

  has_many :sd_search_strategies, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_search_databases, through: :sd_search_strategies

  has_many :sd_summary_of_evidences, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_grey_literature_searches, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_prisma_flows, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_picods,
    -> { ordered },  
    inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_analytic_frameworks, inverse_of: :sd_meta_datum, dependent: :destroy

  has_many :funding_sources_sd_meta_data, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :funding_sources, through: :funding_sources_sd_meta_data

  has_many :sd_meta_data_queries, dependent: :destroy

  has_one_attached :report_file

  accepts_nested_attributes_for :sd_key_questions, allow_destroy: true
  accepts_nested_attributes_for :sd_journal_article_urls, allow_destroy: true
  accepts_nested_attributes_for :sd_other_items, allow_destroy: true
  accepts_nested_attributes_for :sd_analytic_frameworks, allow_destroy: true
  accepts_nested_attributes_for :sd_picods, allow_destroy: true
  accepts_nested_attributes_for :sd_search_strategies, allow_destroy: true
  accepts_nested_attributes_for :sd_grey_literature_searches, allow_destroy: true
  accepts_nested_attributes_for :sd_summary_of_evidences, allow_destroy: true
  accepts_nested_attributes_for :sd_prisma_flows, allow_destroy: true
  accepts_nested_attributes_for :sd_result_items, allow_destroy: true

  def report
    Report.all.find { |report_meta| report_meta.accession_id == self.report_accession_id }
  end

  def create_fuzzy_matches
    sd_key_questions.each do |sd_kq|
      fuzzy_match = sd_kq.fuzzy_match
      SdKeyQuestionsProject.create(sd_key_question_id: sd_kq.id, key_questions_project_id: fuzzy_match.id) if fuzzy_match
    end
  end

  def all_sections_complete?
    section_statuses.all? { |status| status == true }
  end

  def progress_meter_width
    progress_meter_width = ((SECTIONS.length - incomplete_sections.length).to_f * 100 / SECTIONS.length.to_f).round.to_s
  end

  def incomplete_sections
    incomplete_sections = []

    section_statuses.each_with_index { |el, idx| incomplete_sections << SECTIONS[idx] unless el }
    incomplete_sections
  end

  def section_statuses
    (0..7).to_a.map do |i|
      section = "section_flag_" + i.to_s
      self[section]
    end
  end

  def toggle_state
    new_state = state == "DRAFT" ? "COMPLETED" : "DRAFT"
    update(state: new_state)
  end

  def funding_source_ids=(tokens)
    tokens.map do |token|
      resource = FundingSource.new
      save_resource_name_with_token(resource, token)
    end
    super
  end

  def review_type_id=(token)
    resource = ReviewType.new
    save_resource_name_with_token(resource, token)
    super
  end

  def data_analysis_level_id=(token)
    resource = DataAnalysisLevel.new
    save_resource_name_with_token(resource, token)
    super
  end

  private
    def set_report_title
      self.update( report_title: self.report&.title )
    end
end
