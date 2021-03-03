#!/bin/sh

docker build -t="centos-yum" .

#docker-compose up -d
docker run -d -p 1080:80 --name centos-yum --privileged=true centos-yum /usr/sbin/init
