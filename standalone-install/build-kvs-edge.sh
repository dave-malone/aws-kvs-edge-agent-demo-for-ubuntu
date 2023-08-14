#!/bin/bash

echo "installing Amazon Kinesis Video Streams Edge Agent build dependencies"
echo "installing build dependencies"

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt install -y g++-11

wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
sudo add-apt-repository 'deb https://apt.corretto.aws stable main' 

sudo apt-get update 

sudo apt-get install -y \
  curl \
  jq \
  zip \
  unzip \
  gcc \
  java-11-amazon-corretto-jdk \
  maven \
  libssl-dev \
  libcurl4-openssl-dev \
  liblog4cplus-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  gstreamer1.0-plugins-base-apps \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-good \
  gstreamer1.0-tools

tar -xvf KvsEdgeAgent.tar.gz

KVS_EDGE_VERSION=$(cat kvs-edge-agent/KvsEdgeComponent/recipes/recipe.yaml | grep 'ComponentVersion' | sed 's+ComponentVersion: ++g')

cd kvs-edge-agent 
mvn clean package

mv ./target/libs.jar ./KvsEdgeComponent/artifacts/aws.kinesisvideo.KvsEdgeComponent/$KVS_EDGE_VERSION/