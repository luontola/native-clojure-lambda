terraform {
  backend "s3" {
    bucket = "luontola-terraform"
    key = "emergency-letter/terraform.tfstate"
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

//resource "aws_vpc" "example" {
//  cidr_block = "10.0.0.0/16"
//}
//
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
