#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

GH_TOKEN=${1}
RUNNER_PACKAGE_VERSION=${2}
RUNNER_NAME=${3}
RUNNER_REPO_URL=${4}
RUNNER_LABELS=${5}

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

echo -e "${GREEN}Configure the GitHub Runner...${NC}"
chmod +x ./config.sh
./config.sh \
  --url ${RUNNER_REPO_URL} \
  --token ${GH_TOKEN} \
  --name ${RUNNER_NAME} \
  --labels "${RUNNER_LABELS}" \
  --unattended \
  --replace

echo -e "${GREEN}Start the GitHub Runner as service...${NC}"
chmod +x ./svc.sh
./svc.sh install
./svc.sh start
./svc.sh status

echo -e "${BLUE}GitHub Runner installed successfully.${NC}"
