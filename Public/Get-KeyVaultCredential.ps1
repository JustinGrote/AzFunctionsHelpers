function Get-KeyVaultCredential {
<#
.SYNOPSIS
Fetches Azure Key Vault credentials using a managed service identity with a more lightweight approach than the Az powershell module
.OUTPUTS
System.Management.Automation.PSCredential
.EXAMPLE
Get-AzFunctionsKeyVaultCredential.ps1 -Identifier https://MYKEYVAULTNAME.vault.azure.net/secrets/MYSECRETNAME
Retreive a secret from MYKEYV
.EXAMPLE
Get-AzFunctionsKeyVaultCredential.ps1 -KeyVaultName MYKEYVAULTNAME -KeyName MYSECRET
#>

[CmdletBinding(DefaultParameterSetName='Identifier')]

param (
    #The Identifier URI for the key or secret. This can be found on the object itself in the Azure Portal
    [Parameter(Mandatory,Position=0,ParameterSetName='Identifier')][URI]$Identifier,
    #The name of your Azure Key Vault
    [Parameter(Mandatory,ParameterSetName='Components')][String]$KeyVaultName,
    #The name of the key you wish to fetch
    [Parameter(Mandatory,ParameterSetName='Components')][String]$KeyName,
    #The type of key you want to fetch. Valid entires are Secret, Key, and Certificate
    [ValidateSet('Secret','Key','Certificate')][Parameter(ParameterSetName='Components')]$KeyType = 'Secret'
)
$endpoint = $env:MSI_ENDPOINT
$secret = $env:MSI_SECRET

if ($PSCmdlet.ParameterSetName -eq 'Components') {
    [URI]$Identifier = "https://$KeyVaultName.vault.azure.net/$KeyType`s/$KeyName"
}

#Sanity Checks
if (-not $env:FUNCTIONS_EXTENSION_VERSION) {throw "Did not detect the Azure Functions environment. You must run this within azure functions"}
if (-not ($env:MSI_Endpoint -and $env:MSI_SECRET)) {throw "No managed services identity found. You must enable one first. https://gotoguy.blog/2017/09/21/using-azure-ad-managed-service-identity-to-access-microsoft-graph-with-azure-functions-and-powershell/"}

# Get Key Vault AuthN Token
$authRequestParams = @{
    Method = 'GET'
    UseBasicParsing = $true
    Header = @{'Secret' = $secret}
    URI = $endpoint
    Body = @{
        resource = 'https://vault.azure.net'
        'api-version' = '2017-09-01'
    }
}
$authenticationResult = Invoke-RestMethod @AuthRequestParams
$authToken = "Bearer $($authenticationResult.access_token)"

# Fetch the Credential
$CredRequestParams = @{
    Method = 'GET'
    UseBasicParsing = $true
    ContentType = 'application/json'
    Headers = @{Authorization = $authToken}
    Body = @{
        'api-version' = '2016-10-01'
    }
    URI = $Identifier
}

#Safely store the credresult securely in memory
$credValue = New-Object SecureString
(Invoke-RestMethod @credRequestParams).value.tochararray() | ForEach-Object {$credValue.appendchar($PSItem)}

#Extract the credential name from the identifier
$credName = ([uri]$Identifier).segments[2] -replace '/',''

#Return the credential object
New-Object PSCredential ($credName,$credValue)

} #function Get-KeyVaultCredential