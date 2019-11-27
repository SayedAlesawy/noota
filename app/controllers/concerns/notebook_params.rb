# frozen_string_literal: true

require 'active_support/concern'

module NotebookParams
  extend ActiveSupport::Concern

  def notebook_params
    permitted_params = %i[title description]
    notebook_params = params.require(:data).permit permitted_params

    notebook_params
  end
end
