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