#!/usr/bin/env bash

declare LOG_FILE="/tmp/$(basename "${BASH_SOURCE[0]//.sh/}")_$(date +'%Y%m%d').log"

echo "LOG_FILE001___${LOG_FILE}___"

function log_msg() {
  echo "$(date +'%Y-%m-%d %T.%6N')" $@ | tee -a "${LOG_FILE}"
}

function finish_him() {
  # Cleaning yum tmp files
  log_msg "Cleaning yum tmp files"
  yum clean all
  rm -rf /var/cache/yum /tmp/* /vagrant
}
trap finish_him EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGTERM

cat <<\EOF >> /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
PATH+=:/usr/local/bin
EOF

## Installing epel and python 3.6
log_msg "Installing epel and python 3.6"
yum -y -q install epel-release centos-release &> /dev/null

# Dependencies for Virtualbox Guest Additions
log_msg "Installing dependencies for Virtualbox Guest Additions"
yum -y -q install gcc binutils cpp glibc-devel glibc-headers kernel-headers libmpc mpfr glibc glibc-common libgcc libgomp &> /dev/null

## Dependencies for molecule
log_msg "Installing dependencies for molecule"
yum -y -q install kernel-devel python36 python36-devel gcc openssl-devel libselinux-python &> /dev/null
alternatives --install /usr/bin/python3 python3 /usr/bin/python36 0

## Installing Docker
log_msg "Installing Docker"
curl -fsSL https://get.docker.com | sh
usermod -aG docker vagrant
systemctl enable docker
systemctl start docker

## Installing pip (latest+all deps) with/for python36
log_msg "Installing pip (latest+all deps) with/for python36"
curl -L https://bootstrap.pypa.io/get-pip.py | python3

## Installing Molecule
log_msg "Installing Molecule"
/usr/local/bin/pip install --no-cache-dir -U molecule

## Fixing/updating testinfra and installing docker
log_msg "Fixing/updating testinfra and installing docker"
/usr/local/bin/pip install --no-cache-dir 'testinfra>=3.0.0' docker

## Fix selinux molecule bug (Will be fix >2.20.1)
log_msg "Fix selinux molecule bug (Will be fix >2.20.1)"
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
