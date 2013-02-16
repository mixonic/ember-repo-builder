require 'sinatra/base'
require './lib/overalls'

class Overalls < Sinatra::Base
  get '/' do
    'hello world'
  end

  get '/build' do
    start_at = Time.now
    puts Builder.new.run
    "Built in #{Time.now - start_at}s"
  end
end
