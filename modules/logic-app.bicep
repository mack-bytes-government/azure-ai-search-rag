param location string = resourceGroup().location
param logic_app_name string
param subnet_id string
param vnet_id string
param privateDnsZoneName string = 'privatelink.core.usgovcloudapi.net'
param default_tag_name string
param default_tag_value string

resource logic_app 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logic_app_name
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    state: 'Enabled'
    definition: {
      // Define the workflow definition here
    }
    integrationAccount: null
    publicNetworkAccess: 'Disabled'
  }
}

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: {
    '${default_tag_name}': default_tag_value
  }
}

resource private_endpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: '${logic_app_name}-pe'
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${logic_app_name}-plsc'
        properties: {
          privateLinkServiceId: logic_app.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: subnet_id
    }
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
  name: '${logic_app_name}-pdzg'
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
