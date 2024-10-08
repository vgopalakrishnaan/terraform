provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_basic_execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_basic_policy"
  description = "Basic policy for Lambda to write logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:*"
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "/root/amazon/lambda/mylambda_function.py"
  output_path = "lambda_function_payload.zip"
  output_file_mode = "0777"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_sample_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  # Specify the path to the Lambda function code
  filename      = "lambda_function_payload.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256


}

output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}
