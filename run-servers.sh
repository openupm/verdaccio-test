#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VERDACCIO_LOG="$DIR"/logs/verdaccio.log
MINIO_LOG="$DIR"/logs/minio.log

function divider() {
  printf %"$(tput cols)"s |tr " " "-"
  printf "\n"
}
function wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  until test $((wait_seconds--)) -eq 0 -o -f "$file" ; do sleep 1; done

  ((++wait_seconds))
}

./stop-servers.sh

echo "# clean logs..."
rm -rf logs
mkdir -p logs

echo -n "# start minio..."
MINIO_REGION=us-east-1 MINIO_ACCESS_KEY=admin MINIO_SECRET_KEY=password minio server minio-data > "$MINIO_LOG" 2>&1 &
wait_file "$MINIO_LOG" 5 || {
  echo "Minio log file missing after waiting for $? secs: $MINIO_LOG"
  exit 1
}
timeout 15s grep -q 'MinIO Object Storage Server' <(tail -n1000 -f "$MINIO_LOG")
ps axf | grep minio | grep -v grep | awk '{print " PID " $1}'

echo -n "# start verdaccio..."
cd server
# start verdaccio
npm run server > "$VERDACCIO_LOG" 2>&1 &
wait_file "$VERDACCIO_LOG" 5 || {
  echo "Verdaccio log file missing after waiting for $? secs: $VERDACCIO_LOG"
  exit 1
}
# wait server start...
timeout 15s grep -q 'http address' <(tail -n1000 -f "$VERDACCIO_LOG")
# print PID
ps axf | grep verdaccio | grep -v grep | grep -v "sh -c" | awk '{print " PID " $1}'
echo "# config: $VERDACCIO_CONFIG"
