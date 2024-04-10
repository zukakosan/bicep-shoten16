param location string = resourceGroup().location
param suffix string = 'zukako'

var aoaiName = 'aoai-${uniqueString(resourceGroup().id)}${suffix}'
var aspName = 'asp-${uniqueString(resourceGroup().id)}${suffix}'
var appsName = 'apps-${uniqueString(resourceGroup().id)}${suffix}'

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
      ]
    }
  }
}
