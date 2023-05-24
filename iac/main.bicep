targetScope = 'subscription'

@allowed([
  'dev'
  'prod'
])
param environment string
param location string = deployment().location
param addressPrefixes object

var prefix = 'bicep-demo-${environment}'
var tags = {
  environment: environment
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefix}-001'
  location: location
  tags: tags
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    name: 'vnet-${prefix}-001'
    location: location
    addressPrefixes: addressPrefixes[environment]
    subnets: [
      {
        name: 'snet-frontend'
        size: 25
      }
      {
        name: 'snet-backend'
        size: 25
      }
    ]
  }
}

output addressPrefixes object = vnet.outputs.addressPrefixes
