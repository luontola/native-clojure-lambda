#!/bin/sh
set -e
if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  exec /usr/local/bin/aws-lambda-rie "$@"
else
  exec "$@"
fi
