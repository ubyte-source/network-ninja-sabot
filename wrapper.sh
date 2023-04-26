#!/bin/sh

# Start all process describe in ENV variables.
# The process running in subshell.

LISTEN="STARTUP_COMMAND_RUN"

# The function is extracting the command to be executed from an environment variable.

process() {
  local run=${1%%|*}
  local run=${run##*=}
  echo $run
  return 0
}

printenv | more | grep "${LISTEN}" | while read -r line ; do
  process=$(process "$line")
  sh -c "$process" &
done

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

runner() {
    echo "Stop this container."
    kill -SIGINT 1
    exit 1
}

# The function is extracting the process name from environment variable.

name() {
  local brew=${1##*|}
  [[ "$1" == "$brew" ]] && brew=${1##*=}
  echo "$brew"
  return 0
}

trap runner SIGINT SIGQUIT SIGTERM

while sleep 8 & wait $!; do

  printenv | more | grep "${LISTEN}" | while read -r line ; do

    # Grep process status

    process=$(name "$line")
    ps aux | grep "${process%% *}" | grep -v grep > /dev/null

    # If the greps above find anything, they exit with 0 status
    # If they are not both 0, then something is wrong

    if [ $? -ne 0 ] ; then
      echo "The processes ${process} already exited."
      runner
    fi

  done

done