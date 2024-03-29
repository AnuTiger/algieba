class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from BadRequest do |e|
    render status: :bad_request, json: e.errors
  end

  rescue_from NotFound do
    head :not_found
  end

  rescue_from InternalServerError do
    head :internal_server_error
  end
end
