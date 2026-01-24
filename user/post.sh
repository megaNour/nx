#!/bin/sh

set -e

printHelp() {
  cat <<EOF
Usage: $NAME [OPTION...] NAME MAIL PASSWORD [-- [CURL_OPTION...]]
  NAME      The user name (distinct from user id) for the user/group to create.
  EMAIL     Defaults to "test@dev.null".
  PASSWORD  Defaults to "Administrator".

Environment:
  NUXEO_URL
  NUXEO_CREDENTIALS   in a <id>:<pwd>
  SHOUT_LEVEL >= 5    prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command.
  -h, --help                       Show this help message and exit.
  -u, --uid                        a UID for the user.
  -f, --first-name                 Will be the value of NAME if not provided.
  -l, --last-name                  Will be the value of NAME if not provided.

Examples:
  $NAME -g my_group -- -v
EOF
}

maybeHelp "$@"

# do it separately from eval or it will swallow any error code
args=$(getopt -o "dhu:f:l:" -l "dryrun,dryRun,dry-run,help,user-name:,first-name:,last-name:" -- "$@")
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  -u | --user-id)
    uid=$2
    shift
    ;;
  -f | --first-name)
    first_name=$2
    shift
    ;;
  -l | --last-name)
    last_name=$2
    shift
    ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

rejectForbiddenFlags "$@"

name=${1:?${_red}param 1: missing name.$_def}
shift=1
email=${2:-test@dev.null}
[ "$email" = "$2" ] && shift=$((shift + 1))
password=${3:-Administrator}
[ "$password" = "$3" ] && shift=$((shift + 1))
shift $shift

cmd="-X POST -H \"Content-type: application/json\" \"$NUXEO_URL/nuxeo/api/v1/user\" -d"

# TODO: Add flags to parameterize that correctly
uid=${uid:-name}
user_name=${user_name:-name}
first_name=${first_name:-name}
last_name=${last_name:-name}
company=CVS

payload='{
  "entity-type": "user",
  "id": "'$uid'",
  "properties": {
    "username": "'$name'",
    "firstName": "'$first_name'",
    "lastName": "'$last_name'",
    "company": "'$company'",
    "email": "'$email'",
    "password": "'$password'"
  }
}'

doCurlP "$cmd" "$payload" $*
