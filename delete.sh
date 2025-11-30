#!/bin/sh

set -e

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
  -p, --path PATH                  Target path from workspace root.
  -P, --absolute-path ABS_PATH     Target path from root.
  -r, --repo --repo-id REPO_ID     Target a specific repository.

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

# do it separately from eval or it will swallow any error code
args="$(getopt -o "dh" -l "dryrun,dryRun,dry-run,help" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  -P | --absolute-path)
    base_path=
    doc_path=$2
    shift
    ;;
  -p | --path)
    base_path=default-domain/workspaces/
    doc_path=$2
    shift
    ;;
  -r | --repo | --repo-id)
    repo_id=$2
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

doc_path=${1?${_red}param 1: missing target to delete. Pass an empty string if you want to nuke everything under \'/default-domain/workspaces/\'$_def}
shift

sanitizePathSegment doc_path "$base_path"
sanitizePathSegment repo_id "repo/"

doCurl "-XDELETE $NUXEO_URL/nuxeo/api/v1/${repo_id}path/$doc_path" $*
