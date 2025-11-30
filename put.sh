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
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPUT mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -n, --name --title NAME          Document name (title)
  -p, --path PATH                  Target path from workspace root.
  -P, --absolute-path ABS_PATH     Target path from root.
  -r, --repo --repo-id REPO_ID     Target a specific repository.
  -t, --type TYPE                  Document type

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

maybeHelp "$@"

# do it separately from eval or it will swallow any error code
args="$(getopt -o "dhk:n:p:r:t:" -l "dryrun,dryRun,dry-run,help,key-value:,name:,path:,repo:,repo-id:,type:" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  -k | --key-value)
    doc_key_values="${doc_key_values+$doc_key_values,}
      $2"
    shift
    ;;
  -n | --name)
    doc_name=$2
    shift
    ;;
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
  -t | --type)
    doc_type=$2
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

doc_path=${1:?param 1: ${_red}missing path to document to update.$_def}
shift

# check the obtained values
doc_type=${doc_type:-"File"}
doc_name=${doc_name:-"my_test_$doc_type"}

sanitizePathSegment doc_path "default-domain/workspaces/"
sanitizePathSegment repo_id "repo/"

# normalize the doc_type and deduce doc_icon
{
  IFS= read -r doc_type
  # ignore the lower case
} <<EOF
$(printf '%s\n' "$doc_type" | properAndLowercase)
EOF

cmd="-XPUT -H \"Content-type: application/json\" \"$NUXEO_URL/nuxeo/api/v1/${repo_id}path/$doc_path\" -d"
payload="{
    \"entity-type\": \"document\",
    \"name\":\"$doc_name\",
    \"type\": \"$doc_type\",
    \"properties\": {$doc_key_values
    }
}"

doCurlP "$cmd" "$payload" $*
