#!/bin/bash
# Decrypt the private key
openssl aes-256-cbc -K $encrypted_f217180e22ee_key -iv $encrypted_f217180e22ee_iv -in id_rsa.enc -out id_rsa -d -in .travis/ssh_key.enc -out ~/.ssh/id_rsa -d
# Set the permission of the key
chmod 600 ~/.ssh/id_rsa
# Start SSH agent
eval $(ssh-agent)
# Add the private key to the system
ssh-add ~/.ssh/id_rsa
# Copy SSH config
cp .travis/ssh_config ~/.ssh/config
# Set Git config
git config --global user.name "Khadas Bot"
git config --global user.email hello@khadas.com
# Clone the repository
git clone git@github.com:khadas/fenix-debs.git .deploy_git

DIR=`date +%F | sed 's/-//g'`
mkdir -p .deploy_git/${DIR}
cp debs/*.deb .deploy_git/${DIR}
cd .deploy_git
git add .
git commit -m "Debian packages updated: `date +"%Y-%m-%d %H:%M"`"
git push --force --quiet git@github.com:khadas/fenix-debs.git master:master
