<#
.SYNOPSIS

    THANOS! Randomly removes about half of your objects.

.DESCRIPTION

    Thanos enumerates the objects in the literal path specified by Path, and removes each file with probability 1/2.

    Thanos supports FileSystem, Registry, Certificate, Variable, Function, Alias and Environment PowerShell providers. The only built-in provider that it does not recognise is WSMan. When an unrecognised provider is encountered, it performs some random default action.

    This advanced function takes special care for WhatIf and Confirm parameters. Specifically:

    - If both WhatIf and Confirm are specified ($True or $False), they are left intact.
    - If none is specified, both default to $True.
    - If WhatIf is specified while Confirm is not, Confirm defaults to $True.
    - If Confirm is specified while WhatIf is not, WhatIf defaults to $WhatIfPreference.

    Contributed by Gee Law. See examples (Get-Help .\Invoke-Thanos.ps1 -Examples) for examples.s

.PARAMETER Path

    Specifies the literal path. Defaults to ".".

.EXAMPLE

    .\Invoke-Thanos.ps1 C:\

    Prints the effect of removing about half of files in drive C.

.EXAMPLE

    .\Invoke-Thanos.ps1 . -Confirm:$False

    Removes about half of the files in the current directory, WITHOUT confirmation.

.EXAMPLE

    .\Invoke-Thanos.ps1 HKCU:\ -WhatIf:$False

    Removes about half of the registry values in HKEY_CURRENT_USER, with confirmation for each value to be removed.

#>
[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
Param
(
    [string]$Path = '.'
)
Begin
{
    $local:hadDisabled = $PSDefaultParameterValues.ContainsKey('Disabled')
    $local:disabledValue = $PSDefaultParameterValues['Disabled']
    $PSDefaultParameterValues['Disabled'] = $True
    $local:hasWhatIf = $PSBoundParameters.ContainsKey('WhatIf')
    $local:hasConfirm = $PSBoundParameters.ContainsKey('Confirm')
    # Resolve WhatIf and Confirm.
    If (-not $local:hasWhatIf -and -not $local:hasConfirm)
    {
        $WhatIf = $True
        $local:WhatIfPreference = $True
        $Confirm = $True
        $local:ConfirmPreference = 'Low'
        Write-Verbose 'WhatIf and Confirm are not specified. Both default to $True.'
    }
    If ($local:hasWhatIf -and -not $local:hasConfirm)
    {
        $WhatIf = $PSBoundParameters['WhatIf']
        $Confirm = $True
        $local:ConfirmPreference = 'Low'
        Write-Verbose 'WhatIf is specified while Confirm is not. Confirm defaults to $True.'
    }
    If (-not $local:hasWhatIf -and $local:hasConfirm)
    {
        $WhatIf = $WhatIfPreference
        $Confirm = $PSBoundParameters['Confirm']
        Write-Verbose 'Confirm is specified while WhatIf is not. WhatIf defaults to $WhatIfPreference.'
    }
    If ($local:hasWhatIf -and $local:hasConfirm)
    {
        $WhatIf = $PSBoundParameters['WhatIf']
        $Confirm = $PSBoundParameters['Confirm']
        Write-Verbose 'Both WhatIf and Confirm are specified.'
    }
}
Process
{
    $local:resolvedPath = Resolve-Path -LiteralPath $Path
    $local:randomSource = [System.Random]::new()
    If ($local:resolvedPath -eq $null)
    {
        Write-Error 'Thanos failed to come to the site.' -RecommendedAction 'Do not invoke Thanos.'
        Return
    }
    Switch -Regex -CaseSensitive ($local:resolvedPath.Provider.Name)
    {
        'FileSystem' {
            $local:resolvedPath | Get-ChildItem -Recurse -Force -File |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force -WhatIf:$WhatIf -Confirm:$Confirm
        }
        'Registry' {
            $local:resolvedPath | Get-ChildItem -Recurse -Force -PipelineVariable regKey |
                ForEach-Object { $regKey.Property |
                    Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                    ForEach-Object { $regKey |
                        Remove-ItemProperty -Name $_ -WhatIf:$WhatIf -Confirm:$Confirm }
                }
        }
        'Certificate' {
            $local:resolvedPath |
                Get-ChildItem -Recurse -Force |
                Where-Object { $_ -is [X509Certificate] } |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force -WhatIf:$WhatIf -Confirm:$Confirm
        }
        'Variable|Function|Alias' {
            $local:resolvedPath | Get-ChildItem -Force |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force -WhatIf:$WhatIf -Confirm:$Confirm
        }
        'Environment' {
            $local:resolvedPath | Get-ChildItem -Force |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                ForEach-Object {
                    If ($PSCmdlet.ShouldProcess($_.Name, 'Remove environment variable from Machine, User and Process'))
                    {
                        [System.Environment]::SetEnvironmentVariable($_.Name, $null, 'Machine')
                        [System.Environment]::SetEnvironmentVariable($_.Name, $null, 'User')
                        [System.Environment]::SetEnvironmentVariable($_.Name, $null, 'Process')
                    }
                }
        }
        Default
        {
            $local:resolvedPath | Get-ChildItem -Recurse -Force |
                Where-Object { $_ | Test-Path -PathType Leaf } |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force -WhatIf:$WhatIf -Confirm:$Confirm
        }
    }
}
End
{
    If ($local:hadDisabled)
    {
        $PSDefaultParameterValues['Disabled'] = $local:disabledValue
    }
    Else
    {
        $PSDefaultParameterValues.Remove('Disabled')
    }
}
