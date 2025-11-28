#!/bin/sh

printHelp() {
  cat <<EOF
this is the create help
EOF
}

maybeHelp "$1"

batch_id=${1:?param 1: batch Id required. Please init batch}
curl "$NUXEO_CREDENTIALS" "http://$NUXEO/nuxeo/api/v1/upload/$batch_id/execute/FileManager.Import" \
  --json '{ "params": { "context": { "currentDocument": "/default-domain/workspaces/test" } }, "context": { "currentDocument": "/default-domain/workspaces/test" } }'
