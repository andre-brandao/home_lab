# variable "proxmox_api_token" {
#   type        = string
#   description = "Proxmox API token, only set this via env variable (ex: TF_VAR_proxmox_api_token)"
# }

variable "gitea_username" {
  type        = string
  description = "Gitea username"
  sensitive   = true
}

variable "gitea_password" {
  type        = string
  description = "Gitea password"
  sensitive   = true
}


variable "project_name" {
  default = "ubuntu-vm"
}

# variable "s3_endpoint" {
#   type = string
#   default = "http://truenas:9000"
# }

# variable "s3_acess_key" {
#   type = string
#   default = "minio"
# }

# variable "s3_secret_key" {
#   type = string
# }
