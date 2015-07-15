class GamesController < ApplicationController
  def show
	@game = Game.find_by game_Id: params[:game_Id]
	@summoner = Summoner.find_by summonerId: @game.ownerId.to_s
	@ownerParticipant = @game.ownerParticipant
	@ownerParticipantStats = @ownerParticipant["stats"]
	ownerTeamId =  @ownerParticipant["teamId"].to_s
	ownerChampId = @ownerParticipant["championId"].to_s
	@champion = RiotApiCall.getChampionById(@ownerParticipant["championId"].to_s)
	
	@userParticipantFrames = []
	@userEventFrames = []

	@game.timeline["frames"].each do |frame|
		frame["timestamp"]
	# PARTICIPANT FRAME :
		userParticipantFrameHash = { :timestamp => frame["timestamp"], :ownerId => @game.ownerParticipantId,
			:frame => frame["participantFrames"][@game.ownerParticipantId]} 
		@userParticipantFrames.push(userParticipantFrameHash)
		#frame["participantFrames"][@game.ownerParticipantId]
		#frame["participantFrames"][@game.ownerParticipantId]["level"]
		#frame["participantFrames"][@game.ownerParticipantId]["xp"].to_s 
		#frame["participantFrames"][@game.ownerParticipantId]["currentGold"]
		#frame["participantFrames"][@game.ownerParticipantId]["totalGold"]
		#frame["participantFrames"][@game.ownerParticipantId]["minionsKilled"]
		#frame["participantFrames"][@game.ownerParticipantId]["jungleMinionsKilled"].to_s %>

		if frame["events"] != nil
	# EVENT FRAMES: 
			frame["events"].each do |event|
				if event["participantId"] == @game.ownerParticipantId.to_i
					userEventFrameHash = {:timestamp => event["timestamp"], :event => event}
					@userEventFrames.push(userEventFrameHash)
				end
			end
		end
	end


	@allyNames = []

	@game.participants.each do |p|
		if p["championId"].to_s != ownerChampId && p["teamId"].to_s == ownerTeamId
			chmp = RiotApiCall.getChampionById(p["championId"])
			@allyNames.push chmp["name"].to_s
			#Rails.logger.debug "wtf"
		end
	end



	@summoner = Summoner.find_by summonerId: @game.ownerId.to_i
	@update = (Time.now.to_i - @summoner.lastUpdated.to_i)
  end
end
