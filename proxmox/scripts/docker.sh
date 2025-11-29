#! /bin/bash

VMID=7000
STORAGE=local-zfs

set -x
# rm -f noble-server-cloudimg-amd64.img
# wget -q https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img resize noble-server-cloudimg-amd64.img 8G
qm destroy $VMID
qm create $VMID --name "docker-template" --ostype l26 \
    --memory 4096 --balloon 0 \
    --agent 1 \
    --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
    --cpu host --socket 1 --cores 1 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0
qm importdisk $VMID noble-server-cloudimg-amd64.img $STORAGE
qm set $VMID --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$VMID-disk-1,discard=on
qm set $VMID --boot order=virtio0
qm set $VMID --scsi1 $STORAGE:cloudinit

cat << 'OUTER_EOF' | tee /var/lib/vz/snippets/ubuntu-docker.yaml
#cloud-config
timezone: "America/Sao_Paulo"
runcmd:
    - apt-get update
    - apt-get install -y qemu-guest-agent
    - systemctl enable ssh
    - apt install -y ca-certificates curl
    - install -m 0755 -d /etc/apt/keyrings
    - curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    - chmod a+r /etc/apt/keyrings/docker.asc
    - |
      tee /etc/apt/sources.list.d/docker.sources <<EOF
      Types: deb
      URIs: https://download.docker.com/linux/ubuntu
      Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
      Components: stable
      Signed-By: /etc/apt/keyrings/docker.asc
      EOF
    - apt update
    - apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    - reboot
OUTER_EOF

qm set $VMID --cicustom "vendor=local:snippets/ubuntu-docker.yaml"
qm set $VMID --tags ubuntu-template,noble,cloudinit,docker
qm set $VMID --ciuser $USER
qm set $VMID --sshkeys ~/.ssh/authorized_keys
qm set $VMID --ipconfig0 ip=dhcp
qm template $VMID
