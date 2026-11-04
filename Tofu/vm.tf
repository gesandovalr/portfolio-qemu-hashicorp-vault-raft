resource "hyperv_vm" "virtual_machines" {
  for_each   = var.VMS
  name       = each.value.name
  generation = var.hyperv_vm_generation

  cpu    = { count = each.value.vcpu }
  memory = { startup_bytes = each.value.memory * 1024 * 1024, dynamic = false }

  # Generation 1 has no Secure Boot. For Generation 2, disable it until
  # the converted AlmaLinux VHDX has been proven UEFI-bootable.
  secure_boot = var.hyperv_vm_generation == 2 ? false : null

  network_adapter = [
    { name = "primary", switch_name = data.hyperv_virtual_switch.vm_network.name }
  ]

  hard_disk_drive = [
    {
      path                = hyperv_vhd.vm_disk[each.key].path
      controller_type     = var.hyperv_vm_generation == 2 ? "SCSI" : "IDE"
      controller_number   = 0
      controller_location = 0
    }
  ]

  dvd_drive = [
    {
      iso_path            = hyperv_image_file.cloudinit_iso[each.key].destination_path
      controller_type     = var.hyperv_vm_generation == 2 ? "SCSI" : "IDE"
      controller_number   = var.hyperv_vm_generation == 2 ? 0 : 1
      controller_location = var.hyperv_vm_generation == 2 ? 1 : 0
    }
  ]

  # Boot order is supported only on Generation 2 VMs by this provider.
  boot_order = var.hyperv_vm_generation == 2 ? [
    { type = "hard_disk_drive", controller_type = "SCSI", controller_number = 0, controller_location = 0 },
    { type = "dvd_drive", controller_type = "SCSI", controller_number = 0, controller_location = 1 }
  ] : null

  state = { desired = "Running" }
}
