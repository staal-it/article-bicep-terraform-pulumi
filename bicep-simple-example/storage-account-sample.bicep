@description('The name of the storage account')
param name string

@description('Azure region of the deployment')
param location string

@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
@description('Storage SKU')
param storageSkuName string = 'Standard_LRS'

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  location: location
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

output storageId string = storage.id
