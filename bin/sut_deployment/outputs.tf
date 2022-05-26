output "vm_master_ip" {
  description = "Master virtual machine IP addresses."
  value = module.virtual_machine_master.external_ip
}
output "vm_worker_ip" {
  description = "Wroker virtual machine IP addresses."
  value = module.virtual_machine_worker.external_ip
}
