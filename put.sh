#!/usr/bin/env dash

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
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPUT mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -n, --name --title NAME          Document name (title)
  -p, --path PATH                  Path relative to workspace root
  -t, --type TYPE                  Document type
  -u, --url  URL                   Server URL

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

maybeHelp "$1"

# Convert input to proper case and lowercase on two output lines per input line
# Example: "fiLe" -> first line: "File", second line: "file"
properAndLowercase() {
  awk '{
    print toupper(substr($0,1,1)) tolower(substr($0,2))
    print tolower($0)
  }'
}

# do it separately from eval or it will swallow any error code
args="$(getopt -o dhn:p:t:u: -l dry-run,dryrun,dryRun,help,name:,path:,type:,url: -- "$@")"
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
  -n | --name)
    doc_name=$2
    shift
    ;;
  -p | --path)
    doc_path=$2
    shift
    ;;
  -t | --type)
    doc_type=$2
    shift
    ;;
  -u | --url)
    nuxeo_url=$2
    shift
    ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

. "$ENTRY/utils/reject_forbidden_flags.sh"

# check the obtained values
doc_type=${doc_type:-"File"}
doc_name=${doc_name:-"my_test_$doc_type"}
nuxeo_url=${nuxeo_url:-"localhost:8080"}

# normalize the doc_type and deduce doc_icon
{
  IFS= read -r doc_type
  IFS= read -r doc_icon
} <<EOF
$(printf '%s\n' "$doc_type" | properAndLowercase)
EOF

cmd='curl $@ -XPUT -H "Content-type: application/json" -u "${NUXEO_CREDENTIALS#-u}" "$nuxeo_url/nuxeo/api/v1/path/default-domain/workspaces/$doc_path" -d \"$payload\"'
payload="{
    \"entity-type\": \"document\",
    \"name\":\"$doc_name\",
    \"type\": \"$doc_type\",
    \"properties\": {
      $doc_properties
    }
}"

shout 5 "${_yel}$cmd${_grn}$payload"
[ -z "$dry_run" ] && eval "$cmd" || :
