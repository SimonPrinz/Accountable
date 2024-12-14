#!/usr/bin/env bash

checkService() {
  service="$1"
  serviceDir="/run/service/$service"
  echo "[CHECK] [SERVICE] $service:"
  exitCode=0
  serviceRunning=$(/command/s6-svstat -o up "$serviceDir")
  if [ $serviceRunning = "false" ]; then
    exitCode=$(/command/s6-svstat -o exitcode "$serviceDir")
    echo "Service $service exited with code $exitCode"
    if [ $exitCode = "0" ]; then
      exitCode=127 # mark as failed to restart
      echo "Service $service exited normally, but will be flagged with 127"
    fi
  fi
  if [ $exitCode != "0" ]; then
    exit $exitCode
  fi
  status=$(/command/s6-svstat -n "$serviceDir")
  echo "Service $service is $status"
}

checkHttp() {
  echo "[CHECK] [HTTP]:"
  response=$(curl --max-time 2 --connect-timeout 1 -sSf "http://127.0.0.1:80/healthz?sentry=disableTransaction")
  echo "$response"
  if [ $response != "Healthy" ]; then
    exit 1
  fi
}

service=${SERVICE:-'app'}
if [ $service = "app" ]; then
  checkService "php"
  checkService "caddy"
  # ToDo: disabled until project initialized
#  checkHttp
else
  checkService "$service"
fi
