param name string
param location string
param tags object = resourceGroup().tags
param addressPrefix string
param subnets array = []

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [for (subnet, i) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: cidrSubnet(addressPrefix, subnet.size, i)
        networkSecurityGroup: contains(subnet, 'rules') ? {
          id: nsg[i].id
        } : null
      }
    }]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = [for subnet in subnets: if (contains(subnet, 'rules')) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: union(subnet.rules, [
        {
          name: 'deny-inbound-all'
          properties: {
            priority: 4095
            access: 'Deny'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '*'
            protocol: '*'
          }
        }
        {
          name: 'deny-outbound-all'
          properties: {
            priority: 4096
            access: 'Deny'
            direction: 'Outbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '*'
            protocol: '*'
          }
        }
      ])
  }
}]

output addressPrefixes object = toObject(vnet.properties.subnets, subnet => subnet.name, subnet => subnet.properties.addressPrefix)
