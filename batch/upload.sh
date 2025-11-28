#!/usr/bin/env dash

printHelp() {
  cat <<EOF
this is upload help
EOF
}

maybeHelp "$1"

batch_id=${1:?param 1: batch Id required. Please init batch}
file_index=${2:?param 2: file index in the batch required}

curl -s "$NUXEO_CREDENTIALS" "$NUXEO_URL/nuxeo/api/v1/upload/$batch_id/$file_index" \
  -H "X-File-Name: bananas.pdf" \
  -H "X-File-Type: application/pdf" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @/Users/Nour.Alkotob/Documents/PERSONAL/banana-description.pdf
