# 4 workers is enough for our app
worker_processes 4

# App location
@app = "/var/rails/ember-repo-builder/current"

# Listen on fs socket for better performance
listen "#{@app}/tmp/sockets/unicorn.sock", :backlog => 64

# Nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# App PID
pid_file = "#{@app}/tmp/pids/unicorn.pid"
pid pid_file
old_pid = "#{pid_file}.oldbin"

# By default, the Unicorn logger will write to stderr.
# Additionally, some applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{@app}/log/unicorn.stderr.log"
stdout_path "#{@app}/log/unicorn.stdout.log"

# To save some memory and improve performance
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

# Force the bundler gemfile environment variable to
# reference the Сapistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(@app, 'Gemfile')
end

before_fork do |server, worker|
  # zero downtime deploy magic:
  # if unicorn is already running, ask it to start a new process and quit.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
