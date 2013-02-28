require 's3'
require 'pathname'

class Uploader

  attr_accessor :is_pretend

  def initialize(options={})
    @is_pretend = options.fetch(:is_pretend, false)
  end

  def upload_recursively(dir, options={})
    prefix = options[:prefix] || 'uploads'
    glob   = options[:glob]   || '**/*'

    dir_path = Pathname.new(dir)

    Dir[dir + '/' + glob].each do |path|
      path = Pathname.new(path)
      next if path.directory?

      upload_path = "#{prefix}/#{path.relative_path_from(dir_path)}"
      upload( path, upload_path )
    end
  end

  def upload( local_path, remote_path )
    puts "Uploading #{local_path} to S3 #{bucket.name}://#{remote_path}"

    return if is_pretend
    object = bucket.objects.build(remote_path)
    object.content = File.open(local_path)
    object.save
  end

  private

  def connection
    @connection ||=
      S3::Service.new(:access_key_id => S3_ACCESS_KEY,
                      :secret_access_key => S3_SECRET_KEY)
  end

  def bucket
    @bucket ||= _get_or_create_bucket
  end

  def _get_or_create_bucket
    connection.buckets.find(S3_BUCKET)
  rescue S3::Error::NoSuchBucket
    _bucket = connection.buckets.build( S3_BUCKET )
    _bucket.save
    _bucket
  end
end
