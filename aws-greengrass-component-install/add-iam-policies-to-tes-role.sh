#!/bin/bash

IAM_POLICY=KvsEdgeAccessPolicy
IAM_ROLE=KvsEdgeGreengrassV2TokenExchangeRole

if aws iam get-role-policy --role-name $IAM_ROLE --policy-name $IAM_POLICY 2>&1 | grep -q 'NoSuchEntity'; then
  echo "IAM Role Policy $IAM_POLICY does not exist; creating now..."
  aws iam put-role-policy --role-name $IAM_ROLE \
    --policy-name $IAM_POLICY --policy-document 'file://iam-policy-document.json'
fi