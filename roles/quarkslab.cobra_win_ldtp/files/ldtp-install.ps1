$ErrorActionPreference = "Stop"
Set-Location "$Args/cobra-win-ldtp"
#Write-Output "Packing LDTP chocolatey install"
choco.exe pack
#Write-Output "Installing LDTP chocopack"
choco.exe install cobra-win-ldtp -source . --force -y
#Write-Output "Installing LDTP dependencies Dotnet3.5"
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart
