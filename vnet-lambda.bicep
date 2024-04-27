param location string = resourceGroup().location
param suffix string = 'zukako'

param subnetNames array = [
  'AzureFirewallSubnet'
  'AzureBastionSubnet'
  'ApplicationGatewaySubnet'
  'subnet-workload'
  'subnet-management'
]
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
      for (subnet, i) in subnetNames: {
        name: subnet
        properties: {
          addressPrefix: cidrSubnet(vnetAddressSpace, subnetMaskSize, i)
        }
      }
    ]
  }
}

output subnetId string = filter(virtualNetwork.properties.subnets, subnet => subnet.name == 'subnet-workload')[0].id
