# The source must already be a bootable VHDX on the Hyper-V host.
# This host_path resource observes it without deleting it on destroy.
resource "hyperv_image_file" "golden_image" {
  destination_path = var.hyperv_base_image_path
}

# Differencing preserves the original per-VM copy-on-write model.
# Capacity is inherited from the parent VHDX, not vm_disk_capacity.
resource "hyperv_vhd" "vm_disk" {
  for_each    = var.VMS
  path        = "${trimsuffix(var.hyperv_vm_storage_path, "/")}/${each.key}-disk.vhdx"
  vhd_type    = "differencing"
  parent_path = hyperv_image_file.golden_image.destination_path
}
