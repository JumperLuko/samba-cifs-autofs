# https://docs.fedoraproject.org/en-US/quick-docs/samba/
echo "=== Creating share to Samba ==="

# Will use your username 

read -p "Create a password to Samba Share? [y/n]: " option
echo ""
case $option in
    y|Y) 
        echo "Please type the password to acess samba share"
        sudo smbpasswd -a $USER
esac

# read -p "Please type the location to share: " location
# read -p "Please type the name of the share: " name
# sudo semanage fcontext --add --type "$name" "$location(/.*)?"

# /etc/samba/smb.conf

read -p "add things on /etc/samba/smb.conf and press enter to restart samba"

sudo systemctl restart smb