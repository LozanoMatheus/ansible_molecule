#!/usr/bin/env bash

declare -r RELEASE_VERSION="$(<release_version)"
declare -r TMP_FILE="/tmp/${0//\.sh/}_tmp"
declare -r BOX_FILE="molecule.box"

function finish_him() {
  ## Cleaning yum tmp files
  echo "Cleaning tmp files"
  vagrant box remove lozanomatheus/molecule --all
  sleep 5s
  VBoxManage controlvm poweroff "$(<${TMP_FILE})"
  sleep 5s
  VBoxManage unregistervm "$(<${TMP_FILE})" --delete
  sleep 5s
  rm -rf "${BOX_FILE}" .vagrant "${TMP_FILE}"
}
trap finish_him EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGTERM

vagrant up

VBoxManage list vms | awk -F\" 'END {print $2}' | tee "${TMP_FILE}"

[[ ! -f "${BOX_FILE}" ]] && vagrant package --output "${BOX_FILE}"

[[ -f "${BOX_FILE}" ]] && vagrant cloud publish lozanomatheus/molecule "${RELEASE_VERSION// /}" virtualbox "${BOX_FILE}" -d "Molecule to test Ansible Roles" --version-description "Installing Molecule 2.20.1 and all dependencies" --force --release --short-description "Molecule to test Ansible Roles"
