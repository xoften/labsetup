Install-WindowsFeature -Name GPMC
$gpo_exist=Get-GPO -Name "Wallpaper" -erroraction ignore
if ($gpo_exist) {
Remove-GPO -Name "Wallpaper"
}

#Remove the link of the GPO Remove-StarkWallpaper if it exists
Remove-GPLink -Name "Remove-Wallpaper" -Target "OU=dev,OU=labb,DC=labb,DC=local" -erroraction 'silentlycontinue'

New-GPO -Name "Wallpaper"-comment "Change Wallpaper"
New-GPLink -Name "Wallpaper" -Target "OU=dev,OU=labb,DC=labb,DC=local"

#https://www.thewindowsclub.com/set-desktop-wallpaper-using-group-policy-and-registry-editor
#Set-GPRegistryValue -Name "StarkWallpaper" -key "HKEY_CURRENT_USER\Control Panel\Colors" -ValueName Background -Type String -Value "0 0 255"
Set-GPPrefRegistryValue -Name "Wallpaper" -Context User -Action Create -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName Wallpaper -Type String -Value "C:\tmp\GOAD.png"

#Set-GPRegistryValue -Name "StarkWallpaper" -key "HKEY_CURRENT_USER\Control Panel\Desktop" -ValueName Wallpaper -Type String -Value ""
Set-GPPrefRegistryValue -Name "Wallpaper" -Context User -Action Create -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName WallpaperStyle -Type String -Value "4"

Set-GPRegistryValue -Name "Wallpaper" -Key "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\CurrentVersion\WinLogon" -ValueName SyncForegroundPolicy -Type DWORD -Value 1

#Allow kim.stensson to Edit Settings of the GPO
Set-GPPermissions -Name "Wallpaper" -PermissionLevel GpoEdit -TargetName "kim.stensson" -TargetType "User"
