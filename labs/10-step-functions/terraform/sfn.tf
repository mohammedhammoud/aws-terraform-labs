resource "aws_sfn_state_machine" "lab" {
  name     = "${var.project_name}-state-machine"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    StartAt = "Validate"

    States = {
      Validate = {
        Type     = "Task"
        Resource = aws_lambda_function.validate.arn
        Next     = "IsValid"
      }

      IsValid = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.valid"
            BooleanEquals = true
            Next          = "Process"
          }
        ]
        Default = "Invalid"
      }

      Process = {
        Type     = "Task"
        Resource = aws_lambda_function.process.arn
        End      = true
      }

      Invalid = {
        Type  = "Fail"
        Error = "ValidationFailed"
        Cause = "Input value must be a positive number"
      }
    }
  })
}
