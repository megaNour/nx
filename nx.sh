#!/bin/sh

set -e

export NAME=nx
ENTRY=$(CDPATH="" cd -- "$(dirname "$0")" && pwd)
export ENTRY

nxHelp() {
  cat <<EOF
$bold$_blu
            L.
            EW:        ,ft
            E##;       t#E
            E###t      t#E :KW,      L
            E#fE#f     t#E  ,#W:   ,KG
$_cya         –   E#  D#G  $_def  t#t $_cya   ;#W. jWi —— – ° >$_blu
            E#t  f#E.  t#E    i#KED.
$_cya -.|  .--  i#t $_def  t#K: t#E $_cya    L#W. ==— -$_blu
            E#t    ;#W,t#E   .GKj#K.
$_cya        _-—  #t     :${_def}K#D#${_cya}E  iWf  i#K. >$_blu
            E#t      .E##E LK:    t#E
            ..         G#E i       tDj
                        fE
                         ,
$_def
                    $_BLA ${_cya}v0.1.0 $_res

${_mag}Description:$_res
  Handy commands to run your Nuxeo and perform test CRUD.

${_mag}Usage:$_res
  $_yel$NAME [COMMAND [COMMAND_OPTION...] [COMMAND_ARG...]...]$_res

${_mag}Environments:$_res
  ${_yel}NUXEO_HOME$_res           Absolute path to your unzipped nuxeo.
  ${_yel}NUXEO_CREDENTIALS$_res    Used by curl to authenticate.

${_mag}COMMAND:$_res
  ${_yel}[ANYTHING_UNLISTED]$_res  Display contextual help.
  ${_yel}console$_res              Perform nuxeoctl console.
  ${_yel}start$_res                Perform nuxeoctl start.
  ${_yel}stop$_res                 Perform nuxeoctl stop.
  ${_yel}post$_res                 Create a document.
  ${_yel}get$_res                  Read a document.
  ${_yel}batch$_res                Init a batch, upload binaries, create corresponding docs.

${_mag}Examples:$_res
  # display help specific to the init subcommand of the batch subcommand.
  $NAME batch init help
  # start your Nuxeo instance in console mode
  $NAME console
  # create a document with options
  $NAME create -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

command=$1
if [ -n "$1" ]; then shift; fi

case "$command" in
console | start | stop)
  "$NUXEO_HOME/bin/nuxeoctl" $command
  ;;
*)
  ENTRY=$(CDPATH="" cd -- "$(dirname "$0")" && pwd)
  . "$ENTRY/lib/shout/colors.sh"
  . "$ENTRY/lib/shout/libshout.sh"
  command=$ENTRY/${command}.sh
  if [ -f "$command" ]; then
    "$command" "$@"
  else
    nxHelp
  fi
  ;;
esac
