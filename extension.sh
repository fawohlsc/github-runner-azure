#!/bin/bash

#https://jessicadeen.com/github-actions-self-hosted-runner/

# Download GitHub Actions self-hosted runner
pwd > ~/pwd.txt
mkdir actions-runner && cd actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v2.263.0/actions-runner-linux-x64-2.263.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.263.0.tar.gz

#./config.sh --url https://github.com/fawohlsc/gha-self-hosted-runner --token $GITHUB_TOKEN
#./run.sh