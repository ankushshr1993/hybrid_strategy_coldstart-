variable "master_ip" {
  description = "master_ip"
  type        = string
}

variable "worker_ip" {
  description = "worker_ip"
  type        = string
}

variable "user" {
  description = "user for ssh"
  type        = string
  #default     = "buckyy2929"
}

variable "privatekey" {
  description = "privatekey "
  type        = string
  default     = "docker_rsa"
}

variable "privatekey_dir" {
  description = "privatekey directory"
  type        = string
  default     = "../docker_rsa"
}