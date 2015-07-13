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
		match = resp['matches'].last
		#Get that games full details
		match_call = RiotApiCall.new(:server => server)
		match_call.getMatchByMatchId(match['matchId'].to_s)
		match_resp = match_call.response
		#CREATE GAME OBJECT : API CALLS COMPLETE 
		@game = Game.where(game_Id: match_resp["matchId"], summoner_id: summoner_id).last
	
		@ownerParticipId = 0
		
		match_resp["participantIdentities"].each do |m|
			if m["player"]["summonerId"].to_s == summId
				@ownerParticipId = m["participantId"]
				@summonerName = m["player"]["summonerName"].downcase.delete(' ')
				break
			end
		end

		if @game == nil
			@game = Game.new(
					:region => match_resp['region'],
					:matchType => match_resp["matchType"],
					:matchCreation => match_resp["matchCreation"],
					:timeline => match_resp["timeline"],
					:participants => match_resp["participants"],
					
					:ownerParticipantId => @ownerParticipId,
					:ownerParticipant => match_resp["participants"][@ownerParticipId.to_i],
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

