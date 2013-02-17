require 'fileutils'
require 'tmpdir'
require 'bundler'
require 'forwardable'

class Builder
  attr_reader :work_dir, :is_latest

  extend Forwardable

  def_delegators :@project,
    :name, :git_url, :build_dir, :build_task, :build_glob

  def_delegator :@project, :name, :project_name

  def initialize( project=nil, options={} )
    @project ||= Project.ember

    @is_latest    = options[:is_latest]
  end

  def run
    setup_work_dir
    begin
      checkout_code
      bundle
      build
      upload
    ensure
      cleanup
    end
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

    upload_options = {
      prefix: build_prefix,
      glob:   build_glob
    }
    uploader.upload_recursively(build_dir, upload_options)

    if is_latest
      upload_options.merge!( prefix: build_prefix('latest') )
      uploader.upload_recursively( build_dir, upload_options )
    end
  end

  def build_prefix(suffix=nil)
    suffix ||= current_revision
    "builds/#{project_name}/#{suffix}"
  end

  def cleanup
    FileUtils.remove_entry_secure(work_dir) if work_dir
  end

  def current_revision
    Dir.chdir(work_dir)

    exec('git rev-parse HEAD').strip
  end

  def exec(cmd)
    puts "Exec: #{cmd}"
    val = Bundler.with_clean_env{ `#{cmd}` }
    puts "Result: #{val}"
    val
  end
end
