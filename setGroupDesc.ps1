$file = Import-Csv test.txt -Delimiter ";" –header groupname,newdescription
foreach ($line in $file){
    $cmd = “set-adgroup “ + $line.groupname + “-description “ + $line.newdescription
    Write-output $cmd
    Set-ADgroup "$($line.groupname)" -description "$($line.newdescription)" -server tst.aciww.com
    
}

