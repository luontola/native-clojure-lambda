terraform {
  backend "s3" {
    bucket = "luontola-terraform"
    key = "emergency-letter/prod.tfstate"
    region = "eu-north-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = local.aws_region
}

provider "docker" {}

locals {
  # TODO: eu-north-1 doesn't yet support container images for lambdas
  aws_region = "eu-west-1"
  common_tags = {
    application = "emergency-letter"
  }
}

resource "aws_ecr_repository" "releases" {
  name = "emergency-letter"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.common_tags
}

// noinspection MissingProperty - 'runtime' is nowadays optional, but IDEA warns about it
resource "aws_lambda_function" "app" {
  function_name = "emergency-letter"
  image_uri = "${aws_ecr_repository.releases.repository_url}:latest"
  package_type = "Image"
  role = aws_iam_role.app.arn
  # TODO: use image hash?
  source_code_hash = filebase64sha256("../target/uberjar/emergency-letter.jar")
  memory_size = 256
  environment {
    variables = {
      foo = "bar"
    }
  }
  tags = local.common_tags
}

resource "aws_iam_role" "app" {
  name = "emergency-letter-lambda"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          Service: "lambda.amazonaws.com"
        },
        Effect: "Allow",
        Sid: ""
      }
    ]
  })
}

output "aws_region" {
  value = local.aws_region
}

output "docker_repository_url" {
  value = aws_ecr_repository.releases.repository_url
}

//resource "docker_image" "nginx" {
//  name = "nginx:latest"
//  keep_locally = false
//}
//
//resource "docker_container" "nginx" {
//  image = docker_image.nginx.latest
//  name = "tutorial"
//  ports {
//    internal = 80
//    external = 8000
//  }
//}
