require 'sidekiq'

class BuildWorker
  include Sidekiq::Worker

  def perform
    builder  = Builder.new
    start_at = Time.now
    puts builder.run
    puts "Finished building at #{Time.now - start_at}s"
  end

end
