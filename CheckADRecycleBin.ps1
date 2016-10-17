

Get-ADObject -filter{deleted -eq $true} -IncludeDeletedObjects | where objectclass -like "user"