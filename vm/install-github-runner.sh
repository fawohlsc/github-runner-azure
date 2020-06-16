#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

RUNNER_PACKAGE_VERSION="2.263.0"
RUNNER_NAME="github-runner-vm-2"
GITHUB_TOKEN="AJ3UTYFRJYTSIWGN5VLFDNK65D2OE"
REPO_URL="https://github.com/fawohlsc/github-runner-azure "
LABELS="Azure,VM"

export RUNNER_ALLOW_RUNASROOT=1 # TODO: Do not run as root
RUNNER_PACKAGE_URL="https://github.com/actions/runner/releases/download/v${RUNNER_PACKAGE_VERSION}/actions-runner-linux-x64-${RUNNER_PACKAGE_VERSION}.tar.gz"
RUNNER_PACKAGE="./actions-runner-linux-x64-2.263.0.tar.gz"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

echo -e "${BLUE}Installing GitHub Runner...${NC}"

echo -e "${GREEN}Downloading GitHub Runner package...${NC}"
mkdir actions-runner && cd actions-runner
curl -O -L ${RUNNER_PACKAGE_URL}

echo -e "${GREEN}Extracting GitHub Runner package...${NC}"
tar xzf ${RUNNER_PACKAGE}

echo -e "${GREEN}Configure the GitHub Runner ...${NC}"
chmod +x ./config.sh
./config.sh \
  --url ${REPO_URL} \
  --token ${GITHUB_TOKEN} \
  --name ${RUNNER_NAME} \
  --labels "${LABELS}" \
  --unattended \
  --replace

#TODO: Install GitHub runner as service to cover VM reboots
echo -e "${GREEN}Run the GitHub Runner ...${NC}"
chmod +x ./run.sh
./run.sh

echo -e "${BLUE}GitHub Runner installed successfully.${NC}"
