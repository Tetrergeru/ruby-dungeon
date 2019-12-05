class GameController < ApplicationController
  def game
    if params[:action_id]
      @current_user.action(params[:action_id])
    end
    respond_to do |format|
      format.json { render json: @current_user.show }
      format.html { render }
    end
  end
end