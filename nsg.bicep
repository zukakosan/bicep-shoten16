param location string = resourceGroup().location
param suffix string = 'zukako'

var nsgName = 'nsg-${suffix}'
var securityRules = loadJsonContent('./nsgrules/rules.json')

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: securityRules
  }
}
