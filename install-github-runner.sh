#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

RUNNER_NAME=${1}
RUNNER_USER=${2}
ACCESS_TOKEN=${3}
REPO_URL=${4}
LABELS=${5}

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing GitHub runner...${NC}"

echo -e "${GREEN}Adding user [${RUNNER_USER}] to docker group to avoid sudo when running docker...${NC}"
usermod -aG docker ${RUNNER_USER}

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
  myoung34/github-runner:latest

echo -e "${BLUE}GitHub runner was successfully installed.${NC}"
