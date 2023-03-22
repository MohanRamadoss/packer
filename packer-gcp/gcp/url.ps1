# https://www.packer.io/docs/builders/amazon/ebs

 
write-output "Running User Data Script"
write-host "(host) Running User Data Script"
 

#net user ${var.packer_username} \"${var.packer_user_password}\" /add /y & wmic UserAccount where Name=\"${var.packer_username}\" set PasswordExpires=False & net localgroup administrators ${var.packer_username} /add 

#add packer user 
net user packer_user  "=|i3FdD3,{C<:^n" /add /y

Set-LocalUser -Name packer_user -PasswordNeverExpires 0


net localgroup administrators packer_user /add 



 

##Create install folder and use for Gpo
New-Item -ItemType Directory -Force -Path C:\install
 
 
##Create install folder and use for Gpo
New-Item -ItemType Directory -Force -Path C:\install
Start-Transcript -Path "C:\Install\Posh_transcript.txt" -NoClobber


# Create the installation directory
$installPath = "C:\install"
New-Item -ItemType Directory -Path $installPath -Force

# Define the URL to the OpenSSH installer
$installerUrl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.0.0p1-Beta/OpenSSH-Win64-v9.2.0.0.msi"

# Define the path to save the installer
$installerPath = "C:\install\OpenSSH-Win64-v9.2.0.0.msi"

# Download the OpenSSH installer from the URL
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install OpenSSH
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

# Delete the installer file
#Remove-Item $installerPath

Stop-Transcript
