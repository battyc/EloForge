class GamesController < ApplicationController
  def show
	@game = Game.find_by game_Id: params[:game_Id]
	@summoner = Summoner.find_by summonerId: @game.ownerId.to_s
	@ownerParticipant = @game.ownerParticipant
	@ownerParticipantStats = @ownerParticipant["stats"]
	ownerTeamId =  @ownerParticipant["teamId"].to_s
	ownerChampId = @ownerParticipant["championId"].to_s
	@champion = RiotApiCall.getChampionById(@ownerParticipant["championId"].to_s)
	
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
