# 10 - AWS Step Functions with Terraform

AWS Step Functions lab built with Terraform for a state machine that validates input and then processes it with Lambda.

## Architecture

This diagram shows the Step Functions workflow from validation to either failure or processing.

```mermaid
flowchart TD
  Start([Start]) --> Validate[Validate Lambda]
  Validate --> Choice{Input valid?}
  Choice -->|Yes| Process[Process Lambda]
  Choice -->|No| Invalid([Fail])
  Process --> Success([Success])
```

## Resources

- Lambda execution role
- Step Functions IAM role and policy
- Validate Lambda
- Process Lambda
- Step Functions state machine

## Flow

```text
Valid input:   Validate -> Process -> Success
Invalid input: Validate -> Fail
```

## What I learned

- How Step Functions holds the workflow while Lambda holds the business logic
- How `Choice` states branch based on previous output
- How the Step Functions role differs from the Lambda execution role
- Why even a small workflow is easier to read once it is explicit in the state machine

## Run

```sh
../../tools/tf.sh init
../../tools/tf.sh validate
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```

## Verify

Successful execution:

```sh
aws stepfunctions start-execution   --state-machine-arn <state-machine-arn>   --input '{"value":5}'   --no-cli-pager
```

Failed execution:

```sh
aws stepfunctions start-execution   --state-machine-arn <state-machine-arn>   --input '{"value":-1}'   --no-cli-pager
```

Expected shape:

```text
{"value":5}  -> SUCCEEDED
{"value":-1} -> FAILED
```
