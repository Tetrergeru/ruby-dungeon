class SessionsController < ActionController::Base

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    session[:user_id] = @user.id
    redirect_to game_path
  end

  def destroy
    if @current_user_id
      session.delete(:user_id)
      @current_user_id = nil
      flash[:success] = 'Successfully logged out!'
    end
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
