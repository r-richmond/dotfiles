#!/usr/bin/env bash

set -uo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
TMP_ROOT=${TMP_ROOT:-"$ROOT/tests/tmp/symlink"}

tests_run=0
tests_failed=0
current_test=''
case_root=''
fake_dotfiles=''
fake_home=''
run_output=''
run_exit_code=0

# shellcheck disable=SC1091
source "$ROOT/script/lib/symlink"

cleanup() {
  rm -rf "$TMP_ROOT"
}

fail_test() {
  printf 'not ok - %s\n  %s\n' "$current_test" "$1" >&2
  return 1
}

assert_eq() {
  local expected=$1 actual=$2 label=${3:-values differ}

  if [ "$expected" != "$actual" ]; then
    fail_test "$label: expected [$expected], got [$actual]"
    return 1
  fi
}

assert_contains() {
  local haystack=$1 needle=$2 label=${3:-missing expected output}

  if ! grep -Fq -- "$needle" <<<"$haystack"; then
    fail_test "$label: [$needle]"
    printf '  output was:\n%s\n' "$haystack" >&2
    return 1
  fi
}

assert_file_content() {
  local file=$1 expected=$2 actual

  if [ ! -f "$file" ]; then
    fail_test "expected file to exist: $file"
    return 1
  fi

  actual=$(cat "$file")
  assert_eq "$expected" "$actual" "unexpected file content for $file"
}

setup_case() {
  case_root="$TMP_ROOT/$current_test"
  fake_dotfiles="$case_root/dotfiles"
  fake_home="$case_root/home"

  rm -rf "$case_root"
  mkdir -p "$fake_dotfiles/topic" "$fake_home"
  ln -s "$ROOT/script" "$fake_dotfiles/script"
}

write_source() {
  local name=$1 content=$2 source_path

  source_path="$fake_dotfiles/topic/$name"
  mkdir -p "$(dirname "$source_path")"
  printf '%s' "$content" >"$source_path"
  printf '%s\n' "$source_path"
}

run_script() {
  run_output=$(DOTFILES="$fake_dotfiles" HOME="$fake_home" "$@" 2>&1)
  run_exit_code=$?
}

run_script_with_input() {
  local input=$1
  shift

  run_output=$(printf '%s' "$input" | DOTFILES="$fake_dotfiles" HOME="$fake_home" "$@" 2>&1)
  run_exit_code=$?
}

assert_link_points_to() {
  local link_path=$1 expected_target=$2 actual_target

  if [ ! -L "$link_path" ]; then
    fail_test "expected symlink to exist: $link_path"
    return 1
  fi

  actual_target=$(readlink "$link_path")
  assert_eq "$expected_target" "$actual_target" "unexpected symlink target for $link_path"
}

test_path_mapping() {
  setup_case

  local dot_source nested_source library_source invalid_source mapped

  dot_source="$fake_dotfiles/topic/symlink.zshrc"
  mapped=$(HOME="$fake_home" symlink_destination_for "$dot_source") || return 1
  assert_eq "$fake_home/.zshrc" "$mapped" 'dotfile destination mismatch' || return 1

  nested_source="$fake_dotfiles/topic/symlink.config+tool+settings.json"
  mapped=$(HOME="$fake_home" symlink_destination_for "$nested_source") || return 1
  assert_eq "$fake_home/.config/tool/settings.json" "$mapped" 'nested destination mismatch' || return 1

  library_source="$fake_dotfiles/topic/symlinkLibrary+Application Support+Code+User+settings.json"
  mapped=$(HOME="$fake_home" symlink_destination_for "$library_source") || return 1
  assert_eq "$fake_home/Library/Application Support/Code/User/settings.json" "$mapped" 'Library destination mismatch' || return 1

  invalid_source="$fake_dotfiles/topic/symlink"
  if HOME="$fake_home" symlink_destination_for "$invalid_source" >/dev/null; then
    fail_test 'bare symlink source should be invalid'
    return 1
  fi
}

test_link_symlink_creates_parent_directories() {
  setup_case

  local source_path destination_path

  source_path=$(write_source 'symlink.config+tool+settings.json' 'managed')
  destination_path=$(HOME="$fake_home" symlink_destination_for "$source_path") || return 1

  link_symlink "$source_path" "$destination_path"

  [ -d "$fake_home/.config/tool" ] || {
    fail_test 'expected parent directories to be created'
    return 1
  }
  assert_link_points_to "$destination_path" "$source_path"
}

test_test_symlink_reports_all_states() {
  setup_case

  local ok_source ok_destination missing_source missing_destination mismatch_source mismatch_destination mismatch_actual broken_source broken_destination invalid_source

  ok_source=$(write_source 'symlink.ok' 'ok')
  ok_destination=$(HOME="$fake_home" symlink_destination_for "$ok_source") || return 1
  ln -s "$ok_source" "$ok_destination"

  missing_source=$(write_source 'symlink.missing' 'missing')
  missing_destination=$(HOME="$fake_home" symlink_destination_for "$missing_source") || return 1

  mismatch_source=$(write_source 'symlink.mismatch' 'expected')
  mismatch_destination=$(HOME="$fake_home" symlink_destination_for "$mismatch_source") || return 1
  mismatch_actual="$case_root/other-target"
  printf 'other' >"$mismatch_actual"
  ln -s "$mismatch_actual" "$mismatch_destination"

  broken_source=$(write_source 'symlink.broken' 'broken')
  broken_destination=$(HOME="$fake_home" symlink_destination_for "$broken_source") || return 1
  ln -s "$case_root/no-such-target" "$broken_destination"

  invalid_source=$(write_source 'symlink' 'invalid')

  run_script "$ROOT/script/test-symlink"

  assert_eq '1' "$run_exit_code" 'test-symlink should fail when any managed link is unhealthy' || return 1
  assert_contains "$run_output" "OK       $ok_source -> $ok_destination" 'expected OK status' || return 1
  assert_contains "$run_output" "MISSING  $missing_source -> $missing_destination" 'expected MISSING status' || return 1
  assert_contains "$run_output" "MISMATCH $mismatch_source -> $mismatch_destination (actual: $mismatch_actual)" 'expected MISMATCH status' || return 1
  assert_contains "$run_output" "BROKEN   $broken_source -> $broken_destination (actual: $case_root/no-such-target)" 'expected BROKEN status' || return 1
  assert_contains "$run_output" "INVALID  $invalid_source" 'expected INVALID status' || return 1
  assert_contains "$run_output" 'Summary: ok=1 missing=1 mismatch=1 broken=1 invalid=1' 'expected summary counts' || return 1
}

test_test_symlink_accepts_relative_link_targets() {
  setup_case

  local source_path destination_path

  source_path=$(write_source 'symlink.relative' 'relative')
  destination_path=$(HOME="$fake_home" symlink_destination_for "$source_path") || return 1
  ln -s '../dotfiles/topic/symlink.relative' "$destination_path"

  run_script "$ROOT/script/test-symlink"

  assert_eq '0' "$run_exit_code" 'test-symlink should accept a relative symlink that resolves to the source' || return 1
  assert_contains "$run_output" "OK       $source_path -> $destination_path" 'expected relative link to be OK' || return 1
  assert_contains "$run_output" 'Summary: ok=1 missing=0 mismatch=0 broken=0 invalid=0' 'expected all-clear summary' || return 1
}

test_heal_symlink_creates_missing_link() {
  setup_case

  local source_path destination_path

  source_path=$(write_source 'symlink.created' 'managed')
  destination_path=$(HOME="$fake_home" symlink_destination_for "$source_path") || return 1

  run_script "$ROOT/script/heal-symlink"

  assert_eq '0' "$run_exit_code" 'heal-symlink should create a missing managed link' || return 1
  assert_link_points_to "$destination_path" "$source_path" || return 1
  assert_contains "$run_output" 'Summary: ok=1 missing=0 mismatch=0 broken=0 invalid=0' 'expected healed summary' || return 1
}

test_heal_symlink_replaces_broken_link() {
  setup_case

  local source_path destination_path

  source_path=$(write_source 'symlink.broken' 'managed')
  destination_path=$(HOME="$fake_home" symlink_destination_for "$source_path") || return 1
  ln -s "$case_root/no-such-target" "$destination_path"

  run_script "$ROOT/script/heal-symlink"

  assert_eq '0' "$run_exit_code" 'heal-symlink should replace a broken managed link' || return 1
  assert_link_points_to "$destination_path" "$source_path"
}

test_heal_symlink_replaces_matching_regular_file() {
  setup_case

  local source_path destination_path

  source_path=$(write_source 'symlink.same' 'same content')
  destination_path=$(HOME="$fake_home" symlink_destination_for "$source_path") || return 1
  printf 'same content' >"$destination_path"

  run_script "$ROOT/script/heal-symlink"

  assert_eq '0' "$run_exit_code" 'heal-symlink should replace a matching regular file' || return 1
  assert_link_points_to "$destination_path" "$source_path"
}

test_heal_symlink_moves_different_regular_file_to_backup() {
  setup_case

  local source_path destination_path backup_path
  source_path=$(write_source 'symlink.different' 'managed content')
  destination_path=$(HOME="$fake_home" symlink_destination_for "$source_path") || return 1
  printf 'local content' >"$destination_path"

  run_script_with_input 'm' "$ROOT/script/heal-symlink"

  backup_path="$fake_dotfiles/backup-moved/.different"

  assert_eq '0' "$run_exit_code" 'heal-symlink should move a different regular file when requested' || return 1
  assert_link_points_to "$destination_path" "$source_path" || return 1
  assert_file_content "$backup_path" 'local content'
}

run_test() {
  current_test=$1
  shift
  tests_run=$((tests_run + 1))

  if "$@"; then
    printf 'ok - %s\n' "$current_test"
  else
    tests_failed=$((tests_failed + 1))
  fi
}

trap cleanup EXIT

cleanup
mkdir -p "$TMP_ROOT"

run_test 'path mapping' test_path_mapping
run_test 'link_symlink creates parent directories' test_link_symlink_creates_parent_directories
run_test 'test-symlink reports all states' test_test_symlink_reports_all_states
run_test 'test-symlink accepts relative link targets' test_test_symlink_accepts_relative_link_targets
run_test 'heal-symlink creates missing link' test_heal_symlink_creates_missing_link
run_test 'heal-symlink replaces broken link' test_heal_symlink_replaces_broken_link
run_test 'heal-symlink replaces matching regular file' test_heal_symlink_replaces_matching_regular_file
run_test 'heal-symlink moves different regular file to backup' test_heal_symlink_moves_different_regular_file_to_backup

printf '\n%s tests, %s failures\n' "$tests_run" "$tests_failed"

if [ "$tests_failed" -gt 0 ]; then
  exit 1
fi
