#!/bin/sh

# NOTE: sanitize _sanPS_base_path so it never starts with a '/' but always ends with a '/'.
sanitizePathSegment() {
  _sanPS_var_name=$1
  eval "_sanPS_base_path=\$$1"              # copy any given value name
  if [ "${_sanPS_base_path+x}" != x ]; then # not empty, but totally unset, means default
    _sanPS_base_path=${_sanPS_base_path-"default-domain/workspaces/"}
  else
    while true; do
      case "$_sanPS_base_path" in
      /)
        unset _sanPS_base_path # we don't want to return a dangling '/'
        break
        ;;
      /*/) _sanPS_base_path=${_sanPS_base_path#/} ;; # remove leader
      /*) _sanPS_base_path=${_sanPS_base_path#/}/ ;; # remove leader and add a trailer
      *//) _sanPS_base_path=${_sanPS_base_path%/} ;; # remove multi-trailer
      */) break ;;                                   # do nothing everything is fine
      *) _sanPS_base_path=$_sanPS_base_path/ ;;      # add the missing trailer
      esac
    done
  fi
  eval "$1=$_sanPS_base_path" # return the value
}

# for test in "" / baby/bebe /baby/bebe /baby/bebe/ /baby/bebe/// //baby/bebe///; do
#   coco=$test
#   sanitizePathSegment coco
#   printf '%s\t -> %s\n' "$test" "$coco"
# done
