#!/bin/sh

set -e

NAME=${NAME:-$0}

printHelp() {
  cat <<EOF
Usage: $NAME [OPTIONS] [-- [CURL_OPTION...]]

Environments:
  NUXEO_URL
  NUXEO_CREDENTIALS   in a <id>:<pwd>
  SHOUT_LEVEL >= 5    prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XGET mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -p, --path PATH                  Path relative to workspace root

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

maybeHelp "$1"

# do it separately from eval or it will swallow any error code
args="$(getopt -o "dh" -l "dry-run,dryrun,dryRun,help" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  --)
    shift
    break
    ;;
  *) ;; # ignore unhandled flags without error and clear $@ from them
  esac
  shift
done

rejectForbiddenFlags "$@"
target=${1?${_red}param 1: missing target to get from \'/default-domain/workspaces/\'$_def}
shift

doCurl "$NUXEO_URL/nuxeo/api/v1/path/default-domain/workspaces/$target" $*
