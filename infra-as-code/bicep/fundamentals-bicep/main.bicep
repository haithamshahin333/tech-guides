targetScope = 'subscription'

param location string = 'eastus'
param resourceGroupName string = 'bicep-fundamentals'
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

var storageAccountName  = 'toylaunch${uniqueString(resourceGroup.id)}'
module storageAccountModule 'modules/storageAccount.bicep' = {
  scope: resourceGroup
  name: 'storageAcct'
  params: {
    environmentType: environmentType
    location: location
    storageAccountName: storageAccountName
  }
}

var appServiceAppName  = 'toylaunch${uniqueString(resourceGroup.id)}'
module appServiceModule 'modules/appService.bicep' = {
  name: 'appService'
  scope: resourceGroup
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}

output appServiceAppHostName string = appServiceModule.outputs.appServiceAppHostName
