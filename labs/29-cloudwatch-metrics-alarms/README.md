# CloudWatch Metrics and Alarms

Terraform lab for learning how CloudWatch custom metrics and alarms behave.

The lab creates a Lambda function that publishes a custom CloudWatch metric named `RequestProcessed` when it receives requests.

A CloudWatch alarm watches that metric and enters `ALARM` when the request count is greater than `20` for at least `2` datapoints within a `3` minute evaluation window.

## Test

Generate enough requests to cross the threshold:

```bash
for i in {1..30}; do
  curl -s "$(terraform output -raw lambda_function_url)" > /dev/null
done
```

CloudWatch receives the `RequestProcessed` datapoints and evaluates the alarm.

Observed behavior:

```text
INSUFFICIENT_DATA
        ↓
      ALARM
        ↓
INSUFFICIENT_DATA
```

The alarm entered `ALARM` after enough datapoints exceeded the threshold.

After requests stopped, the Lambda stopped publishing metric datapoints. Once the evaluation window contained missing data, the alarm returned to `INSUFFICIENT_DATA`.

This demonstrates that missing datapoints are not automatically treated as a metric value of `0`.

## What this lab demonstrates

- publishing a custom CloudWatch metric
- configuring a CloudWatch metric alarm
- evaluation periods and datapoints to alarm
- triggering an alarm by crossing a threshold
- how missing metric data affects alarm state
