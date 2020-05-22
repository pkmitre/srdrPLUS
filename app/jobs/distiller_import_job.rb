require "import_jobs/distiller_csv_import_job/_distiller_importer"
require "import_jobs/_ris_citation_importer"

class DistillerImportJob < ApplicationJob
  queue_as :default
  rescue_from StandardError, with: :handle_standard_error

  def perform(*args)
    # args:
    #   import_id

    Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"

    import = Import.find args.first
    @references_file = ImportedFile.where( import_id: import.id, file_type_id:FileType.where(name: ['.ris','.csv']).pluck(:id) ).first
    user = import.user
    project = import.project
    distiller_importer = DistillerImporter.new project, user

    if @references_file.file_type.name == '.ris'
      citation_import_status = import_citations_from_ris @references_file
    else
      citation_import_status = import_citations_from_csv @references_file
    end

    import.imported_files.where(file_type_id: FileType.find_by(name: "Distiller Section").id).each do |ifile|
      e = distiller_importer.add_t2_section(ifile)
    end

    ImportMailer.notify_import_completion(@references_file.id).deliver_later
  end

  private
    def handle_standard_error(e)
      ImportMailer.notify_import_failure(@references_file.id, e.message).deliver_later
    end
end
