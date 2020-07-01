#!/bin/bash
set -e

npm-switch -t
./build-all.sh
npm-switch -o
