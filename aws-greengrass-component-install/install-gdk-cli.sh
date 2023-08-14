#!/bin/bash

if ! type "aws" > /dev/null; then
  sudo apt-get install python3-pip -y
  echo "installing the GDK CLI"
  pip3 install git+https://github.com/aws-greengrass/aws-greengrass-gdk-cli.git@v1.3.0
fi

gdk --version
