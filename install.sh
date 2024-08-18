#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

user='' # Change this
if [ -z "$user" ]; then
    echo "Edit this script to set a user to install the application"
    exit 1
fi

read -p "Install or uninstall (1/2): " option

check_error() {
    if [ $? -ne 0 ]; then
        echo -e "\n>>> Operation failed. Exiting."
        exit 1
    fi
}

if [ "$option" == "1" ]; then
    mkdir -p /opt/UserUpdater/
    check_error

    cp ./user_update.sh /opt/UserUpdater/user_update.sh
    check_error

    chown root:root /opt/UserUpdater/user_update.sh
    check_error

    chmod 700 /opt/UserUpdater/user_update.sh
    check_error

    echo "[Desktop Entry]
Name=User Apps Updater
Exec=sudo /opt/UserUpdater/user_update.sh
Icon=synaptic
Comment=User apps updater
Type=Application
Terminal=true
Encoding=UTF-8
Categories=System;Settings;" > /usr/share/applications/updater.desktop
    check_error

    chmod +x /usr/share/applications/updater.desktop
    check_error

    mkdir -p /home/$user/.config/autostart
    check_error

    echo "[Desktop Entry]
Name=User Apps Updater
Exec=sudo /opt/UserUpdater/user_update.sh -y
Hidden=true
Comment=User apps updater
Type=Application
Terminal=true" > /home/$user/.config/autostart/updater.desktop
    check_error
    
    chown $user:$user /home/$user/.config/autostart/updater.desktop
    check_error

    echo "*** (Optional) Open /etc/sudoers and paste:
    $user  ALL=(ALL) NOPASSWD: /opt/UserUpdater/user_update.sh

under the next line:
    # Allow members of group sudo to execute any command
    %sudo   ALL=(ALL:ALL) ALL"

    echo -e "\n=== Successfully installed ==="

elif [ "$option" == "2" ]; then
    rm -r /opt/UserUpdater/
    check_error

    rm /usr/share/applications/updater.desktop
    check_error

    rm /home/$user/.config/autostart/updater.desktop
    check_error

    echo -e "\n=== Successfully uninstalled ==="
else
    echo -e "\nInvalid option. Please choose 1 to install or 2 to uninstall."
    exit 1
fi
