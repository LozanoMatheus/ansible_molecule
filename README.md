[![CircleCI_Badge](https://img.shields.io/circleci/build/github/LozanoMatheus/ansible_molecule/CircleCI.svg?style=plastic)](https://circleci.com/gh/LozanoMatheus/ansible_molecule/tree/CircleCI)

# Vagrant box for Molecule - Testing Ansible roles

## Description

This project is to build a Vagrant box with Molecule and ~~all~~ dependencies.

## How to run the Vagrant box

```bash
vagrant init lozanomatheus/molecule
vagrant up
```

## Testing the Vagrant box

If you want to run a quick test on this Vagrant Box, you can run the script [scripts/test_vagrant_molecule.sh](scripts/test_vagrant_molecule.sh). It will delete the locally box `lozanomatheus/molecule`, create a local directory called `tmp_test`, start the latest box and run the command `molecule test`.

## CircleCI job

You can find the job that's build this image in here: https://circleci.com/gh/LozanoMatheus/ansible_molecule
