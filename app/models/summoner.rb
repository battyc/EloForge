class Summoner < ActiveRecord::Base
	
	def self.update(summName)
    	# Check if name is already connected to a number.
    	summoner = Summoner.find_by internalName: summName.downcase.delete(' ').to_s
    	key = "f41ed978-fff5-4ae3-b1df-7e9131627fee" 

    	if summoner != nil
    		time = summoner.lastUpdated.to_i - Time.now.to_i;
    	end
  		if (summoner == nil || time < -86400 ) # Measured in seconds, auto updates once a day
		# Run only if # is not already stored or it is out of date.
			logger.info "Begin summoner update/creation."
			request = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/" + summName.downcase.delete(' ') + "?api_key=" + key
			uri = URI(request)
			Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Get.new uri.request_uri
				response = http.request request
				response_hash =  JSON.parse response.body.to_s
				summId = response_hash[summName.downcase.delete(' ')]['id']
				if summoner == nil
					summoner = Summoner.new(:formattedName => response_hash[summName.downcase.delete(' ')]['name'], :internalName => summName.downcase.delete(' '), :summonerId => summId, :lastUpdated => nil )
					logger.info "Created summoner data for summoner id: #{summoner.summonerId}"
				else
					logger.info "Updating summoner data for summoner id: #{summoner.summonerId}"
					summoner.lastUpdated = Time.now.to_i
					summoner.formattedName = response_hash[summName.downcase.delete(' ')]['name']
					summoner.internalName = summName.downcase.delete(' ')
				end
				summoner.save
			end
		end
		logger.info "Begin game request for #{summoner.summonerId}"
		if summoner.lastUpdated == nil || ((summoner.lastUpdated - Time.now.to_i) < -900)
			request2 = "https://na.api.pvp.net/api/lol/na/v2.2/matchhistory/" + summoner.summonerId.to_s + "?api_key=" + key
			uri2 = URI(request2)
			Net::HTTP.start(uri2.host, uri2.port, :use_ssl => uri2.scheme == 'https') do |http|
				request2 = Net::HTTP::Get.new uri2.request_uri
				response2 = http.request request2    
				resp = JSON.parse response2.body.to_s
				game = Game.new(:gameData => response2.body.to_s, :gameId => resp['matches'][9]['matchId'])
				summoner.lastGameId = game.gameId
				summoner.lastUpdated = Time.now
				game.save
				summoner.save
			end
		end
		return summoner.summonerId
	end
end