#!/usr/bin/env bash
set -euo pipefail

: "${HOST:?HOST environment variable is required}"
: "${DOMAIN:?DOMAIN environment variable is required}"
: "${KEYCLOAK_ROUTE_PREFIX:?KEYCLOAK_ROUTE_PREFIX environment variable is required}"

KEYCLOAK_URL="${KEYCLOAK_URL:-https://${HOST}.${DOMAIN}/${KEYCLOAK_ROUTE_PREFIX}}"
KEYCLOAK_READY_URL="${KEYCLOAK_READY_URL:-${KEYCLOAK_URL}/health/ready}"

WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-180}"
WAIT_SLEEP_SECONDS="${WAIT_SLEEP_SECONDS:-2}"
WAIT_POST_READY_SECONDS="${WAIT_POST_READY_SECONDS:-30}"

# Default is insecure to support self-signed/local TLS; set CURL_TLS_FLAGS="" in prod if desired.
CURL_TLS_FLAGS="${CURL_TLS_FLAGS:---insecure}"

echo "Waiting for Keycloak readiness at: ${KEYCLOAK_READY_URL}"
deadline="$(( $(date +%s) + WAIT_TIMEOUT_SECONDS ))"
now="$(date +%s)"
waiting=1
while [ "${now}" -le "${deadline}" ] && [ $waiting -gt 0 ]; do
  if curl -fsS ${CURL_TLS_FLAGS} "${KEYCLOAK_READY_URL}" >/dev/null 2>&1; then
    echo "Keycloak is ready."
    waiting=0
  fi
  sleep "${WAIT_SLEEP_SECONDS}"
  now="$(date +%s)"
done
if [ "${now}" -ge "${deadline}" ]; then
  echo "Timed out after ${WAIT_TIMEOUT_SECONDS}s waiting for Keycloak at ${KEYCLOAK_READY_URL}" >&2
  exit 1
fi
deadline="$(( $(date +%s) + WAIT_POST_READY_SECONDS ))"
echo "Waiting ${WAIT_POST_READY_SECONDS}s before exiting to allow time to apply OpenTofu changes for Keycloak at ${KEYCLOAK_URL}" >&2
while [ "${now}" -le "${deadline}" ]; do
  now="$(date +%s)"
  sleep "${WAIT_SLEEP_SECONDS}"
done
echo "Waited ${WAIT_POST_READY_SECONDS}s before exiting to allow time to apply OpenTofu changes for Keycloak at ${KEYCLOAK_URL}" >&2