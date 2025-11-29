#!/bin/sh

printHelp() {
  cat <<EOF
this is the create help
EOF
}

maybeHelp "$1"

args="$(getopt -o "$G_global_short_flags,h,i:" -l "$G_global_long_flags,help,index:,file-index:,file-idx:" -- "$@")"
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

target=${1:?${_red}param 2: file path from /default-domain/workspaces/ required.$_def}
batch_id=${2:?${_red}param 1: batch Id required. Consider using $($NAME init)$_def}
shift 2

cmd="http://$NUXEO_URL/nuxeo/api/v1/upload/$batch_id$file_idx/execute/FileManager.Import --json"
payload="{ \"params\": { \"context\": { \"currentDocument\": \"/default-domain/workspaces/$target\" } } }"
doCurlP "$cmd" "$payload" "$@"
