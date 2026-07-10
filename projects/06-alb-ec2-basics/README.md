# 06 - ALB EC2 Basics

This lab creates a basic Application Load Balancer flow with Terraform using Floci as a local AWS emulator.

The Terraform code was written manually to understand how a VPC, public subnets, security groups, an Application Load Balancer, a listener, a target group, a target group attachment, and an EC2 instance connect to each other.

## Resources

- VPC: `10.0.0.0/16`
- Public subnet A: `10.0.1.0/24`
- Public subnet B: `10.0.2.0/24`
- Internet Gateway
- Public route table with `0.0.0.0/0` routed to the Internet Gateway
- Route table associations for both public subnets
- ALB security group
- EC2 security group
- Application Load Balancer
- Target group
- Target group attachment
- HTTP listener on port `80`
- EC2 instance running a small Python HTTP server

## Architecture

```text
Internet
  -> Application Load Balancer
  -> Listener :80
  -> Target Group
  -> EC2 Instance
```

The EC2 instance runs a simple HTTP server through `user_data`:

```text
hello from 06-alb-ec2-basics
```

## Security Groups

### ALB Security Group

Allows inbound HTTP traffic from the internet:

```text
0.0.0.0/0 -> TCP 80
```

Allows all outbound traffic.

### EC2 Security Group

Allows inbound HTTP traffic only from the ALB security group:

```text
ALB security group -> TCP 80
```

Allows all outbound traffic.

The EC2 instance does not get a public IP address. It is intended to be reached through the ALB, not directly from the internet.

## Key Concepts

### Application Load Balancer

The ALB is the public entry point for HTTP traffic.

```text
Client -> ALB
```

### Listener

The listener defines which port and protocol the ALB listens on.

In this lab:

```text
HTTP :80
```

The listener forwards requests to the target group.

### Target Group

The target group represents the backend destination for the ALB.

In this lab, the target type is:

```text
instance
```

That means EC2 instances are registered as targets.

### Target Group Attachment

The target group attachment registers the EC2 instance in the target group.

```text
Target Group -> EC2 Instance
```

Without this attachment, the ALB would have no backend target to forward traffic to.

### EC2 User Data

The EC2 instance uses `user_data` to start a small HTTP server on port `80`.

This makes it possible to verify that the instance is serving traffic.

## Terraform Flow

```text
VPC
  -> Public subnets
  -> Internet Gateway
  -> Route table
  -> Security groups
  -> ALB
  -> Target group
  -> EC2 instance
  -> Target group attachment
  -> Listener
```

## Commands

From the repository root:

```sh
./tools/tf.sh 06-alb-ec2-basics init
./tools/tf.sh 06-alb-ec2-basics fmt
./tools/tf.sh 06-alb-ec2-basics validate
./tools/tf.sh 06-alb-ec2-basics plan
./tools/tf.sh 06-alb-ec2-basics apply
```

Destroy the lab:

```sh
./tools/tf.sh 06-alb-ec2-basics destroy
```

## Useful AWS CLI Checks

List load balancers:

```sh
aws elbv2 describe-load-balancers --no-cli-pager
```

List target groups:

```sh
aws elbv2 describe-target-groups --no-cli-pager
```

List listeners:

```sh
aws elbv2 describe-listeners \
  --load-balancer-arn "<alb-arn>" \
  --no-cli-pager
```

Check target health:

```sh
aws elbv2 describe-target-health \
  --target-group-arn "<target-group-arn>" \
  --no-cli-pager
```

Check EC2 instances:

```sh
aws ec2 describe-instances --no-cli-pager
```

## Local Floci Notes

Floci successfully creates the ALB, listener, target group, EC2 instance, and target group attachment for this lab.

The EC2 web server responds inside the EC2 container:

```sh
docker exec -it <ec2-container-name> curl http://127.0.0.1:80
```

Expected response:

```text
hello from 06-alb-ec2-basics
```

However, the ALB DNS name is not reachable from the host on port `80` in this local setup.

The `*.localhost.floci.io:4566` endpoint reaches the Floci edge/API gateway, not the ALB listener. Therefore, a request like this may fail locally:

```sh
curl http://<alb-dns-name>
```

## What I Learned

- An ALB is the public entry point for HTTP traffic.
- A listener defines which port and protocol the ALB listens on.
- A target group defines where the ALB forwards traffic.
- A target group attachment registers an EC2 instance as a backend target.
- The EC2 instance still needs to live in a subnet.
- The ALB should be placed in at least two public subnets.
- The EC2 instance can avoid a public IP and still receive traffic through the ALB.
- Security groups can reference other security groups.
- The ALB security group controls who can reach the ALB.
- The EC2 security group controls who can reach the instance.
- In real AWS, public ALB traffic should normally use HTTPS on port `443`.

## Real AWS Note

This lab uses HTTP on port `80` intentionally for local learning.

In production, a public ALB should normally use HTTPS with an ACM certificate:

```text
Client -> HTTPS :443 -> ALB -> Target Group -> EC2
```

The ALB-to-EC2 connection may still use HTTP internally depending on the architecture and security requirements.
