#!/bin/sh

set -e

printHelp() {
  cat <<EOF
Usage:
  $NAME [COMMAND... [COMMAND_OPTIONS...] [COMMAND_ARG...]...]

Commands:
  [ANYTHING_UNLISTED]  Get contextual help for this command.
  post                 Create a user or group entity.

Examples:
  # display $NAME post help
  $NAME post help
EOF
}

maybeHelp "$@"

command=${1}.sh
shift
if [ -f "$ENTRY/$COMMAND/$command" ]; then
  NAME="$NAME ${command%.sh}" . "$ENTRY/$COMMAND/${command}"
else
  printHelp
fi
