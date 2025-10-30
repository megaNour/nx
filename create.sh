#!/usr/bin/env dash

set -e

NAME=${NAME:-$0}

printHelp() {
  cat <<EOF
Usage: $NAME [OPTIONS]

Options:

  -h, --help                  Show this help message and exit
  -d, --dry-run, --dry[Rr]un  Do not execute the curl command
  -s, --silent                Don't print the curl command
  -n, --name --title NAME     Document name (title)
  -p, --path PATH             Path relative to workspace root
  -t, --type TYPE             Document type
  -u, --url  URL              Server URL

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

# Convert input to proper case and lowercase on two output lines per input line
# Example: "fiLe" -> first line: "File", second line: "file"
properAndLowercase() {
  awk '{
    print toupper(substr($0,1,1)) tolower(substr($0,2))
    print tolower($0)
  }'
}

eval set -- "$(getopt -o hdn:p:st:u: -l dry-run,dryrun,dryRun,help,name:,path:,silent,type:,url: -- "$@")"

while true; do
  case "$1" in
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
  -s | --silent)
    silent=1
    ;;
  -t | --type)
    doc_type=$2
    shift
    ;;
  -u | --url)
    nuxeo_url=$2
    shift
    ;;
  -h | --help)
    printHelp
    exit 0
    ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

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

cmd=$(
  cat <<EOF
curl $@ -H "Content-type: application/json" "$NUXEO_CREDENTIALS" "$nuxeo_url/nuxeo/api/v1/path/default-domain/workspaces/$doc_path" -d "{
    \"entity-type\": \"document\",
    \"name\":\"$doc_name\",
    \"type\": \"$doc_type\",
    \"properties\": {
        \"dc:title\": \"$doc_name\",
        \"common:icon\": \"/icons/$doc_icon.gif\"
    }
}"
EOF
)

if [ -z "$silent" ]; then
  printf '%s%s%s\n' "$(tput setaf 11)" "$cmd" "$(tput sgr0)" >&2
fi
if [ -z "$dry_run" ]; then
  eval "$cmd"
fi
