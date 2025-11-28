#!/bin/sh

doCurl() {
  cmd=$1 && shift

  shout 5 "${_yel}curl -u \"\$NUXEO_CREDENTIALS\"${*:+ $*} $cmd"
  [ -z "$dry_run" ] && eval "curl -u \"${NUXEO_CREDENTIALS#-u}\"${*:+ $*} ${cmd##*_CREDENTIALS\" }" || :
}
