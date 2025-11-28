#!/bin/sh

maybeHelp() {
  [ -z "$1" ] || case "$1" in help | -h | --help) true ;; *) false ;; esac && printHelp && exit 0 || :
}

maybeHelp "$1"
