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
file_type=${3:?${_red}param 3: mime-type value required for the X-File-Type header, e.g. "application/pdf"$_def}
shift=4
if [ -t 0 ]; then      # no pipe
  if [ -n "$5" ]; then # file_name and file_location provided
    file_name=$4       # file_name is first
    payload=$5
    shift=5
  elif [ -r "$4" ]; then # no file_name, just a FS location
    file_name=${4##*/}   # then we can deduce a filename
    payload=$4
  else
    shoutf "${_red}In positional mode:
you can upload a file by giving its location on FS as param 4
or
you can upload a file by giving its name as param 4 and any location as param 5
${_def}"
    exit 1
  fi
else
  file_name=${4:?${_red}param 4: file-name is required in pipe mode.$_def}
  payload=@-
fi
shift $shift

cmd="$NUXEO_URL/nuxeo/api/v1/upload/$batch_id/$file_index \
  -H \"X-File-Name: $file_name\" \
  -H \"X-File-Type: $file_type\" \
  -H \"Content-Type: application/octet-stream\" \
  --data-binary"

if [ -t 0 ]; then
  doCurlP "$cmd" "$payload" $*
else
  cat | doCurlP "$cmd" "$payload" $*
fi
