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

args="$(getopt -o "dhn:" -l "dryrun,dryRun,dry-run,help,name:,doc-name:,document-name:" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  -n | --name | --doc-name | --document-name)
    doc_name=$2
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

batch_id=${1:?${_red}param 1: batch Id required. Consider using ${NAME% *} init${_def}}
file_index=${2:?${_red}param 2: file index in the batch required${_def}}
mime_type=${3:?${_red}param 3: mime-type value required for the X-File-Type header, e.g. "application/pdf"${_def}}
shift=3

if [ ! -t 0 ]; then
  file_path=@- # taking from stdin
  doc_name=${doc_name:-piped_content.$$.txt}
elif [ -r "$4" ]; then
  file_path=@${4:?${_red}param 4: file-path required in interactive mode (no pipe)${_def}}
  doc_name=${doc_name:-${4##/}}
  shift=4
else
  shoutf "${_red}No file provided, need either a file location or stdin"
  exit 1
fi

shift $shift

cmd="$NUXEO_URL/nuxeo/api/v1/upload/$batch_id/$file_index \
  -H \"X-File-Name: $doc_name\" \
  -H \"X-File-Type: $mime_type\" \
  -H \"Content-Type: application/octet-stream\" \
  --data-binary"

if [ -t 0 ]; then
  doCurlP "$cmd" "$file_path" $*
else
  cat | doCurlP "$cmd" "$file_path" $*
fi
