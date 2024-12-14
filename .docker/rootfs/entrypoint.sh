#!/usr/bin/env bash

service="${SERVICE:-app}"

if [[ "${service}" == "" ]]; then
    echo "No service given!"
    exit 1
fi

echo "Enabling given service ${service}"
sudo mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d/
sudo touch /etc/s6-overlay/s6-rc.d/user/contents.d/${service}

echo "Starting s6"
exec /init
