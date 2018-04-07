#Global variables
$ProtectedFromAccidentalDeletion = $false #Specify the the code below should protect it from accidental deletion, changeable in the script later

#Build OU structure with custom path
$OUs = Get-ADOrganizationalUnit -Filter * |
    Where-Object Name -NotMatch "Domain Controllers" |
    Select-Object DistinguishedName,
        Name,
        @{Name='Depth';Expression={$PSItem.DistinguishedName.Split(',').Length}},
        @{Name='Path';Expression={(($PSItem.DistinguishedName.Split(',').Where{$PSItem.DistinguishedName -notlike 'DC=*'} | Select-Object -Skip 1).Where{$PSItem -notlike "DC=*"}) -join ','}} |
    Sort-Object Depth #Sort on depth so the parent OUs get made first

[System.Collections.ArrayList]$FileGeneration = @()

#Build variables output
[void]$FileGeneration.Add('#Variable to control Accidental Deletion')
[void]$FileGeneration.Add("$('$ProtectedFromAccidentalDeletion') = $(@('$',$ProtectedFromAccidentalDeletion) -join(''))")
[void]$FileGeneration.Add('#Variable to control base DC path')
[void]$FileGeneration.Add("$('$DomainDC') = $($(@('$($Env:USERDNSDOMAIN.ToLower().split(''.'') | ForEach-Object {"DC=$PSItem"}) -join '',''')))")
[void]$FileGeneration.Add('')

#Loop through OUs and build output file
foreach ($OU in $OUs) {
    $OUPath = "$(
        if (!([string]::IsNullOrWhiteSpace($OU.Path))) {
            @(
                $($OU.Path)
                '$($DomainDC)'
            ) -join ','
        } else {
            '$($DomainDC)'
        }
    )"
    [void]$FileGeneration.Add("New-ADOrganizationalUnit -Name '$($OU.Name)' -Path ""$OUPath"" -ProtectedFromAccidentalDeletion $('$ProtectedFromAccidentalDeletion') -ErrorAction SilentlyContinue")
}

#Store the output file
$FileGeneration | Out-File C:\temp\meta\output\OU_Rebuild.ps1 -Force