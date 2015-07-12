class RiotApiCall 
	include ActiveModel::AttributeMethods
	require 'open-uri'
	require 'json'

	attr_accessor :server, :api_call, :response

	def initialize(attributes={})
		self.server = attributes[:server]
	end

	def getSummonerByName(summonerName)
		#Make the Request
		request_url = "https://" + self.server.to_s + ".api.pvp.net/api/lol/" + self.server.to_s + "/" + ENV['SUMMONER_VERSION'].to_s + "/summoner/by-name/" + summonerName.to_s + "?api_key=" + ENV['RIOT_API_KEY'].to_s
		self.api_call = request_url
		
		if $redis.keys("REQUEST").size < ENV['LONG_COUNT_LIMIT'].to_i
			#if it can, send request
			time = Time.now.to_i
			$redis.set("REQUEST_#{time}" , time)
			$redis.expire("REQUEST_#{time}", 600)
			#Rails.logger.debug "REQUEST_#{time}"
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.api_call = request_url
			self.response = result
		elsif $redis.keys("REQUEST").size == ENV['LONG_COUNT_LIMIT']
			Rails.logger.info "sleeping for #{$redis.first.ttl.to_i} seconds"
			sleep($redis.last.ttl.to_i)
			#sleep then execute request.
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.api_call = request_url
			self.response = result
		else
			#TODO Throw error
			return 12
		end
	end

	def getMatchHistoryById(summonerId)
		#Make the Request
		self.api_call = "https://" + self.server.to_s + ".api.pvp.net/api/lol/" + self.server.to_s + "/" + ENV['MATCH_HISTORY_VERSION'].to_s + "/matchhistory/" + summonerId.to_s + "?api_key=" + ENV['RIOT_API_KEY'].to_s
		#Rails.logger.debug "#{self.api_call}"
		if $redis.keys("REQUEST").size < ENV['LONG_COUNT_LIMIT'].to_i
			request_url = self.api_call
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			return result
		elsif $redis.keys("REQUEST").size == ENV['LONG_COUNT_LIMIT']
			request_url = self.api_call
			Rails.logger.debug "sleeping for #{$redis.first.ttl.to_i} seconds"
			sleep(($redis.first.ttl.to_i)/1000)
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			return result
		else
			#TODO Throw Error
			return 12
		end
	end

	def getMatchByMatchId(matchId)
		#Make the Request
		self.api_call = "https://" + self.server.to_s + ".api.pvp.net/api/lol/" + self.server.to_s + "/" + ENV['MATCH_VERSION'].to_s + "/match/" + matchId.to_s + "?includeTimeline=true&api_key=" + ENV['RIOT_API_KEY'].to_s
		if $redis.keys("REQUEST").size < ENV['LONG_COUNT_LIMIT'].to_i
			request_url = self.api_call
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
		elsif $redis.keys("REQUEST").size == ENV['LONG_COUNT_LIMIT']
			request_url = self.api_call

			Rails.logger.debug "sleeping for #{$redis.first.ttl.to_i} seconds"
			sleep($redis.first.ttl.to_i)
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
		else
			#TODO Throw error
			return 12
		end
	end
end
