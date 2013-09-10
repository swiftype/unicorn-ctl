#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'shellwords'
require 'getoptlong'
require 'httparty'

#---------------------------------------------------------------------------------------------------
# Make sure our console output is synchronous
STDOUT.sync = true
STDERR.sync = true

# Trap interrupts to quit cleanly. See
# https://twitter.com/mitchellh/status/283014103189053442
Signal.trap("INT") { exit 1 }

#---------------------------------------------------------------------------------------------------
def app_file_path(app_dir, config_name)
  return config_name if config_name =~ /^\//
  return File.join(app_dir, config_name)
end

def unicorn_pid_file(options)
  if options[:pid_file]
    app_file_path(options[:app_dir], options[:pid_file])
  else
    File.join(options[:app_dir], 'shared', 'pids', 'unicorn.pid')
  end
end

def unicorn_config_file(options)
  if options[:unicorn_config]
    app_file_path(options[:app_dir], options[:unicorn_config])
  else
    File.join(options[:app_dir], 'shared', 'unicorn.rb')
  end
end

def rackup_config_file(options)
  if options[:rackup_config]
    app_file_path(options[:app_dir], options[:rackup_config])
  else
    File.join(options[:app_dir], 'current', 'config.ru')
  end
end

def unicorn_bin(options)
  "unicorn"
end

def escape(param)
  Shellwords.escape(param)
end

#-------------------------------------------------------------------------------------------
# Check if process is still running
def pid_running?(pid)
  begin
    Process.kill(0, pid)
    return true
  rescue Errno::ESRCH
    return false
  rescue ::Exception   # for example on EPERM (process exists but does not belong to us)
    return true
  end
end

def send_signal(signal, pid)
  Process.kill(signal, pid)
rescue => e
  puts "WARNING: Failed to send signal #{signal} to #{pid}: #{e}"
end

def read_pid(pid_file)
  File.read(pid_file).strip.to_i
end

#---------------------------------------------------------------------------------------------------
# Kills a process and all of its descendants
def kill_tree(pid)
  # FIXME: Implrement a real killtree
  send_signal(9, pid)
end

#---------------------------------------------------------------------------------------------------
# Performs a health check on an http endpoint
def check_app_health(options)
  puts "Checking service health with URL: #{options[:check_url]}"

  start_time = Time.now
  while Time.now - start_time < options[:timeout]
    sleep(1)

    response = begin
      HTTParty.get(options[:check_url], :timeout => options[:check_timeout])
    rescue Timeout::Error => e
      puts "Health check timed out after #{options[:check_timeout]} seconds. Retrying..."
      next
    end

    if response.code.to_i / 100 == 2
      puts "Health check succeeded with code: #{response.code}"
      if options[:check_content]
        if response.body.match(options[:check_content])
          puts "Content check succeeded, found content in response body: #{options[:check_content]}"
          return true
        else
          puts "ERROR: Could not find content in response body: #{options[:check_content]}. Retrying."
          next
        end
      end
      return true
    end

    puts "Health check failed with status #{response.code}. Retrying..."
  end

  puts "ERROR: Health check has been failing for #{Time.now - start_time} seconds, giving up now!"
  exit(1)
end

#---------------------------------------------------------------------------------------------------
def start_application!(options)
  # Check pid file
  pid_file = unicorn_pid_file(options)
  if File.exists?(pid_file)
    pid = read_pid(pid_file)

    if pid_running?(pid)
      puts "OK: The app is already running"

      # If we have a health check url, let's check it
      check_app_health(options) if options[:check_url]

      # Done
      exit(0)
    else
      puts "WARNING: Slate pid file found, removing it: #{pid_file}"
      FileUtils.rm(pid_file)
    end
  end

  # Get unicorn bin
  unicorn_bin = unicorn_bin(options)

  # Get unicorn config
  unicorn_config = unicorn_config_file(options)
  unless File.readable?(unicorn_config)
    puts "ERROR: Could not find unicorn config: #{unicorn_config}"
    exit(1)
  end

  # Get rackup config
  rackup_config = rackup_config_file(options)
  unless File.readable?(rackup_config)
    puts "ERROR: Could not find rackup config: #{rackup_config}"
    exit(1)
  end

  # Compose unicorn startup command
  command = "cd #{escape options[:app_dir]}/current && bundle exec #{unicorn_bin} " <<
            "--env #{escape options[:env]} --daemonize --config-file #{escape unicorn_config} "
            "#{escape rackup_config}"

  # Run startup command
  puts "Starting unicorn..."
  res = system(command)
  unless res
    puts "ERROR: Failed to start unicorn command: #{command}"
    exit(1)
  end

  # Wait for a few seconds...
  sleep(2)

  # Check pid file
  unless File.exists?(pid_file)
    puts "ERROR: Even though startup command succeeded, there is no pid file: #{pid_file}"
    exit(1)
  end

  # Check to make sure the process exists
  pid = File.read(pid_file).strip
  unless pid_running?(pid)
    puts "ERROR: Even though startup command succeeded and pid file exists, there is no process with pid=#{pid}"
    exit(1)
  end

  # If we have a health check url, let's check it
  check_app_health(options) if options[:check_url]

  # Ok, we're good
  puts "Started! PID=#{pid}"
  exit(0)
end

#---------------------------------------------------------------------------------------------------
def stop_application!(options, graceful = false)
  # Check pid file
  pid_file = unicorn_pid_file(options)
  unless File.exists?(pid_file)
    puts "OK: The process is not running"
    exit(0)
  end

  pid = read_pid(pid_file)
  if pid_running?(pid)
    signal = graceful ? 'QUIT' : 'TERM'
    puts "Sending #{signal} signal to process with pid=#{pid}..."
    send_signal(signal, pid)

    print "Waiting for the process to stop: "
    start_time = Time.now
    while Time.now - start_time < options[:timeout]
      print "."
      break unless pid_running?(pid)
      sleep(1)
    end

    if pid_running?(pid)
      puts " Failed to stop, killing!"
      kill_tree(pid)
    else
      puts " Done!"
    end
  else
    puts "WARNING: Slate pid file found, removing it: #{pid_file}"
    FileUtils.rm(pid_file)
  end

  puts "Stopped!"
  exit(0)
end

#---------------------------------------------------------------------------------------------------
def show_help(error = nil)
  puts "ERROR: #{error}\n\n" if error

  puts "Usage: #{$0} [options] <command>"
  puts 'Where args are:'
  puts '  --app-dir=dir                  | -d dir     Base directory for the application (required)'
  puts '  --environment=name             | -e name    RACK_ENV to use for the app (default: development)'
  puts '  --health-check-url=url         | -H url     Health check URL used to make sure the app has started'
  puts '  --health-check-content=string  | -C string  Health check expected content (default: just check for HTTP 200 OK)'
  puts '  --health-check-timeout=sec     | -T sec     Individual health check timeout (default: 5 sec)'
  puts '  --timeout=sec                  | -t sec     Operation (start/stop/etc) timeout (default: 30 sec)'
  puts '  --help                         | -h         This help'
  puts
  exit(error ? 1 : 0)
end

#---------------------------------------------------------------------------------------------------
# Parse options
opts = GetoptLong.new(
  [ '--app-dir',              '-d', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--environment',          '-e', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--health-check-url',     '-U', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--health-check-content', '-C', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--health-check-timeout', '-T', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--timeout',              '-t', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--help',                 '-h', GetoptLong::NO_ARGUMENT ]
)

# Default settings
options = {
  :app_dir => nil,
  :check_url => nil,
  :check_content => nil,
  :env => 'development',
  :timeout => 30,
  :check_timeout => 2
}

# Process options
opts.each do |opt, arg|
  case opt
    when "--app-dir"
      options[:app_dir] = arg.strip

    when "--environment"
      options[:env] = arg.strip

    when "--timeout"
      options[:timeout] = arg.to_i

    when "--health-check-url"
      options[:check_url] = arg.strip

    when "--health-check-content"
      options[:check_content] = arg.strip

    when "--health-check-timeout"
      options[:check_timeout] = arg.to_i

    when "--help"
      show_help
  end
end

# Get command
command = ARGV.first

# Make sure we have the command
show_help("Please specify one of valid commands: start, stop, graceful-stop!") unless command

# Check app directory
show_help("Please specify application directory!") unless options[:app_dir]
show_help("Please specify a valid application directory!") unless File.directory?(options[:app_dir])
options[:app_dir] = File.realpath(options[:app_dir])

#---------------------------------------------------------------------------------------------------
case command
  when 'start'
    start_application!(options)

  when 'stop'
    stop_application!(options, false)

  when 'graceful-stop'
    stop_application!(options, true)

  else
    show_help("ERROR: Invalid command: #{command}")
end
