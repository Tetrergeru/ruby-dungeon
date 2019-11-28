class LevelsController < ActionController::Base
    # FIXME
    skip_before_action :verify_authenticity_token
    def show
      render json: Level.find(params[:id]).show
    end
    
    def create
      render json: Level.random_generate
    end
  end