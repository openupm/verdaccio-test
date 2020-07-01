#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

divider
echo "# build redis-storage..."
cd "$DIR/verdaccio-redis-storage"
rm -f "$DIR"/verdaccio-redis-storage/verdaccio-*.tgz
npm run build
npm pack

echo "# install redis-storage..."
cd "$DIR/server"
npm install -f "$DIR"/verdaccio-redis-storage/verdaccio-*.tgz
