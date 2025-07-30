#!/bin/bash

#
# Check the log of your user data script in:
# /var/log/cloud-init.log and
# /var/log/cloud-init-output.log
#

set -eou pipefail

declare MOUNT_POINT="/data"

function mountVolume() {
  local device

  sleep 30s
  device="/dev/$(lsblk -o NAME,TYPE,FSTYPE -dn | awk '$2 == "disk" {print $1}' | tail -n 1)"

  local fs_type; fs_type=$(file -s "$device" | awk '{print $2}')
  if [ "$fs_type" = "data" ] ; then
    echo "codebeneath formatting device"
    mkfs -t xfs "$device"
  else
    fs_type="$(lsblk -no FSTYPE "$device")"
    if [ "$fs_type" != "xfs" ] ; then
      echo "codebeneath unexpected fstype: $fs_type"
      exit 1
    fi
  fi

  mkdir -p "$MOUNT_POINT"
  blk_id=$(blkid "$device" | cut -d" " -f2)
  echo "$blk_id     $MOUNT_POINT   xfs    defaults   0   2" | tee -a /etc/fstab
  mount -a
}

function configDocker() {
  local docker_data_dir="$MOUNT_POINT/docker"

  systemctl stop docker

  mkdir -p "$docker_data_dir"
  chmod 710 "$docker_data_dir"
  printf '%s\n' "$(cat << EOF
{
  "data-root": "$docker_data_dir"
}
EOF
  )" > /etc/docker/daemon.json

  systemctl enable --now docker
}

function configDockerUser() {
  usermod -aG docker ec2-user
  newgrp docker
}

function installDocker() {
  dnf update -y
  dnf install -y docker

  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/libexec/docker/cli-plugins/docker-compose
  chmod +x /usr/libexec/docker/cli-plugins/docker-compose

  configDocker
  configDockerUser
}

function gitlabSetup() {
  mkdir -p /home/ec2-user/gitlab && chown ec2-user:ec2-user /home/ec2-user/gitlab
  mkdir -p /"$MOUNT_POINT"/gitlab/config
  mkdir -p /"$MOUNT_POINT"/gitlab/logs
  mkdir -p /"$MOUNT_POINT"/gitlab/data
  chown -R ec2-user:ec2-user /"$MOUNT_POINT"/gitlab
}

function main() {
  echo "codebeneath userdata script starting..."
  mountVolume
  installDocker
  gitlabSetup
}

main "$@"
