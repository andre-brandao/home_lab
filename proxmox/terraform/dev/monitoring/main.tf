module "monitoring" {
  source = "../../modules/docker-compose"

  # VM Configuration
  vm_name        = "monitoring"
  vm_description = "Monitoring Stack - Prometheus, Grafana, Jaeger, InfluxDB, Loki"
  vm_tags        = ["terraform", "ubuntu", "docker", "monitoring"]

  # Hardware Resources
  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 50

  # Network Configuration
  node_name      = "pve"
  datastore_id   = "local-zfs"
  ip_address     = "dhcp"
  network_bridge = "vmbr0"

  # Cloud Image - reuse existing image to avoid conflicts
  cloud_image_id = "local:import/noble-server-cloudimg-amd64.qcow2"

  # OS Configuration
  hostname = "monitoring"
  timezone = "America/Sao_Paulo"

  # SSH Keys
  ssh_keys = [
    trimspace(file("~/.ssh/id_ed25519.pub")),
    trimspace(file("~/.ssh/pve.pub"))
  ]

  # Docker Compose Configuration
  docker_compose_content = file("${path.module}/template/docker-compose.yaml")
  docker_compose_path    = "monitoring-stack/docker-compose.yml"
  working_directory      = "monitoring-stack"

  # Systemd Service Configuration
  service_name        = "monitoring-stack"
  service_description = "Monitoring Stack - Prometheus, Grafana, Jaeger, InfluxDB, Loki"

  # Additional packages (if needed)
  additional_packages = [
    "htop",
    "vim",
    "git"
  ]
}

# Create config files using null_resource and provisioners
resource "null_resource" "copy_configs" {
  depends_on = [module.monitoring]

  # Trigger on VM ID change
  triggers = {
    vm_id = module.monitoring.vm_id
  }

  # Wait for VM to be ready
  provisioner "local-exec" {
    command = "sleep 60"
  }

  # Copy configuration files to the VM
  connection {
    type        = "ssh"
    user        = module.monitoring.username
    host        = module.monitoring.vm_ipv4_addresses[1][0]
    private_key = file("~/.ssh/id_ed25519")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${module.monitoring.working_directory}/prometheus",
      "mkdir -p ${module.monitoring.working_directory}/grafana/provisioning/datasources",
      "mkdir -p ${module.monitoring.working_directory}/grafana/provisioning/dashboards",
      "mkdir -p ${module.monitoring.working_directory}/alertmanager",
      "mkdir -p ${module.monitoring.working_directory}/loki",
      "mkdir -p ${module.monitoring.working_directory}/promtail"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/template/prometheus/"
    destination = "${module.monitoring.working_directory}/prometheus/"
  }

  provisioner "file" {
    source      = "${path.module}/template/grafana/provisioning/"
    destination = "${module.monitoring.working_directory}/grafana/provisioning/"
  }

  provisioner "file" {
    source      = "${path.module}/template/alertmanager/"
    destination = "${module.monitoring.working_directory}/alertmanager/"
  }

  provisioner "file" {
    source      = "${path.module}/template/loki/"
    destination = "${module.monitoring.working_directory}/loki/"
  }

  provisioner "file" {
    source      = "${path.module}/template/promtail/"
    destination = "${module.monitoring.working_directory}/promtail/"
  }

  # Fix permissions
  provisioner "remote-exec" {
    inline = [
      "sudo chown -R docker:docker ${module.monitoring.working_directory}",
      "sudo chmod -R 755 ${module.monitoring.working_directory}",
      "sudo systemctl restart ${module.monitoring.service_name}"
    ]
  }
}
