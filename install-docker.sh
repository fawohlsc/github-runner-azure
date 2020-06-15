#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

echo -e "${BLUE}Installing docker...${NC}"

# TODO: Uninstalling previous versions of docker engine and containerd if any

echo -e "${GREEN}Updating the apt package index...${NC}"
apt-get update

echo -e "${GREEN}Installing packages to allow apt to use a repository over HTTPS...${NC}"
apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common 

echo -e "${GREEN}Adding Docker’s official GPG key${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -


echo -e "${GREEN}Adding Docker's stable apt repository...${NC}"
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo -e "${GREEN}Updating the apt package index...${NC}"
apt-get update

echo -e "${GREEN}Installing docker engine and containerd...${NC}"
apt-get install -y docker-ce docker-ce-cli containerd.io

echo -e "${BLUE}Docker installed successfully.${NC}"