#!/usr/bin/env bash

function quit() {
    echo
    read -p "Press any key to close this program."
    exit
}

echo
if [[ `id -u` == "0" ]]; then
    echo "Script is running as root (uid `id -u`)."
else
    # Make sure the script is running as root.
    echo " This patch requires that you run it as root.  Trying: sudo $0"
    sudo "$0"
    exit
fi

echo " > don't prompt about security for programs in ~/Downloads"
xattr -d -r com.apple.quarantine ~/Downloads

echo " > disable warnings about programs downloaded from the internet"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo " > don't capture shadows in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# I don't think this actually does anything
echo " > remove dock delay"
# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

echo " > disable accent characters on vowel key hold"
defaults write -g ApplePressAndHoldEnabled -bool false

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# disable the slow motion hide/show mission control thing
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:34:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:35:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:37:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist

quit
