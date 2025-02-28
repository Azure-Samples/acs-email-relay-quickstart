#run az login and set correct subscription if needed
./scripts/set-az-currentsubscription.ps1

if ($? -eq $true) {

    $azdenv = azd env get-values --output json | ConvertFrom-Json

    # Check if an environment name is available
    if (-not $azdenv.AZURE_ENV_NAME) {
        $environmentName = azd env get-name
        azd env set AZURE_ENV_NAME $environmentName
        $azdenv = azd env get-values --output json | ConvertFrom-Json
    }

    # Create a display name for the app registration based on the environment name
    $displayName = "ACS-Email-Relay-" + $azdenv.AZURE_ENV_NAME
    $app = az ad app list --display-name $displayName --output json | ConvertFrom-Json

    if (!$app) {
        Write-Host "Creating new app registration $displayName..."
    
        # Create app registration for SMTP relay
        $app = az ad app create --display-name $displayName `
            --sign-in-audience AzureADMyOrg `
            --output json | ConvertFrom-Json

        Write-Host "New App registration $displayName created successfully..."

        # Create a service principal for the app registration
        $sp = az ad sp create --id $app.appId --output json | ConvertFrom-Json
        
        Write-Host "Service principal created with object ID: $($sp.id)"
        
        # Store the principal ID in azd environment variables for Bicep
        azd env set AZURE_APP_REGISTRATION_PRINCIPAL_ID $sp.id
        azd env set AZURE_APP_REGISTRATION_CLIENT_ID $app.appId
        
        Write-Host "App Registration Principal ID set in azd environment variables as AZURE_APP_REGISTRATION_PRINCIPAL_ID"
        Write-Host "The App registration's client ID is: $($app.appId)"
    }
    else {
        Write-Host "Application registration $displayName already exists"
        
        # Get the service principal for the existing app registration
        $sp = az ad sp list --filter "appId eq '$($app.appId)'" --output json | ConvertFrom-Json
        
        if ($sp) {
            Write-Host "Using existing service principal with object ID: $($sp.id)"
            azd env set AZURE_APP_REGISTRATION_PRINCIPAL_ID $sp.id
            azd env set AZURE_APP_REGISTRATION_CLIENT_ID $app.appId
            
            Write-Host "The App registration's client ID is: $($app.appId)"
        } else {
            Write-Host "Service principal not found, creating new one..."
            $sp = az ad sp create --id $app.appId --output json | ConvertFrom-Json
            Write-Host "Service principal created with object ID: $($sp.id)"
            azd env set AZURE_APP_REGISTRATION_PRINCIPAL_ID $sp.id
            azd env set AZURE_APP_REGISTRATION_CLIENT_ID $app.appId
        }
    }
}
else {
    Write-Error "Failed to set Azure subscription or login to Azure. Please run 'az login' manually."
    exit 1
}