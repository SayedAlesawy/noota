# frozen_string_literal: true

require 'active_support/concern'

module NoteParams
  extend ActiveSupport::Concern

  def note_params
    permitted_params = %i[title body]
    notebook_params = params.require(:data).permit permitted_params
    notebook_params[:notebook_id] = params[:notebook_id]

    notebook_params
  end
end
