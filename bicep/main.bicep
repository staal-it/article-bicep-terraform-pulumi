targetScope = 'subscription'

param location string = 'westeurope'

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-bicep-article'
  location: location
}

module appService 'Modules/appService.bicep' = {
  scope: resourcegroup
  name: 'appService'
  params: {
    name: 'bicep-article'
    location: location
    cloudFlareToken: 'your_cloudflare_token'
  }
}
