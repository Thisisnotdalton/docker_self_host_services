#!/bin/bash
set -e

if [ -n "$FORGEJO_RUNNER_SECRET" ]; then
    forgejo forgejo-cli actions register --name "${FORGEJO_RUNNER_NAME:-runner}" --secret $FORGEJO_RUNNER_SECRET
fi