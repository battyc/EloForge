class GamesController < ApplicationController
  def show
  	@summoner = Summoner.find_by summonerId: params[:summonerId]
	@game = Game.where(summoner_id: (@summoner.id)).last
	@update = (Time.now.to_i - @summoner.lastUpdated.to_i)
  end
end
