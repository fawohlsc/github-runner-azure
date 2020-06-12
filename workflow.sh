 
#!/bin/bash
# TODO: Use image from container registry
# TODO: Convert to GitHub Actions
# TODO: Validate GitHub runner
# TODO: Delete resource group
# TODO: Remove runner after execution

set -e -u # Exit script on error and treat unset variables as an error

ACCESS_TOKEN=${1} # GitHub access token

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BASE_NAME="github-runner-azure-2"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
RG_NAME=${BASE_NAME}
LOCATION="WestEurope"
ACR_NAME="0c1c3dc3396c4642bce16f3993d44230"
ACR_SKU="Basic"
ACR_URL="${ACR_NAME}.azurecr.io"
RUNNER_IMAGE_SOURCE="docker.io/myoung34/github-runner:latest"
RUNNER_IMAGE="github-runner"
RUNNER_IMAGE_TAG=$(eval "date +%s") # Unix time in s
VM_NAME=${BASE_NAME}
VM_IMAGE="UbuntuLTS"
VM_ADMIN=${BASE_NAME}
VM_EXT_NAME="customScript"
VM_EXT_PUBLISHER="Microsoft.Azure.Extensions"
VM_EXT_FILE_URIS="'https://raw.githubusercontent.com/fawohlsc/github-runner-azure/master/install-docker.sh','https://raw.githubusercontent.com/fawohlsc/github-runner-azure/master/install-github-runner.sh'"
RUNNER_NAME=${BASE_NAME}
# TODO: Do not run GitHub runner under VM Admin
RUNNER_USER=${VM_ADMIN}
REPO_URL="https://github.com/fawohlsc/github-runner-azure"
LABELS="Azure"
# TODO: Do not pass GitHub token via bash to avoid it being stored in bash history
VM_EXT_COMMAND="./install-docker.sh && ./install-github-runner.sh ${RUNNER_NAME} ${RUNNER_USER} ${ACCESS_TOKEN} ${REPO_URL} ${LABELS}"

echo -e "${BLUE}Executing workflow...${NC}"

echo -e "${GREEN}Creating resource group [${RG_NAME}] in subscription [${SUBSCRIPTION_ID}]...${NC}"
az group create --location ${LOCATION} --name ${RG_NAME}

echo -e "${GREEN}Creating container registry [${ACR_NAME} in resource group [${RG_NAME}]]...${NC}"
az acr create --resource-group ${RG_NAME} --name ${ACR_NAME} --sku ${ACR_SKU}

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
  --generate-ssh-keys

echo -e "${GREEN}Installing VM extension [${VM_EXT_NAME}] in VM [${VM_NAME}]...${NC}"
az vm extension set \
  --resource-group ${RG_NAME} \
  --vm-name ${VM_NAME} \
  --name ${VM_EXT_NAME} \
  --publisher ${VM_EXT_PUBLISHER} \
  --protected-settings "{'fileUris': [${VM_EXT_FILE_URIS}],'commandToExecute': '${VM_EXT_COMMAND}'}"

echo -e "${BLUE}Workflow was successfully executed.${NC}"