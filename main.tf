#variable "prism_username" {
#  description = "Prism Endpoint admin user name"
#  default = "adam"
#}

#variable "prism_password" {
#  description = "Prism Endpoint admin password"
#  default = "pocnutanix"
#}

#variable "prism_endpoint" {
#  description = "Prism Endpoint address"
#  default = "10.251.0.91"
#}

variable "vm_num" {
  description = "Number of VMs"
  default = "2"
}

variable "vm_num_vcpus_per_socket" {
  description = "Number of cores per socket"
  default = "4"
}

variable "vm_num_socket" {
  description = "Number of sockets"
  default = "2"
}

variable "vm_memory" {
  description = "Memory Size in MiB"
  default = "32768"
}

variable "vm_network_uuid" {
  description = "VM Netowrk UUID"
  default = "298e4396-b486-4e2d-ad4e-0d59620c2e67"
}

variable "vm_cdrom_uuid" {
  description = "VM cdrom UUID"
  default = "2cf6dbc0-aff6-46bf-803b-7462f58315a5"
}

variable "vm_image_uuid" {
  description = "VM image UUID - Ubuntu"
  default = "64618d12-5a93-407a-8949-0c5352af7b63"
}

variable "cluster1" {
  description = "Cluster UUID"
  default = "00057f19-99fe-e93d-28e2-0cc47ac22ab0"
}

#provider "nutanix" {
#  username = "${var.prism_username}"
#  password = "${var.prism_password}"
#  endpoint = "${var.prism_endpoint}"
#  insecure = true
#  port     = 9440
#}

resource "random_id" "rand" {
  byte_length = 2
}

resource "nutanix_virtual_machine" "simple-vm" {
  count = "${var.vm_num}"
  name  = "${format("simple_vm-${random_id.rand.hex}-%02d", count.index+1)}"
  num_vcpus_per_socket = "${var.vm_num_vcpus_per_socket}"
  num_sockets          = "${var.vm_num_socket}"
  memory_size_mib      = "${var.vm_memory}"

  cluster_reference = {
    kind = "cluster"
    uuid = "${var.cluster1}"
  }

  nic_list = [{
      subnet_reference = {
        kind = "subnet"
        uuid = "${var.vm_network_uuid}"
      }
  }]

  disk_list = [
    {
      data_source_reference = {
        kind = "image"
        uuid = "${var.vm_cdrom_uuid}"
      }
    },
    {
      data_source_reference = {
        kind = "image"
        uuid = "${var.vm_image_uuid}"
      }
    },
	{
      disk_size_mib = "102400"  
	  device_properties = {
		device_type = "DISK" 
	  }
    },
  ]
}

output "simple-vm-ip" {
  value = "${nutanix_virtual_machine.simple-vm.0.state}"
}
