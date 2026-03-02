#!/bin/bash
set -e

if [ -n "$FORGEJO_RUNNER_SECRET" ]; then
  /bin/forgejo-runner create-runner-file --connect --secret $FORGEJO_RUNNER_SECRET --instance $FORGEJO_INSTANCE_URL

fi
while : ; do forgejo-runner daemon ; sleep 1 ; done
