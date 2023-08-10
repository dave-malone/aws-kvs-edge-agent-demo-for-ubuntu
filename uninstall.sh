#!/bin/bash

systemctl stop kvs-edge.service
systemctl disable kvs-edge.service
rm /etc/systemd/system/kvs-edge.service
systemctl daemon-reload
systemctl reset-failed

rm -rf /opt/kvs-edge-agent

# uninstall AWS resources?