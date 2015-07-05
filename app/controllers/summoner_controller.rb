class SummonerController < ApplicationController
	def index
		@total_summoners = Summoner.all
	end

	def search
		id = Summoner.update(params)
		if id != "BUSY"
			redirect_to summoner_path(:summonerId => id.summonerId)
		else
			flash[:error] = "Too Many Requests.  Please try again in a few seconds"
			redirect_to root_path
		end
	end

	def results
		@summoner = Summoner.find_by summonerId: params[:summonerId]
		@game = Game.find_by gameId: @summoner.lastGameId

		@gameData = @game.gameData
		@gameStats = @gameData['matches'][0]['participants'][0]['stats']
		@selectedMatch = @gameData['matches'][9]['participants'][0]
		@lane = @gameData['matches'][9]['participants'][0]['timeline']['lane']
		if @lane == "BOTTOM"
			@lane = @gameData['matches'][9]['participants'][0]['timeline']['role']
		end
		@queueType = @gameData['matches'][9]['queueType']
		@update = (Time.now.to_i - @summoner.lastUpdated.to_i)
	end
end