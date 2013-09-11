#!/bin/sh
#
### BEGIN INIT INFO
# Provides: app-foo
# Defalt-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Required-Start: $local_fs $remote_fs $network $named
# Required-Stop: $local_fs $remote_fs $network
# Description: Rainbows Application - foo
### END INIT INFO

# Fail on undefined variables
set -u

# Fail on errors
set -e

# Since this script could be running from monit, we need to recover PATH
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#---------------------------------------------------------------------------------------------------
# Variables configured in chef
APP_DIR="/u/apps/foo"

# Setup pid file names
PID="/u/apps/foo/shared/pids/rainbows.pid"

# Setup rainbows config file
RAINBOWS_CONFIG="/u/apps/foo/shared/rainbows.rb"

# Setup environment
APP_ENV="production"

#---------------------------------------------------------------------------------------------------
# Get action name from command line
ACTION="$1"

# Pass command to unicorn-ctl
exec /usr/bin/unicornctl \
  --rainbows \
  --app-dir "${APP_DIR}" \
  --pid-file "${PID}" \
  --unicorn-config "${RAINBOWS_CONFIG}" \
  --environment $APP_ENV \
  --health-check-url=http://localhost:8009/ \
  "$ACTION"
