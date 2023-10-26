#!/bin/bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
function divider() {
    printf %"$(tput cols)"s | tr " " "-"
    printf "\n"
}

divider
echo "# build verdaccio-install-counts..."
cd "$DIR/verdaccio-install-counts"
echo "# clean..."
rm -f *.tgz
rm -rf build
echo "# npm install..."
npm install
echo "# npm run build..."
npm run build
echo "# npm pack..."
npm pack
git checkout -- package-lock.json

echo "# install install-counts..."
cd "$DIR/server"
npm install -f "$DIR"/verdaccio-install-counts/verdaccio-*.tgz
