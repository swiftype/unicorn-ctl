## UnicornCtl Changelog

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
