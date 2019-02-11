nutanix_user="adam"
nutanix_password="pocnutanix"
nutanix_endpoint="10.251.0.91"
nutanix_port=9440
nutanix_cluster_uuid="00057f19-99fe-e93d-28e2-0cc47ac22ab0"
nutanix_image_uuid="d9d87adc-7262-472b-9d32-867584c2de22"
nutanix_network_uuid="298e4396-b486-4e2d-ad4e-0d59620c2e67"

ssh_user="ubuntu"                               #Login user in selected template
ssh_password="passw0rd"                    #Login password in selected template
timezone = "Asia/Jakarta"                     #OS Time Zone
vm_private_key_file="nutanix-key"               #Private Key Filename to be saved on local
instance_prefix="pea"                           #VM Instance name prefix

nut = {                                       #VM Specification for ICP Master node
    nodes       = "1"
    name        = "nut"
    cpu_cores   = "2"
    cpu_sockets = "1"
    os_disk     = "250"
    data_disk   = "200"                          #Kubelet Volume size
    memory      = "2048"
}
