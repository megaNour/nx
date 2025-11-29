#!/bin/sh

G_global_short_flags="d"
G_global_long_flags="dryrun,dryrun,dry-run"

for arg in "$@"; do
  case "$arg" in -d | --dry-run | --dry[Rr]un) dry_run=1 ;; esac
done
