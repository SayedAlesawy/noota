# frozen_string_literal: true

require 'active_support/concern'

module NoteParams
  extend ActiveSupport::Concern

  def create_note_params
    permitted_params = %i[title body user_ip]
    note_params = params.require(:data).permit permitted_params

    note_params[:notebook_id] = params[:notebook_id]
    note_params[:country] = Geolocator.country(note_params[:user_ip])
    note_params.delete(:user_ip)

    validate_note_params(note_params)

    note_params
  end

  def validate_note_params(note_params)
    validate_param_existence(note_params[:title], 'title')
    validate_param_existence(note_params[:body], 'body')
  end

  def validate_param_existence(params, param_name)
    return unless params.blank?

    raise ActionController::ParameterMissing, param_name
  end

  def bulk_destroy_note_params
    note_params = {}
    note_params[:notebook_id] = params[:notebook_id]

    note_params
  end
end
