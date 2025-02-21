// Required Parameters:
param project_prefix string
param env_prefix string 
param location string 

// Configuration Paramters:
// Network Implementation:
param existing_network_name string = ''

// Optional Parameters:
param project_cidr string = '10.0.1.0/24'
param storage_cidr string = '10.0.2.0/24'

param default_tag_name string
param default_tag_value string

resource virtual_network 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: existing_network_name
}

// Subnet for pod pods
resource default_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-project'
  parent: virtual_network
  properties: {
    addressPrefix: project_cidr
  }
}

resource storage_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-storage'
  parent: virtual_network 
  properties: {
    addressPrefix: storage_cidr
  }
}

output id string = virtual_network.id
output name string = virtual_network.name
output primary_subnet_id string = virtual_network.properties.subnets[0].id
output storage_subnet_id string = storage_subnet.id
