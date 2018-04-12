$ExecutionTime = Measure-Command -Expression {
    #Get all the cmdlets in a module
    $ModuleToBuildTests = 'AWSPowerShell'
    [System.Collections.ArrayList]$arrayfile = @() #Build an emplty file for us to store LOC to

    #Base coded neested for the Pester test
    [void]$arrayfile.Add('Describe "Unit testing outline" {')

    $ModuleCmdlets = Get-Command -Verb Get -Module $ModuleToBuildTests | Select-Object -ExpandProperty Name

    foreach ($Cmdlet in $ModuleCmdlets) {
        #Let's find all the parameters of each cmdlet
        $CmdletParameters = Get-Help -Name $Cmdlet -Parameter * -ErrorAction SilentlyContinue

        #Find required parameters, and recast as a PSCustomObject
        $RequiredParameters = $CmdletParameters | Where-Object {($PSItem.required -eq $true)} | Select-Object Name,ParameterValue

        #Loop through our required parameters and make it a string
        [System.Collections.ArrayList]$ParameterStrings = @()
        foreach ($Parameter in $RequiredParameters) {
            [void]$ParameterStrings.Add(("-{0} <{1}>" -f $Parameter.name,$Parameter.parameterValue))
        }

        if ($ParameterStrings.Count -gt 0) {
            [string]$ParameterStrings = $ParameterStrings -join ' '
        }

        #Build the pester test outline for each Cmdlet now
        [void]$arrayfile.Add(('     It "Testing {0} with Required Parameters in the module of {1}"' -f $Cmdlet,$ModuleToBuildTests))
        if ($ParameterStrings.Length -gt 0) {
            [void]$arrayfile.Add(('          ({0} {1}) | Should Be' -f $Cmdlet,$ParameterStrings)) #Required parameters
        } else {
            [void]$arrayfile.Add(('          ({0}) | Should Be' -f $Cmdlet)) #No Required parameters
        }
        
        [void]$arrayfile.Add('     }')
    }

    [void]$arrayfile.Add('}') #Housekeeping
}

#Something suprising I noticed was the lack of required parameters
Write-Output "It took us $($ExecutionTime.minutes):$($ExecutionTime.Seconds) minutes to build pester tests for $(Get-Command -Module $ModuleToBuildTests | Measure-Object | Select-Object -ExpandProperty count) cmdlets for the $($ModuleToBuildTests) module, and we generated a total LOC of $($arrayfile.Count + 1)."

#$arrayfile