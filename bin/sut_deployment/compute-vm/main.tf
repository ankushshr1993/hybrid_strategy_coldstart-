resource "google_compute_firewall" "allow-tag-ssh" {
  count         = length(var.network_interfaces) == 1 ? 1 : 0
  name          = "${var.network_interfaces[0].network}-${var.name}-${var.project_id}-ingress-tag"
  description   = "Firewall ports allow to vnet"
  network       = var.network_interfaces[0].network
  project       = var.project_id
  source_ranges = var.firewall_rules.source_ranges
  target_tags   = var.firewall_rules.target_tags

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = var.firewall_rules.protocol
    ports    = var.firewall_rules.ports
  }
}


resource "google_compute_instance" "vm" {
  #provider                  = google-beta
  #count                     = var.create_template ? 0 : 1
  project                   = var.project_id
  zone                      = var.zone
  name                      = var.name
  hostname                  = var.hostname
  description               = var.description
  tags                      = var.tags
  machine_type              = var.instance_type
  min_cpu_platform          = var.min_cpu_platform
  can_ip_forward            = var.can_ip_forward
  allow_stopping_for_update = var.options.allow_stopping_for_update
  deletion_protection       = var.options.deletion_protection
  enable_display            = var.enable_display
  labels                    = var.labels

  dynamic "attached_disk" {
    for_each = local.attached_disks
    iterator = config
    content {
      device_name = config.value.name
      mode        = config.value.options.mode
      source      = config.value.source
    }
  }

  boot_disk {
    auto_delete = var.boot_disk_delete
    initialize_params {
      type  = var.boot_disk.type
      image = var.boot_disk.image
      size  = var.boot_disk.size
    }
    disk_encryption_key_raw = var.encryption != null ? var.encryption.disk_encryption_key_raw : null
    kms_key_self_link       = var.encryption != null ? var.encryption.kms_key_self_link : null
  }

  dynamic "confidential_instance_config" {
    for_each = var.confidential_compute ? [""] : []
    content {
      enable_confidential_compute = true
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    iterator = config
    content {
      network    = config.value.network
      subnetwork = config.value.subnetwork
      network_ip = try(config.value.addresses.internal, null)
      dynamic "access_config" {
        for_each = config.value.nat ? [""] : []
        content {
          nat_ip = try(config.value.addresses.external, null)
        }
      }
      dynamic "alias_ip_range" {
        for_each = local.network_interface_options[config.key].alias_ips != null ? local.network_interface_options[config.key].alias_ips : {}
        iterator = config_alias
        content {
          subnetwork_range_name = config_alias.key
          ip_cidr_range         = config_alias.value
        }
      }
      nic_type = local.network_interface_options[config.key].nic_type
    }
  }

  scheduling {
    automatic_restart   = !var.options.preemptible
    on_host_maintenance = local.on_host_maintenance
    preemptible         = var.options.preemptible
  }

  dynamic "scratch_disk" {
    for_each = [
      for i in range(0, var.scratch_disks.count) : var.scratch_disks.interface
    ]
    iterator = config
    content {
      interface = config.value
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  dynamic "shielded_instance_config" {
    for_each = var.shielded_config != null ? [var.shielded_config] : []
    iterator = config
    content {
      enable_secure_boot          = config.value.enable_secure_boot
      enable_vtpm                 = config.value.enable_vtpm
      enable_integrity_monitoring = config.value.enable_integrity_monitoring
    }
  }

  # metadata = {
  #   ssh-keys = "${var.user}:${file("${var.publickey}")} \nroot:${file("${var.publickey}")}"
  # }

  metadata = {
    ssh-keys = "${var.user}:${file("${var.publickey}")}"
  }

}


