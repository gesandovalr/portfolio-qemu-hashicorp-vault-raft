# Define Values for pool name and path
vm_pool_name = "Virtual_Machines"
vm_pool_path = "/home/gesora/virtual_machines/VMs"
vm_base_template_name = "al9-golden-build.qcow2"
vm_base_image_path = "/home/gesora/Templates/al9-golden-build.qcow2"
vm_domain_name = "lab.local"
vm_gateway = "10.20.10.1"
vm_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEgInN0JnG0h1EtCcT/1cC+8mpQw6d1dpVku/f4pPP1K gesora@odin"

VMS = {
  HCKVTEST01 = {
    name         = "HCKVTEST01"
    memory       = 2048
    vcpu         = 2
    ipv4_add_nic = "10.20.10.10"
    netmask      = 24
  }

  HCKVTEST02 = {
    name         = "HCKVTEST02"
    memory       = 2048
    vcpu         = 2
    ipv4_add_nic = "10.20.10.11"
    netmask      = 24
  }

  HCKVTEST03 = {
    name         = "HCKVTEST03"
    memory       = 2048
    vcpu         = 2
    ipv4_add_nic = "10.20.10.12"
    netmask      = 24
  }
}