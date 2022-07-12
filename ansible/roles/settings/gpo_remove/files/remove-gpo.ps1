Remove-GPLink -Name "Group3Wallpaper" -Target "OU=dev,OU=labb,DC=labb,DC=local" -erroraction 'silentlycontinue'

#if (!(Get-ItemPropertyValue -Path "HKCU:\Control Panel\Desktop\" -Name "Wallpaper")) { Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value "c:\windows\web\wallpaper\windows\img0.jpg"  }
#

$gpo_exist=Get-GPO -Name "Remove-Group3Wallpaper" -erroraction ignore
if ($gpo_exist) {
Remove-GPO -Name "Remove-Group3Wallpaper"
}

New-GPO -Name "Remove-Group3Wallpaper"-comment "Remove Group3Wallpaper"
New-GPLink -Name "Remove-Group3Wallpaper" -Target "OU=dev,OU=labb,DC=labb,DC=local"

Set-GPPrefRegistryValue -Name "Remove-Group3Wallpaper" -Context User -Action Delete -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System"

Set-GPPrefRegistryValue -Name "Remove-Group3Wallpaper" -Context User -Action Delete -Key "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\CurrentVersion"

