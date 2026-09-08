#!/bin/sh

# certbot_renew runs in a separate container and cannot signal this nginx, so pick up new certificates on a timer.
while :; do sleep 6h; nginx -s reload; done &
