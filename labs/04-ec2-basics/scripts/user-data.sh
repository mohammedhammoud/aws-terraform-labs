#!/bin/bash

exec > /tmp/user-data.log 2>&1
set -eux

echo "user_data started"
echo "hello from ec2" > /tmp/ec2-test.txt

dnf install -y unzip --allowerasing || true

curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

aws --version
aws s3 cp /tmp/ec2-test.txt "s3://${bucket_name}/ec2-test.txt"

echo "user_data finished"