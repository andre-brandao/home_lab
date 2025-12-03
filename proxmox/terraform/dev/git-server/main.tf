
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "git-server"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = "pve"

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-zfs"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    # uncomment and specify the datastore for cloud-init disk if default `local-lvm` is not available
    datastore_id = "local-zfs"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # user_account {
    #   username = "git"
    #   password = random_password.ubuntu_vm_password.result
    #   keys = [
    #     trimspace(file("~/.ssh/id_ed25519.pub")),
    #     trimspace(file("~/.ssh/pve.pub"))
    #   ]
    # }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

}

# resource "tls_private_key" "ubuntu_vm_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }
