# VPC Flow Logs

Terraform lab for learning how VPC Flow Logs can be used to inspect network traffic in AWS.

The lab creates:

- a VPC
- a public subnet
- an Internet Gateway and public route table
- an EC2 instance running nginx
- a security group allowing HTTP traffic
- a CloudWatch Log Group
- an IAM role allowing VPC Flow Logs to publish logs
- a VPC Flow Log capturing both accepted and rejected traffic

## Test

First verify that nginx is reachable:

```bash
curl "$(terraform output -raw nginx_public_ip)"
```

The request succeeds and Flow Logs shows traffic to port `80` as:

```text
ACCEPT
```

Example:

```text
83.254.0.190 10.0.0.7 62145 80 6 ... ACCEPT OK
```

The important fields are:

```text
source IP       destination IP   source port   destination port   protocol   action
83.254.0.190    10.0.0.7         62145         80                 6          ACCEPT
```

Protocol `6` is TCP.

The security group rule for port `80` was then removed and the request was repeated.

The request could no longer reach nginx and the corresponding traffic appeared in Flow Logs as:

```text
REJECT
```

The logs also showed unrelated internet traffic attempting to reach other ports on the public EC2 instance, which was rejected by the security group.

## What this lab demonstrates

- enabling VPC Flow Logs
- publishing Flow Logs to CloudWatch Logs
- using IAM to allow the VPC Flow Logs service to write logs
- understanding `ACCEPT` and `REJECT`
- identifying source and destination IPs and ports
- seeing unsolicited traffic against a public EC2 instance
- using Flow Logs to debug network connectivity

A useful mental model is that Flow Logs help answer:

```text
Did the network traffic reach the resource, and was it accepted or rejected?
```

An `ACCEPT` entry does not mean that the application itself is healthy. It only means that the network traffic was accepted at the VPC networking layer.
