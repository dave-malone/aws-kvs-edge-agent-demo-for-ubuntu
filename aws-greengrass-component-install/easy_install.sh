#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "$0 is not running as root. Try executing this script via sudo -E."
    exit 2
fi

if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY || -z $AWS_DEFAULT_REGION ]]; then
  echo 'AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION must be set'
  exit 1
fi

export AWS_REGION=$AWS_DEFAULT_REGION 
export THING_NAME=$1
export KVS_EDGE_AGENT_S3_URI=$2

if [[ -z $AWS_REGION ]]; then
  # prompt for thing name
  echo -n "Which AWS_REGION (i.e. us-east-1): "
  read AWS_REGION
fi 

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

./install-greengrass.sh
exit 1
./build-kvs-edge.sh


chmod +r iot/ -R
cp -r iot/ ./kvs-edge-agent/

# generate run-kvs-webrtc.sh using outputs from previous setps
echo "generating run.sh under $(pwd)/kvs-edge-agent"
cat > ./kvs-edge-agent/run.sh <<EOF
#!/bin/bash

export KVS_EDGE_HOME=/opt/kvs-edge-agent
export KVS_EDGE_COMPONENT=\$KVS_EDGE_HOME/KvsEdgeComponent/artifacts/aws.kinesisvideo.KvsEdgeComponent/1.1.0

export AWS_REGION=$AWS_DEFAULT_REGION
export AWS_IOT_CORE_THING_NAME=`cat $(pwd)/iot/thing-name`
export AWS_IOT_CORE_DATA_ATS_ENDPOINT=`cat $(pwd)/iot/iot-core-endpoint`
export AWS_IOT_CORE_CREDENTIAL_ENDPOINT=`cat $(pwd)/iot/credential-provider-endpoint`
export AWS_IOT_CORE_ROLE_ALIAS=`cat $(pwd)/iot/role-alias`

export AWS_IOT_CORE_PRIVATE_KEY=\$KVS_EDGE_HOME/iot/certs/device.private.key
export AWS_IOT_CORE_CERT=\$KVS_EDGE_HOME/iot/certs/device.cert.pem
export AWS_IOT_CA_CERT=\$KVS_EDGE_HOME/iot/certs/root-CA.crt

export LD_LIBRARY_PATH=\$KVS_EDGE_COMPONENT/lib:/usr/local/lib:/usr/local/lib64
export GST_PLUGIN_PATH=\$KVS_EDGE_COMPONENT

pushd \$KVS_EDGE_COMPONENT

echo "pwd: " \$(pwd)
echo "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH"
echo "GST_PLUGIN_PATH=\$GST_PLUGIN_PATH"
echo "AWS env vars:"
env | grep AWS_

java -Djava.library.path=\$KVS_EDGE_COMPONENT \
  --add-opens java.base/jdk.internal.misc=ALL-UNNAMED \
  -Dio.netty.tryReflectionSetAccessible=true \
  -cp kvs-edge-agent.jar:libs.jar \
  com.amazonaws.kinesisvideo.edge.controller.ControllerApp

popd
EOF

chmod 755 ./kvs-edge-agent/run.sh

echo "moving kvs-edge-agent to /opt/"
sudo cp -r $(pwd)/kvs-edge-agent /opt/

./install-kvs-edge-service.sh
