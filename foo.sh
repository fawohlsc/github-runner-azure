 
#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color
ACR_NAME="${RG_NAME}ACR"
RUNNER_IMAGE_SOURCE="docker.io/myoung34/github-runner:latest"
RUNNER_IMAGE="github-runner"
RUNNER_IMAGE_TAG=${GITHUB_RUN_NUMBER}
VM_NAME="${RG_NAME}VM"
VM_IMAGE="UbuntuLTS"
VM_ADMIN=${RG_NAME}
VM_EXT_NAME="customScript"
VM_EXT_PUBLISHER="Microsoft.Azure.Extensions"
VM_EXT_FILE_URIS="'https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/master/install-docker.sh','https://raw.githubusercontent.com/${{github.GITHUB_REPOSITORY}}/master/install-github-runner.sh'"
NSG_NAME="${RG_NAME}NSG"
NSG_RULE_NAME="default-allow-ssh"
RUNNER_NAME=${RG_NAME}
RUNNER_USER=${VM_ADMIN} # Do not run GitHub Runner under VM Admin
RUNNER_LABELS="Azure"
REPO_URL="https://github.com/${GITHUB_REPOSITORY}"
VM_EXT_COMMAND="./install-docker.sh && ./install-github-runner.sh ${ACR_NAME} ${RUNNER_IMAGE} ${RUNNER_IMAGE_TAG} ${RUNNER_NAME} ${RUNNER_USER} ${GH_TOKEN_REPO} ${REPO_URL} ${RUNNER_LABELS}"

echo -e "${BLUE}Executing deployment...${NC}"

echo -e "${GREEN}Creating resource group [${RG_NAME}] in location [${RG_LOCATION}]...${NC}"

echo -e "${GREEN}Creating container registry [${ACR_NAME}] in resource group [${RG_NAME}]...${NC}"

echo -e "${GREEN}Importing runner image [${RUNNER_IMAGE}] into container registry [${ACR_NAME}]...${NC}"

echo -e "${GREEN}Creating VM [${VM_NAME}] in resource group [${RG_NAME}]...${NC}"

echo -e "${GREEN}Deleting NSG rule [${NSG_RULE_NAME}] in NSG [${RG_NAME}]...${NC}"

echo -e "${GREEN}Configuring VM [${VM_NAME}] with system-managed identity...${NC}"

echo -e "${GREEN}Granting system-managed identity [${VM_IDENTITY}] access to container registry [${ACR_ID}]...${NC}"

echo -e "${GREEN}Installing VM extension [${VM_EXT_NAME}] in VM [${VM_NAME}]...${NC}"

echo -e "${BLUE}Deployment completed successfully.${NC}"