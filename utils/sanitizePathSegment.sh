#!/bin/sh

# NOTE: sanitize _sanPS_base_path so it never starts with a '/' but always ends with a '/'.
# A prefix can be provided as $2. The prefix also acts as a default value
sanitizePathSegment() {
  eval "_sanPS_base_path=\$$1" # copy any given value name. If unset, set ' '
  while true; do
    case "$_sanPS_base_path" in
    "" | /)
      unset _sanPS_base_path
      break
      ;;
    /*/) _sanPS_base_path=${_sanPS_base_path#/} ;; # remove leader
    /*) _sanPS_base_path=${_sanPS_base_path#/}/ ;; # remove leader and add a trailer
    *//) _sanPS_base_path=${_sanPS_base_path%/} ;; # remove multi-trailer
    */) break ;;                                   # do nothing everything is fine
    *) _sanPS_base_path=$_sanPS_base_path/ ;;      # add the missing trailer
    esac
  done

  # return the value
  affectation=$(printf '%s="%s%s"\n\n' "$1" "$2" "$_sanPS_base_path")
  eval "$affectation"
}

# for test in "" / alfa/bravo /alfa/bravo /alfa/bravo/ /alfa/bravo/// //alfa/bravo///; do
#   actual=$test
#   sanitizePathSegment actual
#   printf '%s\t -> %s\n' "$test" "$actual"
# done
#
# sanitizePathSegment myVar "${myVar:+myVar/}"
# printf '%s\t -> %s\n' "unset_var" "$myVar# no default, no value, nothing"
#
# sanitizePathSegment myVar "alfa/bravo/"
# printf '%s\t -> %s\n' "unset_var" "$myVar # default"
#
# sanitizePathSegment myVar "${myVar:+myVar/}"
# printf '%s\t -> %s\n' "unset_var" "$myVar # default is a prefix if there is a value"
