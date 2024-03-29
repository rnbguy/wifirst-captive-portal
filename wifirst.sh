#!/usr/bin/env bash

set -eu

AUTH_TOKEN_FILE="auth_token.html"

CURR_URL=$(curl 'https://connect.wifirst.net/?perform=true' \
  -K curl.conf \
  -o "${AUTH_TOKEN_FILE}" \
  -w %{url_effective})

for _ in {1..5}; do
  echo "URL: ${CURR_URL}"
  case "${CURR_URL}" in
    https://connect.wifirst.net/?perform=true)
      echo "Trying to auto-log."
      CURR_URL=$(curl 'https://apps.wifirst.net/?redirected=true' \
        -K curl.conf \
        -o "${AUTH_TOKEN_FILE}" \
        -w %{url_effective})
      echo "URL: ${CURR_URL}"
      ;;
    https://apps.wifirst.net/?redirected=true)
      CURR_URL="https://selfcare.wifirst.net/sessions/new"
      ;;
    https://selfcare.wifirst.net/sessions/new*)
      . cred.sh
      AUTH_TOKEN=$(grep -oP '(?<=<input name="authenticity_token" type="hidden" value=")[^"]*(?=" /></div>)' "${AUTH_TOKEN_FILE}")
      echo "${AUTH_TOKEN}"
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
