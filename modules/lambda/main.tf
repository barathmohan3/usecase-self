provider "aws" {
  region = "us-east-1"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role_${random_id.lambda_suffix.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.expense_lambda.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "random_id" "lambda_suffix" {
  byte_length = 4
}

resource "aws_lambda_function" "expense_lambda" {
  function_name    = "expenseTracker_${random_id.lambda_suffix.hex}"
  runtime          = "python3.11"
  handler          = "lambda_function.handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.expense_lambda.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.expense_lambda.function_name
}

