#!/bin/bash
echo "Execute with sudo permissions"

#change this
user=''
terminal=''
if [ -z "$terminal" ] || [ -z "$user" ]; then
    echo "Set a user and a terminal to open application"
    exit
fi

read -p "Install or uninstall (1/2): " option

# Verificar el valor ingresado
if [ "$option" == "1" ]; then
    mkdir /opt/UserUpdater/
	cp ./user_update.sh /opt/UserUpdater/user_update.sh
	chown root:root /opt/UserUpdater/user_update.sh
	chmod 700 /opt/UserUpdater/user_update.sh
	
	echo "[Desktop Entry]
	Name=User Apps Updater
	Exec=sudo /opt/UserUpdater/user_update.sh
	Icon=synaptic
	Comment=User apps updater
	Type=Application
	Terminal=true
	Encoding=UTF-8
	Categories=System;Settings;" > /usr/share/applications/updater.desktop
	
	chmod +x /usr/share/applications/updater.desktop
	
	echo "[Desktop Entry]
	Exec=$terminal -e sudo /opt/UserUpdater/user_update.sh -y
	Name=User Apps Updater
	Type=Application
	Version=1.0" > /home/$user/.config/autostart/updater.desktop
	
	echo "(Optional) Open /etc/sudoers and paste:
user  ALL=(ALL) NOPASSWD: /opt/UserUpdater/user_update.sh

under the next line:
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL"
	echo "=== Successfully installed ==="
	
elif [ "$option" == "2" ]; then
    rm -r /opt/UserUpdater/
    rm /usr/share/applications/updater.desktop
    rm /home/$user/.config/autostart/updater.desktop
    
    echo "=== Successfully uninstalled ==="
fi


