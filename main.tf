# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  
}
# Configure the Terraform backend to store the state in S3 and use DynamoDB for locking
terraform {
  backend "s3" {
    bucket = "tf-backend-st"
    key    = "terraform.tfstate"
    region = "us-east-1"
 
    dynamodb_table = "TfStatelock"
  }
}
# Create an ECR repository 
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-ecr-repo"
}
provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "repository" {
  name = "my_repository"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my_bucket"
  acl    = "private"
}

resource "aws_lambda_function" "lambda" {
  function_name = "list_images"
  handler       = "index.handler"
  runtime       = "python3.8"

  role = aws_iam_role.lambda.arn

  filename = "lambda_function_payload.zip"
}

resource "aws_cloudwatch_event_rule" "every_week" {
  schedule_expression = "rate(1 week)"
}

resource "aws_cloudwatch_event_target" "run_lambda_every_week" {
  rule      = aws_cloudwatch_event_rule.every_week.name
  target_id = "run_lambda"
  arn       = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_week.arn
}
