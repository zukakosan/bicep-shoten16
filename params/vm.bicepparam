using '../vm.bicep'

param adminUserName = 'AzureAdmin'
param adminPassword = readEnvironmentVariable('ADMIN_PASSWORD')
