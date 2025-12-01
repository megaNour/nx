#!/bin/sh

doCurlP() {
  cmd=$1 && payload=$2 && shift 2
  [ ! -t 0 ] && maybe_pipe="cat | " || :

  shout 5 "${_yel}curl -u \"\$NUXEO_CREDENTIALS\"${*:+ $*} $cmd
${_grn}$payload"

  [ -z "$dry_run" ] && eval "${maybe_pipe}curl -u \"${NUXEO_CREDENTIALS#-u}\"${*:+ $*} ${cmd##*_CREDENTIALS\" } \"\$payload\"" || :
}
