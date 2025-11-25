#!/bin/sh

set -e

printHelp() {
  cat <<EOF
Usage:
  $NAME [COMMAND... [COMMAND_OPTIONS...] [COMMAND_ARG...]...]

Commands:
  [ANYTHING_UNLISTED]  Get contextual help for this command.
  init                 Init a batch.
  info                 Get batch info.
  upload               Upload a file into the batch.
  create               Create one document per uploaded file.

Examples:
  # display $NAME init help
  $NAME init help
  # create a document with options
  $NAME create -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

maybeHelp "$1"
command=${1}.sh
shift
if [ -f "$ENTRY/$command" ]; then
  NAME="$NAME $command" ENTRY=$ENTRY/$command . "$ENTRY/${command}" "$@"
else
  printHelp
fi
