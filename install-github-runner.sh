#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

ACR_NAME=${1}
RUNNER_IMAGE=${2}
RUNNER_IMAGE_TAG=${3}
RUNNER_NAME=${4}
RUNNER_USER=${5}
ACCESS_TOKEN=${6}
REPO_URL=${7}
LABELS=${8}

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
ACR_URL="${ACR_NAME}.azurecr.io"

echo -e "${BLUE}Installing GitHub runner...${NC}"

echo -e "${GREEN}Adding user [${RUNNER_USER}] to docker group to avoid sudo when running docker...${NC}"
usermod -aG docker ${RUNNER_USER}

echo -e "${GREEN}Installing Azure CLI...${NC}"
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

echo -e "${GREEN}Logging in to Azure...${NC}"
az login --identity

echo -e "${GREEN}Logging in to container registry [${ACR_NAME}]..${NC}"
az acr login --name ${ACR_NAME}

echo -e "${GREEN}Pulling container image [${ACR_URL}/${RUNNER_IMAGE}:${RUNNER_IMAGE_TAG}]..${NC}"
docker pull ${ACR_URL}/${RUNNER_IMAGE}:${RUNNER_IMAGE_TAG}

echo -e "${GREEN}Running GitHub runner as docker container...${NC}"
sudo -u ${RUNNER_USER} \
  -s docker run -d --restart always --name ${RUNNER_NAME} \
  -e ACCESS_TOKEN=${ACCESS_TOKEN} \
  -e REPO_URL=${REPO_URL} \
  -e RUNNER_NAME=${RUNNER_NAME} \
  -e RUNNER_WORKDIR="/tmp/${RUNNER_NAME}" \
  -e LABELS=${LABELS} \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/${RUNNER_NAME}:/tmp/${RUNNER_NAME} \
  ${ACR_URL}/${RUNNER_IMAGE}:${RUNNER_IMAGE_TAG}

echo -e "${BLUE}GitHub runner was successfully installed.${NC}"
