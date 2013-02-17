require 'json'

class Project
  attr_accessor :name, :build_dir,
    :build_task, :build_glob, :repo, :owner

  EMBER_FILES = [
    ['ember.js', 'ember.js'],
    ['handlebars.js', 'modules/handlebars.js'],
    ['ember-runtime.js', 'ember-runtime.js']
  ]

  def self.ember
    new(ember_options)
  end

  def self.sorted(project_name, persistence=Persistence.new)
    persistence.sorted(project_name)
  end

  def initialize(options={})
    @repo         = options[:repo]      # github repo name
    @owner        = options[:owner]     # github owner name
    @build_dir    = options[:build_dir]
    @build_task   = options[:build_task]
    @build_glob   = options[:build_glob]
  end

  def name
    repo
  end

  def git_url
    "https://github.com/#{owner}/#{repo}.git"
  end

  private

  def self.ember_options
    {
      repo: 'ember.js',
      owner: 'emberjs',
      build_dir: 'dist',
      build_task: 'dist',
      is_latest: true
    }
  end
end
