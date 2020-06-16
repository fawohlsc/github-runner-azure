#!/bin/bash

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SP_NAME="gitHub-runner-azure"
SP_ROLE="owner"
SP_SCOPES="/subscriptions/${SUBSCRIPTION_ID}"

set -e -u # Exit script on error and treat unset variables as an error

echo -e "${BLUE}Creating Azure credentials.${NC}"

echo -e "${GREEN}Creating service principal with contributor access to subscription [${SUBSCRIPTION_ID}]...${NC}"
AZURE_CREDENTIALS=$(az ad sp create-for-rbac \
                        --name ${SP_NAME} \
                        --role ${SP_ROLE} \
                        --scopes ${SP_SCOPES} \
                        --sdk-auth)

echo -e "${GREEN}AZURE_CREDENTIALS:\n[${AZURE_CREDENTIALS}]..${NC}"

echo -e "${BLUE}Azure credentials created successfully.${NC}"