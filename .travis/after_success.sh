#!/bin/bash
[  "$TRAVIS_PULL_REQUEST" != "false" ] || [  "$TRAVIS_BRANCH" != "master" ] && echo -e "\n" && exit 0

openssl aes-256-cbc -k "$secret" -in .travis/deploy-key.enc -d -a -out .travis/deploy-key
chmod 600 .travis/deploy-key # this key should have push access
ssh-add .travis/deploy-key
echo -e ">>> Current Repo:$REPO --- Travis Branch:$TRAVIS_BRANCH"
#./deploy

