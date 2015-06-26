#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

@shortTimer = Time.now.to_i
@longTimer = Time.now.to_i
@shortCount = 0
@longCount = 0

@shortCap = 10 # 10 requests
@shortLimit = 10 # per 10 seconds
@longCap = 500 # 500 requests
@longLimit = 600 # per 600 seconds (10m)

while($running) do
	query_text = Query.new.next

	if query_text
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
			Query.execute(query_text)
			
		else
			#return an error.
		end		
	else
		sleep 5
	end
end
