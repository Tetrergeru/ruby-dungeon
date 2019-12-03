class ApplicationController < ActionController::Base
  before_action :load_current_user

  private

  def load_current_user
    #if Rails.env == 'development'
    #  @current_user = User.find(session[:user_id]) # TODO: don't use github
    #end
    user_id = session[:user_id]
    unless user_id.present?
      redirect_to '/auth/login'
      @current_user = nil
      return
    end
    @current_user = User.find(user_id)
    redirect_to '/auth/login' unless @current_user.present?
  end
end
