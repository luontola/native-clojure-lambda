terraform {
  backend "s3" {
    bucket = "luontola-terraform"
    key = "native-clojure-lambda/dev.tfstate"
    region = "eu-north-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  # TODO: eu-north-1 doesn't yet support container images for lambdas
  region = "eu-west-1"
}

data "aws_region" "current" {}

locals {
  common_tags = {
    application = "native-clojure-lambda"
  }
}

#### Docker image

resource "aws_ecr_repository" "releases" {
  name = "native-clojure-lambda"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.common_tags
}

data "aws_ecr_image" "app" {
  registry_id = aws_ecr_repository.releases.registry_id
  repository_name = aws_ecr_repository.releases.name
  image_tag = "latest"
}

#### Lambda

// noinspection MissingProperty - 'runtime' is nowadays optional, but IDEA warns about it
resource "aws_lambda_function" "app" {
  function_name = "native-clojure-lambda"
  image_uri = "${aws_ecr_repository.releases.repository_url}:latest"
  package_type = "Image"
  role = aws_iam_role.app.arn
  source_code_hash = replace(data.aws_ecr_image.app.id, "/^sha256:/", "")
  memory_size = 256
  environment {
    variables = {
      foo = "bar"
    }
  }
  tracing_config {
    mode = "Active"
  }
  tags = local.common_tags
}

resource "aws_iam_role" "app" {
  name = "native-clojure-lambda"
  assume_role_policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Action: "sts:AssumeRole"
        Principal: {
          Service: "lambda.amazonaws.com"
        }
        Effect: "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_access" {
  role = aws_iam_role.app.name
  # "Provides write permissions to CloudWatch Logs."
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray_write_access" {
  role = aws_iam_role.app.name
  # "Allow the AWS X-Ray Daemon to relay raw trace segments data to the service's API
  # and retrieve sampling data (rules, targets, etc.) to be used by the X-Ray SDK."
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/aws/lambda/${aws_lambda_function.app.function_name}"
  retention_in_days = 30
  tags = local.common_tags
}

#### Output variables

output "aws_region" {
  value = data.aws_region.current.name
}

output "docker_repository_url" {
  value = aws_ecr_repository.releases.repository_url
}

output "docker_image_id" {
  value = data.aws_ecr_image.app.id
}
