#!/bin/sh

rejectForbiddenFlags() {
  for arg in "$@"; do
    case "$arg" in
    -X* | --request*) printf '%s\n' "-X, --request is already managed, you cannot override it. Quitting..." && exit 1 ;;
    --) break ;; # in case we non-curl args after another separator...
    esac
  done
}
