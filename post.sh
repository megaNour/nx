#!/bin/sh

set -e

NAME=${NAME:-$0}

printHelp() {
  cat <<EOF
Usage: $NAME [OPTIONS] DOC_PATH [-- [CURL_OPTION...]]
  DOC_PATH   target doc location from '/default-domain/workspaces/'.

Environments:
  NUXEO_URL
  NUXEO_CREDENTIALS   in a <id>:<pwd>
  SHOUT_LEVEL >= 5    prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -n, --name --title NAME          Document name (title)
  -p, --path PATH                  Path relative to workspace root
  -t, --type TYPE                  Document type
  -k, --key-value [JSON_KV]        Repeatably add a key:value pair, must be stringified.
                                     i.e. "\"my:key\": \"my_value\""


Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

maybeHelp "$1"

# do it separately from eval or it will swallow any error code
args=$(getopt -o ${G_global_short_flags}k:hn:p:t: -l $G_global_long_flags,key-value:,help,name:,path:,type: -- "$@")
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -n | --name)
    doc_name=$2
    shift
    ;;
  -p | --path)
    doc_path=${2:?no doc path provided}
    shift
    ;;
  -k | --key-value)
    doc_key_values="$doc_key_values,
        $2"
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

# check the obtained values
doc_type=${doc_type:-"File"}
doc_name=${doc_name:-"my_test_$doc_type"}

# normalize the doc_type and deduce doc_icon
{
  IFS= read -r doc_type
  IFS= read -r doc_icon
} <<EOF
$(printf '%s\n' "$doc_type" | properAndLowercase)
EOF

cmd="-H \"Content-type: application/json\"  \"$NUXEO_URL/nuxeo/api/v1/path/default-domain/workspaces/$doc_path\" -d"
payload="{
    \"entity-type\": \"document\",
    \"name\":\"$doc_name\",
    \"type\": \"$doc_type\",
    \"properties\": {
        \"dc:title\": \"$doc_name\",
        \"common:icon\": \"/icons/$doc_icon.gif\"$doc_key_values
    }
}"

doCurlP "$cmd" "$payload" $*
