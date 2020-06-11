  
#!/bin/bash
# Suggested improvements:
# - Proper error handling 
# - Refactoring into bash functions 
# Good example: https://github.com/paolosalvatori/front-door-apim/blob/master/scripts/deploy.sh

# Variables
projectName="gha-self-hosted-runner"
rgName="$projectName-rg"
vmName="$projectName-vm"
vmExtensionName="customScript"
vmExtensionFileUri="https://raw.githubusercontent.com/fawohlsc/gha-self-hosted-runner/master/extension.sh"
vmExtensionCommandToExecute="./extension.sh"
publisher="Microsoft.Azure.Extensions"
image="UbuntuLTS"
location="WestEurope"
adminUserName=$projectName

# SubscriptionId of the current subscription
subscriptionId=$(az account show --query id --output tsv)

# Resource Group
echo "Checking if resource group [$rgName] exits in subscription [$subscriptionId]..."
if az group show --name $rgName 1>/dev/null; then
  echo "Found resource group [$rgName] in subscription [$subscriptionId]."
else 
  echo "Creating resource group [$rgName] in subscription [$subscriptionId]..."
  az group create --location $location --name $rgName --query id --output tsv
fi
printf "\n"

# VM
echo "Checking if VM [$vmName] exists in resource group [$rgName]..."
if az vm show --resource-group $rgName --name $vmName 1>/dev/null; then
  echo "Found VM [$vmName] in resource group [$rgName]."
else 
  echo "Creating VM [$vmName] in resource group [$rgName]..."
  az vm create \
    --resource-group $rgName \
    --name $vmName \
    --image $image \
    --admin-username $adminUserName \
    --generate-ssh-keys
fi
printf "\n"

# VM Extension
echo "Checking if VM extension [$vmExtensionName] exists in VM [$vmName]..."
if az vm extension show --resource-group $rgName --vm-name $vmName --name $vmExtensionName 2>/dev/null; then
  echo "Found VM extension [$vmExtensionName] in VM [$vmName]."

  echo "Deleting VM extension [$vmExtensionName] in VM [$vmName]..."
  az vm extension delete --resource-group $rgName --vm-name $vmName --name $vmExtensionName
fi

echo "Installing VM extension [$vmExtensionName] in VM [$vmName]..."
az vm extension set \
  --resource-group $rgName \
  --vm-name $vmName \
  --name $vmExtensionName \
  --publisher $publisher \
  --protected-settings "{'fileUris': ['$vmExtensionFileUri'],'commandToExecute': '$vmExtensionCommandToExecute'}"