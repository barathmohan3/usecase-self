resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "expense_lambda" {
  function_name = "expenseTracker"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  filename      = "${path.module}/lambda_function.py"     # <--- Direct file reference
  source_code_hash = filebase64sha256("${path.module}/lambda_function.py")
  role = aws_iam_role.lambda_exec.arn
}
 

output "lambda_invoke_arn" {
  value = aws_lambda_function.expense_lambda.invoke_arn
}
