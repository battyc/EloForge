module RateLimit
	module Query
		class QueryQueue
			def initialize
				@shortCount = 0
				@longCount = 0
				@shortTimer = Time.now.to_i
				@longTimer = Time.now.to_i
				@shortCap = 10 # 10 requests
				@shortLimit = 10 # per 10 seconds
				@longCap = 500 # 500 requests
				@longLimit = 600 # per 600 seconds (10m)
			end

			def shortTimer
				return Time.now.to_i - @shortTimer
			end

			def longTimer
				return Time.now.to_i - @longTimer
			end

			def can_query?
				if(@shortTimer == nil)
					@shortTimer = Time.now.to_i
					@shortCount = 0
				end
				if(@longTimer == nil)
					@longTimer = Time.now.to_i
					@longCount = 0
				end

				currentTime = Time.now.to_i

				shortPass = false
				longPass = false

				# Check shortcap, pass or fail
				if (((currentTime - @shortTimer) <= @shortLimit ) && (@shortCount <= @shortCap))
					shortPass = true
				elsif (currentTime - @shortTimer) >= @shortLimit
					shortPass = true
					@shortTimer = Time.now.to_i
					@shortCount = 0
				end

				# Check longcap, if test fails 
				if (((currentTime - @longTimer) <= @longLimit ) && (@longCount < @longCap))
					longPass = true	
				elsif (currentTime - @longTimer) >= @longLimit
					longPass = true
					@longTimer = Time.now.to_i
					@longCount = 0
				end

				if shortPass && longPass
					@longCount += 1
					@shortCount += 1
					return true
				elsif shortPass
					@shortCount += 1
					return false
				elsif longPass
					@longCount += 1
					return false
				else
					return false
				end
			end
		end

		def self.start
			$globalQueue = RateLimit::Query::QueryQueue.new
		end

		def self.execute(request)
			uri = URI(request)
			Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Get.new uri.request_uri
				@response = http.request request
				#response_hash =  JSON.parse response.body.to_s	
			end
			Rails.logger.debug "response: #{@response.inspect}"
			return @response
		end
	end
end