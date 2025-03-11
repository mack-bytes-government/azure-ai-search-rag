// Basic Parameters
@description('The project abbreviation')
param project_prefix string 

@description('The environment prefix (dev, test, prod)')
@minLength(1)
@maxLength(100)
param env_prefix string

// Network Implementation:
@description('The id of the subnet')
param jumpbox_subnet_id string

// Jumpbox Configuration
param admin_username string
@secure()
param admin_password string

// Tag Configuration:
param default_tag_name string
param default_tag_value string

module jumpbox './modules/jumpbox.bicep' = {
  name: 'jumpbox'
  params: {
    jumpbox_name: '${project_prefix}-box'
    location: resourceGroup().location
    jumpbox_subnet_id: jumpbox_subnet_id
    admin_username: admin_username
    admin_password: admin_password
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}
