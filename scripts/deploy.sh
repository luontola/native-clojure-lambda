#!/usr/bin/env bash
set -euo pipefail
AWS_REGION=$(
  cd deployment
  terraform output -json aws_region | jq -r .
)
DOCKER_REPOSITORY_URL=$(
  cd deployment
  terraform output -json docker_repository_url | jq -r .
)
DOCKER_REPOSITORY_DOMAIN=$(dirname "$DOCKER_REPOSITORY_URL")
set -x

RELEASE_TAG="$DOCKER_REPOSITORY_URL:latest"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$DOCKER_REPOSITORY_DOMAIN"
docker tag emergency-letter "$RELEASE_TAG"
docker push "$RELEASE_TAG"

(
  cd deployment
  terraform apply
)
