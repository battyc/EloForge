=begin
class Query

def initialize
	@@queries = Array.new
end

end



def self.add(request)
    @@queries.push(request)
  end

def self.next
  return @@queries.shift # Removes the next query in line and returns it.
end

def execute(request)
  	uri = URI(@request)
	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		request = Net::HTTP::Get.new uri.request_uri
		response = http.request @request
		response_hash =  JSON.parse response.body.to_s
	end
	
end

	
=begin
	# Initialize the Query infrastructure.
	def start
		@shortTimer = Time.now.to_i
		@longTimer = Time.now.to_i
		@shortCount = 0
		@longCount = 0
		return self
	end

	def self.execute(request)
		if(@shortTimer == nil)
			@shortTimer = Time.now_to_i
			@shortCount = 0
		end
		if(@longTimer == nil)
			@longTimer = Time.now_to_i
			@longCount = 0
		end

		currentTime = Time.now.to_i

		shortPass = false
		longPass = false

		# Check shortcap, pass or fail
		if (((currentTime - @shortTimer) <= @shortLimit ) && (@shortCount <= @shortCap))
			shortPass = true
			@shortCount += 1
		elsif (currentTime - @shortTimer) >= @shortLimit
			shortPass = true
			@shortLimit = time.now.to_i
			@shortCount = 1	
		end

		# Check longcap, if test fails 
		if (((currentTime - @longTimer) <= @longLimit ) && (@longCount <= @longCap))
			longPass = true		
		elsif (currentTime - @longTimer) >= @longLimit
			longPass = true
			@longLimit = time.now.to_i
			@longCount = 1	
		end

		# if everything passed return the response_hash
		if shortPass && longPass
			uri = URI(request)
			Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Get.new uri.request_uri
				response = http.request request
				response_hash =  JSON.parse response.body.to_s
				logger.debug "HELP ME#{response_hash.to_s}"
				return reponse_hash
			end
		else
			#return an error.
			return "1337 - Rate limit reached."
		end		

end


=end