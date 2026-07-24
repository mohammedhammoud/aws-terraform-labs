data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../app/index.js"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "s3_processor" {
  function_name = "s3-processor-03-lambda-s3"

  role    = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "nodejs20.x"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {}
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lab.arn
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.lab.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}
