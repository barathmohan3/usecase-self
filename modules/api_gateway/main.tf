module "lambda" {
  source = "../lambda"  # Adjust path as needed
  # Pass any required variables here
}

resource "aws_api_gateway_rest_api" "expense_api" {
  name        = "ExpenseTrackerAPI"
  description = "API for managing daily expenses"
}

resource "aws_api_gateway_resource" "expenses" {
  rest_api_id = aws_api_gateway_rest_api.expense_api.id
  parent_id   = aws_api_gateway_rest_api.expense_api.root_resource_id
  path_part   = "expenses"
}

resource "aws_api_gateway_resource" "summary" {
  rest_api_id = aws_api_gateway_rest_api.expense_api.id
  parent_id   = aws_api_gateway_rest_api.expense_api.root_resource_id
  path_part   = "summary"
}

resource "aws_api_gateway_method" "get_expenses" {
  rest_api_id   = aws_api_gateway_rest_api.expense_api.id
  resource_id   = aws_api_gateway_resource.expenses.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_summary" {
  rest_api_id   = aws_api_gateway_rest_api.expense_api.id
  resource_id   = aws_api_gateway_resource.summary.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_expenses_get" {
  rest_api_id             = aws_api_gateway_rest_api.expense_api.id
  resource_id             = aws_api_gateway_resource.expenses.id
  http_method             = aws_api_gateway_method.get_expenses.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_invoke_arn
}

resource "aws_api_gateway_integration" "lambda_summary_get" {
  rest_api_id             = aws_api_gateway_rest_api.expense_api.id
  resource_id             = aws_api_gateway_resource.summary.id
  http_method             = aws_api_gateway_method.get_summary.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_expenses_get,
    aws_api_gateway_integration.lambda_summary_get
  ]
  rest_api_id = aws_api_gateway_rest_api.expense_api.id
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.expense_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.expense_api.id}.execute-api.${var.region}.amazonaws.com/prod"
}
