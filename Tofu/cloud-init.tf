locals {
  cloud_init_user_data = {
    preserve_hostname = false
    manage_etc_hosts  = true
    users = [
      {
        name        = "almalinux"
        lock_passwd = true
        sudo        = ["ALL=(ALL) NOPASSWD:ALL"]
        groups      = ["wheel"]
        shell       = "/bin/bash"
        ssh_authorized_keys = [var.vm_ssh_public_key]
      }
    ]
    ssh_pwauth   = false
    disable_root = true
  }
}

data "hyperv_iso_volume" "cloudinit" {
  for_each     = var.VMS
  volume_label = "CIDATA"

  files = {
    "meta-data" = yamlencode({
      "instance-id"    = each.key
      "local-hostname" = each.value.name
    })
    "user-data" = "#cloud-config\n${yamlencode(merge(local.cloud_init_user_data, {
      hostname = each.value.name
      fqdn     = "${each.value.name}.${var.vm_domain_name}"
    }))}"
    "network-config" = yamlencode({
      version = 2
      ethernets = {
        # Preserved from the original libvirt setup; verify actual NIC name on Hyper-V.
        eth0 = {
          dhcp4 = false
          addresses = ["${each.value.ipv4_add_nic}/${each.value.netmask}"]
          routes = [{to = "0.0.0.0/0", via = var.vm_gateway}]
          nameservers = {
            addresses = ["8.8.8.8", "8.8.4.4"]
            search    = [var.vm_domain_name]
          }
        }
      }
    })
  }
}

resource "hyperv_image_file" "cloudinit_iso" {
  for_each = var.VMS
  destination_path    = "${trimsuffix(var.hyperv_vm_storage_path, "/")}/${each.key}-cloudinit.iso"
  content_base64      = data.hyperv_iso_volume.cloudinit[each.key].content_base64
  replace_while_mounted = true
}
