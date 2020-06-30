class ConvertPdf2HtmlJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    accession_id = args.first
    pdf_path = Dir.glob("#{ Rails.root }/reports/#{ accession_id }/*_#{ accession_id }/TOC.pdf").first
    if pdf_path
      system("mkdir -p #{ Rails.root }/public/reports/#{ accession_id }")
      system("Pdf2HtmlEX #{ pdf_path } TOC.html")
      system("mv TOC.html #{ Rails.root }/public/reports/#{ accession_id }/")
    end
  end
end
