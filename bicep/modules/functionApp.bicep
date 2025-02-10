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


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: resourceNames.logAnalyticsName
  scope: resourceGroup(resourceNames.logAnalyticsResourceGroup)
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName  
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'fa-${resourceNames.resourceGroup}'
  location: conventions.location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  tags: conventions.baseTags
  properties: {
    siteConfig: {
      use32BitWorkerProcess: true
      netFrameworkVersion: 'v8.0'
    }
    httpsOnly: true
    serverFarmId: appServicePlanId
    clientAffinityEnabled: false
  }
}

resource functionAppAppsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: functionApp
  properties: {
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
    AzureWebJobsDashboard: storageAccountConnectionString
    AzureWebJobsStorage: storageAccountConnectionString
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString    
    WEBSITE_CONTENTSHARE: toLower(functionApp.name)
    MSDEPLOY_RENAME_LOCKED_FILES: '1'
    WEBSITE_TIME_ZONE: 'AUS Eastern Standard Time'  
    WEBSITE_RUN_FROM_PACKAGE: '1' 
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString    
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagnosticSettings'
  scope: functionApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
    logs: [
      {
        enabled: true
        category: 'FunctionAppLogs'
      }
    ]
  }
}

output functionAppIdentity string = functionApp.identity.principalId
output functionAppTenantId string = functionApp.identity.tenantId
output name string = functionApp.name
