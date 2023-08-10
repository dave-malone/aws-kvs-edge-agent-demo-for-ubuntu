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

aws s3 cp $KVS_EDGE_AGENT_S3_URI ./KvsEdgeAgent.tar.gz

./install-aws-cli.sh
./build-kvs-edge.sh
./provision-thing.sh

chmod +r iot/ -R
cp -r iot/ ./kvs-edge-agent/

# generate run-kvs-webrtc.sh using outputs from previous setps
echo "generating run.sh under $(pwd)/kvs-edge-agent"
cat > ./kvs-edge-agent/run.sh <<EOF
#!/bin/bash

export KVS_EDGE_HOME=/kvs-edge-agent/KvsEdgeComponent/artifacts/aws.kinesisvideo.KvsEdgeComponent/1.1.0

export AWS_REGION=$AWS_DEFAULT_REGION
export AWS_IOT_CORE_THING_NAME=`cat $(pwd)/iot/thing-name`

export AWS_IOT_CORE_DATA_ATS_ENDPOINT=`cat $(pwd)/iot/iot-core-endpoint`
export AWS_IOT_CORE_CREDENTIAL_ENDPOINT=`cat $(pwd)/iot/credential-provider-endpoint`

export AWS_IOT_CORE_ROLE_ALIAS=`cat $(pwd)/iot/role-alias`

export AWS_IOT_CORE_PRIVATE_KEY=\$KVS_EDGE_HOME/iot/certs/device.private.key
export AWS_IOT_CORE_CERT=\$KVS_EDGE_HOME/iot/certs/device.cert.pem
export AWS_IOT_CA_CERT=\$KVS_EDGE_HOME/iot/certs/root-CA.crt

export LD_LIBRARY_PATH=\$KVS_EDGE_HOME/lib:/usr/local/lib:/usr/local/lib64
export GST_PLUGIN_PATH=\$KVS_EDGE_HOME

pushd \$KVS_EDGE_HOME

echo "pwd: " $(pwd)
echo "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH"
echo "GST_PLUGIN_PATH=\$GST_PLUGIN_PATH"
echo "AWS env vars:"
env | grep AWS_

java -Daws-region=us-west-2 \
  -DisIotDevice=true \
  -Dlog4j.configurationFile=log4j2.xml \
  -DiotThingName=\$AWS_IOT_CORE_THING_NAME \
  -cp kvs-edge-agent.jar:libs.jar \
  com.amazonaws.kinesisvideo.edge.controller.ControllerApp

popd
EOF

# sudo chmod 755 ./amazon-kinesis-video-streams-webrtc-sdk-c/run-kvs-webrtc-client-master-sample.sh

# echo "moving amazon-kinesis-video-streams-webrtc-sdk-c to /opt/"
# sudo cp -r $(pwd)/amazon-kinesis-video-streams-webrtc-sdk-c/* $KVS_WEBRTC_HOME
# sudo chmod +r /opt/amazon-kinesis-video-streams-webrtc-sdk-c/iot/ -R

# ./install-kvs-edge-service.sh
