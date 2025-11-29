#!/bin/sh

printHelp() {
  cat <<EOF
Description:
  Initializes a batch to upload files.
  Then, you can call "${NAME% *} upload" to send files.

Usage:
  $NAME init [PROVIDER]

Environments:
  NUXEO_URL           Example: "localhost:8080".
  NUXEO_CREDENTIALS   Used by curl to authenticate you.
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

maybeHelp "${1:-no}" # trigger help only if a help hint is given

args="$(getopt -o "${G_global_short_flags}h" -l "$G_global_long_flags,help" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  --)
    shift
    break
    ;;
  *) ;; # ignore unhandled flags without error and clear $@ from them
  esac
  shift
done

[ -n "$2" ] && infoHelp || : # make it clear we don't take a list of ids to query info for
rejectForbiddenFlags "$@"

[ -n "$1" ] && provider=$1 || :
cmd="-XPOST${*:+ $*} \"$NUXEO_URL/nuxeo/api/v1/upload/new/${provider:-default}\""

doCurl "$cmd" $*
