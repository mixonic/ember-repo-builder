require 'sinatra/base'
require './lib/overalls'

class Overalls < Sinatra::Base
  get '/' do
    @project_files = Project::EMBER_FILES
    @projects = Project.sorted('ember.js')
    erb :index
  end

  get '/build' do
    thread = Thread.new do
      builder  = Builder.new
      start_at = Time.now
      puts builder.run
      puts "Finished building at #{Time.now - start_at}s"
    end
    "Scheduling build."
  end

  helpers do
    def url_from_project(project_data, path)
      ["http://#{ENV['S3_BUCKET']}.s3.amazonaws.com",
       "builds",
       project_data['name'],
       project_data['revision'],
       path].join('/')
    end
  end
end
