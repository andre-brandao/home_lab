terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.76.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.0-alpha.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.5.1"
    }
    gitea = {
      source  = "go-gitea/gitea"
      version = "0.6.0"
    }
  }
}

provider "proxmox" {
  # proxmox.imkumpy.in is reverse proxied through another host which causes issues
  # when this provider tries to SSH, so we use the direct IP address here.
  endpoint = "https://192.168.0.100:8006/"

  api_token = var.proxmox_api_token

  # because self-signed TLS certificate is in use
  insecure = true

  tmp_dir = "/var/tmp"

  ssh {
    agent    = true
    username = "root"
  }
}

provider "talos" {}

provider "gitea" {
  base_url = "https://git.imkumpy.in/"

  username = var.gitea_username
  password = var.gitea_password
}
