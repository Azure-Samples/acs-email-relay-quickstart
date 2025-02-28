param name string
param roleDefinitionId string
param principalId string 
param principalType string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: name
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: principalType
  }
}
