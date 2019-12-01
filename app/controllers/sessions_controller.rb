
class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    session[:user_id] = @user.id
    redirect_to root_path
  end
  
  def destroy
    current_user ||= User.find(session[:user_id]) if session[:user_id]
    if current_user
      session.delete(:user_id)
      flash[:success] = "Sucessfully logged out!"
    end
    redirect_to "/"
  end

  protected
 
  def auth_hash
    request.env['omniauth.auth']
  end
end
