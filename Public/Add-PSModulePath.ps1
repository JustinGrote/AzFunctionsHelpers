function Add-PSModulePath {
<#
.SYNOPSIS
Adds a path to the PS Module Search Path. When run without any parameters, adds "PSModule" in your root function directory to the path
.DESCRIPTION
This is useful when you want to add custom modules to your Azure function, without having them autoload like the "modules" folder in the individual function folders
.EXAMPLE
Add-AzFunctionPSModulePath -PATH $
#>

[CmdletBinding()]
param (
    #The path you wish to add to PSModulePath. Must be an already existing directory. Defaults to "Modules" in the function app root directory to allow for shared modules between functions.
    [String]$Path = (join-path $(split-path $EXECUTION_CONTEXT_FUNCTIONDIRECTORY -Parent) "Modules")
)

$PSLocalModulePath = $Path

if (($env:psmodulepath -notmatch [Regex]::Escape($PSLocalModulePath)) -and (Test-Path $Path)) {
    write-verbose "Adding $PSLocalModulePath to Powershell Module Path"
    $env:psmodulepath = $PSLocalModulePath + ';' + $env:psmodulepath
}

} #function Add-PSModulePath