#!/bin/bash

# Verificar se o script está sendo executado como root
if [ "$(id -u)" -ne 0; then
  echo "Por favor, execute este script como root ou utilizando sudo."
  exit 1
fi

# Atualizar os repositórios
echo "Atualizando os repositórios..."
apt update

# Adicionar o repositório bookworm-backports, se não estiver presente
if ! grep -q "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" /etc/apt/sources.list; then
  echo "Adicionando o repositório bookworm-backports..."
  echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list
  apt update
fi

# Atualizar pacotes existentes
echo "Atualizando pacotes existentes..."
apt upgrade -y

# Remover o firmware-iwlwifi antigo
echo "Removendo o firmware-iwlwifi antigo..."
apt remove -y firmware-iwlwifi

# Instalar o firmware-iwlwifi dos backports
echo "Instalando o firmware-iwlwifi dos backports..."
apt install -y -t bookworm-backports firmware-iwlwifi

# Instalar o kernel 6.9.7 apropriado
echo "Instalando o kernel 6.9.7..."
if mokutil --sb-state | grep -q "enabled"; then
  echo "Secure Boot está habilitado. Instalando o kernel assinado..."
  apt install -y linux-image-6.9.7+bpo-amd64
else
  echo "Secure Boot está desabilitado. Instalando o kernel não assinado..."
  apt install -y linux-image-6.9.7+bpo-amd64-unsigned
fi

# Instalar os headers do kernel 6.9.7
echo "Instalando os headers do kernel 6.9.7..."
apt install -y linux-headers-6.9.7+bpo-amd64

# Atualizar o GRUB
echo "Atualizando o GRUB..."
update-grub

# Adicionar configuração ao alsa-base.conf
echo "Adicionando configuração ao alsa-base.conf..."
echo "options snd-hda-intel dmic_detect=0" >> /etc/modprobe.d/alsa-base.conf

echo "Processo concluído! Por favor, reinicie o sistema para aplicar as mudanças."
