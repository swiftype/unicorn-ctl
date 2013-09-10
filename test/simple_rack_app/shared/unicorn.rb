require 'fileutils'

# Define project root dir
root_dir = File.realpath(File.join(File.dirname(__FILE__), '..'))
current_path = File.join(root_dir, 'current')

# Create logs/pids directories
FileUtils.mkdir_p("#{root_dir}/shared/log")
FileUtils.mkdir_p("#{root_dir}/shared/pids")

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory current_path

# Listen socket
listen "8001", :backlog => 1024

# Nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# PID file path
pid "#{root_dir}/shared/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, some applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{root_dir}/shared/log/unicorn.stderr.log"
stdout_path "#{root_dir}/shared/log/unicorn.stdout.log"
logger Logger.new("#{root_dir}/shared/log/unicorn.stderr.log", Logger::WARN)
