#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function divider() {
    printf %"$(tput cols)"s |tr " " "-"
    printf "\n"
}

./stop-servers.sh

echo "# clean logs..."
rm -rf logs
mkdir -p logs

echo "# clean minio-data..."
rm -rf "$DIR/minio-data/"
mkdir -p "$DIR/minio-data/openupm"

echo -n "# start minio..."
MINIO_REGION=us-east-1 MINIO_ACCESS_KEY=admin MINIO_SECRET_KEY=password minio server minio-data > "$DIR"/logs/minio.log 2>&1 &
timeout 15s grep -q 'Endpoint' <(tail -f "$DIR"/logs/minio.log)
ps axf | grep minio | grep -v grep | awk '{print " PID " $1}'

echo -n "# start verdaccio..."
cd server
npm run server > "$DIR"/logs/verdaccio.log 2>&1 &
timeout 15s grep -q 'http address' <(tail -f "$DIR"/logs/verdaccio.log)
ps axf | grep verdaccio | grep -v grep | grep -v "sh -c" | awk '{print " PID " $1}'
