#!/bin/bash
set -e

function divider() {
  printf %"$(tput cols)"s |tr " " "$1"
  printf "\n"
}

function run_pass() {
  divider "="
  echo "[$1] clean redis..."
  redis-cli KEYS "ve:*" | xargs redis-cli DEL || true

  echo "[$1] run servers..."
  ./run-servers.sh

  divider "-"
  echo "[$1] npm login..."
  npm-cli-adduser -u openupm -p openupm4u -e test@openupm.com -r http://127.0.0.1:4873/

  divider "-"
  echo "[$1] run bats..."
  bats ./tests/*.sh --tap

  divider "-"
  echo "[$1] stop servers..."
  ./stop-servers.sh
}

declare -a arr=(
  "config-redis.yaml"
  "config-s3.yaml"
  "config-mixed.yaml"
  "config-mixed-redirect.yaml"
  )
for conf in "${arr[@]}"
do
  export VERDACCIO_CONFIG="$conf"
  # toggle TEST_TARBALL_REDIRECT flag based on config name
  if [[ "$VERDACCIO_CONFIG" == *"redirect"* ]]; then
    export TEST_TARBALL_REDIRECT=1
  else
    unset "TEST_TARBALL_REDIRECT"
  fi
  run_pass "$VERDACCIO_CONFIG"
done
unset "VERDACCIO_CONFIG" || true
unset "TEST_TARBALL_REDIRECT" || true
