# This file can be used to override default module variables
# Currently, all variables are passed directly to the module in main.tf

variable "vm_cpu_cores" {
  description = "Number of CPU cores for the monitoring VM"
  type        = number
  default     = 4
}

variable "vm_memory_mb" {
  description = "Memory in MB for the monitoring VM"
  type        = number
  default     = 8192
}

variable "vm_disk_size_gb" {
  description = "Disk size in GB for the monitoring VM"
  type        = number
  default     = 50
}

variable "vm_ip_address" {
  description = "IP address configuration (dhcp or static like '192.168.1.100/24')"
  type        = string
  default     = "dhcp"
}

variable "grafana_admin_password" {
  description = "Grafana admin password (change from default!)"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "influxdb_admin_password" {
  description = "InfluxDB admin password"
  type        = string
  default     = "adminpassword"
  sensitive   = true
}

variable "influxdb_token" {
  description = "InfluxDB authentication token"
  type        = string
  default     = "my-super-secret-auth-token"
  sensitive   = true
}
