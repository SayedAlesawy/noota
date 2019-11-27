# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: { message: 'record not found' }, status: 404
  end

  rescue_from ActiveRecord::RecordNotSaved,
              ActiveRecord::RecordInvalid do |exception|
    render json: {
      message: exception.record.errors.full_messages.join(', ')
    }, status: 422
  end
end
