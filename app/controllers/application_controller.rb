class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  # rescue_from Exception do |exception|
  #   respond_to do |format|
  #     format.html {render :text => exception.to_s, :status => 500}
  #     format.json {render :text => {:message => exception.to_s}.to_json, :status => 500}
  #   end
  # end
end
