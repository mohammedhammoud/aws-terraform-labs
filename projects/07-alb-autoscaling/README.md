# 07 - ALB Auto Scaling

ALB in front of an Auto Scaling Group running two EC2 web servers.

## Architecture

```mermaid
flowchart TD
  Client[Client] --> ALB[Application Load Balancer]
  ALB --> Listener[Listener :80]
  Listener --> TG[Target Group]
  TG --> EC2A[EC2 A]
  TG --> EC2B[EC2 B]

  LT[Launch Template] --> ASG[Auto Scaling Group]
  ASG --> EC2A
  ASG --> EC2B
```

## Resources

- VPC: `10.0.0.0/16`
- Two public subnets
- Internet Gateway and public route table
- ALB security group
- EC2 security group
- Application Load Balancer
- Target group and HTTP listener
- Launch Template
- Auto Scaling Group
- Two EC2 instances running a Python HTTP server

The instances respond with:

```text
hello from 07-alb-autoscaling
```

## Auto Scaling setup

```text
min: 2
desired: 2
max: 4
```

The ASG registers instances in the target group, so no manual target attachment is needed.

## What I learned

- How a Launch Template replaces hand-made `aws_instance` resources
- How the ASG and target group wire together directly
- Why `health_check_type = "ELB"` matters here
- Why Launch Template changes do not replace running instances by themselves
- When instance recreation or refresh is needed to see new user data

## Run

```sh
../../tools/tf.sh init
../../tools/tf.sh validate
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```

## Verify

Check target health:

```sh
aws elbv2 describe-target-health   --target-group-arn "<target-group-arn>"   --no-cli-pager
```

Check the app inside one EC2 container:

```sh
docker exec -it <ec2-container-name> curl http://127.0.0.1:80
```

Expected:

```text
healthy
hello from 07-alb-autoscaling
```
