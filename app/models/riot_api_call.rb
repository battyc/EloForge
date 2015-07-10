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
		request_url = "https://" + self.server.to_s + ".api.pvp.net/api/lol/" + self.server.to_s + "/" + ENV['SUMMONER_VERSION'].to_s + "/summoner/by-name/" + self.summName.to_s + "?api_key=" + @key
		#Execute the Request
		#Rails.logger.debug "Request Earl #{request_url}"
		Rails.logger.debug "#{$redis}"

		if $redis.keys("REQUEST").size < ENV['LONG_COUNT_LIMIT'].to_i
			#if it can, send request
			#Rails.logger.debug "SEND REQUEST"
			time = Time.now.to_i
			$redis.set("REQUEST_#{time}" , time)
			$redis.expire("REQUEST_#{time}", 600)
			Rails.logger.debug "REQUEST_#{time}"
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.api_call = request_url
			self.response = result
			#self.save
		elsif $redis.keys("REQUEST").size == ENV['LONG_COUNT_LIMIT']
			## FIX
			Rails.logger.debug "sleeping for #{$redis.first.ttl.to_i} seconds"
			sleep($redis.first.ttl.to_i)
			#sleep then execute request.
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.api_call = request_url
			self.response = result
			#self.save
		else
			#Rails.logger.debug "WHERE AM I????"
			return 12
		end
	end

	def getMatchHistoryById
		
		#Execute the Request
		#TODO CREATE A JOB FOR EXECUTING REQUESTS.
		if $redis.keys("REQUEST").size < ENV['LONG_COUNT_LIMIT'].to_i
			#Rails.logger.debug "SEND REQUEST"
			request_url = self.api_call
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
			#self.save
		elsif $redis.keys("REQUEST").size == ENV['LONG_COUNT_LIMIT']
			#Rails.logger.debug "WAIT THEN SEND REQUEST"
			request_url = self.api_call
			Rails.logger.debug "sleeping for #{$redis.first.ttl.to_i} seconds"
			sleep($redis.first.ttl.to_i)
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
			#self.save
		else
			#Rails.logger.debug "WHERE AM I????"
			return 12
		end
	end

	def getMatchByMatchId
		
		#Execute the Request
		if $redis.keys("REQUEST").size < ENV['LONG_COUNT_LIMIT'].to_i
			#Rails.logger.debug "SEND REQUEST"
			request_url = self.api_call
			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
			#self.save
		elsif $redis.keys("REQUEST").size == ENV['LONG_COUNT_LIMIT']
			#Rails.logger.debug "WAIT THEN SEND REQUEST"
			request_url = self.api_call

			Rails.logger.debug "sleeping for #{$redis.first.ttl.to_i} seconds"
			sleep($redis.first.ttl.to_i)

			buffer = open(request_url).read
			result = JSON.parse(buffer)
			self.response = result
			#self.save
		else
			#Rails.logger.debug "WHERE AM I????"
			return 12
		end
	end
end
