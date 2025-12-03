
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "git-server"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = "pve"
  bios = "ovmf"

  efi_disk {
    datastore_id = "local-zfs"
    pre_enrolled_keys = false
  }
  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
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
    interface = "scsi1" # or scsi2, scsi3,...
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

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
