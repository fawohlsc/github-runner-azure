#!/bin/bash

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color
GH_REPO="fawohlsc/github-runner-azure"
GH_AUTH_HEADER="Authorization: token ${GH_TOKEN}"
GH_ACCEPT_HEADER="Accept: application/vnd.github.everest-preview+json"
GH_API_URL="https://api.github.com/repos/${GH_REPO}"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
RG_NAME_PREFIX=github-runner

[ -z ${GH_TOKEN} ] && echo "Environment variable GH_TOKEN not set." && exit 1
set -e -u # Exit script on error and treat unset variables as an error

echo -e "${BLUE}Cleaning up GitHub Runners...${NC}"

echo -e "${GREEN}Getting all GitHub Runners registered in GitHub Repository [${GH_REPO}]...${NC}"
RUNNERS=$(curl \
    -H "${GH_AUTH_HEADER}" \
    -H "${GH_ACCEPT_HEADER}" \
    "${GH_API_URL}/actions/runners" \
    | jq '.runners[].id')

echo -e "${GREEN}Deregistering GitHub Runners in GitHub Repository [${GH_REPO}]...${NC}"
for RUNNER in ${RUNNERS[@]}; do
    echo -e "${GREEN}Deregistering GitHub Runner [${RUNNER}]...${NC}"
    curl \
    -X DELETE \
    -H "${GH_AUTH_HEADER}" \
    -H "${GH_ACCEPT_HEADER}" \
    "${GH_API_URL}/actions/runners/${RUNNER}"
done

echo -e "${GREEN}Cleaning up GitHub Runners in subscription [${SUBSCRIPTION_ID}]...${NC}"
az group list --query "[].name" \
    | grep "${RG_NAME_PREFIX}" \
    | grep -oP '"\K[^"\047]+(?=["\047])' \
    | xargs -I {} sh -c "az group delete -n {} --yes"

echo -e "${BLUE}GitHub Runners cleanup successfully.${NC}"