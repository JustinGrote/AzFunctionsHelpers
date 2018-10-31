function Install-PSModule {
<#
.SYNOPSIS
Fetches a Powershell module using PackageManagement. Default is a server-local Modules folder.
.NOTES
Uses Save-Module because Install-Module doesn't work in Azure Functions due to a permissions issue (investigating)
#>

[CmdletBinding()]
param (
    [String[]]$ModuleName,
    [String]$PSLocalModulePath = "$($env:UserProfile)\Documents\WindowsPowershell\Modules"
)

if (-not (Test-Path $PSLocalModulePath)) {
    mkdir $PSLocalModulePath > $null
}

Add-PSModulePath $PSLocalModulePath

#Silently Installs the NuGET requirement for Powershell Gallery if it isn't present.
get-packageprovider Nuget -forcebootstrap > $null

foreach ($ModuleToInstall in $ModuleName) {
    write-verbose "Checking for $ModuleToInstall"
    if (-not (get-module $ModuleToInstall -listavailable)) {
        write-verbose "$ModuleToInstall Not Found, Installing to $PSLocalModulePath"
        #Install-Module fails with unauthorized operation for some reason
        save-module $ModuleToInstall -Path $PSLocalModulePath -verbose 4>&1
    }
}

} #function Install-PSModule