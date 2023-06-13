#!/usr/bin/env bash

declare LOG_FILE="/tmp/$(basename "${BASH_SOURCE[0]//.sh/}")_$(date +'%Y%m%d').log"

function log_msg() {
  echo "$(date +'%Y-%m-%d %T.%6N')" $@ | tee -a "${LOG_FILE}"
}

function finish_him() {
  ## Cleaning yum tmp files
  log_msg "Cleaning tmp files"
  rm -f vagrant_${VAGRANT_VERSION}_x86_64.deb
  sudo apt-get clean
  sudo apt-get autoclean
  sudo apt-get autoremove
}
trap finish_him EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGTERM

function install_virtualbox() {
  log_msg "VirtualBox - Install"
  sudo apt-get update -y &> /dev/null
  sudo apt-get install -y linux-headers-$(uname -r) &> /dev/null
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian \"${LINUX_RELEASE}\" contrib" | sudo tee -a /etc/apt/sources.list
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
  sudo apt-get update -y &> /dev/null
  sudo apt-get install -y virtualbox-6.1 &> /dev/null
  log_msg "VirtualBox version is $(VBoxManage --version)"
}

function install_vagrant() {
  log_msg "Vagrant - Install"
  curl -sLO "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb"
  sudo dpkg -i "vagrant_${VAGRANT_VERSION}_x86_64.deb"
  log_msg "Vagrant version is $(vagrant --version)"
  log_msg "Installing vagrant plugin vagrant-vbguest"
  vagrant plugin install vagrant-vbguest
}
