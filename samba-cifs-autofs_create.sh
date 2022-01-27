#!/bin/bash
# Script by JumperLuko jumperluko.github.io
# https://wiki.archlinux.org/title/Autofs

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

echo -e "\n=== Mapping Samba server ===\n"
read -p "IP: " ip
read -p "User: " user
read -s -p "Password: " pass
echo ""
read -p "workgroup: (empty for without) [common=workgroup]" domain
read -p "Folder [default=Servidor] " folder

# Default folder
if [ "$folder" == "" ];then
    folder=Servidor
fi

# Only write if there is no path text, $1 is text, $2 is path
writeTextIfNotExist(){
    
    if ! [ -e "$2" ];then
        sudo bash -c "sudo echo $1 >> $2"
    else
        checkText=`grep "$1" "$2"`
        if [ "$checkText" == "" ];then
            sudo bash -c "sudo echo $1 >> $2"
        fi
    fi
}

# Write to auto.master mount path
writeTextIfNotExist "/mnt/samba/ $autofsDir/auto.samba --timeout 60 --browse" "$autofsDir/auto.master"

# Create credential folder if it doesn't exist, and only allow root
if ! [ -e "$autofsDir/credentials/" ]; then
    sudo mkdir $autofsDir/credentials/
    sudo chown root:root $autofsDir/credentials/
    sudo chmod 600 $autofsDir/credentials/
fi

# Mount samba
writeTextIfNotExist "$ip-$folder -fstype=cifs,credentials=$autofsDir/credentials/$ip-$folder.txt,noperm,nounix,file_mode=0777,dir_mode=0777 ://$ip/$folder" "$autofsDir/auto.samba"

# Save the credentials
if [ "$domain" == "" ];then
    sudo bash -c "echo -e \"user=$user\npassword=$pass\" > $autofsDir/credentials/$ip-$folder.txt"
else
    sudo bash -c "sudo echo -e \"user=$user\npassword=$pass\ndomain=$domain\" > $autofsDir/credentials/$ip-$folder.txt"
fi

# Remove permission for non-root users to read credential file
sudo chown root:root $autofsDir/credentials/$ip-$folder.txt
sudo chmod 600 $autofsDir/credentials/$ip-$folder.txt

# Restart and start on boot
sudo systemctl restart autofs.service 
sudo systemctl enable autofs.service

# Show location and create link
echo -e "\nCreated on /mnt/samba/$ip-$folder"
ln -s /mnt/samba/$ip-$folder $HOME
echo "ln -s /mnt/samba/$ip-$folder $(pwd)"

# Cleaning variables
unset ip user pass folder domain autofsDir checkText