module "api_gateway" {
  source = "./modules/api_gateway"
}

module "lambda" {
  source = "./modules/lambda"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

output "api_gateway_url" {
  value = module.api_gateway.api_url
}
