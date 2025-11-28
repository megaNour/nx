#!/usr/bin/env dash

printHelp() {
  cat <<EOF
Description:
  Retrieve info for a specific batch.

Usage:
  $NAME BATCH_ID
  $NAME [help|-h|--help]

Environments:
  NUXEO_URL            Example: "localhost:8080".
  NUXEO_CREDENTIALS    Used by curl to authenticate you.
  SHOUT_LEVEL >= 5    prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit
  -p, --provider PROVIDER          Also known as upload handler

Examples:
  $NAME -dp foo
EOF
}

maybeHelp "$1"

args="$(getopt -o "d,h" -l "dryrun,dryRun,dry-run,help" -- "$@")"
eval "set -- $args"

while [ $# -gt 0 ]; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dryrun | --dry-run | --dryRun)
    dry_run=1
    shift
    ;;
  --)
    shift
    break
    ;;
  esac
done

[ -n "$2" ] && infoHelp || : # make it clear we don't take a list of ids to query info for
. "$ENTRY/utils/reject_forbidden_flags.sh"

batch_id=${1:?missing batch id}
doCurl "$NUXEO_URL/nuxeo/api/v1/upload/$batch_id" $*
