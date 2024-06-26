param location string = resourceGroup().location
param suffix string = 'zukako'

param subnetNames array = [
  'AzureFirewallSubent'
  'AzureBastionSubnet'
  'ApplicationGatewaySubnet'
  'subnet-workload'
  'subnet-management'
]
param vnetAddressSpace string = '10.0.0.0/16'
param subnetMaskSize int = 24

var vnetName = 'vnet-${suffix}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
  }
}

resource subnets 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = [
  for i in range(0, subnetCount): {
    parent: vnet
    name: 'subnet-${i}'
    properties: {
      addressPrefix: cidrSubnet(vnetAddressSpace, subnetMaskSize, i)
    }
  }
]
