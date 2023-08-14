#!/bin/bash

if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY || -z $AWS_DEFAULT_REGION ]]; then
  echo 'AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION must be set'
  exit 1
fi

export SECRET_NAME=$1
export RTSP_URL=$2

if [[ -z $SECRET_NAME ]]; then
  # prompt for secret name
  echo -n "Enter a Name for your Secret: "
  read SECRET_NAME
fi 

if [[ -z $SECRET_NAME ]]; then
  echo 'SECRET_NAME must be set'
  exit 1
fi 

if [[ -z $RTSP_URL ]]; then
  # prompt for rtsp url
  echo -n "Enter your cameras RTSP URL: "
  read RTSP_URL
fi 

if [[ -z $RTSP_URL ]]; then
  echo 'RTSP_URL must be set'
  exit 1
fi

aws secretsmanager create-secret --name $SECRET_NAME \
    --description "RTSP URL to be used with KVS Edge Agent" \
    --secret-string '{"MediaURI": "${RTSP_URL}"}'