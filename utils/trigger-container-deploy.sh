#!/bin/bash

RG_NAME=${1:-"github-runner-container"}
LOCATION=${2:-"WestEurope"}

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

SP_NAME="gitHub-runner-azure"
SP_ROLE="owner"
SP_SCOPES="/subscriptions/${SUBSCRIPTION_ID}"

set -e -u # Exit script on error and treat unset variables as an error

echo -e "${BLUE}Triggering container deploy...${NC}"

[ -z "$GH_TOKEN" ] && echo "Environment variable GH_TOKEN not set."

curl \
    -H "Authorization: token ${GH_TOKEN}" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    "https://api.github.com/repos/:user/:repo/dispatches" \
    -d "{'event_type': 'container-deploy', 'client_payload': {'rg_name': '${RG_NAME}', 'location': '${LOCATION}'}"

echo -e "${BLUE}Container deploy triggered successfully.${NC}"