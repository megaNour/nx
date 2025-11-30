#!/bin/sh

printHelp() {
  cat <<EOF
Description:
  Deletes a BATCH_ID or a specific FILE_IDX in the batch.

Usage:
  $NAME BATCH_ID [FILE_INDEX]

  BATCH_ID     A Nuxeo batch id. You can get one with ${NAME% *} init.
  FILE_INDEX   If provided, only this file will be used in the operation.

Environments:
  NUXEO_URL           Example: "localhost:8080".
  NUXEO_CREDENTIALS   Used by curl to authenticate you.
  SHOUT_LEVEL >= 5    prints curl

Options:
  --  [CURL_OPTION...]              No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un        Do not execute the curl command.
  -h, --help                        Show this help message and exit.
  -i, --index, --file-[idx|index]   A file index to scope the operation to.

Examples:
  $NAME batchId-... 0 # only use file 0 of batchId-...
EOF
}

maybeHelp "$@"

args="$(getopt -o "${G_global_short_flags}hi:" -l "$G_global_long_flags,help,index:,file-index:,file-idx:" -- "$@")"
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -i | --index | --file-idx | --file-index)
    [ -n "$file_idx" ] && shoutf "${_mag}Only the last -i value will be taken into account!" || :
    file_idx=/$2
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

batch_id=${1:?${_red}param 1: batch Id required.$_def}
shift

cmd="-XDELETE http://$NUXEO_URL/nuxeo/api/v1/upload/$batch_id$file_idx"
doCurl "$cmd" "$@"
