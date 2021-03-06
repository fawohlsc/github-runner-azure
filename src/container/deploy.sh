 
#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color
RANDOM_STRING=$(head /dev/urandom | tr -dc a-z0-9 | head -c 13)
ACR_NAME=${RANDOM_STRING}
ACR_SKU="Basic"
ACR_URL="${ACR_NAME}.azurecr.io"
VM_NAME="${RG_NAME}VM"
VM_IMAGE="UbuntuLTS"
VM_ADMIN=${RG_NAME}
VM_EXT_NAME="customScript"
VM_EXT_PUBLISHER="Microsoft.Azure.Extensions"
VM_EXT_FILE_URIS="'https://raw.githubusercontent.com/${GH_REPOSITORY}/master/container/install-docker.sh','https://raw.githubusercontent.com/${GH_REPOSITORY}/master/container/install-github-runner.sh'"
NSG_NAME="${RG_NAME}VMNSG"
NSG_RULE_NAME="default-allow-ssh"
RUNNER_IMAGE_SOURCE="docker.io/myoung34/github-runner:latest"
RUNNER_IMAGE="github-runner"
RUNNER_IMAGE_TAG="latest" # TODO: #2 Proper versioning of container image
RUNNER_NAME=${RG_NAME}
RUNNER_USER=${VM_ADMIN} # TODO: #3 Do not run GitHub Runner under VM Admin
RUNNER_LABELS="Azure,Container"
REPO_URL="https://github.com/${GH_REPOSITORY}"
# TODO: #4 Do not pass GH_TOKEN via bash
VM_EXT_COMMAND="./install-docker.sh && ./install-github-runner.sh ${ACR_NAME} ${RUNNER_IMAGE} ${RUNNER_IMAGE_TAG} ${RUNNER_NAME} ${RUNNER_USER} ${GH_TOKEN} ${REPO_URL} ${RUNNER_LABELS}"

echo -e "${BLUE}Executing deployment...${NC}"

echo -e "${GREEN}Creating resource group [${RG_NAME}] in location [${RG_LOCATION}]...${NC}"
az group create --location ${RG_LOCATION} --name ${RG_NAME}

echo -e "${GREEN}Creating container registry [${ACR_NAME}] in resource group [${RG_NAME}]...${NC}"
az acr create --resource-group ${RG_NAME} --name ${ACR_NAME} --sku ${ACR_SKU}
ACR_ID=$(az acr show  \
  --resource-group ${RG_NAME} \
  --name ${ACR_NAME} \
  --query id \
  --output tsv)

echo -e "${GREEN}Importing runner image [${RUNNER_IMAGE}] into container registry [${ACR_NAME}]...${NC}"
az acr import \
  --name ${ACR_NAME} \
  --source "${RUNNER_IMAGE_SOURCE}" \
  --image "${RUNNER_IMAGE}:${RUNNER_IMAGE_TAG}"

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

echo -e "${GREEN}Configuring VM [${VM_NAME}] with system-managed identity...${NC}"
az vm identity assign \
 --resource-group ${RG_NAME} \
 --name ${VM_NAME} 
VM_IDENTITY=$(az vm show  \
  --resource-group ${RG_NAME}  \
  --name ${VM_NAME} \
  --query identity.principalId \
  --out tsv)

echo -e "${GREEN}Granting system-managed identity [${VM_IDENTITY}] access to container registry [${ACR_ID}]...${NC}"
# Use assignee-object-id instead of assignee to avoid errors caused by propagation latency in AAD Graph
az role assignment create   \
  --assignee-object-id ${VM_IDENTITY}   \
  --assignee-principal-type ServicePrincipal \
  --scope ${ACR_ID}   \
  --role acrpull

echo -e "${GREEN}Installing VM extension [${VM_EXT_NAME}] in VM [${VM_NAME}]...${NC}"
az vm extension set \
  --resource-group ${RG_NAME} \
  --vm-name ${VM_NAME} \
  --name ${VM_EXT_NAME} \
  --publisher ${VM_EXT_PUBLISHER} \
  --protected-settings "{'fileUris': [${VM_EXT_FILE_URIS}],'commandToExecute': '${VM_EXT_COMMAND}'}"

echo -e "${BLUE}Deployment completed successfully.${NC}"