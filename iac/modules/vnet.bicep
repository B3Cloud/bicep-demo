param name string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param subnets array = []

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [for (subnet, i) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: cidrSubnet(addressPrefixes[0], subnet.size, i)
      }
    }]
  }
}

output addressPrefixes object = toObject(vnet.properties.subnets, subnet => subnet.name, subnet => subnet.properties.addressPrefix)
