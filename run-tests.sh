#!/bin/bash
set -e

function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

divider
echo "# clean redis..."
redis-cli KEYS "ve:*" | xargs redis-cli DEL || true

echo "# run servers..."
./run-servers.sh

divider
echo "# npm login..."
npm-cli-adduser -u openupm -p openupm4u -e test@openupm.com -r http://127.0.0.1:4873/

divider
echo "# run bats..."
bats ./tests/*.sh --tap

divider
echo "# stop servers..."
./stop-servers.sh
