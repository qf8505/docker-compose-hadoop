#!/bin/sh

ssh-keygen -t rsa -P ''

cat /root/.ssh/id_rsa.pub >> /root/docker/authorized_keys

docker build -t="centos-hadoop" .

docker-compose up -d

#sh init.sh

sleep 3s

docker inspect -f '{{ .NetworkSettings.IPAddress }} {{.Config.Hostname}}' $(docker ps -q)  > /etc/hosts

scp /etc/hosts hadoop2:/etc/hosts
scp /etc/hosts hadoop3:/etc/hosts
scp /etc/hosts hadoop4:/etc/hosts
scp /etc/hosts hadoop5:/etc/hosts
