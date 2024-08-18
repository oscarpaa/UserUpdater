#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m'
apps_to_update=""
updated_apps_count=0
apps_sections=()
sorted_sections=()
#selected_sections=''
selected_sections='graphics|web|mail|sound|video|editors|text' #empty to select all
seconds_to_wait=5

echo -e "\n=== Updating repositories ==="
apt-get update

readarray -t available_apps < <(apt list --upgradable 2>/dev/null | awk -F "/" '{print $1}' | tail -n +2)

for app in "${available_apps[@]}"; do
    section=$(sed -n "/Package: $app/,/Package:/p" /var/lib/dpkg/status | sed -n '1,/^Package:/p' | grep Section | awk '{print $2}')
    apps_sections+=("$section")
done

sorted_sections=($(echo "${apps_sections[@]}" | tr ' ' '\n' | sort -u))
available_sections=$(echo "${sorted_sections[@]}" | tr ' ' '|')
echo -e "\n=== Available categories ===\n${available_sections[@]}"
echo -e "\n=== Selected categories (empty to select all) ===\n$selected_sections"

echo -e "\n=== List of apps selected ==="
for i in "${!available_apps[@]}"; do 
    app="${available_apps[$i]}"
    section="${apps_sections[$i]}"
   	if [ -z "$selected_sections" ] || 
   		[[ $(echo "$section" | grep -w -E $selected_sections) != "" ]]; then
    printf "${GREEN}$app${NC}/$section\n"
    apps_to_update+="$app "
    updated_apps_count=$((updated_apps_count+1))
fi

done

if [ $updated_apps_count -eq 1 ]; then
    echo -e "\n=== $updated_apps_count update ==="
else
    echo -e "\n=== $updated_apps_count updates ==="
fi
	
if [ $updated_apps_count -gt 0 ]; then 
	echo -e "$apps_to_update\n"
	command_to_update_y="apt-get --only-upgrade -y install $apps_to_update"
	command_to_update="apt-get --only-upgrade install $apps_to_update"
	command_simulation="apt-get --only-upgrade install --simulate $apps_to_update"
	if [[ $1 == "-y" ]]; then
    	$command_to_update_y
	else
    	read -p "Do you want to update? (yes/sim): " response
    	response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    	if [[ $response == "yes" || $response == "y" ]]; then
        	$command_to_update
    	elif [[ $response == "sim" ]]; then
    		$command_simulation
    	fi
	fi
fi

echo -e "\nPress any key to exit or 'c' to stop timer"
for i in $(seq $seconds_to_wait -1 1); do
    echo -ne "$i seconds remaining \r"
    read -t 1 -n 1 -s -r key
    if [ -n "$key" ]; then
    	key=$(echo "$key" | tr '[:upper:]' '[:lower:]')
    	if [[ $key == "c" ]]; then
    		echo -e "\nPress any key to exit"
    		read -n 1 -s key
    	fi
    	echo "You pressed a key, exiting..."
    	exit
    fi
done

if [ -z "$key" ]; then
    echo "$seconds_to_wait seconds have passed, exiting..."
fi
