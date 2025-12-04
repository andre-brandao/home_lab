output "vm_id" {
  description = "The ID of the monitoring VM"
  value       = module.monitoring.vm_id
}

output "vm_name" {
  description = "The name of the monitoring VM"
  value       = module.monitoring.vm_name
}

output "vm_ipv4_addresses" {
  description = "The IPv4 addresses of the monitoring VM"
  value       = module.monitoring.vm_ipv4_addresses
}

output "vm_password" {
  description = "The generated password for the monitoring user"
  value       = module.monitoring.vm_password
  sensitive   = true
}

output "username" {
  description = "The username for SSH access"
  value       = module.monitoring.username
}

output "prometheus_url" {
  description = "Prometheus web UI URL"
  value       = "http://${module.monitoring.vm_ipv4_addresses[1][0]}:9090"
}

output "grafana_url" {
  description = "Grafana web UI URL (default credentials: admin/admin)"
  value       = "http://${module.monitoring.vm_ipv4_addresses[1][0]}:3000"
}

output "jaeger_url" {
  description = "Jaeger web UI URL"
  value       = "http://${module.monitoring.vm_ipv4_addresses[1][0]}:16686"
}

output "influxdb_url" {
  description = "InfluxDB web UI URL"
  value       = "http://${module.monitoring.vm_ipv4_addresses[1][0]}:8086"
}

output "alertmanager_url" {
  description = "AlertManager web UI URL"
  value       = "http://${module.monitoring.vm_ipv4_addresses[1][0]}:9093"
}

output "node_exporter_url" {
  description = "Node Exporter metrics URL"
  value       = "http://${module.monitoring.vm_ipv4_addresses[1][0]}:9100"
}

output "cadvisor_url" {
  description = "cAdvisor web UI URL"
  value       = "http://${module.monitoring.vm_ipv4_addresses[1][0]}:8080"
}

output "access_info" {
  description = "Quick access information for all services"
  value       = <<-EOT
    Monitoring Stack Access Information:
    ====================================

    VM IP: ${module.monitoring.vm_ipv4_addresses[1][0]}
    Username: ${module.monitoring.username}

    Services:
    ---------
    Grafana:        http://${module.monitoring.vm_ipv4_addresses[1][0]}:3000 (admin/admin)
    Prometheus:     http://${module.monitoring.vm_ipv4_addresses[1][0]}:9090
    Jaeger:         http://${module.monitoring.vm_ipv4_addresses[1][0]}:16686
    InfluxDB:       http://${module.monitoring.vm_ipv4_addresses[1][0]}:8086
    AlertManager:   http://${module.monitoring.vm_ipv4_addresses[1][0]}:9093
    Node Exporter:  http://${module.monitoring.vm_ipv4_addresses[1][0]}:9100
    cAdvisor:       http://${module.monitoring.vm_ipv4_addresses[1][0]}:8080

    InfluxDB Credentials:
    --------------------
    Username: admin
    Password: adminpassword
    Organization: monitoring
    Bucket: metrics
    Token: my-super-secret-auth-token

    SSH Access:
    -----------
    ssh ${module.monitoring.username}@${module.monitoring.vm_ipv4_addresses[1][0]}

    Docker Commands:
    ---------------
    docker compose ps
    docker compose logs -f [service_name]
    docker compose restart [service_name]
  EOT
}
