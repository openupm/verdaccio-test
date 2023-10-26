#!/bin/bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
MINIO_LOG="$DIR"/logs/minio.log

# Start minio
echo "MINIO_REGION=us-east-1 MINIO_ACCESS_KEY=admin MINIO_SECRET_KEY=password minio server minio-data >\"$MINIO_LOG\" 2>&1 &"

./build-verdaccio-redis-storage.sh

./build-verdaccio-redis-search-patch.sh

./build-verdaccio-install-counts.sh

cd server
source ~/.nvm/nvm.sh
nvm use
VERDACCIO_CONFIG=config-tmp-redissearch.yaml npm run server
