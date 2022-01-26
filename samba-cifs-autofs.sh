#!/bin/bash

folder=Servidor
#dominio=workgroup

echo -e "\n=== Mapeando servidor Samba ===\n"
read -p "Qual IP? " ip
read -p "Qual o usuário? " user
read -s -p "Qual a senha? " pass
echo ""
read -p "Qual o nome da pasta? [padrão=Servidor] " folder
#read -p "Qual o dominio / grupo de trabalho? [padrao=workgroup]" domain

# Somente escreve se não tiver o texto do caminho, $1 é texto, $2 é caminho 
escreveTextoSeNaoExistir(){
    
    if ! [ -e "$2" ];then
        sudo bash -c "sudo echo $1 >> $2"
    else
        verificaTexto=`grep "$1" "$2"`
        if [ "$verificaTexto" == "" ];then
            sudo bash -c "sudo echo $1 >> $2"
        fi
    fi
}

# Escreve em auto.master caminho da montagem
escreveTextoSeNaoExistir '/mnt/samba/ /etc/autofs/auto.samba --timeout 60 --browse' '/etc/autofs/auto.master'

# Cria pasta de credenciais se não existir, e permite somente root
if ! [ -e "/etc/autofs/credentials" ]; then
    sudo mkdir /etc/autofs/credentials
    sudo chown root:root /etc/autofs/credentials
    sudo chmod 600 /etc/autofs/credentials
fi

# Monta samba
escreveTextoSeNaoExistir "$ip-$folder -fstype=cifs,credentials=/etc/autofs/credentials/$ip-$folder.txt,noperm,nounix,file_mode=0777,dir_mode=0777 ://$ip/$folder" '/etc/autofs/auto.samba'

# Salva as credenciais
if [ "$domain" == "" ];then
    sudo bash -c "echo -e \"user=$user\npassword=$pass\" > /etc/autofs/credentials/$ip-$folder.txt"
else
    sudo bash -c "sudo echo -e \"user=$user\npassword=$pass\ndomain=$domain\" > /etc/autofs/credentials/$ip-$folder.txt"
fi

# Tirar permissão para usuáios não root lerem arquivo de credenciais
sudo chown root:root /etc/autofs/credentials/$ip-$folder.txt
sudo chmod 600 /etc/autofs/credentials/$ip-$folder.txt

# Limpeza de variaveis
unset ip user pass folder domain