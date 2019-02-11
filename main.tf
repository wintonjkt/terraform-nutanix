provider "nutanix" {
  username = "${var.nutanix_user}"
  password = "${var.nutanix_password}"
  endpoint = "${var.nutanix_endpoint}"
  port     = "${var.nutanix_port}"
  insecure = true
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "cat > ${var.vm_private_key_file} <<EOL\n${tls_private_key.ssh.private_key_pem}\nEOL"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${var.vm_private_key_file}"
  }
}

//user_data
data "template_file" "nut_user_data" {
  count = "${var.nut["nodes"]}"
  template = "${file("${path.module}/scripts/user_data.tpl")}"

  vars {
    password = "${var.ssh_password}"
    timezone = "${var.timezone}"
    vmname = "${format("%s-%s-%01d", lower(var.instance_prefix), lower(var.nut["name"]),count.index + 1) }"
  }
}

//nut
resource "nutanix_virtual_machine" "nut" {
  # lifecycle {
  #   ignore_changes = ["disk_list.0", "disk_list.1"]
  # }

  count = "${var.nut["nodes"]}"
  name = "${format("%s-%s-%01d", lower(var.instance_prefix), lower(var.nut["name"]),count.index + 1) }"
  num_vcpus_per_socket = "${var.nut["cpu_cores"]}"
  num_sockets          = "${var.nut["cpu_sockets"]}"
  memory_size_mib      = "${var.nut["memory"]}"
  hardware_clock_timezone = "${var.timezone}"


  cluster_reference = {
    kind = "cluster"
    uuid = "${var.nutanix_cluster_uuid}"
  }

  guest_customization_cloud_init_user_data = "${base64encode(element(data.template_file.nut_user_data.*.rendered, count.index))}"

  nic_list = [
    {
      subnet_reference = {
        kind = "subnet"
        uuid = "${var.nutanix_network_uuid}"
      } 
    },
  ]

  disk_list = [
    {
      disk_size_mib = "${var.nut["os_disk"] * 1024 }"
      data_source_reference = {
        kind = "image"
        uuid = "${var.nutanix_image_uuid}"
      }
    },
    # {
    #   disk_size_mib = "${var.nut["data_disk"] * 1024 }"
    # },
  ]

  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    password = "${var.ssh_password}"
    host     = "${self.nic_list.0.ip_endpoint_list.0.ip}"
  }

  provisioner "file" {
    content     = "${count.index == 0 ? tls_private_key.ssh.private_key_pem : "none"}"
    destination = "${count.index == 0 ? "~/id_rsa" : "/dev/null" }"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.ssh_password} | sudo -S echo",
      "echo \"${var.ssh_user} ALL=(ALL) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/${var.ssh_user}",
      # "sudo hostnamectl set-hostname ${self.name}",
      "sudo sed -i /^127.0.1.1.*$/d /etc/hosts",
      "echo $(ip addr | grep \"inet \" | grep -v 127.0.0.1 | awk -F\" \" 'NR==1 {print $2}' | cut -d / -f 1) ${self.name} | sudo tee -a /etc/hosts",
      "[ ! -d $HOME/.ssh ] && mkdir $HOME/.ssh && chmod 700 $HOME/.ssh",
      "echo \"${tls_private_key.ssh.public_key_openssh}\" | tee -a $HOME/.ssh/authorized_keys && chmod 600 $HOME/.ssh/authorized_keys",
      "[ -f ~/id_rsa ] && mv ~/id_rsa $HOME/.ssh/id_rsa && chmod 600 $HOME/.ssh/id_rsa",
    ]
  }
}