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
  run $UPM_CLI search mypkg
  assert_success
  assert_output --partial 'mypkg'
}

@test "should redirect tarball" {
  run curl -s -D - -o /dev/null $REGISTRY_URL/mypkg/-/mypkg-1.0.0.tgz
  assert_success
  assert_output --partial '302 Found'
  assert_output --partial 'Location: https://openupm.sfo2.cdn.digitaloceanspaces.com/verdaccio/mypkg/mypkg-1.0.0.tgz'
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
