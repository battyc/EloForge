require 'test_helper'

class SummonerControllerTest < ActionController::TestCase
  test "should throw error" do
    post :search, "search" => 'HotGuy6Pack', "servers" => {"server"=>"NA"}
    puts "1"
    post :search,  "search" => 'THExJOHNxCENA555', "servers"=>{"server"=>"NA"}
    puts "2"
    post :search,  "search" => 'fabbbyyy', "servers"=>{"server"=>"NA"}
    puts "3"
    post :search,  "search" => 'ZeyZal', "servers"=>{"server"=>"NA"}
    puts "4"
    post :search,  "search" => 'ESPORTS LEGEND', "servers"=>{"server"=>"NA"}
    puts "5"
    post :search,  "search" => 'japanman', "servers"=>{"server"=>"NA"}
    puts "6"
    assert_redirected_to root_path
  end

end
