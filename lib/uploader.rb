require 's3'
require 'pathname'

class Uploader
  ENV_CREDS = %w(S3_ACCESS_KEY S3_SECRET_KEY S3_BUCKET)

  def initialize
    self.class.require_env_creds
  end

  def upload_dir_recursively(dir, options={})
    prefix = options[:prefix] || 'uploads'
    dir_path = Pathname.new(dir)

    Dir[dir + '/**'].each do |path|
      path = Pathname.new(path)
      next if path.directory?

      upload_path = "#{prefix}/#{path.relative_path_from(dir_path)}"
      upload( path.to_s, upload_path )
    end
  end

  def upload( local_path, remote_path )
    puts "Uploading #{local_path} to #{remote_path}"

    object = bucket.objects.build(remote_path)
    object.content = File.open(local_path)
    object.save
  end

  private

  def self.require_env_creds
    missing = []
    ENV_CREDS.each do |cred|
      missing << cred if ENV[cred].nil?
    end
    if !missing.empty?
      raise "Missing env creds: #{missing.join(',')}"
    end
  end

  def connection
    @connection ||=
      S3::Service.new(:access_key_id => ENV['S3_ACCESS_KEY'],
                      :secret_access_key => ENV['S3_SECRET_KEY'])
  end

  def bucket
    @bucket ||=
      (connection.buckets.find(ENV['S3_BUCKET']) || create_bucket)
  end

  def create_bucket
    _bucket = connection.buckets.build(ENV['S3_BUCKET'])
    _bucket.save
    _bucket
  end

end
