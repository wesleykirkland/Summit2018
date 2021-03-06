#No escaping
#Lines 4, 9
$String = '
Write-Verbose "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)"
Write-Verbose "$($Arguments.Trim() -join ' ')"

#Invoke the legacy app
if ($SeparateWindow) {
    Write-Verbose "SeparateWindow was invoked, using Start-Process Invocation method"
    Start-Process -FilePath (Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable) -ArgumentList ($Arguments -join ' ')
} else {
    Write-Verbose "Using legacy console invocation method"
    & "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)" $Arguments
}
'
$String

#Basic string escaping
$String = '
Write-Verbose "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)"
Write-Verbose "$($Arguments.Trim() -join '' '')"

#Invoke the legacy app
if ($SeparateWindow) {
    Write-Verbose "SeparateWindow was invoked, using Start-Process Invocation method"
    Start-Process -FilePath (Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable) -ArgumentList ($Arguments -join '' '')
} else {
    Write-Verbose "Using legacy console invocation method"
    & "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)" $Arguments
}
'
$String

#Character escaping Here String
$String = @'
Write-Verbose "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)"
Write-Verbose "$($Arguments.Trim() -join ' ')"

#Invoke the legacy app
if ($SeparateWindow) {
    Write-Verbose "SeparateWindow was invoked, using Start-Process Invocation method"
    Start-Process -FilePath (Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable) -ArgumentList ($Arguments -join ' ')
} else {
    Write-Verbose "Using legacy console invocation method"
    & "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)" $Arguments
}
'@
$String

#Character Escaping Script Blocks
$String = {
    Write-Verbose "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)"
    Write-Verbose "$($Arguments.Trim() -join ' ')"
    
    #Invoke the legacy app
    if ($SeparateWindow) {
        Write-Verbose "SeparateWindow was invoked, using Start-Process Invocation method"
        Start-Process -FilePath (Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable) -ArgumentList ($Arguments -join ' ')
    } else {
        Write-Verbose "Using legacy console invocation method"
        & "$(Join-Path -Path $BinaryPath -ChildPath $BinaryExecutable)" $Arguments
    }
}.ToString()
$String