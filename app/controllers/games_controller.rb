class GamesController < ApplicationController
  def show
	@game = Game.find_by game_Id: params[:game_Id]
	@gameCount = Game.where(game_Id: params[:game_Id], ownerId: @game.ownerId).size
	@summoner = Summoner.find_by summonerId: @game.ownerId.to_i
	@update = (Time.now.to_i - @summoner.lastUpdated.to_i)
  end
end
