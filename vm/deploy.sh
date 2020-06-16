 
#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

VM_NAME="${RG_NAME}VM"
VM_IMAGE="UbuntuLTS"
VM_ADMIN=${RG_NAME}

NSG_NAME="${RG_NAME}VMNSG"
NSG_RULE_NAME="default-allow-ssh"

RUNNER_PACKAGE_VERSION="2.263.0"
RUNNER_NAME=${RG_NAME}
RUNNER_LABELS="Azure,VM"

VM_EXT_NAME="customScript"
VM_EXT_PUBLISHER="Microsoft.Azure.Extensions"
VM_EXT_FILE_URIS="'https://raw.githubusercontent.com/${GH_REPOSITORY}/master/vm/install-github-runner.sh'"
# TODO: Do not pass GH_TOKEN via bash
echo "GH_REPOSITORY: ${GH_REPOSITORY}" && exit
VM_EXT_COMMAND="./install-github-runner.sh ${GH_TOKEN} ${GH_REPOSITORY} ${RUNNER_PACKAGE_VERSION} ${RUNNER_NAME} ${RUNNER_LABELS}"

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

echo -e "${BLUE}Executing deployment...${NC}"

echo -e "${GREEN}Creating resource group [${RG_NAME}] in location [${RG_LOCATION}]...${NC}"
az group create --location ${RG_LOCATION} --name ${RG_NAME}

echo -e "${GREEN}Creating VM [${VM_NAME}] in resource group [${RG_NAME}]...${NC}"
az vm create \
  --resource-group ${RG_NAME} \
  --name ${VM_NAME} \
  --image ${VM_IMAGE} \
  --admin-username $VM_ADMIN \
  --generate-ssh-keys \
  --public-ip-address "" # Only private IP address

echo -e "${GREEN}Deleting NSG rule [${NSG_RULE_NAME}] in NSG [${NSG_NAME}]...${NC}"
az network nsg rule delete -g ${RG_NAME} --nsg-name ${NSG_NAME} -n ${NSG_RULE_NAME}

echo -e "${GREEN}Installing VM extension [${VM_EXT_NAME}] in VM [${VM_NAME}]...${NC}"
az vm extension set \
  --resource-group ${RG_NAME} \
  --vm-name ${VM_NAME} \
  --name ${VM_EXT_NAME} \
  --publisher ${VM_EXT_PUBLISHER} \
  --protected-settings "{'fileUris': [${VM_EXT_FILE_URIS}],'commandToExecute': '${VM_EXT_COMMAND}'}"

echo -e "${BLUE}Deployment completed successfully.${NC}"