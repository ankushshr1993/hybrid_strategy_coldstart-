variable "attached_disk_defaults" {
  description = "Defaults for attached disks options."
  type = object({
    mode         = string
  })
  default = {
    mode         = "READ_WRITE"
  }
}

variable "attached_disks" { 
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name = string
    source = string
    options = object({
      mode = string
    })
  }))
  default = []
}

variable "boot_disk" {
  description = "Boot disk properties."
  type = object({
    image = string
    size  = number
    type  = string
  })
  default = {
    image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    type  = "pd-balanced"
    size  = 10
  }
}

variable "firewall_rules" {
  description = "Firewall rules to be added to vnet"
  type = object({
    source_ranges = list(string)
    target_tags   = list(string)
    protocol      = string
    ports         = list(string)
  })
  default = {
    source_ranges = ["0.0.0.0/0"]
    target_tags   = []
    protocol      = "tcp"
    ports         = ["22","6443","2379-2380","10250-10252","10257","10259","30000-32767","8080","443","80"]
  }
}

variable "boot_disk_delete" {
  description = "Auto delete boot disk."
  type        = bool
  default     = true
}

variable "can_ip_forward" {
  description = "Enable IP forwarding."
  type        = bool
  default     = false
}

variable "confidential_compute" {
  description = "Enable Confidential Compute for these instances."
  type        = bool
  default     = false
}

variable "description" {
  description = "Description of a Compute Instance."
  type        = string
  default     = "Managed by the compute-vm Terraform module."
}
variable "enable_display" {
  description = "Enable virtual display on the instances."
  type        = bool
  default     = false
}

variable "encryption" {
  description = "Encryption options. Only one of kms_key_self_link and disk_encryption_key_raw may be set. If needed, you can specify to encrypt or not the boot disk."
  type = object({
    disk_encryption_key_raw = string
    kms_key_self_link       = string
  })
  default = null
}


variable "hostname" {
  description = "Instance FQDN name."
  type        = string
  default     = null
}


variable "instance_type" {
  description = "Instance type."
  type        = string
  default     = "e2-standard-2"
}

variable "labels" {
  description = "Instance labels."
  type        = map(string)
  default     = {}
}


variable "min_cpu_platform" {
  description = "Minimum CPU platform."
  type        = string
  default     = null
}

variable "name" {
  description = "Instance name."
  type        = string
}

variable "network_interface_options" {
  description = "Network interfaces extended options. The key is the index of the inteface to configure. The value is an object with alias_ips and nic_type. Set alias_ips or nic_type to null if you need only one of them."
  type = map(object({
    alias_ips = map(string)
    nic_type  = string
  }))
  default = {}
}

variable "network_interfaces" {
  description = "Network interfaces configuration. Use self links for Shared VPC, set addresses to null if not needed."
  type = list(object({
    nat        = bool
    network    = string
    subnetwork = string
    addresses = object({
      internal = string
      external = string
    })
  }))
}

variable "options" {
  description = "Instance options."
  type = object({
    allow_stopping_for_update = bool
    deletion_protection       = bool
    preemptible               = bool
  })
  default = {
    allow_stopping_for_update = true
    deletion_protection       = false
    preemptible               = false
  }
}

variable "project_id" {
  description = "Project id."
  type        = string
  #default     = "capable-alcove-346110"
}

variable "scratch_disks" {
  description = "Scratch disks configuration."
  type = object({
    count     = number
    interface = string
  })
  default = {
    count     = 0
    interface = "NVME"
  }
}

variable "service_account_email" {
  description = "Service account email. Unused if service account is auto-created."
  type        = string
  default     = null
}


# scopes and scope aliases list
# https://cloud.google.com/sdk/gcloud/reference/compute/instances/create#--scopes
variable "service_account_scopes" {
  description = "Scopes applied to service account."
  type        = list(string)
  default     = ["userinfo-email", "compute-ro", "storage-ro"]
}

variable "shielded_config" {
  description = "Shielded VM configuration of the instances."
  type = object({
    enable_secure_boot          = bool
    enable_vtpm                 = bool
    enable_integrity_monitoring = bool
  })
  default = null
}

variable "tag_bindings" {
  description = "Tag bindings for this instance, in key => tag value id format."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Instance network tags for firewall rule targets."
  type        = list(string)
  default     = ["http-server","https-server"]
}

variable "region" {
  description = "Compute region."
  type        = string
  #default     = "europe-west2"
}

variable "zone" {
  description = "Compute zone."
  type        = string
  #default     = "europe-west2-a"
}

variable "user" {
  description = "user for ssh"
  type        = string
  default     = "docker"
}


variable "publickey" {
  description = "publickey"
  type        = string
  default     = "docker_rsa.pub"
}
variable "publickey_dir" {
  description = "publickey directory"
  type        = string
  default     = "../keys/docker_rsa.pub"
}

