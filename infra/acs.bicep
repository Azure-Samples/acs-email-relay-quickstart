param name string
param location string
param dataLocation string
param tags object = {}
param acsManagedIdentityName string
param toLinkDomainId string

resource managedIdentityAcs 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: acsManagedIdentityName
}

resource communicationService 'Microsoft.Communication/communicationServices@2023-04-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityAcs.id}': {}
    }
  }
  properties: {
    dataLocation: dataLocation
    linkedDomains: [
      toLinkDomainId
    ]
  }
}

output communicationServiceId string = communicationService.id
output communicationServiceName string = communicationService.name
