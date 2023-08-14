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
export SECRET_ARN=$2
export KVS_EDGE_AGENT_S3_URI=$2

if [[ -z $THING_NAME ]]; then
  # prompt for thing name
  echo -n "Enter a Name for your IoT Thing: "
  read THING_NAME
  if [[ -z $THING_NAME ]]; then
    echo 'THING_NAME must be set'
    exit 1
  fi  
fi 

if [[ -z $SECRET_ARN ]]; then
  # prompt for secret arn
  echo -n "Enter your Secrets Manager Secret ARN: "
  read SECRET_ARN
  if [[ -z $SECRET_ARN ]]; then
    echo 'SECRET_ARN must be set'
    exit 1
  fi 
fi 



if [[ -z $KVS_EDGE_AGENT_S3_URI ]]; then
  # prompt for thing name
  echo -n "Enter the S3 URI for your KVS Edge Agent package (i.e. s3://bucket-name/KvsEgeAgent1.1.0.tar.gz): "
  read KVS_EDGE_AGENT_S3_URI
  if [[ -z $KVS_EDGE_AGENT_S3_URI ]]; then
    echo 'KVS_EDGE_AGENT_S3_URI must be set'
    exit 1
  fi 
fi

./install-greengrass.sh
./install-aws-cli.sh
./add-iam-policies-to-tes-role.sh
./install-secrets-manager-component.sh
./install-kvs-edge-component.sh