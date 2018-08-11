Clear-Host
$VerbosePreference = 'continue'
$i = 1

#Base Work
[System.Collections.ArrayList]$Colors = (Get-Help -Name Write-Host -Parameter ForegroundColor | Out-String -Stream | Select-String -Pattern '- ' | Out-String).Split('-').Split().Where{$PSItem -notlike $null}
[System.Collections.ArrayList]$Results = @()

do {
    if ($i) {
        Write-Verbose $i
    } else {
        Write-Verbose 1
    }
    #Array
    $ArrayMeasure = Measure-Command {
        $array = @()
        $array += "Write-Output 'Let the puppy killing commence'"
        $array += "Write-Output 'pause'"

        foreach ($Num in 1..5000) {
            $array += 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
        }
    }
    [void]$Results.Add(($ArrayMeasure | Select-Object @{Name='Type';Expression={'Array'}},Minutes,Seconds,Milliseconds))

    #ArrayList Legacy Redirection
    $ArrayListMeasureLegacy = Measure-Command {
        [System.Collections.ArrayList]$ArrayList = @()
        $ArrayList.Add("Write-Output 'Let the puppy killing commence'") > ''
        $ArrayList.Add("Write-Output 'pause'") > ''

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            $ArrayList.Add($string) > ''
        }
    }
    [void]$Results.Add(($ArrayListMeasureLegacy | Select-Object @{Name='Type';Expression={'ArrayList_Legacy'}},Minutes,Seconds,Milliseconds))


    #ArrayList Out-Null
    $ArrayListMeasureOutNull = Measure-Command {
        [System.Collections.ArrayList]$ArrayList = @()
        $ArrayList.Add("Write-Output 'Let the puppy killing commence'") | Out-Null
        $ArrayList.Add("Write-Output 'pause'") | Out-Null

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            $ArrayList.Add($string) | Out-Null
        }
    }
    [void]$Results.Add(($ArrayListMeasureOutNull | Select-Object @{Name='Type';Expression={'ArrayList_OutNull'}},Minutes,Seconds,Milliseconds))

    #ArrayList
    $ArrayListMeasure = Measure-Command {
        [System.Collections.ArrayList]$ArrayList = @()
        [void]$ArrayList.Add("Write-Output 'Let the puppy killing commence'")
        [void]$ArrayList.Add("Write-Output 'pause'")

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            [void]$ArrayList.Add($string)
        }
    }
    [void]$Results.Add(($ArrayListMeasure | Select-Object @{Name='Type';Expression={'ArrayList_Void'}},Minutes,Seconds,Milliseconds))

    #ArrayList null
    $ArrayListMeasure = Measure-Command {
        [System.Collections.ArrayList]$ArrayList = @()
        $null = $ArrayList.Add("Write-Output 'Let the puppy killing commence'")
        $null = $ArrayList.Add("Write-Output 'pause'")

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            $null = $ArrayList.Add($string)
        }
    }
    [void]$Results.Add(($ArrayListMeasure | Select-Object @{Name='Type';Expression={'ArrayList_null'}},Minutes,Seconds,Milliseconds))


    #These are slow as can be/not demo suitable
    <#
    #File System
    $FileMeasure = Measure-Command {
        $File = 'C:\temp\meta\output\6_Output_Methods.ps1'
        Remove-Item $File
        Write-Output "Write-Output 'Let the puppy killing commence'" | Add-Content -Path $File
        Write-Output 'pause' | Add-Content -Path $File

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            $string | Add-Content -Path $File
        }
    }
    [void]$Results.Add(($FileMeasure | Select-Object @{Name='Type';Expression={'File'}},Minutes,Seconds,Milliseconds))

    #DB
    $DBMeasure = Measure-Command {
        $Header = Write-Output "Write-Output 'Let the puppy killing commence'"
        Invoke-MSSQLQuery -SQLConnection $SQLConnection -Query "INSERT INTO dbo.example (Project,Code) VALUES ('Puppy Killer','$($Header.replace("'","''"))')" 

        foreach ($Num in 1..5000) {
            $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
            Invoke-MSSQLQuery -SQLConnection $SQLConnection -Query "INSERT INTO dbo.example (Project,Code) VALUES ('Puppy Killer','$string')" 
        }
    }

    [void]$Results.Add(($DBMeasure | Select-Object @{Name='Type';Expression={'DB'}},Minutes,Seconds,Milliseconds))
    #>

    $i++
} until ($i -eq 10)


$Grouping = $Results | Group-Object Type

$TestResults = foreach ($Obj in $Grouping) {
    #$Obj
    
    [System.Collections.ArrayList]$AvgResults = @()
    foreach ($Row in $Obj.Group) {
        if ($Row.Minutes -gt 0) {
            $CalcTime = [timespan]("$($Row.Minutes):$($Row.Seconds)")
            $CalcTime = $CalcTime + [timespan]::FromMilliseconds($Row.Milliseconds)
            [void]$AvgResults.Add($CalcTime)
        } else {
            $CalcTime = [timespan]("00:00:$($Row.Seconds)")
            $CalcTime = $CalcTime + [timespan]::FromMilliseconds($Row.Milliseconds) 
            [void]$AvgResults.Add($CalcTime)
        }
    }

    [PSCustomObject]@{
        Type = $Obj.Group.Type[0]
        Minutes = ($AvgResults.TotalMilliseconds | Measure-Object -Average).Average / 60000
        Seconds = ($AvgResults.TotalMilliseconds | Measure-Object -Average).Average / 1000
    }
}

$TestResults | Sort-Object Minutes -Descending