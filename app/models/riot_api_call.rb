class RiotApiCall < ActiveRecord::Base
	serialize :response
	require 'open-uri'
	require 'json'
	attr_accessor :id, :server, :api_call, :response, :summName

	def initialize(attributes={})
		super
		@key = ENV['RIOT_API_KEY']
	end

	def getSummonerByName
		#Create the Request
		#Rails.logger.info("@summName Inspect call : #{self.summName} , #{@key}")
		request_url = "https://" + self.server.to_s + ".api.pvp.net/api/lol/" + self.server.to_s + "/v1.4/summoner/by-name/" + self.summName.to_s + "?api_key=" + @key
		#Execute the Request
		#Rails.logger.debug "Request Earl #{request_url}"
		buffer = open(request_url).read
		result = JSON.parse(buffer)
		self.api_call = request_url
		self.response = result
	end

	def getMatchHistoryById(summId)
		
		#Execute the Request
		#TODO CREATE A JOB FOR EXECUTING REQUESTS.
		request_url = self.api_call
		buffer = open(request_url).read
		result = JSON.parse(buffer)
		self.response = result
	end
end
