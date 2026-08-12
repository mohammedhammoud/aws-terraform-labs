# ECS Fargate Load Testing

Small Terraform lab for load testing an ECS Fargate service and seeing how autoscaling and self-healing behave under load.

What is in the stack:

- VPC across two availability zones
- public subnets for the Application Load Balancer
- private subnets for Fargate tasks
- NAT Gateway per availability zone
- Application Load Balancer
- ECS Fargate cluster and service
- ECR repository
- CloudWatch Logs
- ECS Service Auto Scaling
- k6 load testing

The app is a small Node.js HTTP server with two endpoints:

- `/health` — lightweight health check
- `/work` — performs CPU-intensive work for load testing

The image is built locally and pushed to ECR.

## Build and Push Image

Terraform has to create ECR before the image can be pushed, so the order matters.

1. Run Terraform first so the repo and the rest of the infrastructure exist.
2. Read the ECR repository URL from Terraform output.
3. Extract the registry hostname from that URL.
4. Log Docker in to ECR.
5. Build and push the image.
6. If the same mutable tag is reused, force a new ECS deployment.

Start by creating the infrastructure:

```bash
terraform -chdir=terraform init
terraform -chdir=terraform apply
```

Then log in to ECR:

```bash
ECR_REGISTRY=$(terraform -chdir=terraform output --raw ecr_repository_url | cut -d/ -f1)

aws ecr get-login-password --region eu-north-1 \
  | docker login \
    --username AWS \
    --password-stdin "$ECR_REGISTRY"
```

Build the image for `linux/amd64` and push it:

```bash
docker buildx build \
  --platform linux/amd64 \
  -t $(terraform -chdir=terraform output --raw ecr_repository_url):v1 \
  --push \
  ./app
```

If `v1` is overwritten, force a new deployment:

```bash
aws ecs update-service \
  --cluster 28-ecs-fargate-load-testing-cluster \
  --service 28-ecs-fargate-load-testing-service \
  --force-new-deployment
```

## Verified

Verified request path:

```text
Internet
  -> ALB
  -> Target Group
  -> ECS Fargate Service
  -> Container
```

Both endpoints work through the ALB:

```bash
curl "http://$(terraform -chdir=terraform output -raw alb_dns)/health"
curl "http://$(terraform -chdir=terraform output -raw alb_dns)/work"
```

On the first deploy, the image was built as ARM64 on Apple Silicon, but the Fargate task expected `linux/amd64`, so this happened:

```text
CannotPullContainerError:
image Manifest does not contain descriptor matching platform 'linux/amd64'
```

Rebuilding the image for `linux/amd64` fixed it.

## Load Testing

k6 is used to hit `/work`:

```bash
BASE_URL="http://$(terraform -chdir=terraform output -raw alb_dns)" \
k6 run k6.js
```

One test ran for 10 minutes and ramped up to 25 virtual users.

Results:

```text
HTTP requests:       4989
Request rate:        8.31 req/s
Failed requests:     0.12% (6 / 4989)

Average latency:     1.65s
Median latency:      834.96ms
p90 latency:         4.08s
p95 latency:         4.41s
Maximum latency:     38.69s
```

## CPU Scaling Experiment

The first autoscaling policy used `ECSServiceAverageCPUUtilization` with a target value of `50`.

Under load, single tasks hit high CPU and started failing ALB health checks before the service average CPU stayed high long enough to scale out.

ECS replaced the unhealthy tasks, but `desiredCount` stayed the same.

So the main takeaway here was that ECS self-healing and Service Auto Scaling are two different things:

```text
Self-healing:
unhealthy task
  -> replacement task

Autoscaling:
scaling metric crosses target
  -> desiredCount changes
```

CPU-based target tracking was not a great fit for this workload.

## Request-Based Autoscaling

The scaling metric was then changed to `ALBRequestCountPerTarget` with a target value of `100`.

With sustained load, request count per target stayed high enough for long enough to trigger scaling.

ECS showed the scale-out:

```text
Successfully set desired count to 3.
Cause: monitor alarm ... triggered policy 28-ecs-fargate-load-testing-requests
```

As load continued, the service scaled:

```text
1 desired
  -> 3 desired
  -> 5 desired
```

At peak load:

```text
5 desired
5 running
```

The service hit the configured max of five tasks while the ALB kept serving traffic.

When load dropped, the CloudWatch alarm went back to `OK` and the service scaled back down to the minimum of one task.

## Self-Healing Under Load

Individual tasks could still go unhealthy under heavy load when the `/health` endpoint timed out.

ECS handled that separately from autoscaling:

```text
health check timeout
  -> target marked unhealthy
  -> replacement task started
  -> connections drained
  -> unhealthy target deregistered
```

This could happen at the same time as a scale-out.

For example, the service could temporarily show more running and pending tasks than the desired count while ECS was replacing an unhealthy task.

## Autoscaling Configuration

The service can scale between one and five tasks:

```text
min_capacity = 1
max_capacity = 5
```

The final autoscaling policy uses:

```text
ALBRequestCountPerTarget
target_value = 100
```

Cooldowns:

```text
scale_out_cooldown = 60
scale_in_cooldown  = 60
```

## Notes

- ECS Service Auto Scaling changes `desiredCount`
- ECS self-healing replaces unhealthy tasks on its own
- Fargate tasks behind an ALB use IP targets
- CPU utilization was not a great scaling signal for this workload
- max CPU on one task and average CPU for the whole service can look very different
- `ALBRequestCountPerTarget` was a better signal here
- target tracking reacts to sustained metrics, not quick spikes
- autoscaling is not instant
- some baseline capacity still matters
- `max_capacity` is a hard ceiling
- ALB health checks, ECS scheduling, Fargate tasks, CloudWatch alarms, and Application Auto Scaling all affect the result
