#!/bin/sh

printHelp() {
  cat <<EOF
Description:
  Get bulk status for a given batch ID.

Usage:
  $NAME [help|-h|--help]
  $NAME BATCH_ID

Environments:
  NUXEO_URL            Example: "localhost:8080".
  NUXEO_CREDENTIALS    Used by curl to authenticate you.
  SHOUT_LEVEL >= 5     prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit

Examples:
  $NAME d5d84d01-ca1f-445c-be0a-0b37d30691b4
EOF
}

args=$(getopt -o 'd,h' -l 'dryrun,dryRun,dry-run,help' "$@")
eval "set -- $args"

shoutaf "$@"

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

maybeHelp "$@"
rejectForbiddenFlags "$@"
batch_id=${1?${_red}param 1: missing path to get.$_def}
shift

doCurl "$NUXEO_URL/nuxeo/api/v1/bulk/$batch_id" $* | jq
