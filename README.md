## unicornctl - unicorn/rainbows control script

`unicornctl` is a simple and easy to use console tool for managing ruby applications using unicorn or
rainbows application server. The tool provides a set of reliable commands to start/stop/restart
unicorn instances or upgrade them without or with minimal downtime. `unicornctl` script could easily
be used as a base for a startup script for unix operating systems (see examples directory for a
Redhat-style startup script example).

Please note, that this is still an alpha-quality software and it could have many issues. If you try it and 
find any problems, feel free to report them using [Github Issues page](https://github.com/swiftype/unicorn-ctl/issues). 
Pull requests are welcome too!

### Installation

The script comes packaged as a rubygem, so installation procedure is as simple as running the
following command:

    sudo gem install unicorn-ctl

After installation you should have an access to the `unicornctl` console command.

### Usage Instructions

Here is the help output from the `unicornctl` command:

```
Usage: ./bin/unicornctl [options] <command>
Valid commands: start, stop, force-stop, restart, force-restart, upgrade
Options:
  --app-dir=dir                  | -d dir     Base directory for the application (required)
  --environment=name             | -e name    RACK_ENV to use for the app (default: development)
  --health-check-url=url         | -H url     Health check URL used to make sure the app has started
  --health-check-content=string  | -C string  Health check expected content (default: just check for HTTP 200 OK)
  --health-check-timeout=sec     | -T sec     Individual health check timeout (default: 5 sec)
  --timeout=sec                  | -t sec     Operation (start/stop/etc) timeout (default: 30 sec)
  --unicorn-config=file          | -c file    Unicorn config file to use, absolute or relative path (default: shared/unicorn.rb)
  --rackup-config=file           | -r file    Rackup config file to use, absolute or relative path (default: current/config.ru)
  --pid-file=file                | -p file    PID-file unicorn is configured to use (default: shared/pids/unicorn.pid)
  --rainbows                     | -R         Use rainbows to start the app (default: use unicorn)
  --help                         | -h         This help
```

The following command are supported at the moment:

* `start` - starts a unicorn application and performs a health check if health check URL is available.
  If the server is already running, only the health check would be performed.
* `stop` - gracefully stops a unicorn application by sending a `QUIT` signal to the master process
  and waiting for a specified amount of time (30 sec by default) for the process and all of its
  children to shut down properly. If the process fails to stop in a given time, it is killed
  with a `KILL` signal.
* `force-stop` - forcefully shuts down a unicorn application by sending a `TERM` signal to it and
  waiting for the process to shut down quickly. If the process fails to stop in a given time, it is
  killed with a `KILL` signal.
* `restart` - gracefully shuts a unicorn application down and then starts it back up (performing a
  helth check if possible).
* `force-restart` - forcefully shuts a unicorn application down and then starts it back up
  (performing a helth check if possible).
* `upgrade` - zero or minimal downtime restart option for a unicorn application. Performs a set of
  steps to start a new copy of the application, test it and then gracefully shut down the old copy.
  If the graceful restart fails for any reason, the application is forcefully restarted.

For more information on unicorn procss management you could check their
[official documentation page](http://unicorn.bogomips.org/SIGNALS.html).

### License

The code is distributed under the MIT license. For more details, see the LICENSE.txt file.
