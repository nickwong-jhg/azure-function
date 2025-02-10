@description('conventions from Main.bicep')
param conventions object

@description('resourceNames')
param resourceNames object

@description('Generated storage account name')
param storageAccountName string

@description('appServicePlanId')
param appServicePlanId string

@description('appInsights connection string')
param appInsightsConnectionString string


var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId(resourceGroup().name, 'Microsoft.Storage/storageAccounts', storageAccountName), '2019-04-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'

var logicAppName = 'lap-${resourceNames.resourceGroup}'

resource logicApp 'Microsoft.Web/sites@2021-02-01' = {
  name: logicAppName
  location: conventions.location
  kind: 'functionapp,workflowapp'
  identity: {
      type: 'SystemAssigned'
  }
  tags: conventions.baseTags
  properties: {
      httpsOnly: true
      siteConfig: {
          appSettings: [
              { name: 'APP_KIND', value: 'workflowApp' }
              { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', appInsightsConnectionString }
              { name: 'AzureFunctionsJobHost__extensionBundle__id', value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows' }
              { name: 'AzureFunctionsJobHost__extensionBundle__version', value: '[1.*, 2.0.0)' }
              { name: 'AzureWebJobsStorage', storageAccountConnectionString }
              { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
              { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'node' }
              { name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING', storageAccountConnectionString }
              { name: 'WEBSITE_CONTENTSHARE', value: toLower(logicAppName) }
              { name: 'WEBSITE_NODE_DEFAULT_VERSION', value: '~16' }
              { name: 'Workflows.my-workflow.FlowState', value: 'Disabled' }
          ]
          use32BitWorkerProcess: true
      }
      serverFarmId: appServicePlanId
      clientAffinityEnabled: false
  }
}
output name string = logicApp.name
