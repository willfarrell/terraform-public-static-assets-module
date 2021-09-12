# TODO - add example how to increase ACM import limit


# lambda
# CloudWatch
# SNS?


resource "aws_cloudwatch_event_rule" "trigger" {
  count = length(var.domains)
  name = "certbot-${count.index}-trigger"
  description = "Trigger certbot check ${var.domains[count.index]}"

  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger" {
  count = length(var.domains)
  target_id = "certbot-trigger"
  arn = aws_lambda_function.lambda.arn
  rule = aws_cloudwatch_event_rule.trigger[count.index].name
  input = "{\"domains\":\"${var.domains[count.index]}\", \"email\":\"${var.email}\", \"key-type\":\"${var.key-type}\"}"
}

resource "aws_lambda_permission" "trigger" {
  count = length(var.domains)
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.trigger[count.index].arn
}

