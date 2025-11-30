#!/bin/sh

printHelp() {
  cat <<EOF
Description:
  Retrieve info for a specific batch.

Usage:
  $NAME BATCH_ID
  $NAME [help|-h|--help]

Environments:
  NUXEO_URL           Example: "localhost:8080".
  NUXEO_CREDENTIALS   Used by curl to authenticate you.
  SHOUT_LEVEL >= 5    prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit

Examples:
  $NAME -dp foo
EOF
}

maybeHelp "$@"

args="$(getopt -o "dh" -l "dryrun,dryRun,dry-run,help" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

[ -n "$2" ] && infoHelp || : # make it clear we don't take a list of ids to query info for
rejectForbiddenFlags "$@"

batch_id=${1:?param 1: batch id required}
doCurl "$NUXEO_URL/nuxeo/api/v1/upload/$batch_id" $*
