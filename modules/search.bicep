param location string = resourceGroup().location
param search_name string 
param privateDnsZoneName string = 'privatelink.search.usgovcloudapi.net'
param subnet_id string
param vnet_id string 
param default_tag_name string
param default_tag_value string


resource search_service 'Microsoft.Search/searchServices@2023-11-01' = {
  name: search_name
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  sku: {
    name: 'standard'
  }
  properties: {
    hostingMode: 'default'
    partitionCount: 1
    replicaCount: 1
    publicNetworkAccess: 'disabled'
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: [
        {
          id: subnet_id
        }
      ]
    }
  }
}

resource private_endpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${search_name}-pe'
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    subnet: {
      id: subnet_id
    }
    privateLinkServiceConnections: [
      {
        name: '${search_name}-plsc'
        properties: {
          privateLinkServiceId: search_service.id
          groupIds: [
            'searchService'
          ]
        }
      }
    ]
  }
}

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: {
    '${default_tag_name}': default_tag_value
  }
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${private_dns_zone.name}-link'
  parent: private_dns_zone
  location: 'global'
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_id
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  name: '${search_name}-pdzg'
  parent: private_endpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: private_dns_zone.id
        }
      }
    ]
  }
}
