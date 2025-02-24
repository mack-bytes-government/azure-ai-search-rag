# Azure-AI-Search-RAG:
This repo contains infrastructure as code for deploying a RAG based implementation to support an AI Model.  

# Installing Azure CLI

To manage your Azure resources, you need to install the Azure CLI. Follow the instructions below to download and install it on your system.

## Windows

1. Download the Azure CLI installer from the following link: [Azure CLI Installer](https://aka.ms/installazurecliwindows).
2. Run the installer and follow the on-screen instructions.

## macOS

1. Open your terminal.
2. Run the following command to install Azure CLI using Homebrew:
    ```bash
    brew update && brew install azure-cli
    ```

## Linux

1. Open your terminal.
2. Run the following commands to install Azure CLI using the package manager for your distribution:

    **Debian/Ubuntu:**
    ```bash
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```

    **RHEL/CentOS:**
    ```bash
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[azure-cli]
    name=Azure CLI
    baseurl=https://packages.microsoft.com/yumrepos/azure-cli
    enabled=1
    gpgcheck=1
    gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
    sudo yum install azure-cli
    ```

    **Fedora:**
    ```bash
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf install -y https://packages.microsoft.com/yumrepos/azure-cli/azure-cli-2.0.81-1.el7.x86_64.rpm
    ```

    **openSUSE:**
    ```bash
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo zypper addrepo --name 'Azure CLI' --check https://packages.microsoft.com/yumrepos/azure-cli azure-cli
    sudo zypper install --from azure-cli -y azure-cli
    ```

After installation, you can verify the installation by running:
```bash
az --version
```

# Logging into Azure

The following steps will make it possible to deploy with a brand new network:
For deploying to Azure Government run the following:
```bash
az cloud set --name AzureUSGovernment
```
The following is the command to login.  
```bash
az login
```

# Deploying the Environment

First this deployment requires a resource group and a virtual network to work with.  If those do not exist, run the following to stand them up.

```bash
RESOURCE_GROUP_NAME="search-rag-dev-rg"
VNET_NAME="search-rag-vnet"
LOCATION="usgovvirginia"
SUBNET_NAME="default"

# Create the resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create the virtual network
az network vnet create --name $VNET_NAME --resource-group $RESOURCE_GROUP_NAME --subnet-name $SUBNET_NAME
```

If you already have a vnet, then run the following:

```bash
RESOURCE_GROUP_NAME="search-rag-dev-rg"
PROJECT_PREFIX="rag"
ENV_PREFIX="dev1"
EXISTING_NETWORK_NAME="search-rag-vnet"
DEFAULT_TAG_NAME="environment"
DEFAULT_TAG_VALUE="search-rag"

az deployment group create --resource-group $RESOURCE_GROUP_NAME --template-file ./main.bicep --parameters project_prefix=$PROJECT_PREFIX env_prefix=$ENV_PREFIX existing_network_name=$EXISTING_NETWORK_NAME default_tag_name=$DEFAULT_TAG_NAME default_tag_value=$DEFAULT_TAG_VALUE
```

To Do:
[ ]: Build out logic app implementation
[ ]: Build out adding index into the Azure Search
[ ]: Build out NSGs to validate everything
[ ]: Review IL4/IL5 to make sure rules are applied.  
[ ]: Build out adding blob for index file for template.