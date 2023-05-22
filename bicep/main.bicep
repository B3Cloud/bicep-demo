targetScope = 'subscription'

@allowed([
  'dev'
  'prod'
])
param environment string
param location string = deployment().location
param addressPrefix string

var prefix = 'bicep-demo-${environment}'
var tags = { environment: environment }

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
    addressPrefix: addressPrefix
    subnets: [
      {
        name: 'snet-frontend'
        size: 25
        rules: [
          {
            name: 'allow-inbound-https'
            properties: {
              priority: 100
              access: 'Allow'
              direction: 'Inbound'
              sourceAddressPrefix: 'Internet'
              sourcePortRange: '*'
              destinationAddressPrefix: addressPrefix
              destinationPortRange: 443
              protocol: 'Tcp'
            }
          }
        ]
      }
      {
        name: 'snet-backend'
        size: 25
        rules: []
      }
    ]
  }
}

output addressPrefixes object = vnet.outputs.addressPrefixes
