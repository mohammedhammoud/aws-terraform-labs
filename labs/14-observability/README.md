# 14 - AWS Observability with CloudWatch and Terraform

AWS observability lab built with Terraform for EC2 metrics, logs, dashboards, alarms, and SNS notifications.

## Architecture

This diagram shows the CloudWatch Agent sending logs and metrics from EC2 into dashboards, alarms, and SNS.

```mermaid
flowchart LR
    User([User]) --> EC2

    subgraph AWS
        EC2[EC2 Instance]
        Agent[CloudWatch Agent]
        Logs[CloudWatch Logs]
        Metrics[CloudWatch Metrics]
        Dashboard[CloudWatch Dashboard]
        Alarm[CloudWatch Alarm]
        SNS[SNS Topic]
    end

    Email([Email])

    EC2 --> Agent
    Agent --> Logs
    Agent --> Metrics
    Metrics --> Dashboard
    Metrics --> Alarm
    Alarm --> SNS
    SNS --> Email
```

## Resources

- VPC, subnet, route table, security group
- EC2 instance and instance profile
- CloudWatch Agent
- CloudWatch Log Groups
- CloudWatch Dashboard
- CloudWatch Metric Alarm
- SNS Topic and email subscription

## What I learned

- Metric names and dimensions have to match exactly or dashboards stay blank
- Disk widgets needed all published dimensions: `InstanceId`, `device`, `fstype`, and `path`
- New dashboards can look broken until the first metrics arrive
- Replacing EC2 creates a new log stream, not a new log group
- SSM Parameter Store is better than hardcoding an AMI ID

## Verify

What I checked in AWS:

- app reachable over HTTP
- CloudWatch Agent running
- memory and disk metrics arriving
- dashboard rendering data
- alarm evaluating memory usage
- SNS email flow working end to end
