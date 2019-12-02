class GameController < ApplicationController
  
  def game
    if @current_user
      if params[:action_id]
        @current_user.action(params[:action_id])
      end
      render json: @current_user.show
    else
      redirect_to '/auth/github'
    end
  end
end