#!/bin/sh

printHelp() {
  cat <<EOF
Description:
  Retrieve info for a specific batch.

Usage:
  $NAME BATCH_ID FILE_INDEX FILE MIMETYPE
  $NAME [help|-h|--help]

Environments:
  NUXEO_URL            Example: "localhost:8080".
  NUXEO_CREDENTIALS    Used by curl to authenticate you.
  SHOUT_LEVEL >= 5     prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit

Examples:
  $NAME -dp foo
EOF
}

maybeHelp "$@"

args="$(getopt -o "dh" -l "dryrun,dryRun,dry-run,help" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

rejectForbiddenFlags "$@"

batch_id=${1:?${_red}param 1: batch Id required. Consider using ${NAME% *} init$_def}
file_index=${2:?${_red}param 2: file index in the batch required$_def}
file=${3:?${_red}param 3: file location required.$_def}
file_type=${4:?${_red}param 4: mime-type value required for the X-File-Type header, e.g. "application/pdf"$_def}
file_name=${file##*/}
shift 4

cmd="$NUXEO_URL/nuxeo/api/v1/upload/$batch_id/$file_index \
  -H \"X-File-Name: $file_name\" \
  -H \"X-File-Type: $file_type\" \
  -H \"Content-Type: application/octet-stream\" \
  --data-binary"
payload="\"@/Users/Nour.Alkotob/Documents/PERSONAL/$file\""

doCurlP "$cmd" "$payload" $*
