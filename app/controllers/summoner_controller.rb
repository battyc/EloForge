class SummonerController < ApplicationController
	def index
		@total_summoners = Summoner.all
	end

	# while it hasnt been 10 seconds
	# count to 10 then stop allowing requests. #replace 10 with rate limit
	# Make an object that stores a created time and a query number. 
	# Each iteration checks the time that has passed between the first query and the current query and the number of queriies
	# run.  If queries run reaches x before 10 seconds has passed or total before 5 minutes, all further queries are ignored.
	# Once the time passed has reached 10 seconds, the count restarts for x.  If the totalCount in 
	# totalTime is over largex in 5 minutes, ignore further queries. 
	# When 10 seconds has passed reset x, when 5 minutes has passed reset largex

	def search
		id = Summoner.update(params['search'])
		redirect_to summoner_results_path(:summId => id)
	end

	def results
		@summoner = Summoner.find_by summonerId: params[:summId]
		@game = Game.find_by gameId: @summoner.lastGameId
		@gameData = JSON.parse @game.gameData
		@gameStats = @gameData['matches'][9]['participants'][0]['stats']
		@selectedMatch = @gameData['matches'][9]['participants'][0]
	end
end