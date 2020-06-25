#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

pkill -f minio && echo "# stop minio..." || true
pkill -f verdaccio && echo "# stop verdaccio..." || true
