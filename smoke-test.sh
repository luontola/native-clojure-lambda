#!/usr/bin/env bash
set -euxo pipefail
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
