# Created: 20200916
# Author: JBrummans
# This script requires a CSV file specified below containing a column titles "drive" with UNC share names.

Write-Host "Auto Drive-Mapper Script"
Write-Host "Please do not close this window"

# Wait a few seconds before start
start-sleep 2

# Delete all existing drives
Write-Host "Removing previously mapped drives"
net use * /delete /y
start-sleep 2

Write-Host "Mapping scatch to Y and aztec to Z"
net use Z: \\3tales\aztec
net use Y: \\3tales\scratch

$letters = 75..90 | %{[char]$_} #Starts lettering from K:
$existing = Get-psdrive | select -ExpandProperty Name
$import = import-csv -Path "\\smb\login_script\drives.csv"
#$paths = $import.drive #could not use this as it didnt work in Powershell v2
$paths = $import | select -ExpandProperty drive
#write-host "paths: "$paths

foreach ($path in $paths){
    #Test connection to drive. If true try to map, if false iterate loop.
    #write-host $path
    if(test-path $path -ErrorAction SilentlyContinue){
        $letter = $letters[0]

        #Check if letter already in use. If true remove from array. If false continue.
        While($existing -contains $letter){
		try {            
			$letters = $letters | Where-Object { $_ -ne $letter[0] }
            		$letter = $letters[0]
		} catch {
			write-host "Out of drive letters. Quitting"
			return
		}
        }

        Write-Host "Mapping" $path "to" $letter
	$let = $letter+":"
        try {
       	    net use $let $path /persistent:yes
            #New-PSDrive -Name $letter -PSProvider FileSystem -Persist -Root $path -Scope "Global" > $null
            $letters = $letters | Where-Object { $_ -ne $letters[0] }
        } catch {
            Write-Host "ERROR MAPPING DRIVE"
        } 
    }
}
Write-Host "Script Complete"
