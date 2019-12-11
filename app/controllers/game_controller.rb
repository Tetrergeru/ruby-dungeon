class GameController < ApplicationController
  def game
    if params[:action_id]
      User.action(@current_user_id, params[:action_id])
    end
    respond_to do |format|
      format.json { render json: User.show(@current_user_id) }
      format.html { render }
    end
  end
end
