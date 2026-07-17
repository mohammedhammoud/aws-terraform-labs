#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y python3 amazon-cloudwatch-agent

install -d -m 755 /opt/observability-app
install -m 644 /dev/null /var/log/observability-app.log

echo '${index_html_base64}' \
  | base64 --decode \
  > /opt/observability-app/index.html

echo '${server_py_base64}' \
  | base64 --decode \
  > /opt/observability-app/server.py

echo '${systemd_service_base64}' \
  | base64 --decode \
  > /etc/systemd/system/observability-app.service

echo '${cloudwatch_config_base64}' \
  | base64 --decode \
  > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

systemctl daemon-reload
systemctl enable --now observability-app

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json