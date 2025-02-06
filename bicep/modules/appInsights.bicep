@description('resourceNames from Main.bicep')
param resourceNames object

@description('Resource deployment location.')
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: resourceNames.logAnalyticsName
  scope: resourceGroup(resourceNames.logAnalyticsResourceGroup)
}

resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ais-${resourceNames.resourceGroup}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    SamplingPercentage: 100
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

output instrumentationkey string = appInsightsComponents.properties.InstrumentationKey
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output connectionString string = appInsightsComponents.properties.ConnectionString
