#!/usr/bin/env bats

UPM_CLI="npm --registry http://127.0.0.1:4873"
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
