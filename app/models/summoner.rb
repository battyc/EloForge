class Summoner < ActiveRecord::Base
	include RateLimit::Query
	def self.update(summName)
    	# Check if name is already connected to a number.
    	summoner = Summoner.find_by internalName: summName.downcase.delete(' ').to_s
    	key = "f41ed978-fff5-4ae3-b1df-7e9131627fee" 

  		if (summoner == nil) # Measured in seconds, auto updates once a day
		# Run only if # is not already stored or it is out of date.
			logger.info "Begin summoner update/creation."
			request = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/" + summName.downcase.delete(' ') + "?api_key=" + key
			if ($globalQueue == nil)
				RateLimit::Query.start
			end

			if $globalQueue.can_query?
				logger.debug "Start queryQueue"
				response = RateLimit::Query.execute(request)
				@response_hash = JSON.parse response.body.to_s
				logger.debug "execute #{request}"
			else
				logger.debug "request failed #{request}"
				response = "BUSY"
				return response
			end
			puts "#{$globalQueue.inspect}"
			summId = @response_hash[summName.downcase.delete(' ')]['id']

			if summoner == nil
				summoner = Summoner.new(:formattedName => @response_hash[summName.downcase.delete(' ')]['name'], :internalName => summName.downcase.delete(' '), :summonerId => summId, :lastUpdated => (Time.now.to_i - 1000) )
				logger.info "Created summoner data for summoner id: #{summoner.summonerId}"
			else
				logger.info "Updating summoner data for summoner id: #{summoner.summonerId}"
				summoner.lastUpdated = Time.now.to_i
				summoner.formattedName = @response_hash[summName.downcase.delete(' ')]['name']
				summoner.internalName = summName.downcase.delete(' ')
			end
			summoner.save
		end

		logger.info "Begin game request for #{summoner.summonerId}"
		
		if summoner.lastUpdated == nil || ((Time.now.to_i - summoner.lastUpdated) > 900)
			request2 = "https://na.api.pvp.net/api/lol/na/v2.2/matchhistory/" + summoner.summonerId.to_s + "?api_key=" + key
			
			if ($globalQueue == nil)
				RateLimit::Query.start
			end
			if $globalQueue.can_query?
				@resp = RateLimit::Query.execute(request2)
				@resp_hash = JSON.parse @resp.body.to_s
				logger.debug "execute #{request2}"
			else
				logger.debug "execute #{request2}"
				response = "BUSY"
				return response
			end
			game = Game.new(:gameData => @resp.body.to_s, :gameId => @resp_hash['matches'][9]['matchId'])
			summoner.lastGameId = game.gameId
			summoner.lastUpdated = Time.now.to_i
			game.save
			summoner.save
			logger.info "Game #{game.gameId} saved."
		end

		return summoner.summonerId
	end
end
