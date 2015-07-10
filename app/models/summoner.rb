class Summoner < ActiveRecord::Base
	has_many :games
	def self.update(params)
    	# Check if name is already connected to a number.
    	summName = params['search']
    	server = params['servers']['server']
    	@internalName = summName.to_s.downcase.delete(' ')
    	@summoner = Summoner.find_by internalName: @internalName

  		if (@summoner == nil)
		# Run only if # is not already stored or it is out of date
			call = RiotApiCall.new(:server => server)
			call.getSummonerByName(@internalName)
			@responseHash = call.response

			@summoner = Summoner.find_by summonerId: @responseHash[@internalName]['id']
			if @summoner != nil
				#summoner is already stored under a different name, update the name
				@summoner.internalName = @internalName
				@summoner.formattedName = @responseHash[@internalName]['name']
				@summoner.lastUpdated = Time.now.to_i
				@summoner.save
			else
				summId = @responseHash[@internalName]['id']
				@summoner = Summoner.new(:formattedName => @responseHash[@internalName]['name'], :internalName => @internalName, :summonerId => summId, :lastUpdated => (Time.now - ENV['UPDATE_AFTER_SECONDS'].to_i) )
				@summoner.save
			end
		elsif (Time.now.to_i - @summoner.lastUpdated.to_i > 900)
			call = RiotApiCall.new(:server => server)
			call.getSummonerByName(@internalName)
			resp_hash = call.response
			@summoner.formattedName = resp_hash[@internalName]['name']
			@summoner.internalName = @internalName
			@summoner.save
		end
		
		if (Time.now.to_i - @summoner.lastUpdated.to_i) > 900
			#If the summoner is due for a game update, update the games.

			#Get Match History
			call = RiotApiCall.new(:server => server.downcase)
			call.getMatchHistoryById(@summoner.summonerId)
			resp = call.response
			#Take most recent game
			match = resp['matches'].last
			#Get that games full details
			match_call = RiotApiCall.new(:server => server.downcase)
			match_call.getMatchByMatchId(match['matchId'].to_s)
			match_resp = match_call.response

			#CREATE GAME OBJECT : API CALLS COMPLETE 
			@lame = Game.find_by(gameId: match_resp["matchId"], summoner_id: @summoner.id)
			
			
			if @lame == nil
				game = Game.new(:gameData => match_resp, :gameId => match_resp['matchId'], :summoner_id => @summoner.id)
				game.save
				logger.info 'Game Updated'
				@summoner.lastGameId = game.gameId
			else
				logger.info 'No New Game'
			end
	
			@summoner.lastUpdated = Time.now.to_i
			@summoner.save
			#logger.info "Game #{game.gameId} saved."
		end


		return @summoner
	end
end
