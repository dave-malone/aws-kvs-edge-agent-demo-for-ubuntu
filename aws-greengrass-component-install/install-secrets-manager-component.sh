#!/bin/bash

thing_group_arn=$(aws iot describe-thing-group --thing-group-name $THING_GROUP_NAME --query thingGroupArn --output text)

deployment_id=$(aws greengrassv2 list-deployments --target-arn $thing_group_arn --query deployments[0].deploymentId --output text)

aws greengrassv2 get-deployment --deployment-id $deployment_id > deployment.json

read -r -d '' cloud_secrets <<EOF
{ "cloudSecrets": [ {"arn": "$SECRET_ARN" } ] }
EOF

jq --arg cloudsecrets "$cloud_secrets" 'del(.deploymentId, .revisionId, .iotJobId, .iotJobArn, .creationTimestamp, .isLatestForTarget, .deploymentStatus, .tags) |
.components += {
    ("aws.greengrass.SecretManager"): { 
        "componentVersion": "2.1.6", 
        ("configurationUpdate"): { 
            ("merge"): $cloudsecrets
        }
    }
}' deployment.json > update-deployment.json

aws greengrassv2 create-deployment --cli-input-json file://update-deployment.json
