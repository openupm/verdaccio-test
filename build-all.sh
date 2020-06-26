#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

divider
echo "# build verdaccio..."
cd "$DIR/verdaccio"
echo "# clean..."
git checkout -f openupm
git checkout -- yarn.lock
rm -f *.tgz
echo "# patch yarn.lock..."
find . -name yarn.lock -exec sed -i "s#registry.verdaccio.org#registry.npm.taobao.org#g" {} \;
echo "# yarn install..."
yarn install --frozen-lockfile
echo "# yarn code:build..."
yarn code:build
echo "# yarn npm pack..."
npm pack

divider
echo "# build aws-s3-storage..."
cd "$DIR/monorepo"
echo "# clean..."
git checkout -f openupm
git checkout -- yarn.lock
lerna exec "git checkout -f -- yarn.lock package.json package-lock.json > /dev/null 2>&1 || true"
lerna exec "rm -f *.tgz"
cd "$DIR/monorepo/plugins/aws-s3-storage"
rm -f package-lock.json
echo "# npm install..."
npm install @types/node
npm install
echo "# npm run build..."
npm run build
echo "# npm pack..."
npm pack

divider
echo "# build storage-proxy..."
cd "$DIR/verdaccio-storage-proxy"
echo "# clean..."
rm -f *.tgz
echo "# npm install..."
npm install
echo "# npm run build..."
npm run build
echo "# npm pack..."
npm pack

divider
echo "# install..."
cd "$DIR/server"
echo "# clean..."
rm -f package-lock.json
echo "# npm install verdaccio..."
npm install -f "$DIR"/verdaccio/verdaccio-*.tgz
echo "# npm install aws-s3-storage..."
npm install -f "$DIR"/monorepo/plugins/aws-s3-storage/verdaccio-*.tgz
echo "# npm install verdaccio-storage-proxy..."
npm install -f "$DIR"/verdaccio-storage-proxy/verdaccio-*.tgz
divider
