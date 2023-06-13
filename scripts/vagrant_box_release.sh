#!/usr/bin/env bash

declare -xr PROJECT_BASEDIR="$(dirname "${BASH_SOURCE[0]}")/../"
declare -r  RELEASE_VERSION="$(<${PROJECT_BASEDIR}/release_version)"
declare -r  BOX_FILE="${PROJECT_BASEDIR}/molecule.box"
declare     TMP_FILE="/tmp/$(basename "${BASH_SOURCE[0]//.sh/}")_tmp"
declare     LOG_FILE="/tmp/$(basename "${BASH_SOURCE[0]//.sh/}")_$(date +'%Y%m%d').log"

function log_msg() {
  echo "$(date +'%Y-%m-%d %T.%6N')" $@ | tee -a "${LOG_FILE}"
}

function finish_him() {
  ## Cleaning yum tmp files
  log_msg "Cleaning tmp files"
  vagrant box list | awk -F' ' '{print $1}' | xargs -I{} vagrant box remove {} --all --force || true
  sleep 5s
  
  log_msg "Shutting down the VM"
  set -vx
  VBoxManage controlvm "$(<${TMP_FILE})" poweroff || true
  set +vx
  sleep 5s
  
  log_msg "Cleaning up the VM"
  set -vx
  VBoxManage unregistervm "$(<${TMP_FILE})" --delete || true
  set +vx
  sleep 5s
  
  log_msg "Cleaning up local files"
  rm -rf .vagrant "${TMP_FILE}" || true
  set +vx
}
trap finish_him EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGTERM

function build_vagrant_box() {
  [[ ! -z "${VAGRANT_CLOUD_TOKEN// /}" ]] || log_msg "Variable VAGRANT_CLOUD_TOKEN is not defined. Setup the variable or run the command: vagrant cloud auth login ..."
  vagrant up --provider=virtualbox || true
  log_msg "Getting all VirtualBox VMs"
  VBoxManage list vms | awk -F\" 'END {print $2}' | tee "${TMP_FILE}"
  cat ${TMP_FILE}
  log_msg "Listing the VMs"
  VBoxManage list vms
  log_msg "Generating a Vagrant box file. The file name is: ${BOX_FILE}"
  [[ ! -f "${BOX_FILE}" ]] && vagrant package --output "${BOX_FILE}"
}

function publish_vagrant_box() {
  log_msg "Publishing the Vagrant Box to https://app.vagrantup.com/lozanomatheus/boxes/molecule"
    [[ -f "${BOX_FILE}" ]] && vagrant cloud publish lozanomatheus/molecule "${RELEASE_VERSION// /}" virtualbox "${BOX_FILE}" -d "Molecule to test Ansible Roles" --version-description "Installing Molecule 2.20.1 and all dependencies" --force --release --short-description "Molecule to test Ansible Roles"
  rm -f "${BOX_FILE}"
}
