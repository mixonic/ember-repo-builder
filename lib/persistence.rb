require 'redis'
require 'redis-namespace'
require 'json'

class Persistence
  attr_reader :connection

  def save(key, data)
    puts "Saving #{key}: #{data.inspect}"
    connection.set( key, data.to_json )
  end

  def score(group, member, score)
    puts "Scoring #{group} -> #{member}: #{score}"
    connection.zadd(group, score, member)
  end

  def sorted(group)
    json_results = connection.zrevrangebyscore(group, '+inf', '-inf')
    json_results.map {|result| JSON.parse connection.get(result) }
  end

  private

  def connection
    @connection ||= self.class.connection
  end

  def self.connection
    @@redis ||= begin
      redis = Redis.new
      Redis::Namespace.new("repo-builder", redis:redis)
    end
  end
end
