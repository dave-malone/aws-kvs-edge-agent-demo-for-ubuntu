#!/bin/bash

echo "installing AWS IoT Greengrass build dependencies"
echo "installing build dependencies"

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt install -y g++-11

wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
sudo add-apt-repository 'deb https://apt.corretto.aws stable main' 

sudo apt-get update 

sudo apt-get install -y \
  curl \
  java-11-amazon-corretto-jdk

curl -s https://d2s8p88vqu9w66.cloudfront.net/releases/greengrass-nucleus-latest.zip > greengrass-nucleus-latest.zip

unzip greengrass-nucleus-latest.zip -d GreengrassInstaller && rm greengrass-nucleus-latest.zip