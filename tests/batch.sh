#!/bin/sh

bid=$(nx batch init -- -s | jq -r .batchId)
nx batch upload "$bid" 0 text/markdown my_test_markdown.md <<EOF
# this is a test document

This is a heredoc sent as part of a test script.

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
nx batch create test_ws "$bid" #-- --trace-ascii /dev/stderr
