

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda-${var.name}-${var.event_type}.zip"

  source {
    filename = "index.js"
    content  = var.content
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = "${var.name}-edge-${var.event_type}"
  filename      = data.archive_file.lambda.output_path

  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  memory_size      = 128
  timeout          = 1
  publish          = true

//  dead_letter_config {
//    target_arn = var.dead_letter_arn
//  }

  tracing_config {
    mode = "Active"
  }
}

# Need for all regions?
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}-edge-${var.event_type}"
  retention_in_days = 30
}

// IAM
resource "aws_iam_role" "lambda" {
  name               = "${var.name}-edge-${var.event_type}"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Add X-Ray
resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

// Add DLQ
//resource "aws_iam_role_policy_attachment" "dlq" {
//  role       = aws_iam_role.lambda.name
//  policy_arn = var.dead_letter_policy_arn
//}