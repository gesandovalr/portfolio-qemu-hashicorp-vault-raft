# REQUIRED: replace with paths and boot mode confirmed on your Hyper-V host.
# No Windows paths or firmware choice were present in the original ZIP.
hyperv_host = "192.168.1.84"
hyperv_username = "tofu"
hyperv_base_image_path = "C:\\Users\\GermanEduardoSandova\\Documents\\Templates\\AlmaLinux9-Golden.vhdx"
hyperv_vm_storage_path = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
hyperv_vm_generation   = 1 # CHANGE to 2 only if the converted image boots with UEFI
vm_network_name        = "LAN-Internal" # CHANGE if Get-VMSwitch shows a different switch name

vm_domain_name = "lab.local"
vm_gateway     = "10.20.10.1"
vm_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINXVkhslGb4Dtxb3z009jfUPgjbICgcefR7VT9YRdBn+ gesora"

VMS = {
  HCKVTEST01 = { 
    name = "HCKVTEST01", 
    memory = 2048, 
    vcpu = 2, 
    ipv4_add_nic = "10.20.10.10", 
    netmask = 24 
    }
  
  HCKVTEST02 = { 
    name = "HCKVTEST02", 
    memory = 2048, 
    vcpu = 2, 
    ipv4_add_nic = "10.20.10.11", 
    netmask = 24 }
  
  HCKVTEST03 = { 
    name = "HCKVTEST03", 
    memory = 2048, 
    vcpu = 2, 
    ipv4_add_nic = "10.20.10.12", 
    netmask = 24 }
}
