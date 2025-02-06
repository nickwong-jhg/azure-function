targetScope = 'subscription'

@description('Resource Group Name')
param resourceGroupName string

@description('Location')
param location string

var customTags = {
  costCentre    : 'jhg-integration'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: customTags
  properties: {}
}
