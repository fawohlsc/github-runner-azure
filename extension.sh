#!/bin/bash
# TODO:
# - Proper error handling 
# - Refactoring into bash functions 
# - Service should not run as sudoer
# - Access variables with ${<NAME>} 

# Parameters
runAsUser=$1
githubToken=$2

# Download GitHub Actions self hosted runner
cd /home/$runAsUser
echo "Downloading GitHub Actions self hosted runner to [$(pwd)]..."
mkdir actions-runner && cd actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v2.263.0/actions-runner-linux-x64-2.263.0.tar.gz

# Extract GitHub Actions self hosted runner into directory
echo "Extracting GitHub Actions self hosted runner to [$(pwd)]..."
tar xzf ./actions-runner-linux-x64-2.263.0.tar.gz
rm ./actions-runner-linux-x64-2.263.0.tar.gz

# Configure GitHub Actions self hosted runner 
echo "Configuring GitHub Actions self hosted runner..."
# VM extension is installed via sudo, but the GitHub Actions self hosted runner should not be configured as root.
# If configured as root, the service will later fail to start because the files are owned by root and the service will not start as user $runAsUser.
# See: https://github.com/Microsoft/azure-pipelines-agent/issues/1481)
sudo chown $runAsUser: ../actions-runner/
sudo chmod -R o=rwx ../actions-runner/
sudo -u $runAsUser -s ./config.sh --url https://github.com/fawohlsc/gha-self-hosted-runner --token $githubToken --unattended

# Install GitHub Actions self hosted runner as a service
echo "Installing GitHub Actions self hosted runner as a service..."
./svc.sh install
./svc.sh start
./svc.sh status