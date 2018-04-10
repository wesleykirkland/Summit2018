#Global Variables
$DomainDC = $($Env:USERDNSDOMAIN.ToLower().split('.') | ForEach-Object {"DC=$PSItem"}) -join ',' #Build DN for this one time run
$Users = Get-ADUser -Filter * -Properties * | Where-Object {($PSItem.distinguishedname -notlike "*cn=users,$DomainDC")}

[System.Collections.ArrayList]$FileGeneration = @()

#Build variable output
[void]$FileGeneration.Add('#Variable to control base DC path')
[void]$FileGeneration.Add("$('$DomainDC') = $($(@('$($Env:USERDNSDOMAIN.ToLower().split(''.'') | ForEach-Object {"DC=$PSItem"}) -join '',''')))")
[void]$FileGeneration.Add('')

#Loop through all users that are not in the default Users container
foreach ($ADUser in $Users) {
    #Build the users path in AD without the DN or DCs
    $ADUserPath = ($ADUser.DistinguishedName.split(',') | Select-Object -Skip 1 | Where-Object {($PSItem -notlike "DC=*")}) -join ','

    $ADUserPathFull = "$(
            @(
                $($ADUserPath)
                '$($DomainDC)'
            ) -join ','
    )"

    [void]$FileGeneration.Add("New-ADUser -Name ""$($ADUser.Name)"" -EmployeeID ""$($ADUser.EmployeeID)"" -EmployeeNumber ""$($ADUser.EmployeeNumber)"" -SamAccountName ""$($ADUser.SamAccountName)"" -Enabled $(@('$',($ADUser.Enabled))-join'') -Surname ""$($ADUser.sn)"" -GivenName ""$($ADUser.GivenName)"" -DisplayName ""$($ADUser.DisplayName)"" -ChangePasswordAtLogon $(@('$',$true) -join '') -AccountPassword (ConvertTo-SecureString 'P@ssword!' -AsPlainText -Force) -Path ""$ADUserPathFull""")
}

$FileGeneration | Out-File C:\temp\meta\output\Rebuild_AD_Users.ps1