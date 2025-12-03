resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name    = "noble-server-cloudimg-amd64.qcow2"

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}


resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: git
    timezone: America/Sao_Paulo
    users:
      - default
      - name: git
        groups:
          - sudo
          - docker
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(file("~/.ssh/id_ed25519.pub"))}
          - ${trimspace(file("~/.ssh/pve.pub"))}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    write_files:
      - path: /home/git/tea/docker-compose.yml
        content: |
              ${indent(10, file("${path.module}/template/docker-compose.yaml"))}
        owner: 'git:docker'
        defer: true
      - path: /etc/systemd/system/tea.service
        content: |
              ${indent(10, file("${path.module}/template/tea.service"))}
        owner: 'root:root'
        permissions: '0644'
        defer: true
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - apt install -y ca-certificates curl
      - install -m 0755 -d /etc/apt/keyrings
      - curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      - chmod a+r /etc/apt/keyrings/docker.asc
      - |
        tee /etc/apt/sources.list.d/docker.sources <<EOF_D
        Types: deb
        URIs: https://download.docker.com/linux/ubuntu
        Suites: $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}")
        Components: stable
        Signed-By: /etc/apt/keyrings/docker.asc
        EOF_D
      - apt update
      - apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      - mkdir -p /home/git/tea
      - chown -R git:docker /home/git/tea
      - systemctl daemon-reload
      - systemctl enable tea.service
      - echo "done" > /tmp/cloud-config.done
      - reboot
    EOF

    file_name = "ubuntu-vm-cloud-config.yaml"

  }
}
