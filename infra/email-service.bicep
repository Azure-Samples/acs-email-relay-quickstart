param name string
param location string
param dataLocation string
param tags object = {}

resource emailService 'Microsoft.Communication/emailServices@2023-06-01-preview' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  properties: {
    dataLocation: dataLocation
  }  
}

resource managedDomain 'Microsoft.Communication/emailServices/domains@2023-06-01-preview' = {
  parent: emailService
  location: location
  name: 'AzureManagedDomain'
  tags: union(tags, { 'azd-service-name': name })
  properties: {
    domainManagement: 'AzureManaged'
    userEngagementTracking: 'Disabled'
  }
}

output domainName string = managedDomain.name
output domainId string = managedDomain.id
output emailServiceId string = emailService.id
output emailServiceName string = emailService.name
output fromSenderDomain string = managedDomain.properties.fromSenderDomain
