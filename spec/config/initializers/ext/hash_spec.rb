require 'spec_helper'

describe Hash do
 it "should recursively symbolise keys" do
   h = {"india" => {"metros" => {"pune" => "1", "mumbai" =>  "2"}}}

   h.recursively_symbolize_keys!
   h.should ==  {:india => {:metros => {:pune => "1", :mumbai =>  "2"}}}
 end
end
