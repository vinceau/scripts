#!/usr/bin/env bash

# Title: Driver for disabling the Mac boot sound
# Description: This is a simple command line driver for disabling the
# sound that gets played on boot.
# Author: vinceau <vinceau09@gmail.com>

mute_path=/Library/Scripts/mute.sh
mute_text="#"'!'"/bin/bash\nosascript -e 'set volume with output muted'"

unmute_path=/Library/Scripts/unmute.sh
unmute_text="#"'!'"/bin/bash\nosascript -e 'set volume without output muted'"

function patch() {
    echo -e "$mute_text" > "$mute_path"
    chmod u+x "$mute_path"
    echo " + Generated mute script to $mute_path"

    echo -e "$unmute_text" > "$unmute_path"
    chmod u+x "$unmute_path"
    echo " + Generated unmute script to $unmute_path"

    defaults write com.apple.loginwindow LogoutHook $mute_path
    echo " + Binding mute script to logout"
    defaults write com.apple.loginwindow LoginHook $unmute_path
    echo " + Binding unmute script to login"
    echo " + Finished patching."
    echo
    echo "Successfully disabled boot sound! Please reboot your system to verify."
    echo "Run this script again if you would like to re-enable the boot sound."
}

function unpatch() {
    rm -f "$mute_path"
    echo " + Removed $mute_path"
    rm -f "$unmute_path"
    echo " + Removed $unmute_path"
    defaults delete com.apple.loginwindow LogoutHook
    echo " + Unbound mute script"
    defaults delete com.apple.loginwindow LoginHook
    echo " + Unbound unmute script"
    echo " + Finished unpatching."
    echo
    echo " Successfully re-enabled boot sound!"
    echo " Please reboot your system to verify."
}

function quit() {
    read -p "Press any key to close this program."
    exit
}

if [[ `id -u` == "0" ]]; then
    echo " Confirmed that the script is running as root (uid `id -u`)."
fi

# Banner
echo
echo "---------------------- Disable Boot Sound Patch ----------------------"

# Make sure the script is running as root.
if [[ `id -u` != "0" ]]; then
    echo " This patch requires that you run it as root.  Trying: sudo $0"
    sudo "$0"
    exit
fi

# Print a banner and confirm that the user has root access.
if [[ "$1" != "--nobanner" ]]; then
    echo " This program will patch the system to prevent the boot sound from"
    echo " sounding whenever you boot the computer."
    echo
    echo " It achieves this by creating scripts to mute the system when you"
    echo " logout and unmute the system when you log back in."
    echo
    echo " After patching, you may also re-run this program to restore the"
    echo " original functionality."
    echo
    echo " This program comes with ABSOLUTELY NO WARRANTY; please see the"
    echo " included license file for details."
    echo
fi


# Check if the program has already been in patched, in which case, present the
# option to restore the original file.
confirm=1
if [ -f "$mute_path" ] && [ -f "$unmute_path" ]; then
    echo " Your system appears to have already been patched. "
    echo -n " Would you like to undo the patch? (y/N) "
    read revert
    revert=`echo "$revert" | tr '[:lower:]' '[:upper:]' | cut -b 1`
    if [[ "$revert" != "Y" ]]; then
        echo " Good bye. "
        echo
        quit
    fi

    # Remove script files and unbind hooks
    echo
    unpatch
    echo
    quit
fi

# === Otherwise, we are patching the original file for the first time.

# Get a final confirmation from the user.
echo
echo -n "Everything is ready. Would you like to apply the patch? (y/N) "
read go_ahead
go_ahead=`echo "$go_ahead" | tr '[:lower:]' '[:upper:]' | cut -b 1`
if [[ "$go_ahead" != "Y" ]]; then
    echo "You must answer yes, aborting."
    echo
    quit
fi

# Everything is good, let's patch.
echo "Patching..."
echo
patch
echo
quit
