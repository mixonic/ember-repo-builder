require 'sinatra/base'
require './lib/overalls'

class Overalls < Sinatra::Base
  get '/' do
    @project_files = Project::EMBER_FILES
    @projects = Project.sorted('ember.js')
    erb :index
  end

  get '/build' do
    BuildWorker.perform_async
    "Scheduling build."
  end

  helpers do
    def url_from_project(project_data, path)
      ["http://#{S3_BUCKET}.s3.amazonaws.com",
       "builds",
       project_data['name'],
       project_data['revision'],
       path].join('/')
    end
  end
end
