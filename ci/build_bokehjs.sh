#!/bin/bash

set -x #echo on
set -e #exit on error

pushd bokehjs
node make build
popd
