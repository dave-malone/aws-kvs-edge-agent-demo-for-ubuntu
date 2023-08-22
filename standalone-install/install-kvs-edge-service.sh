
KVS_EDGE_HOME=/opt/kvs-edge-agent
KVS_EDGE_VERSION=$(cat kvs-edge-agent/KvsEdgeComponent/recipes/recipe.yaml | grep 'ComponentVersion' | sed 's+ComponentVersion: ++g')
KVS_EDGE_COMPONENT=$KVS_EDGE_HOME/KvsEdgeComponent/artifacts/aws.kinesisvideo.KvsEdgeComponent/$KVS_EDGE_VERSION

# generate kvs-edge.service using outputs from previous setps
echo "generating kvs-edge.service under $(pwd)"
cat > ./kvs-edge.service <<EOF
[Unit]
Description=Amazon Kinesis Video Streams Edge Agent Demo Application
After=network.target
StartLimitBurst=3
StartLimitInterval=30

[Service]
Type=simple
Restart=on-failure
RestartSec=10
User=root
WorkingDirectory=$KVS_EDGE_COMPONENT
Environment="AWS_KVS_EDGE_LOG_OUTPUT_DIRECTORY=/var/log/"
Environment="AWS_KVS_EDGE_RECORDING_DIRECTORY=/tmp/"
Environment="AWS_REGION=$AWS_DEFAULT_REGION"
Environment="AWS_IOT_CORE_THING_NAME=`cat $(pwd)/iot/thing-name`"
Environment="AWS_IOT_CORE_DATA_ATS_ENDPOINT=`cat $(pwd)/iot/iot-core-endpoint`"
Environment="AWS_IOT_CORE_CREDENTIAL_ENDPOINT=`cat $(pwd)/iot/credential-provider-endpoint`"
Environment="AWS_IOT_CORE_ROLE_ALIAS=`cat $(pwd)/iot/role-alias`"
Environment="AWS_IOT_CORE_PRIVATE_KEY=$KVS_EDGE_HOME/iot/certs/device.private.key"
Environment="AWS_IOT_CORE_CERT=$KVS_EDGE_HOME/iot/certs/device.cert.pem"
Environment="AWS_IOT_CA_CERT=$KVS_EDGE_HOME/iot/certs/root-CA.pem"
Environment="GST_PLUGIN_PATH=$KVS_EDGE_COMPONENT"
Environment="LD_LIBRARY_PATH=$KVS_EDGE_COMPONENT/lib"

ExecStart=/usr/lib/jvm/java-11-amazon-corretto/bin/java --add-opens java.base/jdk.internal.misc=ALL-UNNAMED -Dio.netty.tryReflectionSetAccessible=true -cp kvs-edge-agent.jar:libs.jar com.amazonaws.kinesisvideo.edge.controller.ControllerApp
StandardOutput=append:/var/log/kvs-edge.log
StandardError=append:/var/log/kvs-edge.log
 
[Install]
WantedBy=multi-user.target
EOF

cp ./kvs-edge.service /etc/systemd/system/kvs-edge.service

systemctl daemon-reload
systemctl enable kvs-edge.service
systemctl start kvs-edge.service
