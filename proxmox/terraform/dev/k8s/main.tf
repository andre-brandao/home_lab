module "cluster" {
  source = "../../modules/proxmox-talos-k8s-cluster"

  image = {
    version = "v1.11.5"
    # update_version = "v1.11.3"
    schematic_path =  "image/schematic.yaml"
    # update_schematic_path = "image/schematic-updated.yaml"
  }

  cluster = {
    name    = "talos-dev"
    vip     = "192.168.0.2"
    gateway = "192.168.0.1"
    # The version of talos features to use in generated machine configuration. Generally the same as image version.
    # See https://github.com/siderolabs/terraform-provider-talos/blob/main/docs/data-sources/machine_configuration.md
    # Uncomment to use this instead of version from talos_image.
    # talos_machine_config_version = "v1.9.5"
    proxmox_cluster    = "pve"
    kubernetes_version = "v1.34.2" # only applies at bootstrap time, but try to keep in sync

    # only in dev
    allow_scheduling_on_control_plane_nodes = true
  }

  flux_bootstrap_repo = {
    username = "andre-brandao"
    name     = "flux-test"
  }

  nodes = {
    "k8s-dev-01" = {
      host_node      = "pve"
      machine_type   = "controlplane"
      ip             = "192.168.0.3"
      network_bridge = "vmbr0" # dev
      vm_id          = 400
      cpu            = 3
      ram_dedicated  = 4096
      disk_size      = 20
      update         = false
    }
    "k8s-dev-02" = {
      host_node      = "pve"
      machine_type   = "controlplane"
      ip             = "192.168.0.4"
      network_bridge = "vmbr0" # dev
      vm_id          = 401
      cpu            = 3
      ram_dedicated  = 4096
      disk_size      = 20
      update         = false
    }
    "k8s-dev-03" = {
      host_node      = "pve"
      machine_type   = "controlplane"
      ip             = "192.168.0.5"
      network_bridge = "vmbr0" # dev
      vm_id          = 402
      cpu            = 3
      ram_dedicated  = 4096
      disk_size      = 20
      update         = false
    }
  }
}
