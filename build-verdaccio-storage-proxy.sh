#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

divider
echo "# build storage-proxy..."
cd "$DIR/verdaccio-storage-proxy"
npm run build
npm pack

echo "# install storage-proxy..."
cd "$DIR/server"
npm install -f "$DIR"/verdaccio-storage-proxy/verdaccio-*.tgz
