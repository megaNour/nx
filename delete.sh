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
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XDELETE mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -p, --path PATH                  Path relative to workspace root

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

# do it separately from eval or it will swallow any error code
args="$(getopt -o dhp: -l dry-run,dryrun,dryRun,help,path: -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dry-run | --dry[Rr]un)
    dry_run=1
    ;;
  -p | --path)
    doc_path=$2
    shift
    ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

rejectForbiddenFlags "$@"

doCurl "$NUXEO_URL/nuxeo/api/v1/path/default-domain/workspaces/$doc_path" $*
