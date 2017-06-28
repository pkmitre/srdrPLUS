class QuestionRowColumnsController < ApplicationController
  before_action :set_question_row_column, only: [:destroy_entire_column]

  def destroy_entire_column
    @question = @question_row_column.question

    QuestionRowColumn.transaction do
      destroy_all_question_row_columns_on_column_index
    end

    respond_to do |format|
      format.html { redirect_to edit_question_path(@question), notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private

    def set_question_row_column
      @question_row_column = QuestionRowColumn.find(params[:id])
    end

    # This method will remove question_row_columns down all the rows
    # in the question. To find the index of the column to remove we use
    # the index of the @question_row_column on which the destroy/remove
    # request was triggered.
    def destroy_all_question_row_columns_on_column_index
      index_to_nuke = find_index_to_nuke

      # Iterate through each row and remove the question_row_column at
      # index column_index_to_nuke.
      @question.question_rows.each do |qr|
        qr.question_row_columns[index_to_nuke].destroy
      end
    end

    def find_index_to_nuke
      question_row_column_index_to_nuke = 0

      # Find the index of the question_row_column on which the
      # destroy/remove request was triggered.
      @question.question_rows.first.question_row_columns.each do |qrc|
        break if qrc == @question_row_column
        question_row_column_index_to_nuke += 1
      end

      return question_row_column_index_to_nuke
    end
end
