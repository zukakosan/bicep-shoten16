
@description('The location to create the resources')
param location string = resourceGroup().location

@description('The suffix to append to the resources that will be created')
param suffix string = 'zukako'

@description('The names of the subnets to create in the virtual network')
param subnetNames array = [
  'AzureFirewallSubnet'
  'AzureBastionSubnet'
  'ApplicationGatewaySubnet'
  'subnet-workload'
  'subnet-management'
]

@description('The address space for the virtual network')
param vnetAddressSpace string = '10.0.0.0/16'

@description('The size of the subnet mask to use for the subnets')
@minValue(24)
param subnetMaskSize int = 24

@description('The admin username for the virtual machine')
param adminUserName string

@secure()
@description('The admin password for the virtual machine')
param adminPassword string

@description('The security rules for the network security group')
var securityRules = loadJsonContent('./nsgrules/rules.json')

var nsgName = 'nsg-${suffix}'
var vnetName = 'vnet-${suffix}'
var publicIpName = 'pip-${suffix}'
var vmName = 'vm-${suffix}'
var strgName = 'strg${uniqueString(resourceGroup().id)}${suffix}'
var aoaiName = 'aoai-${uniqueString(resourceGroup().id)}${suffix}'
var aspName = 'asp-${uniqueString(resourceGroup().id)}${suffix}'
var appsName = 'apps-${uniqueString(resourceGroup().id)}${suffix}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: securityRules
  }
}

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
          networkSecurityGroup: !(subnet == 'AzureFirewallSubnet' || subnet == 'AzureBastionSubnet') ? { id: nsg.id } : null
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: filter(virtualNetwork.properties.subnets, subnet => subnet.name == 'subnet-workload')[0].id
          }
        }
      }
    ]
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v4'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-g2'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}


resource strgAcct 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: strgName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource aoai 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aoaiName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: aspName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'S1'
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appsName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AZURE_OPENAI_SERVICE_KEY'
          value: aoai.listKeys().key1
        }
        {
          name: 'AZURE_OPENAI_SERVICE_ENDPOINT'
          value: aoai.properties.endpoint
        }
        {
          name: 'STORAGE_ACCOUNT_KEY'
          value: strgAcct.listKeys().keys[0].value
        }
      ]
    }
  }
}
