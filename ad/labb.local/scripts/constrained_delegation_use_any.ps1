# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#with-protocol-transition
Set-ADUser -Identity "tyra.Norrqvist" -ServicePrincipalNames @{Add='CIFS/dc02.dev.labb.local'}
Get-ADUser -Identity "tyra.Norrqvist" | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADUser -Identity "tyra.Norrqvist" -Add @{'msDS-AllowedToDelegateTo'=@('CIFS/dc02.dev.labb.local','CIFS/dc02')}