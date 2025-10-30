#!/bin/sh

set -e

export NAME=nx
ENTRY=$(CDPATH="" cd -- "$(dirname "$0")" && pwd)
export ENTRY
. "$ENTRY/lib/shout/shout.sh"

nxHelp() {
  cat <<EOF
$bold$blue
            L.
            EW:        ,ft
            E##;       t#E
            E###t      t#E :KW,      L
            E#fE#f     t#E  ,#W:   ,KG
$cyan         –   E#  D#G  $default  t#t $cyan   ;#W. jWi —— – ° >$blue
            E#t  f#E.  t#E    i#KED.
$cyan -.|  .--  i#t $default  t#K: t#E $cyan    L#W. ==— -$blue
            E#t    ;#W,t#E   .GKj#K.
$cyan        _-—  #t     :${default}K#D#${cyan}E  iWf  i#K. >$blue
            E#t      .E##E LK:    t#E
            ..         G#E i       tDj
                        fE
                         ,
$default
                      v0.1.0$reset

Description:
  Handy commands to run your Nuxeo and perform CRUD.

Usage:
  $NAME [COMMAND [COMMAND_OPTION...] [COMMAND_ARG...]...]

Environments:
  NUXEO_CTL            Path to nuxeoctl.
  NUXEO_CREDENTIALS    Used by curl to authenticate.

Commands:
  [ANYTHING_UNLISTED]  Display contextual help.
  console              Perform $NUXEO_CTL console.
  start                Perform $NUXEO_CTL start.
  stop                 Perform $NUXEO_CTL stop.
  create               Create a document.
  batch                Init a batch, upload binaries, create corresponding docs.

Examples:
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
  "$NUXEO_CTL $command"
  ;;
*)
  ENTRY=$(CDPATH="" cd -- "$(dirname "$0")" && pwd)
  command=$ENTRY/${command}.sh
  if [ -f "$command" ]; then
    "$command" "$@"
  else
    nxHelp
  fi
  ;;
esac
