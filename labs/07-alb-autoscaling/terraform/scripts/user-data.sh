#!/bin/bash
set -euxo pipefail

mkdir -p /opt/web
echo "hello from 07-alb-autoscaling" > /opt/web/index.html

cd /opt/web
nohup python3 -m http.server 80 > /var/log/web.log 2>&1 &