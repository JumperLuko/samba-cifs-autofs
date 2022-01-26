#!/bin/bash

# Set directory if it exists
if [ -e "/etc/autofs/" ]; then
    autofsDir="/etc/autofs"
elif [ -e "/etc/auto.master" ]; then
    autofsDir="/etc"
else
    echo "Directory not found, stoping!"
    sleep 5
    exit
fi

# Function yes or no
yes_no() {
    unset yes_or_no;
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) yes_or_no="yes" && return 0 ;;  
            [Nn]*) yes_or_no="no" && return 1 ;;
        esac
        yes_or_no="null"
    done
}

# sudo nano "$autofsDir/auto.master"

echo -e "\n Edit samba mount?"
yes_no;if [ "$yes_or_no" == "yes" ];then
    sudo nano "$autofsDir/auto.samba"
fi

echo -e "\nSaved credentials files"
sudo ls $autofsDir/credentials/

echo ""
read -p "Write the credentials file to remove or press enter to ignore: " credFile
if [ "$credFile" != "" ];then
    sudo rm $autofsDir/credentials/$credFile
fi

echo -e "\nEdit some credentials?"
yes_no;if [ "$yes_or_no" == "yes" ];then
    echo ""
    read -p "Credential file to edit: " credFile
    read -p "User: " user
    read -s -p "Password: " pass
    echo ""
    read -p "workgroup: (empty for without) [common=workgroup] " domain

    # Save the credentials
    if [ "$domain" == "" ];then
        sudo bash -c "echo -e \"user=$user\npassword=$pass\" > $autofsDir/credentials/$credFile"
    else
        sudo bash -c "sudo echo -e \"user=$user\npassword=$pass\ndomain=$domain\" > $autofsDir/credentials/$credFile"
    fi

    # Create credential folder if it doesn't exist, and only allow root
    if ! [ -e "$autofsDir/credentials/" ]; then
        sudo mkdir $autofsDir/credentials/
        sudo chown root:root $autofsDir/credentials/
        sudo chmod 600 $autofsDir/credentials/
    fi
fi