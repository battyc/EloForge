class RiotApiCall < ActiveRecord::Base
	serialize :response
	require 'open-uri'
	require 'json'

	attr_accessor :summName

	def initialize(attributes={})
		super
		@key = ENV['RIOT_API_KEY']
	end

	def getSummonerByName
		#Create the Request
		request_url = "https://" + self.server.to_s + ".api.pvp.net/api/lol/" + self.server.to_s + "/v1.4/summoner/by-name/" + self.summName.to_s + "?api_key=" + @key
		#Execute the Request
		#Rails.logger.debug "Request Earl #{request_url}"
		if $rate_count == nil 
			$rate_count = 1
			$count_reset = Time.now.to_i + ENV['LONG_TIME_LIMIT'].to_i
		end
		if $rate_count < ENV['LONG_COUNT_LIMIT'].to_i
			#if it can, send request
			#Rails.logger.debug "SEND REQUEST"
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.api_call = request_url
			self.response = result
			self.save
			$rate_count += 1;
		elsif $rate_count == ENV['LONG_COUNT_LIMIT'] && ($count_reset - Time.now.to_i) > 0 
			#Rails.logger.debug "WAIT THEN SEND REQUEST"
			sleep($count_reset - Time.now.to_i)
			#sleep then execute request.
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.api_call = request_url
			self.response = result
			self.save
			$count_reset = Time.now.to_i
			$rate_count = 1;
		else
			#Rails.logger.debug "WHERE AM I????"
			return 12
		end
	end

	def getMatchHistoryById(summId)
		
		#Execute the Request
		#TODO CREATE A JOB FOR EXECUTING REQUESTS.
		if $rate_count == nil 
			$rate_count = 1
			$count_reset = Time.now.to_i + ENV['LONG_TIME_LIMIT'].to_i
		end
		if $rate_count < ENV['LONG_COUNT_LIMIT'].to_i
			#Rails.logger.debug "SEND REQUEST"
			request_url = self.api_call
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
			self.save
			$rate_count += 1;
		elsif $rate_count == ENV['LONG_COUNT_LIMIT'] && ($count_reset - Time.now.to_i) > 0
			#Rails.logger.debug "WAIT THEN SEND REQUEST"
			request_url = self.api_call
			sleep($count_reset - Time.now.to_i)
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
			self.save
			$count_reset = Time.now.to_i
			$rate_count = 1;
		else
			#Rails.logger.debug "WHERE AM I????"
			return 12
		end
	end
end
