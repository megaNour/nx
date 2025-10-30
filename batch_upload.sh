#!/bin/sh
# Trash and create test workspace
# upload 10 dummy files
# make documents out of it
set -e

NUXEO=localhost:8080
CREDS="-u Administrator:Administrator"

create_workspace() {
  curl $CREDS "http://$NUXEO/nuxeo/api/v1/path/default-domain/workspaces" \
    -H 'Content-Type: application/json' \
    -d '{"entity-type":"document","repository":"default","type":"Workspace", "name":"test"}'
}

trash_workspace() {
  curl -XDELETE $CREDS "http://$NUXEO/nuxeo/api/v1/path/default-domain/workspaces/test"
}

# really delete, but needs root doc id or something
# delete_workspace() {
#   curl $CREDS "http://$NUXEO/nuxeo/api/v1/search/pp/advanced_document_content/execute?currentPageIndex=0&offset=0&pageSize=40&ecm_parentId=ec386b12-bd13-4524-bb98-32d043f3fbfd&ecm_trashed=true"
# }

batch_init() {
  curl -s -X POST $CREDS "$NUXEO/nuxeo/api/v1/upload/new/default" | jq -r .batchId
}

batch_upload() {
  batch_id=${1:?param 1: batch Id required. Please init batch}
  file_index=${2:?param 2: file index in the batch required}

  curl -s $CREDS "$NUXEO/nuxeo/api/v1/upload/$batch_id/$file_index" \
    -H "X-File-Name: bananas.pdf" \
    -H "X-File-Type: application/pdf" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @/Users/Nour.Alkotob/Documents/PERSONAL/banana-description.pdf
}

batch_info() {
  batch_id=${1:?param 1: batch Id required. Please init batch}
  curl $CREDS "$NUXEO/nuxeo/api/v1/upload/$batch_id"
}

create_documents() {
  batch_id=${1:?param 1: batch Id required. Please init batch}
  curl $CREDS "http://$NUXEO/nuxeo/api/v1/upload/$batch_id/execute/FileManager.Import" \
    --json '{ "params": { "context": { "currentDocument": "/default-domain/workspaces/test" } }, "context": { "currentDocument": "/default-domain/workspaces/test" } }'
}

# for the first iteration, I don't remember if it errors if nothing to trash
# trash_workspace 2>/dev/null
#
# create_workspace

c=0
while [ "$c" -lt 10 ]; do
  batch_id=$(batch_init)
  i=1
  while [ "$i" -le 100 ]; do
    batch_upload "$batch_id" "$i"
    i=$((i + 1))
    batch_info "$batch_id"
  done
  c=$((c + 1))
done
create_documents "$batch_id"
