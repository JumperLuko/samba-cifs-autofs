#!/bin/bash

folder=Servidor
#domain=workgroup

echo -e "\n=== Mapeando servidor Samba ===\n"
read -p "Qual IP? " ip
read -p "Qual o usuário? " user
read -s -p "Qual a senha? " pass
echo ""
read -p "Qual o nome da pasta? [padrão=Servidor] " folder
#read -p "Qual o dominio / grupo de trabalho? [padrao=workgroup]" domain

# Define diretório se existir
if [ -e "/etc/autofs/" ]; then
    autofsDir="/etc/autofs"
elif [ -e "/etc/auto.master" ]; then
    autofsDir="/etc"
fi

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
escreveTextoSeNaoExistir '/mnt/samba/ $autofsDir/auto.samba --timeout 60 --browse' '$autofsDir/auto.master'

# Cria pasta de credenciais se não existir, e permite somente root
if ! [ -e "$autofsDir/credentials/" ]; then
    sudo mkdir $autofsDir/credentials/
    sudo chown root:root $autofsDir/credentials/
    sudo chmod 600 $autofsDir/credentials/
fi

# Monta samba
escreveTextoSeNaoExistir "$ip-$folder -fstype=cifs,credentials=$autofsDir/credentials/$ip-$folder.txt,noperm,nounix,file_mode=0777,dir_mode=0777 ://$ip/$folder" '$autofsDir/auto.samba'

# Salva as credenciais
if [ "$domain" == "" ];then
    sudo bash -c "echo -e \"user=$user\npassword=$pass\" > $autofsDir/credentials/$ip-$folder.txt"
else
    sudo bash -c "sudo echo -e \"user=$user\npassword=$pass\ndomain=$domain\" > $autofsDir/credentials/$ip-$folder.txt"
fi

# Tirar permissão para usuáios não root lerem arquivo de credenciais
sudo chown root:root $autofsDir/credentials/$ip-$folder.txt
sudo chmod 600 $autofsDir/credentials/$ip-$folder.txt

# Limpeza de variaveis
unset ip user pass folder domain autofsDir verificaTexto