data "archive_file" "lambda" {
  type        = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda-certbot.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "certbot"
  filename      = data.archive_file.lambda.output_path

  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.9"
  memory_size      = 128
  timeout          = 60
  publish          = true

  dead_letter_config {
    target_arn = var.dead_letter_arn
  }

  tracing_config {
    mode = "Active"
  }
}

# Need for all regions?
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/certbot"
  retention_in_days = terraform.environment == "production" ? 365 : 7
}

resource "aws_iam_role" "lambda" {
  name               = "certbot"
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
      ]
    }
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "certbot-policy"
  policy = jsonencode(
  {
    "Sid": "CreateCertificate",
    "Effect": "Allow",
    "Action": [
      "acm:ImportCertificate",
      "acm:DescribeCertificate",
      "acm:ListCertificates"
    ],
    "Resource": "*"
  },
  {
    "Sid": "GetRoute53Zones",
    "Effect": "Allow",
    "Action": [
      "route53:ListHostedZones"
    ],
    "Resource": "*"
  },
  {
    "Sid": "UpdateRoute53Record",
    "Effect": "Allow",
    "Action": [
      "route53:GetChange",
      "route53:ChangeResourceRecordSets"
    ],
    "Resource": [
      "arn:aws:route53:::hostedzone/*",
      "arn:aws:route53:::change/*"
    ]
  }

  )
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

// Adds CloudWatch
resource "aws_iam_role_policy_attachment" "cloud-watch" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Add X-Ray
resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

// Add DLQ
resource "aws_iam_role_policy_attachment" "dlq" {
  role       = aws_iam_role.lambda.name
  policy_arn = var.dead_letter_policy_arn
}