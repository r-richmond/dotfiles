#!/usr/bin/env bash

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari.plist UniversalSearchEnabled -bool false
defaults write com.apple.Safari.plist SuppressSearchSuggestions -bool true

# Press Tab to highlight each item on a web page
defaults write com.apple.Safari.plist WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari.plist com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari.plist ShowFullURLInSmartSearchField -bool true

# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari.plist HomePage -string "about:blank"

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari.plist AutoOpenSafeDownloads -bool false

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari.plist ShowFavoritesBar -bool false

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari.plist DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu
defaults write com.apple.Safari.plist IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari.plist FindOnPageMatchesWordStartsOnly -bool false

# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari.plist ProxiesInBookmarksBar "()"

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari.plist IncludeDevelopMenu -bool true
defaults write com.apple.Safari.plist WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari.plist com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable continuous spellchecking
defaults write com.apple.Safari.plist WebContinuousSpellCheckingEnabled -bool true
# Disable auto-correct
defaults write com.apple.Safari.plist WebAutomaticSpellingCorrectionEnabled -bool false

# Disable AutoFill
defaults write com.apple.Safari.plist AutoFillFromAddressBook -bool false
defaults write com.apple.Safari.plist AutoFillPasswords -bool false
defaults write com.apple.Safari.plist AutoFillCreditCardData -bool false
defaults write com.apple.Safari.plist AutoFillMiscellaneousForms -bool false

# Warn about fraudulent websites
defaults write com.apple.Safari.plist WarnAboutFraudulentWebsites -bool true

# Disable plug-ins
defaults write com.apple.Safari.plist WebKitPluginsEnabled -bool false
defaults write com.apple.Safari.plist com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

# Disable Java
defaults write com.apple.Safari.plist WebKitJavaEnabled -bool false
defaults write com.apple.Safari.plist com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

# Block pop-up windows
# defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Enable “Do Not Track”
defaults write com.apple.Safari.plist SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
defaults write com.apple.Safari.plist InstallExtensionUpdatesAutomatically -bool true
