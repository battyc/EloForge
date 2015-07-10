class SummonerController < ApplicationController
	def index
	end

	def search
		summoner = Summoner.update(params)
		#gameUpdate
		if summoner != nil
			redirect_to summoner_path(:summonerId => summoner.summonerId)
		else
			flash[:error] = "Too Many Requests.  Please try again in a few seconds"
			redirect_to root_path
		end
	end

	def results
		@summoner = Summoner.find_by summonerId: params[:summonerId]
		@game = Game.where(summoner_id: (@summoner.id)).last
		@game2 = Game.where(summoner_id: (@summoner.id)).count

		#@gameData = @game.gameData
		#@gameStats = @gameData['participants'][0]['stats']
		#@selectedMatch = @gameData['participants'][0]
		#@lane = @gameData['participants'][0]['timeline']['lane']
		#if @lane == "BOTTOM"
		#	@lane = @gameData['participants'][0]['timeline']['role']
		#end
		#@queueType = @gameData['queueType']
		@update = (Time.now.to_i - @summoner.lastUpdated.to_i)
	end
end