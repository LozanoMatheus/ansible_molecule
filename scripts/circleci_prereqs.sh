#!/usr/bin/env bash

declare LOG_FILE="/tmp/$(basename "${BASH_SOURCE[0]//.sh/}")_$(date +'%Y%m%d').log"

function log_msg() {
  echo "$(date +'%Y-%m-%d %T.%6N')" $@ | tee -a "${LOG_FILE}"
}

function finish_him() {
  ## Cleaning yum tmp files
  log_msg "Cleaning tmp files"
  rm -f vagrant_${VAGRANT_VERSION}_x86_64.deb
  sudo apt clean
  sudo apt autoclean
  sudo apt autoremove
}
trap finish_him EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGTERM

function install_virtualbox() {
  set -x
  log_msg "VirtualBox - Install"
  sudo apt update -y
  sudo apt install -y linux-headers-$(uname -r) build-essential dkms
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian ${LINUX_RELEASE} contrib" | sudo tee -a /etc/apt/sources.list
  wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
  sudo apt update -y
  sudo apt install -y virtualbox-6.1
  log_msg "VirtualBox version is $(VBoxManage --version)"
}

function install_vagrant() {
  log_msg "Vagrant - Install"
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt install vagrant -y
  log_msg "Vagrant version is $(vagrant --version)"
  log_msg "Installing vagrant plugin vagrant-vbguest"
  vagrant plugin install vagrant-vbguest
}
