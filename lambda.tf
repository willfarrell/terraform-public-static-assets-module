
module "lambda-viewer-request" {
  source = "./modules/lambda"
  count = can(var.lambda["viewer-request"]) ? 1 : 0
  name = local.name
  event_type = "viewer-request"
  content = var.lambda["viewer-request"]
}

module "lambda-origin-request" {
  source = "./modules/lambda"
  count = can(var.lambda["origin-request"]) ? 1 : 0
  name = local.name
  event_type = "origin-request"
  content = var.lambda["origin-request"]
}

module "lambda-origin-response" {
  source = "./modules/lambda"
  count = can(var.lambda["origin-response"]) ? 1 : 0
  name = local.name
  event_type = "origin-response"
  content = var.lambda["origin-response"]
}

module "lambda-viewer-response" {
  source = "./modules/lambda"
  count = can(var.lambda["viewer-response"]) ? 1 : 0
  name = local.name
  event_type = "viewer-response"
  content = var.lambda["viewer-response"]
}

//# Lambda@Edge
//data "aws_iam_policy_document" "lambda" {
//  statement {
//    actions = [
//      "sts:AssumeRole",
//    ]
//
//    principals {
//      type = "Service"
//
//      identifiers = [
//        "lambda.amazonaws.com",
//        "edgelambda.amazonaws.com",
//      ]
//    }
//  }
//}
//
//
//## Template
//resource "aws_iam_role" "lambda" {
//  count              = length(keys(var.lambda))
//  name               = "${local.name}-edge-${keys(var.lambda)[count.index]}"
//  assume_role_policy = data.aws_iam_policy_document.lambda.json
//}
//
//resource "aws_iam_role_policy_attachment" "lambda" {
//  count      = length(keys(var.lambda))
//  role       = aws_iam_role.lambda[count.index].name
//  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
//}
//
//data "archive_file" "lambda" {
//  count       = length(keys(var.lambda))
//  type        = "zip"
//  output_path = "${path.module}/lambda-${local.name}-${keys(var.lambda)[count.index]}.zip"
//
//  source {
//    filename = "index.js"
//    content  = var.lambda[keys(var.lambda)[count.index]]
//  }
//}
//
//resource "aws_lambda_function" "lambda" {
//  count         = length(keys(var.lambda))
//  function_name = "${local.name}-edge-${keys(var.lambda)[count.index]}"
//  filename      = data.archive_file.lambda[count.index].output_path
//
//  source_code_hash = data.archive_file.lambda[count.index].output_base64sha256
//  role             = aws_iam_role.lambda[count.index].arn
//  handler          = "index.handler"
//  runtime          = "nodejs14.x"
//  memory_size      = 128
//  timeout          = 1
//  publish          = true
//}
//
//# Need for all regions?
//resource "aws_cloudwatch_log_group" "lambda" {
//  count         = length(keys(var.lambda))
//  name              = "/aws/lambda/${local.name}-edge-${keys(var.lambda)[count.index]}"
//  retention_in_days = 30
//}