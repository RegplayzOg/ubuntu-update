#!/bin/bash

# Check if zenity is installed
if ! command -v zenity &> /dev/null
then
    echo "zenity is not installed. Please install it to use the graphical interface."
    echo "You can install it using: sudo apt install zenity"
    exit 1
fi

# Function to update normal Ubuntu packages
update_ubuntu() {
    zenity --info --title="Ubuntu Update" --text="Starting Ubuntu package update..."
    output=$(sudo apt update && sudo apt upgrade -y)
    if [ $? -eq 0 ]; then
        zenity --text-info --title="Ubuntu Update Output" --text="$output"
        zenity --info --title="Ubuntu Update" --text="Ubuntu packages updated successfully."
    else
        zenity --error --title="Ubuntu Update Error" --text="An error occurred during Ubuntu package update."
    fi
}

# Function to update Flatpak packages
update_flatpak() {
    zenity --info --title="Flatpak Update" --text="Starting Flatpak package update..."
    output=$(flatpak update -y)
    if [ $? -eq 0 ]; then
        zenity --text-info --title="Flatpak Update Output" --text="$output"
        zenity --info --title="Flatpak Update" --text="Flatpak packages updated successfully."
    else
        zenity --error --title="Flatpak Update Error" --text="An error occurred during Flatpak package update."
    fi
}

# Function to update both
update_all() {
    zenity --info --title="System Update" --text="Starting update of all packages..."

    zenity --info --title="Ubuntu Update" --text="Updating Ubuntu packages..."
    ubuntu_output=$(sudo apt update && sudo apt upgrade -y)
    ubuntu_status=$?

    zenity --info --title="Flatpak Update" --text="Updating Flatpak packages..."
    flatpak_output=$(flatpak update -y)
    flatpak_status=$?

    combined_output="--- Ubuntu Updates ---\n\n$ubuntu_output\n\n--- Flatpak Updates ---\n\n$flatpak_output"
    zenity --text-info --title="Update Output" --text="$combined_output"

    if [ $ubuntu_status -eq 0 ] && [ $flatpak_status -eq 0 ]; then
        zenity --info --title="System Update" --text="All packages updated successfully."
    elif [ $ubuntu_status -ne 0 ] && [ $flatpak_status -eq 0 ]; then
        zenity --warning --title="System Update" --text="Ubuntu package update failed, but Flatpak packages updated successfully."
    elif [ $ubuntu_status -eq 0 ] && [ $flatpak_status -ne 0 ]; then
        zenity --warning --title="System Update" --text="Flatpak package update failed, but Ubuntu packages updated successfully."
    else
        zenity --error --title="System Update Error" --text="An error occurred during the update process."
    fi
}

# Create the main menu using zenity --list
chosen=$(zenity --list --title="System Updater" --text="Choose an action:" \
              --column=" " --column="Action" \
              --radiolist --print-column=2 \
              FALSE "Update Ubuntu Packages" \
              FALSE "Update Flatpak Packages" \
              FALSE "Update All")

# Perform action based on user choice
case "$chosen" in
    "Update Ubuntu Packages")
        update_ubuntu
        ;;
    "Update Flatpak Packages")
        update_flatpak
        ;;
    "Update All")
        update_all
        ;;
    "")
        zenity --info --title="System Updater" --text="No action selected."
        ;;
    *)
        zenity --error --title="System Updater" --text="Invalid option."
        ;;
esac

exit 0
