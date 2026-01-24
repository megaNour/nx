#!/bin/sh

set -e

printHelp() {
  cat <<EOF
Usage: $NAME [OPTION...] NAME [-- [CURL_OPTION...]]
  NAME   the name for the group to create.

Environment:
  NUXEO_URL
  NUXEO_CREDENTIALS   in a <id>:<pwd>
  SHOUT_LEVEL >= 5    prints curl commands in yellow

Options:
  --  [CURL_OPTION...]             No -X|--request allowed. Already in -XPOST mode.
  -d, --dry-run, --dry[Rr]un       Do not execute the curl command
  -h, --help                       Show this help message and exit.
  -l, --label                      Label for the group being created.
  -g, --member-groups              Groups to add as members in the form: "alif,ba,ta"
                                     can be used multiple times: -g alif,ba -g ta,tha
  -u, --member-users               Users to add as members in the form: "alif,ba,ta"
                                     can be used multiple times: -u alif,ba -u ta,tha


Examples:
  $NAME -l my_label my_group -g alif,ba -g ta -u foo,bar -u baz -- -v
EOF
}

maybeHelp "$@"

# do it separately from eval or it will swallow any error code
args=$(getopt -o "dhl:g:u:" -l "dryrun,dryRun,dry-run,help,label:,member-groups:,member-users:" -- "$@")
eval "set -- $args"

while true; do
  case "$1" in
  -h | --help)
    printHelp
    exit 0
    ;;
  -d | --dry-run | --dry[Rr]un) dry_run=1 ;;
  -l | --label)
    label=$2
    shift
    ;;
  -g | --member-groups)
    if [ "$member_groups" ]; then member_groups=$member_groups,${2}; else member_groups=${2}; fi
    shift
    ;;
  -u | --member-users)
    if [ "$member_users" ]; then member_users=$member_users,${2}; else member_users=${2}; fi
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
shift

{
  IFS='' read -r member_users
  IFS='' read -r member_groups
} <<EOF
$(printf '%s\n%s\n' "$member_users" "$member_groups" | awk '{gsub(/,/, "\",\""); print "\"" $0 "\""}')
EOF

cmd="-X POST -H \"Content-type: application/json\" \"$NUXEO_URL/nuxeo/api/v1/group\" -d"

# TODO: Add flags to parameterize that correctly
label=$name

payload='{
  "entity-type": "group",
  "groupname": "'$name'",
  "grouplabel": "'$label'",
  "memberUsers": ['$member_users'],
  "memberGroups": ['$member_groups']
}'

doCurlP "$cmd" "$payload" $*
