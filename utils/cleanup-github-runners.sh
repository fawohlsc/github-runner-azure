#!/bin/bash

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
RG_NAME_PREFIX=github-runner

set -e -u # Exit script on error and treat unset variables as an error

echo -e "${BLUE}Cleaning up GitHub Runners...${NC}"

echo -e "${GREEN}Cleaning up GitHub Runners in subscription [${SUBSCRIPTION_ID}]...${NC}"
az group list --query "[].name" \
 | grep "${RG_NAME_PREFIX}" \
 | grep -oP '"\K[^"\047]+(?=["\047])' \
 | xargs -I {} sh -c "az group delete -n {} --yes"

# TODO: Delete GitHub Runners in repository

echo -e "${GREEN}AZURE_CREDENTIALS:\n[${AZURE_CREDENTIALS}]..${NC}"

echo -e "${BLUE}GitHub Runners cleanup successfully.${NC}"