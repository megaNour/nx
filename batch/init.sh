#!/usr/bin/env dash

printHelp() {
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

eval set -- "$(getopt -o "h,p:" -l "help,provider:" -- "$@")"
maybeHelp "$1"

provider=${1:-default}
curl -s -XPOST "$NUXEO_CREDENTIALS" "$NUXEO_URL/nuxeo/api/v1/upload/new/$provider" | jq -r .batchId
