param location string = resourceGroup().location

resource dScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createUserScript'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '{YOUR-MANAGED-ID-RESOURCE-ID}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    scriptContent: loadTextContent('./scripts/createUser.ps1')
    retentionInterval: 'P1D'
  }
}
