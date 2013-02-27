require 'fileutils'
require 'tmpdir'
require 'bundler'
require 'forwardable'

class Builder
  attr_reader :work_dir, :is_latest, :revision, :commit_message

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
      save
    ensure
      cleanup
    end
  end

  def save(persistence=Persistence.new)
    key = "build:#{name}:#{revision}"
    timestamp = Time.now.to_i

    persistence.save(
      key,
      { revision:       revision,
        commit_message: commit_message,
        name:           name,
        timestamp:      timestamp })
    persistence.score(group=name,
                      member=key,
                      score=timestamp)
  end

  private

  def setup_work_dir
    @original_dir = Dir.pwd
    @work_dir     = Dir.mktmpdir
  end

  def checkout_code
    exec "git clone #{git_url} --depth=1 #{work_dir}"
    @revision = current_revision
    @commit_message = current_commit_message
  end

  def bundle
    Dir.chdir(work_dir)

    exec 'mkdir gembundle'
    exec 'bundle show'
    exec 'bundle check'
    exec 'bundle install --path gembundle'
  end

  def build
    Dir.chdir(work_dir)

    exec 'bundle show'
    exec 'bundle check'
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
    suffix ||= revision
    "builds/#{project_name}/#{suffix}"
  end

  def cleanup
    Dir.chdir(@original_dir)
    FileUtils.remove_entry_secure(work_dir) if work_dir
  end

  def current_revision
    Dir.chdir(work_dir)
    exec('git rev-parse HEAD').strip
  end

  def current_commit_message
    Dir.chdir(work_dir)
    exec('git log --format=%B -n 1').strip
  end

  def exec(cmd)
    puts "Exec: #{cmd}"
    val = Bundler.with_clean_env{ `#{cmd}` }
    puts "Result: #{val}"
    val
  end
end
