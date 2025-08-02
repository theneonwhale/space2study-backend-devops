#!/bin/bash

backend_json=$(vault kv get -format=json secret/backend 2>/dev/null)
frontend_json=$(vault kv get -format=json secret/frontend 2>/dev/null)

if echo "$backend_json" | jq -e '.data' >/dev/null 2>&1; then
  backend_env=$(echo "$backend_json" | jq -r '.data | to_entries | .[] | "export \(.key)=\(.value)"')
  if [ -n "$backend_env" ]; then
    eval "$backend_env"
  fi
fi

if echo "$frontend_json" | jq -e '.data' >/dev/null 2>&1; then
  frontend_env=$(echo "$frontend_json" | jq -r '.data | to_entries | .[] | "export \(.key)=\(.value)"')
  if [ -n "$frontend_env" ]; then
    eval "$frontend_env"
  fi
fi
