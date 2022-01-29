#!/bin/bash

echo -e "\e[34m1\e[0m - Create a samba mount"
echo -e "\e[34m2\e[0m - Edit a samba mount"
read -p "Type an option: " option

while true; do
    case $option in
        1) 
            ./samba-cifs-autofs_create.sh
            break;;
        2) 
            ./samba-cifs-autofs_edit.sh
            break;;
        "exit")
            echo "exit"
            break;;
        *) 
            read -p "enter a valid value: " option;;
    esac
done