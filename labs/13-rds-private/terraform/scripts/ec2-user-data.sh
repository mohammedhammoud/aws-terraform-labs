#!/bin/bash
dnf install -y postgresql15

PGPASSWORD="${db_password}" psql \
  --host="${db_endpoint}" \
  --port="${db_port}" \
  --username="${db_username}" \
  --dbname="${db_name}" \
  --command="SELECT 1;" \
  > /var/log/rds-test.log 2>&1