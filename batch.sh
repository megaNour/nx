#!/bin/sh

set -e

NAME="${NAME:-$0} batch"

batchHelp() {
  cat <<EOF
Usage:
  $NAME [COMMAND... [COMMAND_OPTIONS...] [COMMAND_ARG...]...]

Commands:
  [ANYTHING_UNLISTED]  Get contextual help for this command.
  init                 Init a batch.
  info                 Get batch info.
  upload               Upload a file into the batch.
  create               Create one document per uploaded file.
  repeat               Init a batch, upload a file repeatedly to create docs.

Examples:
  # display $NAME init help
  $NAME init help
  # create a document with options
  $NAME create -n my_doc -p my_workspace -t workspace -u localhost:8080
EOF
}

initHelp() {
  cat <<EOF
Description:
  Initializes a batch to upload files.
  Then, you can call "${NAME% *} upload" to send files.

Usage:
  $NAME init

Environments:
  NUXEO_URL            Example: "localhost:8080".
  NUXEO_CREDENTIALS    Used by curl to authenticate you.
EOF
}

init() {
  if [ -n "$1" ]; then
    initHelp
    exit 0
  fi
  curl -s -XPOST "$NUXEO_CREDENTIALS" "$NUXEO_URL/nuxeo/api/v1/upload/new/default" | jq -r .batchId
}

infoHelp() {
  cat <<EOF
Description:
  Retrieve info for a specific batch.

Usage:
  $NAME BATCH_ID
  $NAME [help|-h|--help]

Environments:
  NUXEO_URL            Example: "localhost:8080".
  NUXEO_CREDENTIALS    Used by curl to authenticate you.
EOF
}

info() {
  if [ -n "$2" ]; then
    infoHelp
  else
    batch_id=${1:-help}
    case "$batch_id" in
    help | -h | --help)
      infoHelp
      ;;
    *)
      curl "$NUXEO_CREDENTIALS" "$NUXEO_URL/nuxeo/api/v1/upload/$batch_id"
      ;;
    esac
  fi
}

upload() {
  batch_id=${1:?param 1: batch Id required. Please init batch}
  file_index=${2:?param 2: file index in the batch required}

  curl -s "$NUXEO_CREDENTIALS" "$NUXEO_URL/nuxeo/api/v1/upload/$batch_id/$file_index" \
    -H "X-File-Name: bananas.pdf" \
    -H "X-File-Type: application/pdf" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @/Users/Nour.Alkotob/Documents/PERSONAL/banana-description.pdf
}

create() {
  batch_id=${1:?param 1: batch Id required. Please init batch}
  curl "$NUXEO_CREDENTIALS" "http://$NUXEO/nuxeo/api/v1/upload/$batch_id/execute/FileManager.Import" \
    --json '{ "params": { "context": { "currentDocument": "/default-domain/workspaces/test" } }, "context": { "currentDocument": "/default-domain/workspaces/test" } }'
}

if [ -n "$1" ]; then
  command=$1
  shift
fi
if type "$command" >/dev/null 2>&1; then
  "$command" "$@"
else
  batchHelp
fi
