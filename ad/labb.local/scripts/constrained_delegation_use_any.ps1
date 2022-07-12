# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#with-protocol-transition
Set-ADUser -Identity "molly.walsh" -ServicePrincipalNames @{Add='CIFS/dc02.dev.labb.local'}
Get-ADUser -Identity "molly.walsh" | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADUser -Identity "molly.walsh" -Add @{'msDS-AllowedToDelegateTo'=@('CIFS/dc02.dev.labb.local','CIFS/dc02')}