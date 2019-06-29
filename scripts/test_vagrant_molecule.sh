#!/usr/bin/env bash -e

declare -r LOG_FILE="/tmp/$(basename "${BASH_SOURCE[0]//.sh/}")_$(date +'%Y%m%d').log"

function log_msg() {
  echo "$(date +'%Y-%m-%d %T.%6N')" $@ | tee -a "${LOG_FILE}"
}

[[ -z "${PROJECT_BASEDIR// /}" ]] || declare -r PROJECT_BASEDIR="$(dirname "${BASH_SOURCE[0]}")/../"
[[ -z "${PROJECT_NAME// /}" ]] || declare -r PROJECT_NAME="test_molecule"

log_msg "Deleting all lozanomatheus/molecule boxes"
vagrant box list | awk '/lozanomatheus\/molecule/{ print $1 }' | xargs -I{} vagrant box remove {} --all --force || true

log_msg "Starting the molecule box"
mkdir -p "${PROJECT_BASEDIR}/tmp_test" && cd "${PROJECT_BASEDIR}/tmp_test"
vagrant init lozanomatheus/molecule
vagrant up

log_msg "Generating the molecule structure"
vagrant ssh -c "molecule init role -d docker -r ${PROJECT_NAME}"

log_msg "Uploading the molecule files"
vagrant upload ${PROJECT_BASEDIR}/molecule_test_files/ ${PROJECT_NAME}/

log_msg "Running molecule test"
vagrant ssh -c "cd ${PROJECT_NAME} ; molecule test"
