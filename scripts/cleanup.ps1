./scripts/set-az-currentsubscription.ps1
if ($? -eq $true) {
    $azdenv = azd env get-values --output json | ConvertFrom-Json
    az ad app delete --id $azdenv.AZURE_APP_REGISTRATION_CLIENT_ID
}