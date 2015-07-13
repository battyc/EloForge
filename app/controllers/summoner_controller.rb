class SummonerController < ApplicationController
	def index
	end

	def search
		summoner = Summoner.update(params)
		Rails.logger.debug "#{summoner}"
		if summoner.to_s == "404"
			flash[:alert] = "Summoner not found."
			return redirect_to root_path
		end

		@matchId = summoner.lastGameId

		if (Time.now.to_i - summoner.lastUpdated.to_i) > 900
			# Run the Game Updates
			gameHash = {:summId => summoner.summonerId, :server => summoner.server, :summoner_id => summoner.id}
			@matchId = Game.updateLastRanked(gameHash)
			if @matchId != 0
				summoner.lastGameId = @matchId
			else
				logger.info 'No games added.'
			end
			summoner.lastUpdated = Time.now.to_i
			summoner.save
		end

		if summoner != nil
			redirect_to game_path(:game_Id => summoner.lastGameId , :summonerId => summoner.summonerId)
		else
			flash[:error] = "No valid games were found.  Play a ranked game first and then try again!"
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