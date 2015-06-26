class MakeRequestJob < ActiveJob::Base
  queue_as :urgent

  def perform(*args)
    uri = URI(request)
	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		request = Net::HTTP::Get.new uri.request_uri
		response = http.request request
		response_hash =  JSON.parse response.body.to_s
		logger.debug "HELP ME#{response_hash.to_s}"
	end
  end
  
end
