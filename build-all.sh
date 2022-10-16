#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

echo "# set yarn version..."
yarn set version 1.22.19
divider

echo "# set yarn version..."
source ~/.nvm/nvm.sh
nvm use

divider
echo "# build verdaccio..."
cd "$DIR/verdaccio"
echo "# clean..."
git checkout -f openupm
git checkout -- yarn.lock
rm -f *.tgz
rm -rf build
echo "# patch yarn.lock..."
find . -name yarn.lock -exec sed -i "s#registry.verdaccio.org#registry.npmjs.org#g" {} \;
echo "# yarn install..."
yarn install --immutable
echo "# yarn code:build..."
yarn code:build
echo "# yarn npm pack..."
npm pack

# divider
# echo "# build aws-s3-storage..."
# cd "$DIR/monorepo"
# echo "# clean..."
# git checkout -f openupm
# git checkout -- yarn.lock
# lerna exec "git checkout -f -- yarn.lock package.json package-lock.json > /dev/null 2>&1 || true"
# lerna exec "rm -f *.tgz"
# lerna exec "rm -rf build"
# cd "$DIR/monorepo/plugins/aws-s3-storage"
# rm -f package-lock.json
# echo "# npm install..."
# npm install @types/node
# npm install
# echo "# npm run build..."
# npm run build
# echo "# npm pack..."
# npm pack
# git checkout -- package.json
# rm -f package-lock.json

divider
echo "# build storage-proxy..."
cd "$DIR/verdaccio-storage-proxy"
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

divider
echo "# build redis-storage..."
cd "$DIR/verdaccio-redis-storage"
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

divider
echo "# install..."
cd "$DIR/server"
echo "# clean..."
rm -f package-lock.json
git checkout -- package.json
echo "# install verdaccio..."
npm install -f "$DIR"/verdaccio/verdaccio-*.tgz
echo "# install aws-s3-storage..."
npm install verdaccio-aws-s3-storage@latest
echo "# install redis-storage..."
npm install -f "$DIR"/verdaccio-redis-storage/verdaccio-*.tgz
echo "# install verdaccio-storage-proxy..."
npm install -f "$DIR"/verdaccio-storage-proxy/verdaccio-*.tgz
echo "# install bunyan..."
npm install bunyan
divider

cat "$DIR"/server/package.json
