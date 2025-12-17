resource "proxmox_virtual_environment_container" "nixos_container" {
  description = "nixos"

  node_name = "pve"
  vm_id     = null # Will use next available ID from Proxmox

  operating_system {
    type             = "unmanaged"
    template_file_id = "local:vztmpl/nixos-image-lxc-proxmox-25.11.20251206.d9bc5c7-x86_64-linux.tar.xz"
  }

  cpu {
    # architecture = "amd64"
    cores = 4 # Default, adjust as needed
  }

  memory {
    dedicated = 8192 # 8GB RAM
  }

  disk {
    datastore_id = "local-zfs"
    size         = 80 # 80GB disk
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
    enabled  = true
    firewall = true
  }

  initialization {
    hostname = "nixos"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

  }

  console {
    enabled = true
    type    = "console"
  }

  features {
    nesting = true
  }

  started      = true
  unprivileged = true

  tags = ["terraform", "nixos", "lxc"]
}

# resource "random_password" "container_password" {
#   length           = 5
#   override_special = "_%@"
#   special          = true
# }

# output "container_password" {
#   value     = random_password.container_password.result
#   sensitive = true
# }
