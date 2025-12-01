#!/bin/sh

set -e

# test file name + pipe
bid=$(nx batch init -- -s | jq -r .batchId)
nx batch upload "$bid" 0 "text/markdown" "my_test_markdown_from_stdin.$$.md" -- -fsS <<EOF
# this is a test document

This is a heredoc sent as part of a test script.
The PID was **$$**

## Metadata

The metadata is lost because we use curl --data-binary.
To work around the loss of filename and mime type we use
\`\`\`sh
X-File-Type # you always provide thiS
X-File-Name # if the file you send is readable in your FS, this will be deduced
            # you can also override it with -n anyway
\`\`\`
## Stamp

it was generated at: $(date)
EOF
nx batch create test_ws "$bid" -- -fsS

# test file location on FS without providing a file-name
temp=$(mktemp /tmp/nx.test.without.file.name.$$.md)
echo "# this is a test document backed by a real file" >"$temp"

bid=$(nx batch init -- -s | jq -r .batchId)
nx batch upload "$bid" 0 "text/markdown" "$temp" -- -fsS
nx batch create "test_ws" "$bid" -- -fsS
rm "$temp"

# change name to distinguish
temp=$(mktemp /tmp/nx.test.with.name.$$.md)
echo "# this is a test document backed by a real file" >"$temp"

# test file location and file name
bid=$(nx batch init -- -s | jq -r .batchId)
nx batch upload "$bid" 0 "text/markdown" -n "my_test_markdown.${temp##*.}.md" "$temp" -- -fsS
nx batch create "test_ws" "$bid" -- -fsS
rm "$temp"
