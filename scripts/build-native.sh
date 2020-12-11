#!/usr/bin/env bash
set -euxo pipefail

lein kaocha
lein uberjar
docker build --tag emergency-letter --file Dockerfile-native .
