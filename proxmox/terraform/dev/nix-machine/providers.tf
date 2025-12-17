terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.87.0"
    }
  }
}
provider "proxmox" {
  # proxmox.imkumpy.in is reverse proxied through another host which causes issues
  # when this provider tries to SSH, so we use the direct IP address here.
  endpoint = "https://pve:8006/"

  username = "terraform-prov@pve"
  # api_token = var.proxmox_api_token


  # because self-signed TLS certificate is in use
  insecure = true

  tmp_dir = "/var/tmp"


  ssh {
    # address = "pve"
    agent       = true
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
    # node {
    #   name    = "pve"
    #   # address = "100.104.247.4"
    # }
  }
}
