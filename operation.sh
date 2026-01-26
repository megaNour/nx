#!/bin/sh

set -e

printHelp() {
  cat <<EOF
Usage:
  $NAME [OPERATION_ID [PAYLOAD]]

  OPERATION_ID  A valid Nuxeo Operation name (see last example)
  PAYLOAD       A valid JSON Operation payload. (empty by default)
                see the Nuxeo Documentation for more specs.

Commands:
  help | -h | --help   Get contextual help for this command.

Examples:
  # display $NAME init help
  $NAME init help
  # block permission inheritence on a specific doc
  $NAME Document.BlockPermissionInheritance '{
    "input": "doc:/default-domain/workspaces/my_workspace/my_file"
  }'
EOF
}

maybeHelp "$@"

operation=${1:?operation id required}
payload=${2:-"{}"}
shift 2
cmd="-H \"Content-type: application/json\" \"$NUXEO_URL/nuxeo/api/v1/automation/$operation\" -d "

doCurlP "$cmd" "$payload" $*
