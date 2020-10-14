class Api::V1::CitationsController < Api::V1::BaseController
  before_action :skip_policy_scope, :skip_authorization, :set_before_variables
  PAGE_SIZE = 30

  def index
    project = params[:project_id] ? Project.find(params[:project_id]) : nil
    @citations = project ? project.citations : Citation
    @citations = @citations.includes({ authors_citations: [:author, :ordering] }, :journal, :keywords)
    @citations = @citations.by_query(@query)
    @citation_project_dict = project ?
      Hash[
        *project.
          citations_projects.
          where(citation: @citations).
          map { | c_p | [ c_p.citation_id,  c_p.id ] }.
          flatten
      ] :
      {}

    set_common_variables
  end

  def titles
    @citations = Citation.by_query(@query)
    set_common_variables
  end

  private

    def set_before_variables
      @page = params[:page].to_i || 1
      @query = params[:q] || ''
    end

    def set_common_variables
      @citations = Kaminari.paginate_array(@citations) if @citations.class == Array
      @citations = @citations.page(@page).per(PAGE_SIZE)
      @total_count = @citations.total_count
      @more = !@citations.last_page?
    end
end
