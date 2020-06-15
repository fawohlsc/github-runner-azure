 
#!/bin/bash
# TODO: Run within GitHub Actions
# TODO: Validate GitHub Runner

set -e -u # Exit script on error and treat unset variables as an error

ACCESS_TOKEN=${1} # GitHub access token

BLUE="\033[0;34m"
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color
UNIX_TIME=$(eval "date +%s") # Seconds
RANDOM_STRING=$(head /dev/urandom | tr -dc a-z0-9 | head -c 13)
BASE_NAME="github-runner-2"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
RG_NAME=${BASE_NAME}
LOCATION="WestEurope"
ACR_NAME=${RANDOM_STRING}
ACR_SKU="Basic"
ACR_URL="${ACR_NAME}.azurecr.io"
RUNNER_IMAGE_SOURCE="docker.io/myoung34/github-runner:latest"
RUNNER_IMAGE="github-runner"
RUNNER_IMAGE_TAG=${UNIX_TIME}
# TODO: Do not run GitHub Runner under VM Admin
VM_NAME="${BASE_NAME}"
VM_IMAGE="UbuntuLTS"
VM_ADMIN=${BASE_NAME}
VM_EXT_NAME="customScript"
VM_EXT_PUBLISHER="Microsoft.Azure.Extensions"
VM_EXT_FILE_URIS="'https://raw.githubusercontent.com/fawohlsc/github-runner-azure/master/install-docker.sh','https://raw.githubusercontent.com/fawohlsc/github-runner-azure/master/install-github-runner.sh'"
RUNNER_NAME=${BASE_NAME}
RUNNER_USER=${VM_ADMIN}
REPO_URL="https://github.com/fawohlsc/github-runner-azure"
LABELS="Azure"
# TODO: Do not pass GitHub token via bash to avoid it being stored in bash history
VM_EXT_COMMAND="./install-docker.sh && ./install-github-runner.sh ${ACR_NAME} ${RUNNER_IMAGE} ${RUNNER_IMAGE_TAG} ${RUNNER_NAME} ${RUNNER_USER} ${ACCESS_TOKEN} ${REPO_URL} ${LABELS}"

echo -e "${BLUE}Executing deployment...${NC}"

if az group show --name ${RG_NAME} 2>/dev/null; then
  echo -e "${RED}Resource group [${RG_NAME}] in subscription [${SUBSCRIPTION_ID}] already exists. Exiting...${NC}"
  exit 1
fi

echo -e "${GREEN}Creating resource group [${RG_NAME}] in subscription [${SUBSCRIPTION_ID}]...${NC}"
az group create --location ${LOCATION} --name ${RG_NAME}

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
  --generate-ssh-keys

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
az role assignment create   \
  --assignee ${VM_IDENTITY}   \
  --scope ${ACR_ID}   \
  --role acrpull \
  --debug

echo -e "${GREEN}Installing VM extension [${VM_EXT_NAME}] in VM [${VM_NAME}]...${NC}"
az vm extension set \
  --resource-group ${RG_NAME} \
  --vm-name ${VM_NAME} \
  --name ${VM_EXT_NAME} \
  --publisher ${VM_EXT_PUBLISHER} \
  --protected-settings "{'fileUris': [${VM_EXT_FILE_URIS}],'commandToExecute': '${VM_EXT_COMMAND}'}"

echo -e "${BLUE}Deployment completed successfully.${NC}"