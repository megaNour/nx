#!/usr/bin/env dash

printHelp() {
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

maybeHelp "$1"

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
