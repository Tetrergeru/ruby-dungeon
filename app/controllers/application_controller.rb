class ApplicationController < ActionController::Base
  before_action :load_current_user

  private

  class NotUser
    attr_accessor :user_id
  end

  def load_current_user
    #if Rails.env == 'development'
    #  @current_user = User.find(session[:user_id]) # TODO: don't use github
    #end

    user_id = session[:user_id]
    unless user_id.present?
      redirect_to '/auth/login'
      @current_user_id = nil
      return
    end
    @current_user_id = user_id['$oid']
    
    redirect_to '/auth/login' unless @current_user_id.present?
  end
end
