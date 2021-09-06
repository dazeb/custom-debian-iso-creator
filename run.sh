#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker build "${SCRIPT_DIR}/lib" -t williamhaley/custom-debian-builder

docker run \
  --rm \
  -it \
  -v "${SCRIPT_DIR}/output":/output \
  -v "${SCRIPT_DIR}/config.yaml":/app/config.yaml:ro \
  -v "${SCRIPT_DIR}/lib/scripts":/app/scripts:ro \
  -v "${SCRIPT_DIR}/lib/standard-files":/app/standard-files:ro \
  -v "${SCRIPT_DIR}/lib/generate.py":/app/generate.py:ro \
  -v "${SCRIPT_DIR}/custom-system-files":/app/custom-system-files:ro \
  -v "${SCRIPT_DIR}/custom-user-files":/app/custom-user-files:ro \
  williamhaley/custom-debian-builder \
  /bin/bash
