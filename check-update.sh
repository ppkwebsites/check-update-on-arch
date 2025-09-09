#!/bin/bash

# This script checks for available system updates on Arch Linux using yay or pacman.
# It uses zenity to display a popup window if updates are found.
# It now uses pkexec to provide a graphical password prompt for the upgrade.

# Check if pkexec is installed. If not, inform the user and exit.
if ! command -v pkexec &> /dev/null; then
    zenity --error --title="Error" --text="pkexec is not installed. Please install it with 'sudo pacman -S polkit'."
    exit 1
fi

# Check if yay is installed. If not, default to pacman.
if command -v yay &> /dev/null; then
    PKG_MANAGER="yay"
    CHECK_CMD="yay -Qu"
    UPGRADE_CMD="yay -Syu --noconfirm"
    CLEAN_CMD="yay -Yc --noconfirm"
else
    PKG_MANAGER="pacman"
    CHECK_CMD="pacman -Qu"
    UPGRADE_CMD="pacman -Syu --noconfirm"
    CLEAN_CMD="pacman -Rns \$(pacman -Qtdq) --noconfirm"
fi

# Run the update check and capture the output.
# The "2>/dev/null" redirects stderr to /dev/null to hide any non-critical errors.
UPDATE_LIST=$($CHECK_CMD 2>/dev/null)

# Check if the output is not empty, meaning updates are available.
if [[ -n "$UPDATE_LIST" ]]; then
    # Use zenity to create a popup window.
    zenity --question \
           --title="System Updates Available" \
           --text="Your system needs updating!\n\nDo you want to run a full system upgrade and clean unneeded packages?" \
           --ok-label="Upgrade Now" \
           --cancel-label="Cancel"

    # Capture the exit code from the zenity command.
    if [[ $? -eq 0 ]]; then
        echo "Starting graphical upgrade with $PKG_MANAGER..."

        # Use pkexec to run the upgrade and cleanup commands with a graphical prompt.
        # The "sh -c" command is used to combine both commands into a single execution block for pkexec.
        pkexec sh -c "$UPGRADE_CMD && $CLEAN_CMD"

        # Check the exit status of the pkexec command to see if it was successful.
        if [[ $? -eq 0 ]]; then
            zenity --info --title="Update Complete" --text="The update and cleanup process is complete!"
        else
            zenity --error --title="Update Failed" --text="The update and cleanup process was cancelled or failed."
        fi

    else
        echo "Update cancelled."
        zenity --info --title="Update Cancelled" --text="System update cancelled."
    fi
else
    echo "Your system is up to date."
    zenity --info --title="No Updates" --text="Your system is up to date."
fi

# End of script.
