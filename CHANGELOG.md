## UnicornCtl Changelog

### 0.1.7 / 2014-06-19

* Add version module and `-v` key to the script allowing users to see what version is installed.

### 0.1.6 / 2014-06-18

* Do not follow recirects when performing a health check and handle all 1xx/2xx/3xx as success.
* When pid file is empty, treat it as a stale one.

### 0.1.5 / 2014-02-21

* Fix --unicorn-config/--rackup-config/--pid-file options handling.

### 0.1.4 / 2014-02-20

* Add a wait period after upgrade/start to make sure new master has a chance to start before we perform a health check on it.
* Add an option for the script to watch new master process until its proctitle changes.

### 0.1.3 / 2013-09-17

* Fix unicorn upgrades: really wait for the new master to replace the old one.

### 0.1.2 / 2013-09-11

* Added `status` command.

### 0.1.1 / 2013-09-11

* Added `reopen-logs` command.

### 0.1.0 / 2013-09-11

* Initial open-source release of unicornctl.
