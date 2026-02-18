#!/bin/sh
set -eu

# Required env vars
: "${CONSUL_HTTP_ADDR:?missing CONSUL_HTTP_ADDR}"
: "${SERVICE_NAME:?missing SERVICE_NAME}"

SERVICE_ID="${SERVICE_ID:-$SERVICE_NAME}"
SERVICE_PORT="${SERVICE_PORT:-80}"
SERVICE_ADDRESS="${SERVICE_ADDRESS:-$SERVICE_NAME}"
HEALTH_PATH="${SERVICE_HEALTH_PATH:-/health}"
HEALTH_URL="http://${SERVICE_ADDRESS}:${SERVICE_PORT}${HEALTH_PATH}"

register() {
  echo "[consul] registering: name=${SERVICE_NAME} id=${SERVICE_ID} addr=${SERVICE_ADDRESS}:${SERVICE_PORT} health=${HEALTH_URL}"

  # Wait for Consul
  i=0
  until curl -fsS "${CONSUL_HTTP_ADDR}/v1/status/leader" >/dev/null 2>&1; do
    i=$((i+1))
    if [ "$i" -ge 60 ]; then
      echo "[consul] Consul not reachable after 60 tries"
      exit 1
    fi
    sleep 1
  done

  curl -fsS -X PUT "${CONSUL_HTTP_ADDR}/v1/agent/service/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"ID\": \"${SERVICE_ID}\",
      \"Name\": \"${SERVICE_NAME}\",
      \"Address\": \"${SERVICE_ADDRESS}\",
      \"Port\": ${SERVICE_PORT},
      \"Tags\": [\"laravel\", \"apache\", \"http\"],
      \"Checks\": [
        {
          \"HTTP\": \"${HEALTH_URL}\",
          \"Interval\": \"10s\",
          \"Timeout\": \"2s\"
        }
      ]
    }" >/dev/null

  echo "[consul] registered OK"
}

deregister() {
  echo "[consul] deregistering: id=${SERVICE_ID}"
  curl -fsS -X PUT "${CONSUL_HTTP_ADDR}/v1/agent/service/deregister/${SERVICE_ID}" >/dev/null 2>&1 || true
  echo "[consul] deregistered"
}

trap 'deregister' INT TERM EXIT

register

# Start Apache (official php-apache images use this)
exec apache2-foreground