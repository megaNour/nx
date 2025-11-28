#!/bin/sh

_autosource() {
  _autosource_file=${1:?command name required for autosourcing}
  _autosource_fn=${_autosource_file##*/}
  _autosource_fn=${_autosource_fn%.sh}

  [ -r "$_autosource_file" ] || {
    printf "${_red}autosource for %s not found!\n" "$_autosource_file" 2>/dev/null
    return 1
  }

  eval "$_autosource_fn() {
    unset -f $_autosource_fn; . \"$_autosource_file\"; $_autosource_fn \"\$@\"
  }"
}
