# aws-kvs-edge-agent-demo-for-ubuntu

Demo assets and instructions to quickly get started with the Amazon Kinesis Video Streams Edge Agent.

Requires an AWS account, ideally a gateway device that is running Ubuntu 18.04, and an IP camera.

## Obtain the Amazon Kinesis Video Streams Edge Agent

To access the Amazon Kinesis Video Streams Edge Agent, complete this [brief form](https://pages.awscloud.com/GLOBAL-launch-DL-KVS-Edge-2023-learn.html). You will receive a response shortly from AWS with a link to download the Edge Agent. Download the Edge Agent, and use the following command to extract its contents:

```
tar -xvf 1.1.0.tar.gz
```

The extracted contents of the tarball contain OS and CPU architecture specific builds of the KVS edge agent. The scripts in this directory are designed to work with the `kvs-edge-agent.tar.gz` built for Ubuntu 18.04 running an ARM processor, and they expect to download these contents from an S3 bucket in your AWS account. From the directory where you ran the previous command, execute the following to upload the KVS Edge Agent to your S3 bucket:

```
aws s3 cp 1.1.0/ubuntu/18.04/arm/kvs-edge-agent.tar.gz s3://YOUR-BUCKET-NAME/
```

## Obtain AWS credentials

The scripts in this project make use of the AWS CLI in order to provision resources into your AWS account. To use these scripts, create a temporary AWS key pair and set these as environment variables in your OS. These will only be used to provision your initial set of AWS Cloud resources and can be discarded after the subsequent steps have successfully completed. Follow these instructions to create an AWS access key: https://repost.aws/knowledge-center/create-access-key.

Then, set your AWS access key as environment variables in your device:

```
export AWS_ACCESS_KEY_ID= <AWS account access key>
export AWS_SECRET_ACCESS_KEY= <AWS account secret key>
export AWS_DEFAULT_REGION=us-east-1
```

## Use the install scripts in this repo

```
sudo -E ./easy_install.sh my-ubuntu-kvs-edge s3://YOUR-BUCKET/kvs-edge-agent.tar.gz
```

Upon successful completion, a new service named `kvs-edge.service` will be registered. You can check the status of this service by running the following command: 
`sudo systemctl status kvs-edge.service`. 

The sample applications have been installed under `/opt/kvs-edge-agent`. The service will direct Stdout and Stderror logs to `/var/log/kvs-edge.log`, and service specific logs are in the usual `tail -f /var/log/syslog` file.

## Clean up 

Ensure that you have deleted the AWS access key pair used to initially provision your device as it is no longer needed. 