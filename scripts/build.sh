#!/usr/bin/env bash
set -euxo pipefail

lein kaocha
lein uberjar
