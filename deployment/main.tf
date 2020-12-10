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
  region = "eu-north-1"
}

provider "docker" {}

locals {
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
