#This will auto build the Domain Component of the LDAP Path, or you could change it yourself
$DomainDC = ($Env:USERDNSDOMAIN.ToLower().split('.') | foreach {"DC=$PSItem"}) -join ','
#$DomainDC = 'DC=contoso,DC=com'

$OUs = Get-ADOrganizationalUnit -Filter * |
    Select-Object DistinguishedName,
        Name,
        @{Name='Depth';Expression={$PSItem.DistinguishedName.Split(',').Length}},
        @{Name='Path';Expression={($OU.DistinguishedName.Split(',').Where{$PSItem -notlike 'DC=*'} | Select-Object -Skip 1) -join ','}} |
    Sort-Object Depth #Sort on depth so the parent OUs get made first


[System.Collections.ArrayList]$FileGeneration = @()

foreach ($OU in $OUs) {
    if (!(Get-ADOrganizationalUnit -Identity $OU.DistinguishedName)) {
        $OUPath = "$(
            if (!([string]::IsNullOrWhiteSpace($OU.Path))) {
                @(
                    $($OU.Path)
                    $($DomainDC)
                ) -join ','
            } else {
                $($DomainDC)
            }
        )"
        $FileGeneration.Add("New-ADOrganizationalUnit -Name $($OU.Name) -Path $OUPath -ProtectedFromAccidentalDeletion $true") | Out-Null
    }
}