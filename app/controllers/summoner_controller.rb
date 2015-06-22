class SummonerController < ApplicationController
	def index

	end

	# while it hasnt been 10 seconds
	# count to 10 then stop allowing requests. #replace 10 with rate limit
	# Make an object that stores a created time and a query number. 
	# Each iteration checks the time that has passed between the first query and the current query and the number of queriies
	# run.  If queries run reaches x before 10 seconds has passed or total before 5 minutes, all further queries are ignored.
	# Once the time passed has reached 10 seconds, the count restarts for x.  If the totalCount in 
	# totalTime is over largex in 5 minutes, ignore further queries. 
	# When 10 seconds has passed reset x, when 5 minutes has passed reset largex


	def results 
		summName = params['search']
    # Check if name is already connected to a number.
    	@summoner = Summoner.find_by internalName: summName.downcase.delete(' ').to_s
    	key = "f41ed978-fff5-4ae3-b1df-7e9131627fee" 

    	if @summoner != nil
    		time = @summoner.lastUpdated.to_i - Time.now.to_i;
    	end
  		if (@summoner == nil || time < -86400 ) # Measured in seconds, auto updates once a day
	# Run only if # is not already stored or it is out of date.
			request = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/" + summName.downcase.delete(' ') + "?api_key=" + key
			uri = URI(request)
			

			Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Get.new uri.request_uri
				response = http.request request
				response_hash =  JSON.parse response.body.to_s
				summId = response_hash[summName.downcase.delete(' ')]['id']
				if @summoner == nil
					@summoner = Summoner.new(:formattedName => response_hash[summName.downcase.delete(' ')]['name'], :internalName => summName.downcase.delete(' '), :summonerId => summId, :lastUpdated => nil )
					logger.info "Created summoner data for summoner id: #{@summoner.summonerId}"
				else
					logger.info "Updating summoner data for summoner id: #{@summoner.summonerId}"
					@summoner.lastUpdated = Time.now.to_i
					@summoner.formattedName = response_hash[summName.downcase.delete(' ')]['name']
					@summoner.internalName = summName.downcase.delete(' ')
				end
				@summoner.save
			end
		end

		if @summoner.lastUpdated == nil || ((@summoner.lastUpdated - Time.now.to_i) < -900)
			request2 = "https://na.api.pvp.net/api/lol/na/v2.2/matchhistory/" + @summoner.summonerId.to_s + "i_key=" + key
			uri2 = URI(request2)
			Net::HTTP.start(uri2.host, uri2.port, :use_ssl => uri2.scheme == 'https') do |http|
				request2 = Net::HTTP::Get.new uri2.request_uri
				response2 = http.request request2    
				resp = JSON.parse response2.body.to_s
				@game = Game.new(:gameData => response2.body.to_s, :gameId => resp['matches'][0]['matchId'])
				@summoner.lastGameId = @game.gameId
				@summoner.lastUpdated = Time.now
				@gameStats = resp['matches'][0]['participantIdentities'][0]['stats']
				@game.save
				@summoner.save
			end
		else
			@game = Game.find_by gameId: @summoner.lastGameId
			@gameStats = JSON.parse(@game.gameData)['matches'][0]['participantIdentities'][0]['stats']


		end
	end
end