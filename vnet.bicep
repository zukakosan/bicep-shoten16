param location string = resourceGroup().location
param suffix string = 'zukako'

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

// 必要なサブネットの id は VNet のプロパティとして参照できる
// 以下は Microsoft.Network/virtualNetworks/vnet-zukako/subnets/subnet-0 を出力
output subnetId string = virtualNetwork.properties.subnets[0].id
