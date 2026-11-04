variable "hyperv_host" {
  description = "Existing folder on the Hyper-V host for per-VM VHDX and CIDATA ISO files."
  type        = string
}

variable "hyperv_username" {
  description = "Existing folder on the Hyper-V host for per-VM VHDX and CIDATA ISO files."
  type        = string
}

variable "hyperv_base_image_path" {
  description = "Absolute VHDX path on the Hyper-V host; must already exist and be bootable."
  type        = string
}

variable "hyperv_vm_storage_path" {
  description = "Existing folder on the Hyper-V host for per-VM VHDX and CIDATA ISO files."
  type        = string
}

variable "hyperv_vm_generation" {
  description = "Hyper-V generation matching the golden image's boot mode: 1=BIOS, 2=UEFI."
  type        = number
  validation {
    condition     = contains([1, 2], var.hyperv_vm_generation)
    error_message = "hyperv_vm_generation must be 1 (BIOS) or 2 (UEFI)."
  }
}

variable "vm_ssh_public_key" {
  description = "Public SSH key for cloud-init user"
  type        = string
}

variable "vm_network_name" {
  description = "Name of an existing Hyper-V virtual switch (not a libvirt network)."
  type        = string
}

variable "vm_domain_name" {
  type = string
}

variable "vm_gateway" {
  type = string
}

variable "VMS" {
  type = map(object({
    name         = string
    memory       = number # MiB
    vcpu         = number
    ipv4_add_nic = string
    netmask      = number
  }))
}
