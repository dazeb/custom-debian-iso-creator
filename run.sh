#!/usr/bin/env bash

set -e

docker build . -t williamhaley/custom-debian-builder

docker run \
    --rm \
    -it \
    -v `pwd`/output:/output \
    -v `pwd`/config:/root/config:ro \
    -v `pwd`/lib:/root/lib:ro \
    -v `pwd`/generate.sh:/root/generate.sh:ro \
    -v `pwd`/static-pre:/root/static-pre:ro \
    -v `pwd`/static-post:/root/static-post:ro \
    williamhaley/custom-debian-builder \
    /bin/bash
