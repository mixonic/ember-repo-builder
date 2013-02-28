require 'yaml'

require File.dirname(__FILE__) + '/builder'
require File.dirname(__FILE__) + '/uploader'
require File.dirname(__FILE__) + '/project'
require File.dirname(__FILE__) + '/persistence'
require File.dirname(__FILE__) + '/workers/build_worker'

settings = YAML.load_file(File.dirname(__FILE__) + '/../config/settings.yml')

S3_ACCESS_KEY = settings[:s3_access_key]
S3_SECRET_KEY = settings[:s3_secret_key]
S3_BUCKET     = settings[:s3_bucket]
