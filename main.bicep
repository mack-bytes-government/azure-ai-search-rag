// Basic Parameters
@description('The project abbreviation')
param project_prefix string 

@description('The environment prefix (dev, test, prod)')
@minLength(1)
@maxLength(100)
param env_prefix string

// Network Implementation:
@description('The id of an existing network to be passed')
param existing_network_name string

// Subnet Configuration
param project_cidr string = '10.0.1.0/24'
param storage_cidr string = '10.0.2.0/24'

// Tag Configuration:
param default_tag_name string
param default_tag_value string

//Deploy into a existing network
module existing_network './modules/network.bicep' = {
  name: 'existing-network'
  params: {
    location: resourceGroup().location
    project_prefix: project_prefix
    env_prefix: env_prefix
    existing_network_name: existing_network_name
    project_cidr: project_cidr
    storage_cidr: storage_cidr
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

module storage './modules/storage.bicep' = {
  name: 'storage'
  params: {
    storage_account_name: '${project_prefix}${env_prefix}stg'
    location: resourceGroup().location
    subnet_id: existing_network.outputs.storage_subnet_id
    vnet_id: existing_network.outputs.id
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

module search './modules/search.bicep' = {
  name: 'search'
  params: {
    search_name: '${project_prefix}${env_prefix}search'
    location: resourceGroup().location
    subnet_id: existing_network.outputs.primary_subnet_id
    vnet_id: existing_network.outputs.id
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
  dependsOn: [
    storage
  ]
}
