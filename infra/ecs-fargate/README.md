# ECS Fargate Terraform

Terraform stack for running the todo application on AWS ECS Fargate.

The stack contains a frontend service, backend service, private PostgreSQL database, load balancer, deployment roles, logging, monitoring, alarm notifications, and automatic rollback for failed ECS deployments.

GitHub Actions is the normal way to plan, deploy, and destroy the environment. Local Terraform commands are mainly used for debugging.

## Architecture

```mermaid
flowchart TD
  User[User] --> ALB[Application Load Balancer]

  ALB -->|/| Frontend[ECS Fargate frontend]
  ALB -->|/api| Backend[ECS Fargate backend]

  Backend --> RDS[(Private PostgreSQL RDS)]

  Frontend --> Logs[CloudWatch Logs]
  Backend --> Logs

  Frontend --> Metrics[CloudWatch Metrics and Alarms]
  Backend --> Metrics
  ALB --> Metrics
  RDS --> Metrics

  Metrics --> SNS[SNS email notifications]
```

The ALB runs in public subnets.

The frontend and backend ECS services run in private subnets and use NAT gateways for outbound traffic.

The frontend is intentionally deployed as a separate ECS service in this lab to practice running multiple services behind one ALB. For a simple static SPA, S3 and CloudFront would normally be a better fit.

RDS runs in separate private database subnets and is only reachable from the backend security group.

![Frontend service](docs/frontend.png)

![Backend service](docs/backend.png)

## Main resources

- VPC across two availability zones
- Public, private, and database subnets
- Internet gateway and NAT gateways
- Application Load Balancer
- Frontend and backend target groups
- ECS Fargate cluster and services
- ECS deployment circuit breakers with rollback
- Frontend and backend ECR repositories
- One-off backend migration task definition
- Private PostgreSQL RDS instance
- Secrets Manager managed database credentials
- CloudWatch log groups
- CloudWatch dashboard and alarms
- SNS email notifications
- IAM roles and policies for ECS and GitHub Actions

## Traffic flow

Requests to the ALB are routed by path:

- `/` goes to the frontend ECS service
- `/api` and `/api/*` go to the backend ECS service

The backend connects to PostgreSQL on port `5432`.

Security group access is limited to:

```text
Internet → ALB
ALB → frontend and backend
Backend → RDS
```

The ECS tasks and RDS instance do not have public IP addresses.

## Deployment

GitHub Actions uses AWS OIDC instead of long-lived AWS access keys.

Pull requests use a read-only Terraform plan role.

Deployments use an environment-specific apply role for:

- `dev`
- `stage`
- `prod`

The main workflows are:

- PR checks: `.github/workflows/ecs-fargate-pr-check.yml`
- Deploy: `.github/workflows/ecs-fargate-deploy.yml`
- Destroy: `.github/workflows/ecs-fargate-destroy.yml`

The deployment process builds the application images, pushes them to ECR, runs database migrations, and updates the ECS services.

Terraform creates the initial ECS task definitions. Later application deployments manage new task definition revisions.

The deployment workflow waits for both ECS services to reach a stable state:

```sh
aws ecs wait services-stable
```

If either service fails to stabilize, the workflow exits with an error.

## Deployment rollback

Both ECS services use the deployment circuit breaker with automatic rollback enabled.

During a rolling deployment, the previous healthy task remains available while ECS starts and validates the new task.

The backend target group checks the `/health` endpoint and expects an HTTP `200` response.

If the new task repeatedly fails to start or does not pass its health check:

1. The target is marked unhealthy.
2. ECS stops the failed task and retries the deployment.
3. The circuit breaker eventually marks the deployment as failed.
4. ECS stops deploying the broken revision.
5. The previous stable task definition remains active or is restored.

This allows the old release to continue serving traffic while the new release is being validated.

The rollback behavior was tested by temporarily changing the backend `/health` endpoint to return HTTP `500`. The ALB marked the new target unhealthy, ECS retried the task, the deployment failed, and the previous healthy release continued serving traffic.

![ECS deployment rollback](docs/rollback.png)

## Terraform state

Bootstrap and workload infrastructure use separate Terraform states.

`infra/bootstrap/terraform` owns:

- Terraform state bucket
- GitHub OIDC provider
- Terraform plan role
- Environment-specific apply roles

`infra/ecs-fargate/terraform` owns:

- Networking
- ALB
- ECS services
- ECR repositories
- RDS
- CloudWatch resources
- SNS topic
- Workload IAM roles and policies

Destroying the ECS Fargate stack does not destroy the bootstrap resources or the state bucket.

## Observability

Application logs are sent to CloudWatch Logs.

Separate log streams are created for:

- Frontend
- Backend
- Backend migrations

Logs are retained for 14 days.

The CloudWatch dashboard includes:

- ECS CPU utilization
- ECS memory utilization
- ALB target 5XX responses
- ALB unhealthy targets
- ALB target response time
- RDS CPU utilization
- RDS database connections
- RDS free storage
- Current alarm status

CloudWatch alarms send notifications through an SNS email subscription.

The unhealthy-target metric can also show failed deployment attempts while ECS starts and validates new tasks.

ECS deployment details and rollback progress are available through the service deployment timeline and service events.

![CloudWatch dashboard](docs/cloudwatch.png)

## Security

The stack includes several basic security controls:

- GitHub Actions authenticates through OIDC
- No permanent AWS credentials are stored in GitHub
- RDS is not publicly accessible
- Database credentials are managed by AWS Secrets Manager
- The backend task role can read the database secret
- The frontend task has no database access
- The state bucket blocks public access
- State bucket versioning and encryption are enabled
- HTTP access to the state bucket is denied
- ECR image scanning is enabled
- ECR repositories use immutable image tags

HTTPS for the application ALB is not configured yet.

## Local commands

Local Terraform commands can be run through the helper script:

```sh
cd infra/ecs-fargate

../../tools/tf.sh --env dev fmt
../../tools/tf.sh --env dev validate

../../tools/tf.sh --env dev plan \
  -var frontend_image_tag=bootstrap \
  -var backend_image_tag=bootstrap

../../tools/tf.sh --env dev apply \
  -var frontend_image_tag=bootstrap \
  -var backend_image_tag=bootstrap
```

The SNS email is normally provided through GitHub Actions as a Terraform variable.

## Verify

Get the ALB address:

```sh
terraform -chdir=terraform output -raw alb_dns_name
```

Check backend logs:

```sh
aws logs tail "/ecs/ecs-fargate-dev/backend" \
  --region eu-north-1 \
  --follow
```

Check frontend logs:

```sh
aws logs tail "/ecs/ecs-fargate-dev/frontend" \
  --region eu-north-1 \
  --follow
```

The CloudWatch dashboard is named:

```text
ecs-fargate-dev-dashboard
```

A successful deployment should end with:

- Healthy targets in both target groups
- Stable frontend and backend ECS services
- No active CloudWatch alarms
- The latest task definition revision running

A failed deployment should show:

- Unhealthy new targets
- Health check failures in ECS service events
- A failed deployment in the ECS deployment timeline
- Circuit breaker rollback activity
- The previous healthy revision remaining active

## Destroy

The normal destroy path is the GitHub Actions destroy workflow.

For a controlled local teardown:

```sh
cd infra/ecs-fargate

../../tools/tf.sh --env dev destroy \
  -var frontend_image_tag=bootstrap \
  -var backend_image_tag=bootstrap
```

This destroys the workload environment but keeps the shared bootstrap infrastructure and Terraform state bucket.
