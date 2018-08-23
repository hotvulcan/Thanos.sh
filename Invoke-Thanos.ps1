<#
.SYNOPSIS

    THANOS! Randomly removes about half of your objects.

.DESCRIPTION

    Thanos enumerates the objects in the literal path specified by Path, and removes each file with probability 1/2.

    Thanos supports FileSystem, Registry, Certificate, Variable, Function, Alias and Environment PowerShell providers. The only built-in provider that it does not recognise is WSMan. When an unrecognised provider is encountered, it performs some random default action.

    Contributed by Gee Law.

.PARAMETER Path

    Specifies the literal path. Defaults to ".".

#>
[CmdletBinding(SupportsShouldProcess = $false)]
Param
(
    [string]$Path = '.'
)
Begin
{
    $local:hadDisabled = $PSDefaultParameterValues.ContainsKey('Disabled')
    $local:disabledValue = $PSDefaultParameterValues['Disabled']
    $PSDefaultParameterValues['Disabled'] = $True
}
Process
{
    $local:ConfirmPreference = 'High'
    $local:DebugPreference = 'SilentlyContinue'
    $local:ErrorActionPreference = 'SilentlyContinue'
    $local:InformationPreference = 'SilentlyContinue'
    $local:ProgressPreference = 'SilentlyContinue'
    $local:VerbosePreference = 'SilentlyContinue'
    $local:WarningPreference = 'SilentlyContinue'
    $local:WhatIfPreference = $False
    $local:resolvedPath = Resolve-Path -LiteralPath $Path
    $local:randomSource = [System.Random]::new()
    If ($local:resolvedPath -eq $null)
    {
        Write-Error 'Thanos failed to come to the site.' -RecommendedAction 'Do not invoke Thanos.' -ErrorAction 'Continue'
        Return
    }
    Switch -Regex -CaseSensitive ($local:resolvedPath.Provider.Name)
    {
        'FileSystem' {
            $local:resolvedPath | Get-ChildItem -Recurse -Force -File |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force
        }
        'Registry' {
            $local:resolvedPath | Get-ChildItem -Recurse -Force -PipelineVariable regKey |
                ForEach-Object { $regKey.Property |
                    Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                    ForEach-Object { $regKey | Remove-ItemProperty -Name $_ }
                }
        }
        'Certificate' {
            $local:resolvedPath |
                Get-ChildItem -Recurse -Force |
                Where-Object { $_ -is [X509Certificate] } |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force
        }
        'Variable|Function|Alias' {
            $local:resolvedPath | Get-ChildItem -Force |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force
        }
        'Environment' {
            $local:resolvedPath | Get-ChildItem -Force |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                ForEach-Object {
                    [System.Environment]::SetEnvironmentVariable($_.Name, $null, 'Machine')
                    [System.Environment]::SetEnvironmentVariable($_.Name, $null, 'User')
                    [System.Environment]::SetEnvironmentVariable($_.Name, $null, 'Process')
                }
        }
        Default
        {
            $local:resolvedPath | Get-ChildItem -Recurse -Force |
                Where-Object { $_ | Test-Path -PathType Leaf } |
                Where-Object { $randomSource.NextDouble() -lt 0.5 } |
                Remove-Item -Force
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
