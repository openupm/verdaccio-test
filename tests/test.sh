#!/usr/bin/env bats
REGISTRY_URL="http://127.0.0.1:4873"
UPM_CLI="npm --registry $REGISTRY_URL"
load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ../node_modules/bats-file/load

setup () {
  npm config set color false
}

teardown () {
  npm config set color true
}

@test "should publish mypkg" {
  # publish mypkg@1.0.0
  cd "$BATS_TEST_DIRNAME"/mypkg-1.0.0
  run $UPM_CLI publish
  assert_success

  # view mypkg@1.0.0
  run $UPM_CLI view mypkg
  assert_success
  assert_output --partial 'mypkg-1.0.0'

  # publish mypkg@1.0.1
  cd "$BATS_TEST_DIRNAME"/mypkg-1.0.1
  run $UPM_CLI publish
  assert_success

  # view mypkg@1.0.1
  run $UPM_CLI view mypkg
  assert_success
  assert_output --partial 'mypkg-1.0.1'
}

@test "should search mypkg" {
  [ -z "$TEST_SEARCH_ENDPOINT" ] && skip
  run $UPM_CLI search mypkg
  assert_success
  assert_output --partial 'mypkg'
  refute_output --partial 'No matches found'
}

@test "should redirect tarball" {
  [ -z "$TEST_TARBALL_REDIRECT" ] && skip
  run curl -s -D - -o /dev/null $REGISTRY_URL/mypkg/-/mypkg-1.0.0.tgz
  assert_success
  assert_output --partial '302 Found'
  assert_output --partial 'Location: https://openupm.sfo2.cdn.digitaloceanspaces.com/verdaccio/mypkg/mypkg-1.0.0.tgz'
}

@test "should download tarball" {
  [ ! -z "$TEST_TARBALL_REDIRECT" ] && skip
  # clean
  rm -f /tmp/mypkg-1.0.0.tgz
  # download
  run curl -s -o /tmp/mypkg-1.0.0.tgz $REGISTRY_URL/mypkg/-/mypkg-1.0.0.tgz
  assert_success
  # file should exist
  assert_file_exist /tmp/mypkg-1.0.0.tgz
  run file /tmp/mypkg-1.0.0.tgz
  assert_success
  # file should be a gzip
  assert_output --partial 'gzip compressed data'
  run tar -ztvf /tmp/mypkg-1.0.0.tgz
  # file can be viewed
  assert_success
  assert_output --partial 'package/package.json'
}

@test "should get install counts" {
  [ -z "$TEST_INSTALL_COUNTS" ] && skip
  today=$(date +%Y-%m-%d)
  json='{"downloads":1,"start":"1970-01-01","end":"'"$today"'","package":"mypkg"}'
  run curl -s $REGISTRY_URL/downloads/point/1970-01-01:$today/mypkg
  assert_success
  assert_output --partial $json
}

@test "should unpublish mypkg" {
  # unpublish mypkg@1.0.0
  run $UPM_CLI unpublish -f mypkg@1.0.1
  assert_success

  # view mypkg@1.0.0
  run $UPM_CLI view mypkg
  assert_success
  assert_output --partial 'mypkg-1.0.0'

  run $UPM_CLI unpublish -f mypkg
  assert_success

  # view mypkg
  run $UPM_CLI view mypkg
  assert_failure
}

@test "should view uplink" {
  # view is-number package by jonschlinkert which exists in the uplink registry
  run $UPM_CLI view is-number
  assert_success
  assert_output --partial 'jonschlinkert'
}

# The test will fail on local-storage due to the inconsistent search implementation.
# @test "should not search uplink" {
#   # search is-number package by jonschlinkert which exists in the uplink registry
#   run $UPM_CLI search is-number
#   assert_success
#   assert_output --partial 'No matches found'
#   # refute_output --partial 'No matches found'
# }

@test "should redirect uplink tarball" {
  # fetch is-number package by jonschlinkert which exists in the uplink registry
  [ -z "$TEST_TARBALL_REDIRECT" ] && skip
  # The first time the registry will download the uplink package and return a stream
  run curl -s -D - -o /dev/null $REGISTRY_URL/is-number/-/is-number-7.0.0.tgz
  assert_success
  assert_output --partial '200 OK'
  # The second time the registry will return a HTTP redirect
  run curl -s -D - -o /dev/null $REGISTRY_URL/is-number/-/is-number-7.0.0.tgz
  assert_success
  assert_output --partial '302 Found'
  assert_output --partial 'Location: https://openupm.sfo2.cdn.digitaloceanspaces.com/verdaccio/is-number/is-number-7.0.0.tgz'
}

@test "should download uplink tarball" {
  # fetch is-number package by jonschlinkert which exists in the uplink registry
  [ ! -z "$TEST_TARBALL_REDIRECT" ] && skip
  # clean
  rm -f /tmp/is-number-7.0.0.tgz
  # download
  run curl -s -o /tmp/is-number-7.0.0.tgz $REGISTRY_URL/is-number/-/is-number-7.0.0.tgz
  assert_success
  # file should exist
  assert_file_exist /tmp/is-number-7.0.0.tgz
  run file /tmp/is-number-7.0.0.tgz
  assert_success
  # file should be a gzip
  assert_output --partial 'gzip compressed data'
  run tar -ztvf /tmp/is-number-7.0.0.tgz
  # file can be viewed
  assert_success
  assert_output --partial 'package/package.json'
}
