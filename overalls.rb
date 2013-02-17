require 'sinatra/base'
require './lib/overalls'

class Overalls < Sinatra::Base
  get '/' do
    erb :index
  end

  get '/build' do
    builder = Builder.new
    Thread.new do
      start_at = Time.now
      puts builder.run
      builder.save
      puts "Finished building at #{Time.now - start_at}s"
    end
    "Scheduling build of #{builder.name}"
  end
end
