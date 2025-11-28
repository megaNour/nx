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
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XDELETE mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -p, --path PATH                  Path relative to workspace root
  -u, --url  URL                   Server URL

Examples:
  $NAME -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

eval set -- "$(getopt -o dhp:u: -l dry-run,dryrun,dryRun,help,path:,url: -- "$@")"

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
  -u | --url)
    nuxeo_url=${2:-$NUXEO_URL}
    shift
    ;;
  -X | --request)
    set -- -X # setup for failure
    break
    ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

for arg in "$@"; do
  case "$arg" in
  -X* | --request*) printf '%s\n' "-X, --request not allowed in -XDELETE mode. Quitting..." && exit 1 ;;
  --) break ;; # in case we non-curl args after another separator...
  esac
done

# check the obtained values
nuxeo_url=u${nuxeo_url:-"localhost:8080"}

cmd='curl $@ -XDELETE -u "${NUXEO_CREDENTIALS#-u}" "$nuxeo_url/nuxeo/api/v1/path/default-domain/workspaces/$doc_path"'

shout 5 "${_yel}$cmd"
[ -z "$dry_run" ] && eval "$cmd"
