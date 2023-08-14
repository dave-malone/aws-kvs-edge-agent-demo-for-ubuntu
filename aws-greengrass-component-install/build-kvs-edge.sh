#!/bin/bash

echo "installing Amazon Kinesis Video Streams Edge Agent build dependencies"
echo "installing build dependencies"

sudo apt-get install -y \
  jq \
  zip \
  unzip \
  gcc \
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

cd kvs-edge-agent 
mvn clean package

mv ./target/libs.jar ./KvsEdgeComponent/artifacts/aws.kinesisvideo.KvsEdgeComponent/1.1.0/