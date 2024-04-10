param location string = resourceGroup().location
param suffix string = 'zukako'

param subnetNames array = [
  'AzureFirewallSubent'
  'AzureBastionSubnet'
  'ApplicationGatewaySubnet'
  'subnet-workload'
  'subnet-management'
]
param subnetCount int = 5
param vnetAddressSpace string = '10.0.0.0/16'
param subnetMaskSize int = 24

var vnetName = 'vnet-${suffix}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      for i in range(0, subnetCount): {
        name: 'subnet-${i}'
        properties: {
          addressPrefix: cidrSubnet(vnetAddressSpace, subnetMaskSize, i)
        }
      }
    ]
  }
}

// output subnetId string = filter(virtualNetwork.properties.subnets, s => s.name == subnetName)[0].id
output subnetId string = virtualNetwork.properties.subnets[0].id
