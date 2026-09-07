#!/usr/bin/env bash

set -eo pipefail

# Discover connected keyboards and include saved mappings for disconnected ones.
# System Settings uses vendor-product-0 keys, not the USB LocationID.
get_keyboard_ids() {
	hidutil list --matching keyboard --ndjson | jq -rs --argjson saved "$1" '
		([.[] | select(.VendorID != null and .ProductID != null) |
			"\(.VendorID)-\(.ProductID)-0"] +
			($saved | keys | map(ltrimstr("com.apple.keyboard.modifiermapping.")))) |
		unique[]'
}

# Save Caps Lock to Escape for every known keyboard, retaining other remaps.
# Unlike hidutil UserKeyMapping, these preferences survive a restart.
preferences=$(mktemp)
trap 'rm -f "$preferences"' EXIT
defaults -currentHost export NSGlobalDomain "$preferences"
saved_mappings=$(osascript -l JavaScript - "$preferences" <<'JAVASCRIPT'
ObjC.import('Foundation');
function run(argv) {
	var preferences = $.NSDictionary.dictionaryWithContentsOfFile(argv[0]);
	if (preferences.isNil()) {
		throw new Error('Could not read current-host keyboard preferences');
	}
	var mappings = {};
	ObjC.deepUnwrap(preferences.allKeys).forEach(function (key) {
		if (/^com\.apple\.keyboard\.modifiermapping\.[0-9]+-[0-9]+-[0-9]+$/.test(key)) {
			mappings[key] = ObjC.deepUnwrap(preferences.objectForKey(key));
		}
	});
	return JSON.stringify(mappings);
}
JAVASCRIPT
)
keyboard_ids=$(get_keyboard_ids "$saved_mappings")
while IFS= read -r keyboard_id; do
	[[ -n "$keyboard_id" ]] || continue
	key="com.apple.keyboard.modifiermapping.$keyboard_id"
	mapping=$(jq -nr --argjson saved "$saved_mappings" --arg key "$key" '
		(($saved[$key] // []) | map(select(.HIDKeyboardModifierMappingSrc != 30064771129))) +
		[{HIDKeyboardModifierMappingSrc: 30064771129, HIDKeyboardModifierMappingDst: 1095216660483}] |
		"<array>" + (map("<dict><key>HIDKeyboardModifierMappingSrc</key><integer>" +
			(.HIDKeyboardModifierMappingSrc | tostring) +
			"</integer><key>HIDKeyboardModifierMappingDst</key><integer>" +
			(.HIDKeyboardModifierMappingDst | tostring) + "</integer></dict>") | join("")) + "</array>"')
	defaults -currentHost write NSGlobalDomain "$key" "$mapping"
done <<< "$keyboard_ids"

# Set a blazingly fast keyboard repeat rate
# lower is faster
defaults write NSGlobalDomain KeyRepeat -int 1
# Set the delay before a held key starts repeating.
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Set mouse and scrolling speed
defaults write NSGlobalDomain com.apple.mouse.scaling -int 1
# Set scroll-wheel speed independently of pointer speed.
defaults write NSGlobalDomain com.apple.scrollwheel.scaling -float 0.6875

# Toggle Notification Center with Command-Option-backtick (symbolic hotkey 163).
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 163 \
	'<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>96</integer><integer>50</integer><integer>1572864</integer></array><key>type</key><string>standard</string></dict></dict>'

# Disable press-and-hold for keys in favor of key repeat.
# defaults write -g ApplePressAndHoldEnabled -bool false

# Disable “natural” (Lion-style) scrolling
#defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Restore Control + mouse buttons, including their Shift (slow animation) variants.
# Button parameters are bitmasks: button 4 = 8, button 5 = 16, button 3 = 4.
set_mouse_shortcut() {
	local shortcut="$1" button="$2" modifiers="$3"
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$shortcut" \
		"<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>$button</integer><integer>$button</integer><integer>$modifiers</integer></array><key>type</key><string>button</string></dict></dict>"
}

# Mission Control: Control + mouse button 4.
set_mouse_shortcut 38 8 262144
# Application Windows: Control + mouse button 5.
set_mouse_shortcut 39 16 262144
# Mission Control: Control + Shift + mouse button 4.
set_mouse_shortcut 40 8 393216
# Application Windows: Control + Shift + mouse button 5.
set_mouse_shortcut 41 16 393216
# Show Desktop: Control + mouse button 3.
set_mouse_shortcut 42 4 262144
# Show Desktop: Control + Shift + mouse button 3.
set_mouse_shortcut 43 4 393216
