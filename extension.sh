#!/bin/bash

echo "Downloading GitHub Actions self hosted runner to [$(pwd)]..."
mkdir actions-runner && cd actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v2.263.0/actions-runner-linux-x64-2.263.0.tar.gz

echo "Extracting GitHub Actions self hosted runner to [$(pwd)]..."
tar xzf ./actions-runner-linux-x64-2.263.0.tar.gz
rm ./actions-runner-linux-x64-2.263.0.tar.gz

echo "Configuring GitHub Actions self hosted runner..."
./config.sh --unattended --name $GITHUB_RUNNER_NAME --labels $GITHUB_RUNNER_LABEL --url https://github.com/fawohlsc/gha-self-hosted-runner --token $GITHUB_TOKEN

echo "Installing GitHub Actions self hosted runner as a service..."
./svc.sh install
./svc.sh start
./svc.sh status