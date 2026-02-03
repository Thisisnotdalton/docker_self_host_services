# ---------- Keycloak readiness ----------
KEYCLOAK_URL="https://${HOST}.${DOMAIN}/${}KEYCLOAK_ROUTE_PREFIX}"
KEYCLOAK_READY_URL="${KEYCLOAK_URL}/"health/ready
WAIT_TIMEOUT_SECONDS=180
WAIT_SLEEP_SECONDS= 2
# Set to empty if you have valid publicly trusted certs (e.g., prod with LE)
CURL_TLS_FLAGS= --insecure

@set -eu;
echo "Waiting for Keycloak readiness at: ${KEYCLOAK_READY_URL}";
deadline="$$(($$(date +%s) + $(WAIT_TIMEOUT_SECONDS)))";
while true; do
  if curl -fsS $(CURL_TLS_FLAGS) "$(KEYCLOAK_READY_URL)" >/dev/null 2>&1; then
    echo "Keycloak is ready.";
    break;
  fi;
  now="$$(date +%s)";
  if [ "$$now" -ge "$$deadline" ]; then
    echo "Timed out after $(WAIT_TIMEOUT_SECONDS)s waiting for Keycloak at $(KEYCLOAK_READY_URL)" >&2;
    exit 1;
  fi;
  sleep $(WAIT_SLEEP_SECONDS);
done