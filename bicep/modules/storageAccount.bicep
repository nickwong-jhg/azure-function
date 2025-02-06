@description('conventions from Main.bicep')
param conventions object

@description('appName without prefix')
param appName string

@description('For multiple storage accounts, specify uniqueValue for this field in your main.bicep to create a unique StorageName')
param storageAccountIdentifier string

@description('table names in key-value pairs')
param tables object = {}

@description('blob containers in key-value pairs')
param blobContainers object = {}

@description('Configurations based on the environment type.')
var environmentConfigurationMap = {
  dev: {
    sku: 'Standard_LRS'
  }
  test: {
    sku: 'Standard_LRS'
  }
  uat: {
    sku: 'Standard_LRS'
  }
  prod: {
    sku: 'Standard_LRS'
  }
}

@description('StorageAccount Kind')
param storageAccountKind string = 'StorageV2'

var storageName = take(toLower('st${uniqueString(resourceGroup().id, appName, storageAccountIdentifier)}${conventions.environment}'),24)

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageName
  location: conventions.location
  tags: conventions.baseTags
  kind: storageAccountKind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
  sku: {
    name: environmentConfigurationMap[conventions.environment].sku
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = if (!empty(blobContainers)) {
  name: 'default'
  parent: storageAccount
}

resource createBlobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = [for blobContainer in items(blobContainers): {
  name: blobContainer.value
  parent: blobService  
}]

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2021-06-01' = if (!empty(tables)) {
  name: 'default'
  parent: storageAccount
}

resource createTables 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-06-01' = [for table in items(tables): {
  name: table.value
  parent: tableService
}]

output name string = storageAccount.name
