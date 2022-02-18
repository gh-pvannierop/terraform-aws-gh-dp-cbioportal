#!/bin/bash

yum update -y >> /usr/tmp/user-data.logs
yum -y install jq >> /usr/tmp/user-data.logs
yum -y install docker-19.03.6ce-4.amzn2.x86_64 >> /usr/tmp/user-data.logs
systemctl stop docker >> /usr/tmp/user-data.logs
sed s/^ExecStart=.*/"ExecStart=\/usr\/bin\/dockerd -H tcp:\/\/0.0.0.0:2375  --containerd=\/run\/containerd\/containerd.sock \$OPTIONS \$DOCKER_STORAGE_OPTIONS \$DOCKER_ADD_RUNTIMES"/ /usr/lib/systemd/system/docker.service>/usr/tmp/deamon.service
mv -f /usr/tmp/deamon.service /usr/lib/systemd/system/docker.service
systemctl start docker >> /usr/tmp/user-data.logs
usermod -aG docker ec2-user >> /usr/tmp/user-data.logs
MY_IP=$(hostname -I | awk '{print $1}')
ACCOUNT_NAME=$(aws secretsmanager --region us-west-2 get-secret-value --secret-id account_name | jq --raw-output '.SecretString')
aws secretsmanager --region us-west-2 update-secret --secret-id /$ACCOUNT_NAME/platform/jenkins/docker_daemon_server --secret-string tcp://$MY_IP:2375

exit