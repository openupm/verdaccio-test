#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

divider
echo "# build redis-search-patch..."
cd "$DIR/verdaccio-redis-search-patch"
rm -f "$DIR"/verdaccio-redis-search-patch/verdaccio-*.tgz
npm run build
npm pack

echo "# install redis-search-patch..."
cd "$DIR/server"
npm install -f "$DIR"/verdaccio-redis-search-patch/verdaccio-*.tgz
