#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

GH_TOKEN=${1}
GH_REPOSITORY=${2}
RUNNER_PACKAGE_VERSION=${3}
RUNNER_NAME=${4}
RUNNER_LABELS=${5}

export RUNNER_ALLOW_RUNASROOT=1 # TODO: Do not run as root

RUNNER_PACKAGE_URL="https://github.com/actions/runner/releases/download/v${RUNNER_PACKAGE_VERSION}/actions-runner-linux-x64-${RUNNER_PACKAGE_VERSION}.tar.gz"
RUNNER_PACKAGE="./actions-runner-linux-x64-2.263.0.tar.gz"

RUNNER_API_ACCEPT_HEADER="Accept: application/vnd.github.v3+json"
RUNNER_API_AUTH_HEADER="Authorization: token ${GH_TOKEN}"
RUNNER_API_URL="https://api.github.com/repos/${GH_REPOSITORY}/actions/runners/registration-token"

RUNNER_URL="https://github.com/${GH_REPOSITORY}"

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

echo -e "${BLUE}Installing GitHub Runner...${NC}"

echo -e "${GREEN}Updating the apt package index...${NC}"
apt-get update

echo -e "${GREEN}Installing jq...${NC}"
apt-get install -y jq

echo -e "${GREEN}Downloading GitHub Runner package...${NC}"
mkdir actions-runner && cd actions-runner
curl -O -L "${RUNNER_PACKAGE_URL}"

echo -e "${GREEN}Extracting GitHub Runner package...${NC}"
tar xzf "${RUNNER_PACKAGE}"

echo -e "${GREEN}Retrieving GitHub Runner token...${NC}"
# TODO Fix CURL command
RUNNER_TOKEN="$(curl \
  -XPOST \
  -fsSL \
  -H "${RUNNER_API_ACCEPT_HEADER}" \
  -H "${RUNNER_API_AUTH_HEADER}" \
  "${RUNNER_API_URL}" \
  | jq -r '.token')"

echo -e "${GREEN}Configure the GitHub Runner...${NC}"
chmod +x ./config.sh
./config.sh \
  --url "${RUNNER_URL}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "${RUNNER_LABELS}" \
  --unattended \
  --replace
unset RUNNER_TOKEN

echo -e "${GREEN}Start the GitHub Runner as service...${NC}"
chmod +x ./svc.sh
./svc.sh install
./svc.sh start
./svc.sh status

echo -e "${BLUE}GitHub Runner installed successfully.${NC}"
