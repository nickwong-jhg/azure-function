@description('Environment short name.')
@allowed([
  'dev'
  'test'
  'uat'
  'prod'
])
param environment string = 'dev'

@description('Deployment Location')
param location string = resourceGroup().location

@description('Date of Deployment')
param dateNow string = utcNow('ddMMyyyyHHmmss')


// Variables
//dateNow is a fall back if there is no buildNumber available on the resourceGroup Tag. 
var deploymentSuffix = contains(resourceGroup().tags, 'buildNumber') ? resourceGroup().tags.buildNumber : dateNow

var conventions   = {
  location        : location
  environment     : environment
  baseTags        : resourceGroup().tags
  customTags      : {
    teamName    : 'Integration'
  }
}

var resourceNames     = {
  resourceGroup       : resourceGroup().name   
  logAnalyticsName    : 'law-eai-core-log-${toLower(environment)}'
  logAnalyticsResourceGroup: 'rg-eai-core-log-analytics-${toLower(environment)}' 
  storageAccount      : {    
    storageAccountIdentifier: 'default'    
  }
}

// modules
module storageAccountDeployment 'modules/storageAccount.bicep' = {
  name: take('st-module-${resourceNames.storageAccount.storageAccountIdentifier}-${deploymentSuffix}', 64)
  params: {
    conventions: conventions
    appName: resourceNames.resourceGroup
    storageAccountIdentifier: resourceNames.storageAccount.storageAccountIdentifier    
  }
}

module appInsightsDeployment 'modules/appInsights.bicep' = {
  name: take('ais-module', 64)
  params: {
    resourceNames: resourceNames
    location: conventions.location
  }
}

module functionAppDeployment 'modules/functionApp.bicep' = {
  name: take('fa-module-${deploymentSuffix}', 64)
  params: {
    conventions: conventions
    resourceNames: resourceNames
    storageAccountName: storageAccountDeployment.outputs.name  
    appInsightsConnectionString: appInsightsDeployment.outputs.connectionString    
  }
}


output functionAppName string = functionAppDeployment.outputs.name
output storageAccountName string = storageAccountDeployment.outputs.name
