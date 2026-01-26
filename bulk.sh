#!/bin/sh

set -e

printHelp() {
  cat <<EOF
Usage:
  $NAME [COMMAND... [COMMAND_OPTIONS...] [COMMAND_ARG...]...]

Commands:
  help | -h | --help   Get contextual help for this command.
  status               Get status for your bulk commands.

Examples:
  # display $NAME status help
  $NAME status

  # Get status for command matching the UID
  $NAME status d5d84d01-ca1f-445c-be0a-0b37d30691b4
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
