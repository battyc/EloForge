class Summoner < ActiveRecord::Base
	def self.update(params)
    	# Check if name is already connected to a number.
    	summName = params['search']
    	server = params['servers']['server']
    	@internalName = summName.to_s.downcase.delete(' ')
    	@summoner = Summoner.find_by internalName: @internalName

  		if (@summoner == nil)
		# Run only if # is not already stored or it is out of date
			call = RiotApiCall.new(:server => server, :summName => @internalName)
			call.getSummonerByName
			call.save
			#logger.debug "MODEL LEVEL: #{call.inspect}"
			@responseHash = call.response

			@summoner = Summoner.find_by summonerId: @responseHash[call.summName]['id']
			if @summoner != nil
				#summoner is already stored under a different name, update the name
				@summoner.internalName = @internalName
				@summoner.formattedName = @responseHash[call.summName]['name']
				@summoner.lastUpdated = Time.now.to_i
				@summoner.save
			else
				summId = @responseHash[call.summName]['id']
				@summoner = Summoner.new(:formattedName => @responseHash[call.summName]['name'], :internalName => call.summName, :summonerId => summId, :lastUpdated => (Time.now - ENV['UPDATE_AFTER_SECONDS'].to_i) )
				@summoner.save
			end
		elsif (Time.now.to_i - @summoner.lastUpdated.to_i > 900)
			call = RiotApiCall.new(:server => server, :summName => @internalName)
			call.getSummonerByName
			resp_hash = call.response
			@summoner.formattedName = resp_hash[call.summName]['name']
			@summoner.internalName = @internalName
			@summoner.save
		end
		
		if (Time.now.to_i - @summoner.lastUpdated.to_i) > 900
			#If the summoner is due for a game update, update the games.
			request2 = "https://" + server.downcase + ".api.pvp.net/api/lol/" + server.downcase + "/v2.2/matchhistory/" + @summoner.summonerId.to_s + "?api_key=" + ENV['RIOT_API_KEY'].to_s
			call = RiotApiCall.new(:server => server.downcase, :api_call => request2, :summName => @internalName)
			call.getMatchHistoryById(@summoner.summonerId)
			resp = call.response
			#logger.debug "#{resp['matches']}"
			game = Game.new(:gameData => resp, :gameId => resp['matches'][9]['matchId'])			
			@summoner.lastGameId = game.gameId
			@summoner.lastUpdated = Time.now.to_i
			game.save
			@summoner.save
			#logger.info "Game #{game.gameId} saved."
		end


		return @summoner
	end
end
