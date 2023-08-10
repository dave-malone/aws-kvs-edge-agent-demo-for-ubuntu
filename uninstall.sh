#!/bin/bash

systemctl stop kvs-edge.service
systemctl disable kvs-edge.service
rm /etc/systemd/system/kvs-edge.service
systemctl daemon-reload
systemctl reset-failed

rm -rf /opt/amazon-kinesis-video-streams-edge-sdk-c

# uninstall AWS resources?