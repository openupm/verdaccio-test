#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

./build-verdaccio-redis-storage.sh

./build-verdaccio-redis-search-patch.sh

cd server
source ~/.nvm/nvm.sh
nvm use
VERDACCIO_CONFIG=config-tmp-redissearch.yaml npm run server
