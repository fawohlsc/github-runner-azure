#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

RUNNER_URL="https://github.com/actions/runner/releases/download/v2.263.0/actions-runner-linux-x64-2.263.0.tar.gz"
RUNNER_PACKAGE="./actions-runner-linux-x64-2.263.0.tar.gz"
RUNNER_NAME="github-runner-vm"
GITHUB_TOKEN="AJ3UTYFBPRYPDDFTKGRULYC65DV72"
REPO_URL="https://github.com/fawohlsc/github-runner-azure "
LABELS="Azure,VM"

export RUNNER_ALLOW_RUNASROOT=1 # TODO: Do not run as root
BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

echo -e "${BLUE}Installing GitHub Runner...${NC}"

echo -e "${GREEN}Downloading GitHub Runner package...${NC}"
mkdir actions-runner && cd actions-runner
curl -O -L ${RUNNER_URL}

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
