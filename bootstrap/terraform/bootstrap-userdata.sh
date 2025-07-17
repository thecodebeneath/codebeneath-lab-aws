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

  sudo systemctl stop docker

  mkdir -p "$docker_data_dir"
  chmod 710 "$docker_data_dir"
  printf '%s\n' "$(cat << EOF
{
  "data-root": "$docker_data_dir"
}
EOF
  )" > /etc/docker/daemon.json

  sudo systemctl enable --now docker
}

function configDockerUser() {
  sudo usermod -aG docker ec2-user
  newgrp docker
}

function installDocker() {
  sudo dnf update -y
  sudo dnf install -y docker

  configDocker
  configDockerUser
}

function main() {
  echo "codebeneath userdata script starting..."
  mountVolume
  installDocker
}

main "$@"
