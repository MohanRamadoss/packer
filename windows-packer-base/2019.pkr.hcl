variable "ami_name" {
  type    = string
  default = "windows-2019-Base-Golden-{{timestamp}}"
}


variable "subnet_id" {
  type    = string
  default = "YOURSUBNETID"
}


variable "region" {
  type    = string
  default = "us-east-1"
}


locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


data "amazon-ami" "image" {
  filters = {
    virtualization-type = "hvm"
    architecture        = "x86_64"
    name                = "Windows_Server-2019-English-Full-Base*"
    root-device-type    = "ebs"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.region
}



# https://www.packer.io/docs/builders/amazon/ebs
source "amazon-ebs" "windows" {
  ami_name      = "${var.ami_name}"
  instance_type = "t3.medium"
  region        = "${var.region}"
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "100"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  source_ami              = data.amazon-ami.image.id
  communicator            = "winrm"
  winrm_username          = "Administrator"
  winrm_use_ssl           = true
  winrm_insecure          = true
  skip_profile_validation = true
  #subnet_id    = "${var.subnet_id}"

  # This user data file sets up winrm and configures it so that the connection
  # from Packer is allowed. Without this file being set, Packer will not
  # connect to the instance.
  user_data_file = "winrm_bootstrap.txt"

  tags = {
    "Name"        = "MyWindowsImage"
    "Environment" = "Production"
    "OS_Version"  = "Windows"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }

}

# https://www.packer.io/docs/provisioners
build {
  sources = ["source.amazon-ebs.windows"]

  # provisioner "powershell" {
  #   script = "./scripts/install-windows-updates.ps1"
  # }


  provisioner "powershell" {
    scripts = ["./scripts/disable-uac.ps1", "./scripts/cleanup-useless-defaults.ps1"]
  }


  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }


  provisioner "powershell" {
    inline = [
      # Re-initialise the AWS instance on startup
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule",
      # Remove system specific information from this image
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/SysprepInstance.ps1 -NoShutdown"
    ]
  }
}
