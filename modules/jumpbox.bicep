param jumpbox_name string
param location string = resourceGroup().location
param jumpbox_subnet_id string

@secure()
param admin_username string
@secure()
param admin_password string

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: '${jumpbox_name}-jumpbox-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${jumpbox_name}-jumpbox-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: jumpbox_subnet_id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
  dependsOn: [
    publicIP
  ]
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: '${jumpbox_name}-jumpbox-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: '${jumpbox_name}-jumpbox'
      adminUsername: admin_username
      adminPassword: admin_password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
  dependsOn: [
    networkInterface
  ]
}

output vmId string = virtualMachine.id
output vmName string = virtualMachine.name
output publicIpAddress string = publicIP.properties.ipAddress
