#!/bin/bash

THING_GROUP_ARN=$(aws iot describe-thing-group --thing-group-name $THING_GROUP_NAME --query thingGroupArn --output text)

DEPLOYMENT_ID=$(aws greengrassv2 list-deployments --target-arn $THING_GROUP_ARN --query deployments[0].deploymentId --output text)

aws greengrassv2 get-deployment --deployment-id $DEPLOYMENT_ID > deployment.json

jq 'del(.deploymentId, .revisionId, .iotJobId, .iotJobArn, .creationTimestamp, .isLatestForTarget, .deploymentStatus, .tags)
 | .components += {"aws.greengrass.SecretManager": { "componentVersion": "2.1.4", "configurationUpdate": { "merge": ""} } }' deployment.json > update-deployment.json

aws greengrassv2 create-deployment --cli-input-json file://update-deployment.json
