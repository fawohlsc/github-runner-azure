#!/bin/bash

RG_NAME=${1:-"github-runner-vm"}
LOCATION=${2:-"WestEurope"}

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

[ -z ${GH_TOKEN} ] && echo "Environment variable GH_TOKEN not set." && exit 1
set -e -u # Exit script on error and treat unset variables as an error

echo -e "${BLUE}Triggering VM deploy...${NC}"

curl \
    -H "Authorization: token ${GH_TOKEN}" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    "https://api.github.com/repos/fawohlsc/github-runner-azure/dispatches" \
    -d "{\"event_type\": \"vm-deploy\", \"client_payload\": {\"rg_name\": \"${RG_NAME}\", \"location\": \"${LOCATION}\"}"

echo -e "${BLUE}VM deploy triggered successfully.${NC}"
