Write-Host "Cleaning up app registration with client ID: $($azdenv.AZURE_APP_REGISTRATION_CLIENT_ID)"
./scripts/set-az-currentsubscription.ps1
if ($? -eq $true) {
    $azdenv = azd env get-values --output json | ConvertFrom-Json
    az ad app delete --id $azdenv.AZURE_APP_REGISTRATION_CLIENT_ID
    Write-Host "Cleaned up app registration with client ID: $($azdenv.AZURE_APP_REGISTRATION_CLIENT_ID)"
}