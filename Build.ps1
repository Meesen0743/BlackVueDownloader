<#  
.SYNOPSIS
    You can add this to you build script to ensure that psbuild is available before calling
    Invoke-MSBuild. If psbuild is not available locally it will be downloaded automatically.
#>
function EnsurePsbuildInstalled{  
    [cmdletbinding()]
    param(
        [string]$psbuildInstallUri = 'https://raw.githubusercontent.com/ligershark/psbuild/master/src/GetPSBuild.ps1'
    )
    process{
        if(-not (Get-Command "Invoke-MsBuild" -errorAction SilentlyContinue)){
            'Installing psbuild from [{0}]' -f $psbuildInstallUri | Write-Verbose
            (new-object Net.WebClient).DownloadString($psbuildInstallUri) | iex
        }
        else{
            'psbuild already loaded, skipping download' | Write-Verbose
        }

        # make sure it's loaded and throw if not
        if(-not (Get-Command "Invoke-MsBuild" -errorAction SilentlyContinue)){
            throw ('Unable to install/load psbuild from [{0}]' -f $psbuildInstallUri)
        }
    }
}

# Taken from psake https://github.com/psake/psake

<#  
.SYNOPSIS
  This is a helper function that runs a scriptblock and checks the PS variable $lastexitcode
  to see if an error occcured. If an error is detected then an exception is thrown.
  This function allows you to run command-line programs without having to
  explicitly check the $lastexitcode variable.
.EXAMPLE
  exec { svn info $repository_trunk } "Error executing SVN. Please verify SVN command-line client is installed"
#>
function Exec  
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock]$cmd,
        [Parameter(Position=1,Mandatory=0)][string]$errorMessage = ($msgs.error_bad_command -f $cmd)
    )
    & $cmd
    if ($lastexitcode -ne 0) {
        throw ("Exec: " + $errorMessage)
    }
}

if(Test-Path .\artifacts) { Remove-Item .\artifacts -Force -Recurse }

EnsurePsbuildInstalled

exec { & dotnet restore }

Set-MsBuild "C:\Program Files (x86)\MSBuild\14.0\bin\msbuild.exe"
Invoke-MSBuild

$revision = @{ $true = $env:APPVEYOR_BUILD_NUMBER; $false = 1 }[$env:APPVEYOR_BUILD_NUMBER -ne $NULL];
$revision = "{0}" -f [convert]::ToInt32($revision, 10)

exec { & dotnet test .\BlackVueDownloader.Tests -c Release }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\win10-x64 -f netcoreapp2.2 -r win10-x64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\win10-x64 -f netcoreapp2.2 -r win10-x64 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\win7-x64 -f netcoreapp2.2 -r win7-x64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\win7-x64 -f netcoreapp2.2 -r win7-x64 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\win7-x86 -f netcoreapp2.2 -r win7-x86 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\win7-x86 -f netcoreapp2.2 -r win7-x86 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\win10-arm -f netcoreapp2.2 -r win10-arm --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\win10-arm -f netcoreapp2.2 -r win10-arm --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\win10-arm64 -f netcoreapp2.2 -r win10-arm64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\win10-arm64 -f netcoreapp2.2 -r win10-arm64 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\osx.10.10-x64 -f netcoreapp2.2 -r osx.10.10-x64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\osx.10.10-x64 -f netcoreapp2.2 -r osx.10.10-x64 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\linux-x64 -f netcoreapp2.2 -r linux-x64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\linux-x64 -f netcoreapp2.2 -r linux-x64 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\linux-arm -f netcoreapp2.2 -r linux-arm --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\linux-arm -f netcoreapp2.2 -r linux-arm --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\ubuntu.14.04-x64 -f netcoreapp2.2 -r ubuntu.14.04-x64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\ubuntu.14.04-x64 -f netcoreapp2.2 -r ubuntu.14.04-x64 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\ubuntu.16.04-x64 -f netcoreapp2.2 -r ubuntu.16.04-x64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\ubuntu.16.04-x64 -f netcoreapp2.2 -r ubuntu.16.04-x64 --version-suffix=$revision }

exec { & dotnet build .\BlackVueDownloader -c Release -o .\artifacts\ubuntu.18.04-x64 -f netcoreapp2.2 -r ubuntu.18.04-x64 --version-suffix=$revision }
exec { & dotnet publish .\BlackVueDownloader -c Release -o .\artifacts\ubuntu.18.04-x64 -f netcoreapp2.2 -r ubuntu.18.04-x64 --version-suffix=$revision }
