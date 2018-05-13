class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:screen]

  def screen
    @citations_projects = CitationsProject.unlabeled( @assignment.project, params[:count] )
    @past_labels = Label.last_updated( current_user, @assignment.project, 0, params[:count] )
    render 'screen'
  end

  private
    def set_assignment
      @assignment = Assignment.find( params[:id] )
    end
end

