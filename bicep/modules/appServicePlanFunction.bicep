@description('conventions from Main.bicep')
param conventions object

@description('resourceGroupName')
param resourceGroupName string 

@description('App Service Plan SKU Tier')
param appServicePlanSkuTier string = 'Dynamic'

@description('Configurations based on the environment type.')
var environmentConfigurationMap = {
  dev: {
    sku: 'B1'
  }
  test: {
    sku: 'B1'
  }
  uat: {
    sku: 'B1'
  }
  prod: {
    sku: 'Y1'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${resourceGroupName}-func-plan'
  location: conventions.location
  tags: conventions.baseTags
  sku: {
    name: environmentConfigurationMap[conventions.environment].sku
    tier: appServicePlanSkuTier
  }  
}


output id string = appServicePlan.id
