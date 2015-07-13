class Game < ActiveRecord::Base
	serialize :participants
	serialize :participantIds
	serialize :teams
	serialize :ownerParticipant
	serialize :timeline
	belongs_to :summoner

	def self.updateLastRanked(gameHash)
    	# Check if name is already connected to a number.
    	summoner_id = gameHash[:summoner_id].to_s
    	server = gameHash[:server].to_s
    	summId = gameHash[:summId].to_s
    	#gameHash[:gameId]
		#Get Match History
		call = RiotApiCall.new(:server => server)
		resp = call.getMatchHistoryById(summId)

		#Take most recent game
		#Rails.logger.debug "MATCH#{resp["matches"][0]["matchId"].to_s}"
		#Get that games full details
		match_call = RiotApiCall.new(:server => server)
		match_call.getMatchByMatchId(resp["matches"][0]["matchId"].to_s)
		match_resp = match_call.response
		#CREATE GAME OBJECT : API CALLS COMPLETE 
		@game = Game.where(game_Id: match_resp["matchId"], summoner_id: summoner_id).last
	
		@ownerParticipId = 0
		@summonerName = ""
		@ownerParticip = nil
		
		match_resp["participantIdentities"].each do |m|
			if m["player"]["summonerId"].to_s == summId
				@ownerParticipId = m["participantId"]
				@summonerName = m["player"]["summonerName"].downcase.delete(' ')
			end
		end

		match_resp["participants"].each do |m|
			if m["participantId"].to_s == @ownerParticipId.to_s
				@ownerParticip = m
			end
		end

		#Rails.logger.debug("OWNER PARTICIPANT NAME #{@ownerParticipId}")

		if @game == nil
			@game = Game.new(
					:region => match_resp['region'],
					:matchType => match_resp["matchType"],
					:matchCreation => match_resp["matchCreation"],
					:timeline => match_resp["timeline"],
					:participants => match_resp["participants"],
					:ownerParticipantId => @ownerParticipId,
					:ownerParticipant => @ownerParticip,
					:platformId => match_resp["platformId"],
					:matchMode => match_resp["matchMode"],
					:matchVersion => match_resp["matchVersion"],
					:teams => match_resp["teams"],
					:mapId => match_resp["mapId"],
					:matchDuration => match_resp["matchDuration"],
					:queueType => match_resp["queueType"],
					:season => match_resp["season"],
					:game_Id => match_resp['matchId'],
					:ownerId =>  gameHash[:summId].to_s, 
					:ownerName => @summonerName,
					:summoner_id => summoner_id)

			# :participantIds => match_resp["participantIdentities"],
			@game.save
			logger.info 'Game Updated'
			return @game.game_Id
		else
			logger.info 'No New Game'
		end

		return 0
	end
end

