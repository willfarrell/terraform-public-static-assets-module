# Lambda@Edge
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

## Viewer Request
resource "aws_iam_role" "viewer_request" {
  count              = var.lambda_viewer_request == "" ? 0 : 1
  name               = "${local.name}-edge-viewer-request"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "viewer_request" {
  count      = var.lambda_viewer_request == "" ? 0 : 1
  role       = aws_iam_role.viewer_request[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "viewer_request" {
  count       = var.lambda_viewer_request == "" ? 0 : 1
  type        = "zip"
  output_path = "${path.module}/lambda-viewer-request.zip"

  source {
    filename = "index.js"
    content  = var.lambda_viewer_request
  }
}

resource "aws_lambda_function" "viewer_request" {
  count         = var.lambda_viewer_request == "" ? 0 : 1
  function_name = "${local.name}-edge-viewer-request"
  filename      = data.archive_file.viewer_request[0].output_path

  source_code_hash = data.archive_file.viewer_request[0].output_base64sha256
  role             = aws_iam_role.viewer_request[0].arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

## Origin Request
resource "aws_iam_role" "origin_request" {
  count              = var.lambda_origin_request == "" ? 0 : 1
  name               = "${local.name}-edge-origin-request"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "origin_request" {
  count      = var.lambda_origin_request == "" ? 0 : 1
  role       = aws_iam_role.origin_request[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "origin_request" {
  count       = var.lambda_origin_request == "" ? 0 : 1
  type        = "zip"
  output_path = "${path.module}/lambda-origin-request.zip"

  source {
    filename = "index.js"
    content  = var.lambda_origin_request
  }
}

resource "aws_lambda_function" "origin_request" {
  count         = var.lambda_origin_request == "" ? 0 : 1
  function_name = "${local.name}-edge-origin-request"
  filename      = data.archive_file.origin_request[0].output_path

  source_code_hash = data.archive_file.origin_request[0].output_base64sha256
  role             = aws_iam_role.origin_request[0].arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

## Origin Response
resource "aws_iam_role" "origin_response" {
  count              = var.lambda_origin_response == "" ? 0 : 1
  name               = "${local.name}-edge-origin-response"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "origin_response" {
  count      = var.lambda_origin_response == "" ? 0 : 1
  role       = aws_iam_role.origin_response[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "origin_response" {
  count       = var.lambda_origin_response == "" ? 0 : 1
  type        = "zip"
  output_path = "${path.module}/lambda-origin-response.zip"

  source {
    filename = "index.js"
    content  = var.lambda_origin_response
  }
}

resource "aws_lambda_function" "origin_response" {
  count         = var.lambda_origin_response == "" ? 0 : 1
  function_name = "${local.name}-edge-origin-response"
  filename      = data.archive_file.origin_response[0].output_path

  source_code_hash = data.archive_file.origin_response[0].output_base64sha256
  role             = aws_iam_role.origin_response[0].arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

## Viewer Response
resource "aws_iam_role" "viewer_response" {
  count              = var.lambda_viewer_response == "" ? 0 : 1
  name               = "${local.name}-edge-viewer-response"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "viewer_response" {
  count      = var.lambda_viewer_response == "" ? 0 : 1
  role       = aws_iam_role.viewer_response[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "viewer_response" {
  count       = var.lambda_viewer_response == "" ? 0 : 1
  type        = "zip"
  output_path = "${path.module}/lambda-viewer-response.zip"

  source {
    filename = "index.js"
    content  = var.lambda_viewer_response
  }
}

resource "aws_lambda_function" "viewer_response" {
  count         = var.lambda_viewer_response == "" ? 0 : 1
  function_name = "${local.name}-edge-viewer-response"
  filename      = data.archive_file.viewer_response[0].output_path

  source_code_hash = data.archive_file.viewer_response[0].output_base64sha256
  role             = aws_iam_role.viewer_response[0].arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}
