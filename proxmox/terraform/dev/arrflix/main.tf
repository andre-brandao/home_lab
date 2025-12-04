module "monitoring" {
  source = "../../modules/docker"

  # VM Configuration
  vm_id          = 110
  vm_name        = "arrflix"
  vm_description = "Managed by Terraform - Docker VM"
  vm_tags        = ["terraform", "ubuntu", "docker"]

  # Hardware Resources
  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 30

  # Network Configuration
  node_name      = "pve"
  datastore_id   = "local-zfs"
  ip_address     = "dhcp"
  network_bridge = "vmbr0"

  # Cloud Image - reuse existing image to avoid conflicts
  cloud_image_id = "local:import/noble-server-cloudimg-amd64.qcow2"

  # OS Configuration
  hostname = "arrflix"
  timezone = "America/Sao_Paulo"

  # SSH Keys
  ssh_keys = [
    trimspace(file("~/.ssh/id_ed25519.pub")),
    trimspace(file("~/.ssh/pve.pub"))
  ]

  # Additional packages (if needed)
  additional_packages = [
    "htop",
    "vim",
    "git"
  ]
}
