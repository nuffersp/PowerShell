import-module ActiveDirectory

function getADData {
    param([string]$Domain )
    #[cmdletbinding()]

    $file = "C:\temp\AD_$Domain.csv"

    Get-ADUser -Filter * -Properties DistinguishedName,SamAccountName,displayName,sn,givenname,manager -Server $domain | select DistinguishedName,SamAccountName,displayName,sn,givenname,manager | Export-CSV $file
 
    Write-Output "`nFile output for $Domain domain is $file"
}


exit
#
# Get the current AD Domain
#
$currentAD = ( Get-ADDomain | select DistinguishedName ).DistinguishedName
Set-ADUser nuffers -GivenName Steve nuffersda -DisplayName -Surname -

function setADData {
    param([string]$Domain, [string]$user )

    $file = "C:\cygwin64\home\nuffers\idm\displayname\${domain}_final"
    
    $arrayAD=Import-Csv -Delimiter "," -Header DistinguishedName,SamAccountName,displayName,sn,givenname -Path $file

    ForEach ($element in $arrayAD) {
        $dn = $element.DistinguishedName
        $samAcct = $element.SamAccountName
        if ( $element.sn ) { $sn = " -Surname """ + $element.sn + """"} else { $sn = ""}
        if ( $element.givenname ) { $givenName = " -GivenName """ + $element.givenname + """"} else { $givenName = ""}
        if ( $element.displayName ) { $DisplayName = " -DisplayName """ + $element.displayName + """"} else { $DisplayName = ""}
        $cmd = "Set-ADUser " + ${samAcct} + ${DisplayName} + ${givenName} + ${sn}

        if ( $user ) {
            if ( $user -eq $samAcct ) {
                $cmd = "Set-ADUser " + ${samAcct} + ${DisplayName} + ${givenName} + ${sn} + " -server " + $Domain

                Write-Output $cmd
                #Invoke-Expression $cmd
            }
        } else {
            $cmd = "Set-ADUser " + ${samAcct} + ${DisplayName} + ${givenName} + ${sn} + " -server " + $Domain
            Write-Output $cmd
            #Invoke-Expression $cmd
        }
                
    } # ForEach
} 




 Get-ADUser -Server "s1ad.s1.com" -Filter {EmailAddress -like "*erik.battle*"} -Properties EmailAddress