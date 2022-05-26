locals {
  attached_disks = {
    for disk in var.attached_disks :
    disk.name => merge(disk, {
      options = disk.options == null ? var.attached_disk_defaults : disk.options
    })
  }

  on_host_maintenance = (
    var.options.preemptible || var.confidential_compute
    ? "TERMINATE"
    : "MIGRATE"
  )
  region = join("-", slice(split("-", var.zone), 0, 2))

  network_interface_options = {
    for i, v in var.network_interfaces : i => lookup(var.network_interface_options, i, {
      alias_ips = null,
      nic_type  = null
    })
  }
}
