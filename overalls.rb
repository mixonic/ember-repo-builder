require 'sinatra/base'
require './lib/overalls'

class Overalls < Sinatra::Base
  get '/' do
    erb :index
  end

  get '/build' do
    start_at = Time.now
    Thread.new do
      puts Builder.new.run
    end
    "Built in #{Time.now - start_at}s"
  end
end
