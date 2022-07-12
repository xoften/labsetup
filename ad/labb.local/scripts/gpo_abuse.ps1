Install-WindowsFeature -Name GPMC
$gpo_exist=Get-GPO -Name "Group3Wallpaper" -erroraction ignore
if ($gpo_exist) {
Remove-GPO -Name "Group3Wallpaper"
}

#Remove the link of the GPO Remove-Group3Wallpaper if it exists
Remove-GPLink -Name "Remove-Group3Wallpaper" -Target "OU=dev,OU=labb,DC=labb,DC=local" -erroraction 'silentlycontinue'

New-GPO -Name "Group3Wallpaper"-comment "Change Wallpaper"
New-GPLink -Name "Group3Wallpaper" -Target "OU=dev,OU=labb,DC=labb,DC=local"

#https://www.thewindowsclub.com/set-desktop-wallpaper-using-group-policy-and-registry-editor
#Set-GPRegistryValue -Name "Group3Wallpaper" -key "HKEY_CURRENT_USER\Control Panel\Colors" -ValueName Background -Type String -Value "0 0 255"
Set-GPPrefRegistryValue -Name "Group3Wallpaper" -Context User -Action Create -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName Wallpaper -Type String -Value "C:\tmp\GOAD.png"

#Set-GPRegistryValue -Name "Group3Wallpaper" -key "HKEY_CURRENT_USER\Control Panel\Desktop" -ValueName Wallpaper -Type String -Value ""
Set-GPPrefRegistryValue -Name "Group3Wallpaper" -Context User -Action Create -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName WallpaperStyle -Type String -Value "4"

Set-GPRegistryValue -Name "Group3Wallpaper" -Key "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\CurrentVersion\WinLogon" -ValueName SyncForegroundPolicy -Type DWORD -Value 1

#Allow brian.stewart to Edit Settings of the GPO
Set-GPPermissions -Name "Group3Wallpaper" -PermissionLevel GpoEdit -TargetName "brian.stewart" -TargetType "User"
