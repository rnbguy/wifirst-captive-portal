#!/usr/bin/env bash

set -eu

AUTH_TOKEN_FILE="auth_token.html"

CURR_URL=$(curl 'https://connect.wifirst.net/?perform=true' \
  -K curl.conf \
  -o "${AUTH_TOKEN_FILE}" \
  -w %{url_effective})

for N_LOOP in {1..5}; do
  echo "URL: ${CURR_URL}"
  case "${CURR_URL}" in
    https://selfcare.wifirst.net/sessions/new*)
      . cred.sh
      AUTH_TOKEN=$(grep -oP '(?<=<input name="authenticity_token" type="hidden" value=")[^"]*(?=" /></div>)' "${AUTH_TOKEN_FILE}")
      CURR_URL=$(curl -X POST 'https://selfcare.wifirst.net/sessions' \
        -K curl.conf \
        --data-urlencode "utf8=✓" \
        --data-urlencode "authenticity_token=${AUTH_TOKEN}" \
        --data-urlencode "login=${EMAIL}" \
        --data-urlencode "password=${PASSW}" \
        -o /dev/null \
        -w %{url_effective})
      echo "Retrying."
      ;;
    https://apps.wifirst.net*)
      echo "Done."
      rm "${AUTH_TOKEN_FILE}"
      break
      ;;
    https://selfcare.wifirst.net/sessions*)
      echo "Probably wrong credentials. Update cred.sh with corrent ones."
      rm "${AUTH_TOKEN_FILE}"
      break
      ;;
    *)
      echo "Unknown URL."
      rm "${AUTH_TOKEN_FILE}"
      break
      ;;
  esac
done
