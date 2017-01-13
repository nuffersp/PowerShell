import-module ActiveDirectory
#$VerbosePreference = "continue"
$Logfile = "C:\windows\temp\compare_SLD_AD.txt"

Function LogWrite
{
   Param ([string]$logstring)

   $now=Get-Date -format "yyyyMMdd_HHmmss"

   Add-content $Logfile -value "$now : $logstring"
}


Clear-Host

#
# Get the current AD Domain
#
$currentAD = ( Get-ADDomain | select DistinguishedName ).DistinguishedName

$now=Get-Date -format "yyyyMMdd_HHmmss"

Write-Output "currentAD = $currentAD"
LogWrite "currentAD = $currentAD"
/*
    Rule:  aci_ADFindPrimaryEmail
    
    Author:  Steve Nuffer
	
    Date:  April 28, 2016
    Version:  1.2

*/
import org.apache.log4j.Logger; 
import sailpoint.object.*;

Logger logger = Logger.getLogger("com.aci.rule.aci_CombinePhoneAttr");

String countryCode = link.getAttribute("COUNTRY_CODE");
String areaCode= link.getAttribute("AREA_CODE");
String phoneNumber= link.getAttribute("PHONE_NUMBER");

if ( Util.isNotNullOrEmpty(countryCode) ) 
    countryCode = countryCode.replaceAll("[^0-9]", "");
else
    countryCode = "";
    
if ( Util.isNotNullOrEmpty(areaCode) ) 
    areaCode = areaCode.replaceAll("[^0-9]", "");
else
    areaCode = "";
    
if ( Util.isNotNullOrEmpty(phoneNumber) ) 
    phoneNumber = phoneNumber.replaceAll("[^0-9]", "");
else
    phoneNumber = "";
    
String telePhoneNumber = "+" + countryCode  + areaCode + phoneNumber;     
logger.debug("telePhoneNumber=" +  telePhoneNumber );

// Check for only the +
if ( telePhoneNumber.equals("+")  ) {
    return "";
}  else {
    return telePhoneNumber;
}
$arrayAD=Import-Csv -Delimiter ! -Header "dstName","samAcct","sid","grpDSN" -Path test.csv

# Reset the counter
$counter = 0

ForEach ($element in $arrayAD) {
    $dstName = $element.dstName
    $samAcct = $element.samAcct
    $sid = $element.sid
    $grpDSN = $element.grpDSN


    if ( $dstName.Contains($currentAD) -and ! $grpDSN.Contains("Domain Users") ) {
        # Correct Domain
        #

        Try {
            Get-ADUser -Identity $samAcct | Out-Null

            if ( ! ( (Get-ADUser $samAcct -Properties memberof).memberof -like $grpDSN) )
            {
                $counter++
                $groupname  = ($grpDSN -split ",")[0].Substring(3)
                [string] $logEntry = "$dstName!$samAcct!$sid!$groupname"

                Write-Output "$samAcct : $groupname"
                LogWrite $logEntry

                #$input = Read-Host -Prompt 'Hit <enter> to continue'
            
                Add-ADGroupMember $groupname  $element.samAcct

            } # if (
        }
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "$samAcct could not be found"
            LogWrite "$samAcct could not be found"

        }

    } # if (
} # ForEach

Write-Output "`nTotal # of updates $counter"
