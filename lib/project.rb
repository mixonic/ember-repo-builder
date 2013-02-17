class Project
  attr_accessor :name, :git_url, :build_dir,
    :build_task, :build_glob

  def self.ember
    new(ember_options)
  end

  def initialize(options={})
    @name         = options[:name]
    @git_url      = options[:git_url]
    @build_dir    = options[:build_dir]
    @build_task   = options[:build_task]
    @build_glob   = options[:build_glob]
  end

  def self.ember_options
    {
      name: 'ember.js',
      git_url: 'https://github.com/emberjs/ember.js.git',
      build_dir: 'dist',
      build_task: 'dist',
      is_latest: true,
      build_glob: '**'
    }
  end
end
