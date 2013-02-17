require 'fileutils'
require 'tmpdir'
require 'bundler'

class Builder
  attr_reader :work_dir, :project_name, :git_url,
    :build_dir, :build_task, :is_latest

  def initialize( options=nil )
    options ||= ember_options

    @project_name = options[:project_name]
    @git_url      = options[:git_url]
    @build_dir    = options[:build_dir]
    @build_task   = options[:build_task]
    @is_latest    = options[:is_latest]
  end

  def run
    setup_work_dir
    checkout_code
    bundle
    build
    upload
    cleanup
  end

  def ember_options
    {
      project_name: 'ember.js',
      git_url: 'https://github.com/emberjs/ember.js.git',
      build_dir: 'dist',
      build_task: 'dist',
      is_latest: true
    }
  end

  private

  def setup_work_dir
    @work_dir = Dir.mktmpdir
  end

  def checkout_code
    exec "git clone #{git_url} --depth=1 #{work_dir}"
  end

  def bundle
    Dir.chdir(work_dir)

    exec 'bundle install'
  end

  def build
    Dir.chdir(work_dir)

    exec "bundle exec rake #{build_task}"
  end

  def upload(uploader=Uploader.new)
    Dir.chdir(work_dir)

    uploader.upload_dir_recursively(
      build_dir,
      prefix: build_prefix)

    if is_latest
      uploader.upload_dir_recursively(
        build_dir,
        prefix: build_prefix('latest'))
    end
  end

  def build_prefix(suffix=nil)
    suffix ||= current_revision
    "builds/#{project_name}/#{suffix}"
  end

  def cleanup
    FileUtils.remove_entry_secure(work_dir)
  end

  def current_revision
    Dir.chdir(work_dir)

    exec('git rev-parse HEAD').strip
  end

  def exec(cmd)
    puts cmd
    val = Bundler.with_clean_env{ `#{cmd}` }
    puts val
    val
  end
end
