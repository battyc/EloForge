class Summoner < ActiveRecord::Base
	has_many :games
	def self.update(params)
		##
		# Runs the summoner update sequence.
		# Accepts params for summoner name server.
		# Returns a summoner object or throws a does not exist error.
    	# Check if name is already connected to a number.
    	summName = params['search']
    	@server = params['servers']['server'].to_s.downcase
    	@internalName = summName.to_s.downcase.delete(' ')
    	@summoner = Summoner.find_by internalName: @internalName

  		if (@summoner == nil)
		# Run only if # is not already stored or it is out of date
			call = RiotApiCall.new(:server => @server)
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
			call = RiotApiCall.new(:server => @server)
			call.getSummonerByName(@internalName)
			resp_hash = call.response
			@summoner.formattedName = resp_hash[@internalName]['name']
			@summoner.internalName = @internalName
			@summoner.save
		end
		
		if (Time.now.to_i - @summoner.lastUpdated.to_i) > 900
			# Run the Game Updates
			gameHash = { :summId => @summoner.summonerId, :server => @server, :summoner_id => @summoner.id}
			matchId = Game.updateLastRanked(gameHash)
			if matchId != 0
				@summoner.lastGameId = matchId
			else
				logger.info 'No games added.'
			end
			@summoner.lastUpdated = Time.now.to_i
			@summoner.save
		end

		return @summoner
	end
end
