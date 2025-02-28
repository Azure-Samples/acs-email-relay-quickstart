$azdenv = azd env get-values --output json | ConvertFrom-Json

$targetSubscription = $azdenv.AZURE_SUBSCRIPTION_ID
$currentSubscription = $null

# Check if we are logged in and get current subscription
try {
    $currentSubscription = az account show --query id -o tsv 2>$null
}
catch {
    $currentSubscription = $null
}

# If not logged in or login session expired
if (!$currentSubscription) {
    Write-Host "AZ CLI Login to the Entra ID tenant used by AZD"
    az login --scope https://graph.microsoft.com//.default
    
    # After login, check if we need to set a specific subscription
    if ($targetSubscription) {
        az account set --subscription $targetSubscription
        $currentSubscription = (az account show --query id -o tsv)
    } else {
        # If no target subscription specified, just get the current one after login
        $currentSubscription = (az account show --query id -o tsv)
        # Update the azd environment with the selected subscription
        azd env set AZURE_SUBSCRIPTION_ID $currentSubscription
    }
}
# If already logged in but need to switch subscriptions
elseif ($targetSubscription -and ($currentSubscription -ne $targetSubscription)) {
    Write-Host "Switching to target subscription: $targetSubscription"
    az account set --subscription $targetSubscription
    if ($? -eq $false) {
        Write-Host "Failed to set the subscription.."
        Write-Host "Make sure you have access to subscription $targetSubscription"
        exit 1
    }
} 
# If no target subscription is set, use the current one
elseif (!$targetSubscription) {
    Write-Host "No target subscription specified in azd environment. Using current subscription: $currentSubscription"
    azd env set AZURE_SUBSCRIPTION_ID $currentSubscription
}

Write-Host "Using subscription: $((az account show --query name -o tsv)) ($((az account show --query id -o tsv)))"
exit 0