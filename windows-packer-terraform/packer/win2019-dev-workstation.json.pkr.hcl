
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

data "amazon-ami" "autogenerated_1" {
  filters = {
    name                = "*Windows_Server-2019-English-Full-Base-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["801119661308"]
  profile     = "${var.profile}"
  region      = "${var.aws_region}"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "autogenerated_1" {
  ami_name      = "windows_dev_workstation_${local.timestamp}"
  communicator  = "winrm"
  instance_type = "t2.micro"
  profile       = "${var.profile}"
  region        = "${var.aws_region}"
  run_tags = {
    Automation    = "packer"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Environment   = "${var.profile}"
    Name          = "bake-windows-dev-workstation-${local.timestamp}"
    Version       = "${local.timestamp}"
  }
  shutdown_behavior = "terminate"
  source_ami        = "${data.amazon-ami.autogenerated_1.id}"
  tags = {
    Automation    = "packer"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Environment   = "${var.profile}"
    Name          = "win19-dev-workstation-${local.timestamp}"
    OS            = "windows"
    Release       = "2019 Core"
    Version       = "${local.timestamp}"
  }
  user_data_file = "unattended/bootstrap.txt"
  winrm_timeout  = "15m"
  winrm_username = "Administrator"
}

build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "powershell" {
    scripts = ["./scripts/disable-uac.ps1", "./scripts/choco.ps1"]
  }

  provisioner "powershell" {
    inline = ["C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SendWindowsIsReady.ps1 -Schedule", "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule", "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown"]
    only   = ["amazon-ebs"]
  }

}
