output "external_ip" {
  description = "Instance main interface external IP addresses."
  value = (
    var.network_interfaces[0].nat
    ? try(google_compute_instance.vm.network_interface.0.access_config.0.nat_ip, null)
    : null
  ) 
}