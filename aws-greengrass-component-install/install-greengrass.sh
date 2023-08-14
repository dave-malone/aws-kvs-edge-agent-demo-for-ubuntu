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

unzip -o greengrass-nucleus-latest.zip -d GreengrassInstaller

sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE \
  -jar ./GreengrassInstaller/lib/Greengrass.jar \
  --aws-region $AWS_REGION \
  --thing-name $THING_NAME \
  --thing-group-name KvsEdgeGreengrassCoreGroup \
  --thing-policy-name KvsEdgeGreengrassV2IoTThingPolicy \
  --tes-role-name KvsEdgeGreengrassV2TokenExchangeRole \
  --tes-role-alias-name KvsEdgeGreengrassCoreTokenExchangeRoleAlias \
  --component-default-user ggc_user:ggc_group \
  --provision true \
  --setup-system-service true \
  --deploy-dev-tools true