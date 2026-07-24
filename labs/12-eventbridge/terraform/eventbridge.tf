resource "aws_cloudwatch_event_bus" "lab" {
  name = "${var.project_name}-bus"
}

resource "aws_cloudwatch_event_rule" "order_created" {
  name           = "${var.project_name}-order-created"
  event_bus_name = aws_cloudwatch_event_bus.lab.name
  event_pattern = jsonencode({
    source      = ["app.orders"]
    detail-type = ["OrderCreated"]
  })
}

resource "aws_cloudwatch_event_target" "log_order" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.lab.name
  arn            = aws_lambda_function.log_order.arn
}

resource "aws_cloudwatch_event_target" "log_customer" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.lab.name
  arn            = aws_lambda_function.log_customer.arn
}

resource "aws_lambda_permission" "allow_eventbridge_log_order" {
  statement_id  = "AllowEventBridgeLogOrder"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_order.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.order_created.arn
}

resource "aws_lambda_permission" "allow_eventbridge_log_customer" {
  statement_id  = "AllowEventBridgeLogCustomer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_customer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.order_created.arn
}
