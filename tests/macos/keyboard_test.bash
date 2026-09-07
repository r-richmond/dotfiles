#!/usr/bin/env bash

set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
scratch=$(mktemp -d)
export scratch
trap 'rm -rf "$scratch"' EXIT

defaults() {
  local domain
  if [[ "$1" == -currentHost ]]; then
    shift
    domain="$scratch/host"
    if [[ "$1" == export ]]; then
      command defaults export "$domain" "$3"
      return
    fi
  else
    case "$2" in
      NSGlobalDomain) domain="$scratch/global" ;;
      com.apple.symbolichotkeys) domain="$scratch/hotkeys" ;;
      *) printf 'Unexpected defaults domain: %s\n' "$2" >&2; return 1 ;;
    esac
  fi
  [[ "$1" == write ]]
  shift 2
  command defaults write "$domain" "$@"
}
export -f defaults

hidutil() {
  [[ "$*" == 'list --matching keyboard --ndjson' ]]
  case "${keyboard_discovery:-connected}" in
    empty) return 0 ;;
    failed) return 1 ;;
  esac
  printf '%s\n' \
    '{"VendorID":0,"ProductID":0,"LocationID":110}' \
    '{"VendorID":13364,"ProductID":1616,"LocationID":1048576}' \
    '{"VendorID":13364,"ProductID":1616,"LocationID":1048576}' \
    '{"VendorID":1234,"ProductID":5678}'
}
export -f hidutil
command defaults write "$scratch/host" com.apple.keyboard.modifiermapping.13364-1616-0 -array \
  '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771072</integer></dict>' \
  '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771298</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771299</integer></dict>'
command defaults write "$scratch/host" com.apple.keyboard.modifiermapping.9456-321-0 -array
command defaults write "$scratch/host" Unrelated -string keep
command defaults write "$scratch/hotkeys" AppleSymbolicHotKeys -dict-add 999 \
  '<dict><key>enabled</key><false/></dict>'
bash "$repo/macos/defaults-macos-keyboard.sh"
bash "$repo/macos/defaults-macos-keyboard.sh"

plutil -convert json -o - "$scratch/host.plist" | jq -e '
  .Unrelated == "keep" and
  ([to_entries[] | select(.key | startswith("com.apple.keyboard.modifiermapping."))] |
    length == 4 and all(.[];
      [.value[] | select(.HIDKeyboardModifierMappingSrc == 30064771129)] == [{
        HIDKeyboardModifierMappingSrc: 30064771129,
        HIDKeyboardModifierMappingDst: 1095216660483
      }])) and
  .["com.apple.keyboard.modifiermapping.13364-1616-0"][0] == {
    HIDKeyboardModifierMappingSrc: 30064771298,
    HIDKeyboardModifierMappingDst: 30064771299
  } and
  (keys | sort) == (["Unrelated"] + (["0-0-0", "1234-5678-0", "13364-1616-0", "9456-321-0"] |
    map("com.apple.keyboard.modifiermapping." + .)) | sort)' > /dev/null
plutil -extract AppleSymbolicHotKeys json -o - "$scratch/hotkeys.plist" | jq -e '
  .["999"].enabled == false and
  .["163"] == {enabled: true, value: {type: "standard", parameters: [96,50,1572864]}} and
  ([to_entries[] | select(.value.value.type == "button") |
    [.key, .value.enabled, .value.value.parameters]] | sort) == [
    ["38",true,[8,8,262144]], ["39",true,[16,16,262144]],
    ["40",true,[8,8,393216]], ["41",true,[16,16,393216]],
    ["42",true,[4,4,262144]], ["43",true,[4,4,393216]]]' > /dev/null

# Disconnected keyboards still retain their saved mappings.
export keyboard_discovery=empty
command defaults export "$scratch/host" "$scratch/before.plist"
bash "$repo/macos/defaults-macos-keyboard.sh"
command defaults export "$scratch/host" "$scratch/after.plist"
cmp "$scratch/before.plist" "$scratch/after.plist"

# Failed enumeration must stop before any preference writes.
export keyboard_discovery=failed
if bash "$repo/macos/defaults-macos-keyboard.sh"; then
  printf 'Expected failed keyboard discovery to stop the script\n' >&2
  exit 1
fi
command defaults export "$scratch/host" "$scratch/after.plist"
cmp "$scratch/before.plist" "$scratch/after.plist"

printf 'macOS keyboard and mouse shortcut tests passed\n'
