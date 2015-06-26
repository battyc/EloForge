module SummonerHelper
	class Query

		def initialize
			@@queries = Array.new
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
	end
end
