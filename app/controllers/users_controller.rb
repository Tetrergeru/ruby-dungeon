class UsersController < ActionController::Base
  # FIXME
  skip_before_action :verify_authenticity_token
  def new
    User.create(name: params[:name])
  end

  def show
    render json: User.find_by(name: params[:name])
  end
end