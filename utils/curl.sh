#!/bin/sh

[ -z "$dry_run" ] && eval "curl \"$NUXEO_CREDENTIALS\" $@ ${cmd##*_CREDENTIALS\" }" || :
