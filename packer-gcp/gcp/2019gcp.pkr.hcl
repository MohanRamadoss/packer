
variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "playground-s-11-45d50f97"
}

variable "account_file_path" {
  type = string
  description = "GCP Account File Path"
  default    = "accounts.json"
}

variable "packer_username" {
  type = string
  default = "packer_user"
}

variable "packer_user_password" {
  type = string
  sensitive = true
  default = "=|i3FdD3,{C<:^n"
}

variable "win_packages" {
  type = list(string)
  default = ["git","notepadplusplus","python3"]
}


variable "image_name" {
  type    = string
  default = "_IMAGE_NAME"
}

variable "machine_type" {
  type    = string
  default = "_MACHINE_TYPE"
}

variable "network-tags" {
  type    = string
  default = "_TAGS"
}

variable "network_id" {
  type    = string
  default = "_NETWORK"
}


variable "region" {
  type    = string
  default = "_REGION"
}


source "googlecompute" "windows-ssh-example" {
  project_id = var.project_id
  source_image_project_id = ["windows-cloud"]
  source_image_family = "windows-2019"
  zone = "us-central1-a"
  disk_size = 50
  machine_type = "e2-medium"
  communicator = "ssh"
  ssh_username = var.packer_username
  ssh_password = var.packer_user_password
  ssh_timeout = "1h"
  tags = ["packer"]
  preemptible = true
  image_name = "gcp-win-2019-full-baseline"
  image_description = "GCP Windows 2019 Base Image"
  image_labels = {
      server_type = "windows-2019"
  }
 metadata = {
  user_data_file = "winrm_bootstrap.txt"
}  
 # metadata = {
 #   windows-startup-script-cmd = "net user ${var.packer_username} \"${var.packer_user_password}\" /add /y & wmic UserAccount where Name=\"${var.packer_username}\" set PasswordExpires=False & net localgroup administrators ${var.packer_username} /add & powershell Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 & powershell Start-Service sshd & powershell Set-Service -Name sshd -StartupType 'Automatic' & powershell New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"Set-ExecutionPolicy -ExecutionPolicy bypass -Force\""
 # }
  account_file = var.account_file_path

}

build {
  sources = ["sources.googlecompute.windows-ssh-example"]

  provisioner "powershell" {
    script = "../scripts/install-features.ps1"
    elevated_user     = var.packer_username
    elevated_password = var.packer_user_password
  }
  provisioner "powershell" {
    inline          = [ "Write-Host \"Hello from PowerShell\""]
  }

  #provisioner "powershell" {
  #  inline = ["GCESysprep -NoShutdown"]
  #}

}