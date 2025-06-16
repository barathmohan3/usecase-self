provider "aws" {
  region = "us-east-1"
}

resource "random_id" "dynamodb_suffix" {
  byte_length = 4
}

resource "aws_dynamodb_table" "expenses" {
  name           = "Expenses_${random_id.dynamodb_suffix.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"
  range_key      = "date"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }
}

output "table_name" {
  value = aws_dynamodb_table.expenses.name
}
