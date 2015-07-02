require 'test_helper'

class SummonerControllerTest < ActionController::TestCase
  test "should throw error" do
    post :search, "search" => 'HotGuy6Pack'
    puts "1"
    post :search,  "search" => 'THExJOHNxCENA555'
    puts "2"
    post :search,  "search" => 'fabbbyyy'
    puts "3"
    post :search,  "search" => 'ZeyZal'
    puts "4"
    post :search,  "search" => 'ESPORTS LEGEND'
    puts "5"
    post :search,  "search" => 'japanman'
    puts "6"
    puts "#{$globalQueue.inspect}"
    assert_redirected_to root_path
  end

end
