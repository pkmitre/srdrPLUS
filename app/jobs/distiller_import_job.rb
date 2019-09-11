require 'import_jobs/distiller_csv_import_job/_distiller_importer'
require 'import_jobs/distiller_csv_import_job/_reference_importer'
require 'import_jobs/json_import_job/_project_importer'
require 'import_jobs/_ris_citation_importer'

class DistillerImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # args:
    #   project_id,
    #   user_id,
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @user = User.find( args.first )
    @project = Project.find( args.second )

    ris_file_type_id = FileType.find_by(name:'.ris')
    citation_import_id = ImportType.find_by(name:'Distiller References').id
    section_import_id = ImportType.find_by(name:'Distiller Section').id

    import_citations_from_ris ImportedFile.where(project: @project, user: @user, import_type_id: citation_import_id, file_type_id: ris_file_type_id).first

    distiller_importer = DistillerImporter.new @project, @user

    #currently we only support ris_file
    ImportedFile.where(project: @project, user: @user, import_type_id: section_import_id).each do |ifile|
      distiller_importer.add_t2_section ifile
    end

    # #we need to import references first
    # import_references @project, ImportedFile.find args.third

    # args[4..args.length].each do |s_imported_file_id|
    #   import_references @project, ImportedFile.find args.third
    # end
    # import_references @project, ImportedFile.find args.third

    ImportMailer.notify_import_completion(@user.id, @project.id).deliver_later
  end
end

