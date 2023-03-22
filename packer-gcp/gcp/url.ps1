# https://www.packer.io/docs/builders/amazon/ebs

 
write-output "Running User Data Script"
write-host "(host) Running User Data Script"

# Set variables
$OpenSSHName = "OpenSSH-Win64-v9.2.0.0.msi"
$OpenSSHFile =   "gs://apptest10/ssh/OpenSSH-Win64-v9.2.0.0.msi"
# Define the path to save the installer
$installerPath = "C:\install\OpenSSH-Win64-v9.2.0.0.msi"


#net user ${var.packer_username} \"${var.packer_user_password}\" /add /y & wmic UserAccount where Name=\"${var.packer_username}\" set PasswordExpires=False & net localgroup administrators ${var.packer_username} /add 

#add packer user 
#net user packer_user  "=|i3FdD3,{C<:^n" /add /y

#Set-LocalUser -Name packer_user -PasswordNeverExpires 0
#
#net localgroup administrators packer_user /add 


# Set administrator password
#net user Administrator cred
#wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE
 
#set mrbar password and add it to the adminstrator
#net user /add packeradmin cred
#net localgroup administrators packeradmin /add
 

 
##Create install folder and use for Gpo
New-Item -ItemType Directory -Force -Path C:\install
Start-Transcript -Path "C:\Install\Posh_transcript.txt" -NoClobber


# Create the installation directory
$installPath = "C:\install"
New-Item -ItemType Directory -Path $installPath -Force

Write-Host "Downloading OpenSSH binary"
Add-Content C:\Install\gcp_soi.log "[$(Get-Date)] => Installing OpenSSH`n"


# Define the URL to the OpenSSH installer
#$installerUrl = "https://storage.cloud.google.com/abctest2/ssh/OpenSSH-Win64-v9.2.0.0.msi"


# Define the path to save the installer
#$installerPath = "C:\install\OpenSSH-Win64-v9.2.0.0.msi"

# Download the OpenSSH installer from the URL
#Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install OpenSSH
#Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

# Delete the installer file
#Remove-Item $installerPath



# Download  OpenSSH installer
Start-Process -FilePath "gsutil.cmd" -ArgumentList "cp", $OpenSSHFile, "C:\install\" -Wait


# Install OpenSSH
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait


# Delete the installer file
#Remove-Item $installerPath



Stop-Transcript


