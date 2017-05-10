#!/bin/bash

ifconfig br0 down
brctl delbr br0
brctl addbr br0
ip link set dev br0 up
ip addr add 192.168.2.1/24 dev br0

rm -rf /root/.ssh/known_hosts

docker run -itd  --privileged --name="hadoop1" --hostname hadoop1 -p 50070:50070 -p 8088:8088 --add-host hadoop1:192.168.2.11 --add-host hadoop2:192.168.2.12 --add-host hadoop3:192.168.2.13 --add-host hadoop4:192.168.2.14 --add-host hadoop5:192.168.2.15 centos-hadoop
docker run -itd  --privileged --name="hadoop2" --hostname hadoop2 --add-host hadoop1:192.168.2.11 --add-host hadoop2:192.168.2.12 --add-host hadoop3:192.168.2.13 --add-host hadoop4:192.168.2.14 --add-host hadoop5:192.168.2.15  centos-hadoop
docker run -itd  --privileged --name="hadoop3" --hostname hadoop3 --add-host hadoop1:192.168.2.11 --add-host hadoop2:192.168.2.12 --add-host hadoop3:192.168.2.13 --add-host hadoop4:192.168.2.14 --add-host hadoop5:192.168.2.15  centos-hadoop
docker run -itd  --privileged --name="hadoop4" --hostname hadoop4 --add-host hadoop1:192.168.2.11 --add-host hadoop2:192.168.2.12 --add-host hadoop3:192.168.2.13 --add-host hadoop4:192.168.2.14 --add-host hadoop5:192.168.2.15  centos-hadoop
docker run -itd  --privileged --name="hadoop5" --hostname hadoop5 --add-host hadoop1:192.168.2.11 --add-host hadoop2:192.168.2.12 --add-host hadoop3:192.168.2.13 --add-host hadoop4:192.168.2.14 --add-host hadoop5:192.168.2.15  centos-hadoop

pipework br0  hadoop1 192.168.2.11/24
pipework br0  hadoop2 192.168.2.12/24
pipework br0  hadoop3 192.168.2.13/24
pipework br0  hadoop4 192.168.2.14/24
pipework br0  hadoop5 192.168.2.15/24

#登�执行
#ssh 192.168.2.11 "sh /usr/local/startHadoop.sh"
