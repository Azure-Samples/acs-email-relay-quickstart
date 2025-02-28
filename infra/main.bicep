targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = 'westeurope'

param resourceGroupName string = ''
param acsIdentityName string = ''
param acsName string = ''
param emailServiceName string = ''

@description('Principal ID of the app registration that is leveraged to authenticate against the SMTP server')
param appRegistrationPrincipalId string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module managedIdentityAcs './managed-identity.bicep' = {
  name: 'acs-managed-identity'
  scope: rg
  params: {
    name: !empty(acsIdentityName) ? acsIdentityName : '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}-acs'
    location: location
    tags: tags
  }
}

module emailService './email-service.bicep' = {
  name: 'email-service'
  scope: rg
  params: {
    name: !empty(emailServiceName) ? emailServiceName : '${abbrs.communicationServices}${resourceToken}'
    location: 'global'
    dataLocation: 'Europe'
    tags: tags
  }
}

module acs './acs.bicep' = {
  name: 'acs'
  scope: rg
  params: {
    name: !empty(acsName) ? acsName : '${abbrs.communicationServices}${resourceToken}'
    location: 'global'
    dataLocation: 'Europe'
    tags: tags
    acsManagedIdentityName: managedIdentityAcs.outputs.managedIdentityName
    toLinkDomainId: emailService.outputs.domainId
  }
}

resource customRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: guid(subscription().id, 'smtp-sender-role-${environmentName}')
  properties: {
    roleName: 'smtp-sender-role-${environmentName}'
    description: 'Custom role for sending email through SMTP on ACS'
    permissions: [
      {
        actions: [
          'Microsoft.Communication/CommunicationServices/Read'
          'Microsoft.Communication/CommunicationServices/Write'
          'Microsoft.Communication/EmailServices/write'
        ]
        notActions: []
      }
    ]
    assignableScopes: [
      rg.id
    ]
  }
}

module roleAssignment './role-assignment.bicep' = {
  name: 'app-registration-rolebinding'
  scope: rg
  params: {
    name: guid(subscription().id, 'smtp-sender-role-assignment-${environmentName}')
    roleDefinitionId: customRole.id
    principalId: appRegistrationPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output DOMAIN_NAME string = emailService.outputs.domainName
output FROM_SENDER_DOMAIN string = emailService.outputs.fromSenderDomain
output ACS_ID string = acs.outputs.communicationServiceId
output ACS_NAME string = acs.outputs.communicationServiceName
