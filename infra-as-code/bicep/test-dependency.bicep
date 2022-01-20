resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: 'toy-product-launch-plan'
  location: 'eastus'
  sku: {
      name: 'F1'
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: 'toy-product-launch-1'
  location: 'eastus'
  properties: {
      serverFarmId: appServicePlan.id
      httpsOnly: true
  }
}
