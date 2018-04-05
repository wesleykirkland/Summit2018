#This will auto build the Domain Component of the LDAP Path, or you could change it yourself
$DomainDC = ($Env:USERDNSDOMAIN.ToLower().split('.') | foreach {"DC=$PSItem"}) -join ','
#$DomainDC = 'DC=contoso,DC=com'

$OUs = Get-ADOrganizationalUnit -Filter * |
    Select-Object DistinguishedName,
        Name,
        @{Name='Depth';Expression={$PSItem.DistinguishedName.Split(',').Length}},
        @{Name='Path';Expression={(($PSItem.DistinguishedName.Split(',').Where{$PSItem.DistinguishedName -notlike 'DC=*'} | Select-Object -Skip 1).Where{$PSItem -notlike "DC=*"}) -join ','}} |
    Sort-Object Depth #Sort on depth so the parent OUs get made first

[System.Collections.ArrayList]$FileGeneration = @()

foreach ($OU in $OUs) {
    #if (!(Get-ADOrganizationalUnit -Identity $OU.DistinguishedName)) {
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
    [void]$FileGeneration.Add("New-ADOrganizationalUnit -Name $($OU.Name) -Path '$OUPath' -ProtectedFromAccidentalDeletion $true -ErrorAction SilentlyContinue")
    #}
}

$FileGeneration | Out-File C:\temp\meta\output\OU_Rebuild.ps1 -Force