#!/bin/bash

echo "installing Amazon Kinesis Video Streams Edge Agent dependencies"
apt-get install -y \
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

echo "downloading KVS edge agent from $KVS_EDGE_AGENT_S3_URI"
aws s3 cp $KVS_EDGE_AGENT_S3_URI ./KvsEdgeAgent.tar.gz

tar -xvf KvsEdgeAgent.tar.gz

KVS_EDGE_VERSION=$(cat kvs-edge-agent/KvsEdgeComponent/recipes/recipe.yaml | grep 'ComponentVersion' | sed 's+ComponentVersion: ++g')

pushd kvs-edge-agent 
mvn clean package
mv ./target/libs.jar ./KvsEdgeComponent/artifacts/aws.kinesisvideo.KvsEdgeComponent/$KVS_EDGE_VERSION/
popd

/greengrass/v2/bin/greengrass-cli deployment create \
  --recipeDir ./kvs-edge-agent/KvsEdgeComponent/recipes/ \
  --artifactDir ./kvs-edge-agent/KvsEdgeComponent/artifacts/ \
  --merge "aws.kinesisvideo.KvsEdgeComponent=$KVS_EDGE_VERSION"

