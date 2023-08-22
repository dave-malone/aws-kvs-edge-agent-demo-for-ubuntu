#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "$0 is not running as root. Try executing this script via sudo -E."
    exit 2
fi


if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY || -z $AWS_DEFAULT_REGION ]]; then
  echo 'AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION must be set'
  exit 1
fi

export THING_NAME=$1
export KVS_EDGE_AGENT_S3_URI=$2

if [[ -z $THING_NAME ]]; then
  # prompt for thing name
  echo -n "Enter a Name for your IoT Thing: "
  read THING_NAME
fi 

if [[ -z $THING_NAME ]]; then
  echo 'THING_NAME must be set'
  exit 1
fi 

if [[ -z $KVS_EDGE_AGENT_S3_URI ]]; then
  # prompt for thing name
  echo -n "Enter the S3 URI for your KVS Edge Agent package (i.e. s3://bucket-name/KvsEgeAgent1.1.0.tar.gz): "
  read KVS_EDGE_AGENT_S3_URI
fi 

if [[ -z $KVS_EDGE_AGENT_S3_URI ]]; then
  echo 'KVS_EDGE_AGENT_S3_URI must be set'
  exit 1
fi 

echo "downloading KVS edge agent from $KVS_EDGE_AGENT_S3_URI"
aws s3 cp $KVS_EDGE_AGENT_S3_URI ./KvsEdgeAgent.tar.gz

./install-aws-cli.sh
./build-kvs-edge.sh
./provision-thing.sh

chmod +r iot/ -R
cp -r iot/ ./kvs-edge-agent/

echo "moving kvs-edge-agent to /opt/"
sudo cp -r $(pwd)/kvs-edge-agent /opt/

./install-kvs-edge-service.sh
