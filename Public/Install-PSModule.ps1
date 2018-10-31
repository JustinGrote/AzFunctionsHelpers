function Install-PSModule {
    [CmdletBinding()]
    param (
        [String[]]$ModuleName,
        [String]$PSLocalModulePath = "$($env:UserProfile)\Documents\WindowsPowershell\Modules"
    )

    if (-not (Test-Path $PSLocalModulePath)) {
        mkdir $PSLocalModulePath > $null
    }

    if ($env:psmodulepath -notmatch [Regex]::Escape($PSLocalModulePath)) {
        write-verbose "Adding $PSLocalModulePath to Powershell Module Path"
        $env:psmodulepath = $PSLocalModulePath + ';' + $env:psmodulepath
    }

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
}