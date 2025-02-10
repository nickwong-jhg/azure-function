@description('conventions from Main.bicep')
param conventions object

@description('resourceGroupName')
param resourceGroupName string 

@description('App Service Plan SKU Name')
param appServicePlanSkuName string = 'W1'

@description('App Service Plan SKU Tier')
param appServicePlanSkuTier string = 'Dynamic'


resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${resourceGroupName}-la-plan'
  location: conventions.location
  tags: conventions.baseTags
  sku: {
    name: appServicePlanSkuName
    tier: appServicePlanSkuTier
  }  
}


output id string = appServicePlan.id
