#!/bin/bash
set -e

# Capture auth list output
AUTH_LIST="$(forgejo admin auth list)"
echo "Existing auths: ${AUTH_LIST}"

# Extract first column where provider name matches exactly
AUTH_ID="$(printf "%s\n" "$AUTH_LIST" | awk -v name="$OAUTH2_NAME" '
  NR > 1 && $0 ~ name {
    print $1
    exit
  }
')"

args=(
  --name "$OAUTH2_NAME"
  --provider "$OAUTH2_PROVIDER"
  --key "$OAUTH2_CLIENT_ID"
  --secret "$CLIENT_SECRET"
  --auto-discover-url "$OAUTH2_OPENID_CONNECT_AUTO_DISCOVERY_URL"
  --scopes "openid email profile groups"
)

if [ -n "$AUTH_ID" ]; then
  forgejo admin auth update-oauth --id "$AUTH_ID" "${args[@]}"
else
  forgejo admin auth add-oauth "${args[@]}"
fi