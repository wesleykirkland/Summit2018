#Base Work
[System.Collections.ArrayList]$Colors = (Get-Help -Name Write-Host -Parameter ForegroundColor | Out-String -Stream | Select-String -Pattern '- ' | Out-String).Split('-').Split().Where{$PSItem -notlike $null}

#Array
$ArrayMeasure = Measure-Command {
    $array = @()
    $array += "Write-Output 'Let the puppy killing commence'"
    $array += "Write-Output 'pause'"

    foreach ($Num in 1..5000) {
        $array += 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
    }
}
$ArrayMeasure | Select-Object @{Name='Type';Expression={'Array'}},Seconds,Milliseconds

#ArrayList
$ArrayListMeasure = Measure-Command {
    [System.Collections.ArrayList]$ArrayList = @()
    $ArrayList.Add("Write-Output 'Let the puppy killing commence'") | Out-Null
    $ArrayList.Add("Write-Output 'pause'") | Out-Null

    foreach ($Num in 1..5000) {
        $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
        $ArrayList.Add($string) |  Out-Null
    }
}
$ArrayListMeasure | Select-Object @{Name='Type';Expression={'ArrayList'}},Seconds,Milliseconds

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
$ArrayListMeasure | Select-Object @{Name='Type';Expression={'ArrayList_Void'}},Seconds,Milliseconds


$FileMeasure = Measure-Command {
    $File = 'C:\temp\meta\output\6_Output_Methods.ps1'
    Remove-Item $File
    Write-Output "Write-Output 'Let the puppy killing commence'" | Add-Content -Path $File
    Write-Output 'pause' | Add-Content -Path $File

    foreach ($Num in 1..2000) {
        $string = 'Write-Host -ForegroundColor {0} -BackgroundColor {1} {2}' -f ($Colors | Get-Random),($Colors | Get-Random),$Num
        Write-Output $string | Add-Content -Path $File
    }
}
$FileMeasure | Select-Object @{Name='Type';Expression={'File'}},Seconds,Milliseconds

#No DB example