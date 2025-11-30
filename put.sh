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
-p, --path PATH                  Path relative to workspace root
-t, --type TYPE                  Document type

Examples:
$NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

maybeHelp "$@"

# do it separately from eval or it will swallow any error code
args="$(getopt -o ${G_global_short_flags}hk:n:p:t: -l $G_global_long_flags,help,key-value:,name:,path:,type: -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -k | --key-value)
    doc_key_values="${doc_key_values+$doc_key_values,}
      $2"
    shift
    ;;
  -n | --name)
    doc_name=$2
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
  *) ;; # ignore unhandled flags without error and clear $@ from them
  esac
  shift
done

rejectForbiddenFlags "$@"

target=${1:?param 1: ${_red}missing path to document to update.$_def}
shift

# check the obtained values
doc_type=${doc_type:-"File"}
doc_name=${doc_name:-"my_test_$doc_type"}
base_path=${doc_path-"default-domain/workspaces/"}

sanitizePathSegment base_path # if a value was given, we still need to sanitize

# normalize the doc_type and deduce doc_icon
{
  IFS= read -r doc_type
  read # ignore the lower case
} <<EOF
$(printf '%s\n' "$doc_type" | properAndLowercase)
EOF

cmd="-XPUT -H \"Content-type: application/json\" \"$NUXEO_URL/nuxeo/api/v1/path/$base_path$target\" -d"
payload="{
    \"entity-type\": \"document\",
    \"name\":\"$doc_name\",
    \"type\": \"$doc_type\",
    \"properties\": {$doc_key_values
    }
}"

doCurlP "$cmd" "$payload" $*
