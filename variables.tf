#variable "nutanix_user" {
#  description = "Nutanix user"
#  default = "adam"
#}
#variable "nutanix_password" {
#  description = "Nutanix password"
#  default = "pocnutanix"
#}
#variable "nutanix_endpoint" {
#  description = "Nutanix endpoint"
#  default = "10.251.0.91"
#}
#variable "nutanix_port" {
#  description = "Nutanix port"
#  default = 9440
#}
variable "nutanix_cluster_uuid" {
  description = "Nutanix Cluster UUID"
  default = "00057f19-99fe-e93d-28e2-0cc47ac22ab0"
}
variable "nutanix_image_uuid" {
  description = "The UUID of the image to be used for deploy operations."
  default = "d9d87adc-7262-472b-9d32-867584c2de22"
}
variable "nutanix_network_uuid" {
  description = "The UUID of the network to be used for deploy operations."
  default = "298e4396-b486-4e2d-ad4e-0d59620c2e67"
}

variable "ssh_user" {
  description = "VM Username"
  default = "ubuntu"
}

variable "ssh_password" {
  description = "VM Password"
  default = "passw0rd"
}

variable "timezone" {
  description = "Time Zone"
  default     = "Asia/Jakarta"
}

variable "vm_private_key_file" {
  default = "nutanix-key"
}

variable "instance_prefix" {
  default = "pea"
}

variable "nut" {
  type = "map"

  default = {
    nodes         = "1"
    name          = "nut"
    cpu_cores     = "2"
    cpu_sockets   = "1"
    os_disk       = "250"
    data_disk     = "100"
    memory        = "4096"
    # ipaddresses   = "192.168.1.81"
    # netmask       = "24"
    # gateway       = "192.168.1.1"
  }
}