terraform {
  required_providers {
    hyperv = {
      source  = "windsorcli/hyperv"
      version = "= 0.5.0"
    }
  }
}

# Host access is configured through HYPERV_* environment variables.
# See README-HYPERV.md; do not commit secrets in *.tfvars.
provider "hyperv" {}

data "hyperv_virtual_switch" "vm_network" {
  name = var.vm_network_name
}

resource "terraform_data" "wait_for_ssh" {
  depends_on = [hyperv_vm.virtual_machines]

  triggers_replace = [
    sha256(jsonencode(var.VMS)),
    var.hyperv_vm_generation,
    [for vm in hyperv_vm.virtual_machines : vm.vm_id]
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOT
      set -e
      for ip in ${join(" ", [for vm in values(var.VMS) : vm.ipv4_add_nic])}; do
        echo "Waiting for SSH TCP port on $ip..."
        until nc -z -w 2 "$ip" 22 >/dev/null 2>&1; do
          sleep 3
        done
        echo "SSH port available on $ip"
      done
    EOT
  }
}

resource "terraform_data" "run_ansible" {
  depends_on = [terraform_data.wait_for_ssh]

  triggers_replace = [
    sha256(jsonencode(var.VMS)),
    filesha256("${path.module}/../Ansible/requirements.yml"),
    filesha256("${path.module}/../Ansible/main.yml")
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}/../Ansible"
    command = <<-EOT
      set -e
      echo "Installing Ansible collections..."
      ansible-galaxy collection install -r ./requirements.yml -p ./collections
      echo "Running Ansible playbook..."
      ANSIBLE_CONFIG=${path.module}/../Ansible/config/ansible.cfg \
      ansible-playbook -i ./inventory.yml ./main.yml
    EOT
  }
}
