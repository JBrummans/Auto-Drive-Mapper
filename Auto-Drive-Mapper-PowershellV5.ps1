# Created: 20200916
# Author: JBrummans
# This script requires a CSV file specified below containing a column titles "drive" with UNC share names.

Write-Host "Auto Drive-Mapper Script"
Write-Host "Please do not close this window"

$letters = 75..90 | %{[char]$_} #Starts lettering from K:
$existing = (Get-psdrive).Name
$import = import-csv -Path "\\PATH\TO\CSV\drives.csv" #REPLACE THIS PATH
$paths = $import.drive

foreach ($path in $paths){
    #Test connection to drive. If true try to map, if false iterate loop.
    if(test-path $path -ErrorAction SilentlyContinue){
        $letter = $letters[0]

        #Check if letter already in use. If true remove from array. If false continue.
        While($existing.contains($letter)){
            $letters = $letters | Where-Object { $_ -ne $letter }
            $letter = $letters[0]
        }

        Write-Host "Mapping" $path "to" $letter
        try {
            New-PSDrive -Name $letter -PSProvider FileSystem -Root $path -Persist -Scope "Global" > $null
            $letters = $letters | Where-Object { $_ -ne $letters[0] }
        } catch {
            Write-Host "ERROR MAPPING DRIVE"
        }           
    }
}
Write-Host "Script Complete"
