<#
.SYNOPSIS
Tests if this script is being run within an Azure Functions environment or not
#>
function Test-Environment {

if ($env:FUNCTIONS_EXTENSION_VERSION) {return $true} else {return $false}

} #Function Test-Environment