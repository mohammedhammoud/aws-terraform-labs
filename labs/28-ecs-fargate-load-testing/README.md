# ECS Fargate Load Testing

> [!WARNING]
> This lab is still in progress.

The stack currently includes:

- VPC across two availability zones
- public subnets for the Application Load Balancer
- private subnets for Fargate tasks
- NAT Gateway per availability zone
- Application Load Balancer
- ECS Fargate cluster and service
- ECR repository
- CloudWatch Logs
- ECS Service Auto Scaling based on average CPU utilization

The application is a small Node.js HTTP server with two endpoints:

- `/health` — lightweight health check
- `/work` — performs CPU-intensive work for load testing

The container image is built locally and pushed to ECR.

## Verified

The full request path has been verified:

```text
Internet
  -> ALB
  -> Target Group
  -> ECS Fargate Service
  -> Container
```

Both endpoints respond successfully through the ALB:

```bash
curl "http://$(terraform output -raw alb_dns)/health"
curl "http://$(terraform output -raw alb_dns)/work"
```

During the first deployment, the container was built for ARM64 on Apple Silicon while the Fargate task expected `linux/amd64`, resulting in:

```text
CannotPullContainerError:
image Manifest does not contain descriptor matching platform 'linux/amd64'
```

Rebuilding the image explicitly for `linux/amd64` resolved the issue.

## Next

- add k6 load test
- generate sustained CPU load against `/work`
- observe ECS CPU utilization
- verify scale-out from 1 task toward the configured maximum
- stop load and verify scale-in
- document the observed scaling behavior
