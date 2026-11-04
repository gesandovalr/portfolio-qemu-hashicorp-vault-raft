# Hyper-V provider migration (windsorcli/hyperv 0.5.0)

## What changed
- `libvirt_domain` -> `hyperv_vm` (inline NIC, disk, DVD, power state)
- `libvirt_volume` -> host VHDX `hyperv_image_file` + `hyperv_vhd` differencing children
- `libvirt_cloudinit_disk` -> `hyperv_iso_volume` + `hyperv_image_file` (`CIDATA`)
- Existing switch is looked up by `data.hyperv_virtual_switch`; it is **not** created or changed.
- Existing Bash wait / Ansible hook remains and requires the sibling `../Ansible` directory, which was **not** in the supplied ZIP.

## Critical prerequisites
1. **Convert the original `/home/gesora/Templates/al9-golden-build.qcow2` to VHDX externally**. On a Linux machine with qemu-img, a possible command is:
   `qemu-img convert -p -f qcow2 -O vhdx /home/gesora/Templates/al9-golden-build.qcow2 al9-golden-build.vhdx`
   This is an image conversion command, **not** a Hyper-V provider operation. Copy the VHDX to the Windows Hyper-V host.
2. Determine whether the **guest installation actually boots with BIOS (Hyper-V generation 1) or UEFI (generation 2)**. The original libvirt `q35` machine type is not proof of UEFI. Select `hyperv_vm_generation` accordingly; **do not trust the placeholder value**. Hyper-V cannot change generation after creation. For generation 2, secure boot is disabled initially; test the converted image before using it in the fleet.
3. Update `hyperv_base_image_path` and `hyperv_vm_storage_path` in terraform.tfvars to valid paths on the **Windows Hyper-V host**, and ensure the folder exists. Ensure the base disk does not change while differencing children exist.
4. Run `Get-VMSwitch` on the Hyper-V host and confirm the name set in `vm_network_name`. The source libvirt network named `LAN` need not exist in Hyper-V. Confirm the switch routes the `10.20.10.0/24` network and gateway `10.20.10.1`.
5. Cloud-init `network-config` still addresses `eth0`, as in the original. Hyper-V may enumerate the NIC with a different Linux interface name (e.g. `eth0`, `ens...`). Inspect the guest and adjust the matching name if necessary before relying on static IP / Ansible.
6. Configure SSH or WinRM to the Hyper-V host and permissions per the upstream provider documentation. Example for **a Linux OpenTofu runner** (replace values):
   `export HYPERV_BACKEND=ssh HYPERV_HOST=your-hyperv-host HYPERV_USERNAME=your-remote-user HYPERV_SSH_PRIVATE_KEY_PATH="$HOME/.ssh/id_ed25519"`
   The Windows SSH server must be set up as required by the provider. Prefer credentials in environment variables rather than checked-in tfvars.
7. You need `tofu` and a network connection to fetch `windsorcli/hyperv`. Run `tofu init -reconfigure`, `tofu validate`, then inspect `tofu plan` before apply.

## State protection / warning
The input ZIP contained `terraform.tfstate` with **libvirt** resources. That state and the `.terraform` provider cache have intentionally **not** been included. Use a **new, empty directory and a separate state** for Hyper-V. Simply changing providers in an existing libvirt state is not a supported in-place VM conversion; do not run `tofu apply` against the old state. Back up the original state separately.

## Disk / boot considerations
- Each VM gets a **differencing VHDX** child. Its size is inherited from the converted golden VHDX; the original `vm_disk_capacity=50` variable was unused in `libvirt_volume` and was removed rather than falsely promising a resize.
- `hyperv_vm` generation 1 uses IDE, generation 2 uses SCSI. The documented `boot_order` only applies to generation 2.
- The source ZIP had no actual `../Ansible` files; the provisioning command is retained but **cannot be verified or executed** from this archive alone.
- `nc -z` tests TCP port availability, not successful SSH authentication. The original approach is retained, but first-boot SSH and cloud-init success require guest verification.
- There was no `tofu` executable or Hyper-V endpoint accessible in the editing environment, so **the configuration has not been passed through `tofu validate` or applied on a Hyper-V host**.

## Official docs (exact provider release)
- https://github.com/windsorcli/terraform-provider-hyperv/tree/v0.5.0/docs
- https://raw.githubusercontent.com/windsorcli/terraform-provider-hyperv/v0.5.0/docs/resources/vm.md
- https://raw.githubusercontent.com/windsorcli/terraform-provider-hyperv/v0.5.0/docs/resources/vhd.md
- https://raw.githubusercontent.com/windsorcli/terraform-provider-hyperv/v0.5.0/docs/resources/image_file.md
- https://raw.githubusercontent.com/windsorcli/terraform-provider-hyperv/v0.5.0/docs/data-sources/iso_volume.md
- https://raw.githubusercontent.com/windsorcli/terraform-provider-hyperv/v0.5.0/docs/data-sources/virtual_switch.md
