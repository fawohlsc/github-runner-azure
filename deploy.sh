  
#!/bin/bash

# Variables
PROJECT_NAME="gha-self-hosted-runner"
RESOURCE_GROUP_NAME="$PROJECT_NAME-rg"
VM_NAME="$PROJECT_NAME-vm"
VM_EXTENSION_NAME="$VM_NAME-ext"
IMAGE="UbuntuLTS"
LOCATION="WestEurope"
ADMIN_USERNAME=$PROJECT_NAME

# Resource Group
az group create -l $LOCATION -n $RESOURCE_GROUP_NAME

# VM
az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VM_NAME \
  --image $IMAGE \
  --admin-username $ADMIN_USERNAME \
  --generate-ssh-keys

# VM Extension
az vm extension set \
--resource-group $RESOURCE_GROUP_NAME \
--vm-name $VM_NAME \
--name $VM_EXTENSION_NAME \
--publisher Microsoft.Azure.Extensions \
--force-update \
--protected-settings '{"fileUris": ["https://raw.githubusercontent.com/fawohlsc/gha-self-hosted-runner/master/extension.sh"],"commandToExecute": "./extension.sh"}'