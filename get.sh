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
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XGET mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -p, --path PATH                  Target path from workspace root.
  -P, --absolute-path ABS_PATH     Target path from root.
  -r, --repo --repo-id REPO_ID     Target a specific repository.

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

maybeHelp "$@"

# do it separately from eval or it will swallow any error code
args="$(getopt -o "dhP:p:r:" -l "dry-run,dryrun,dryRun,help,path:,absolute-path:,repo:,repo-id:" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  -P | --absolute-path)
    absolute_path=1
    base_path=$2
    shift
    ;;
  -p | --path)
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
doc_path=${1?${_red}param 1: missing path to get.$_def}
shift

[ -z "$absolute_path" ] && base_path=default-domain/workspaces/ || :

sanitizePathSegment base_path
sanitizePathSegment doc_path "$base_path"
sanitizePathSegment repo_id

doCurl "$NUXEO_URL/nuxeo/api/v1/${repo_id}path/$doc_path" $*
