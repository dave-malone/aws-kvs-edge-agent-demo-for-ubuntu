# aws-kvs-edge-agent-demo-for-ubuntu

## Obtain AWS credentials

The scripts in this project make use of the AWS CLI in order to provision resources into your AWS account. To use these scripts, create a temporary AWS key pair and set these as environment variables in your OS. These will only be used to provision your initial set of AWS Cloud resources and can be discarded after the subsequent steps have successfully completed. Follow these instructions to create an AWS access key: https://repost.aws/knowledge-center/create-access-key.

Then, set your AWS access key as environment variables in your Raspberry Pi device:

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