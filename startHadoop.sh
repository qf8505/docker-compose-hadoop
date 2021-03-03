#!/bin/bash

topology=hadoop/etc/hadoop/topology.data
nu=`cat $topology | wc -l`
for ((i=1;i<=$nu;i++))
do
        sed -i ''$i's/$/ \/dc1\/rack'"$[($RANDOM%2+1)]"'/' $topology
done

scp hadoop/etc/hadoop/topology.data hadoop2:/hadoop/etc/hadoop/topology.data
scp hadoop/etc/hadoop/topology.data hadoop3:/hadoop/etc/hadoop/topology.data
scp hadoop/etc/hadoop/topology.data hadoop4:/hadoop/etc/hadoop/topology.data
scp hadoop/etc/hadoop/topology.data hadoop5:/hadoop/etc/hadoop/topology.data

ssh hadoop1 "echo 1 >> /data/zookeeper/data/myid"
ssh hadoop2 "echo 2 >> /data/zookeeper/data/myid"
ssh hadoop3 "echo 3 >> /data/zookeeper/data/myid"
ssh hadoop4 "echo 4 >> /data/zookeeper/data/myid"
ssh hadoop5 "echo 5 >> /data/zookeeper/data/myid"

ssh hadoop1 "sh /home/hadoop/zookeeper/bin/zkServer.sh start"
ssh hadoop2 "sh /home/hadoop/zookeeper/bin/zkServer.sh start"
ssh hadoop3 "sh /home/hadoop/zookeeper/bin/zkServer.sh start"
ssh hadoop4 "sh /home/hadoop/zookeeper/bin/zkServer.sh start"
ssh hadoop5 "sh /home/hadoop/zookeeper/bin/zkServer.sh start"


#sh /home/hadoop/hadoop/sbin/start-dfs.sh
# start JournalNode
echo "start hadoop2's JournalNode"
ssh hadoop2 "sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start journalnode"
echo "start hadoop3's JournalNode"
ssh hadoop3 "sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start journalnode"
echo "start hadoop4's JournalNode"
ssh hadoop4 "sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start journalnode"
echo "start hadoop5's JournalNode"
ssh hadoop5 "sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start journalnode"
# Format ZK
echo "Format ZK, this need you input Y or N"
/home/hadoop/hadoop/bin/hdfs zkfc -formatZK
# start DFZK
sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start zkfc
ssh hadoop1 "sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start zkfc"
# start namenode
echo "start hadoop1's namenode, this need input Y or N"
/home/hadoop/hadoop/bin/hdfs namenode -format ns1
sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start namenode
echo "start hadoop1's namenode, this need input Y or N"
ssh hadoop2 "/home/hadoop/hadoop/bin/hdfs namenode -bootstrapStandby"
ssh hadoop2 "sh /home/hadoop/hadoop/sbin/hadoop-daemon.sh start namenode"
# NN's HA succeeded or not
echo "hadoop1's NN is "
/home/hadoop/hadoop/bin/hdfs haadmin -getServiceState nn1
echo "hadoop2's NN is "
/home/hadoop/hadoop/bin/hdfs haadmin -getServiceState nn2
# start datanode
echo "start hadoop1's datanode"
sh /home/hadoop/hadoop/sbin/hadoop-daemons.sh start datanode
# start historyserver
echo "start historyserver"
sh /home/hadoop/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
# start yarn
echo "hadoop1's RM"
ssh hadoop1 "sh /home/hadoop/hadoop/sbin/start-yarn.sh"
echo "start hadoop2's RM"
ssh hadoop2 "sh /home/hadoop/hadoop/sbin/start-yarn.sh"
# RM's HA succeeded or not
echo "hadoop1's RM is "
/home/hadoop/hadoop/bin/yarn rmadmin -getServiceState rm1
echo "hadoop2's RM is "
/home/hadoop/hadoop/bin/yarn rmadmin -getServiceState rm2


# start hive metastore nohup需要刷新环境变量，或者用全路径
ssh hadoop2 "mv /home/hadoop/hive/conf/hive-site.xml.metastore /home/hadoop/hive/conf/hive-site.xml"
ssh hadoop3 "mv /home/hadoop/hive/conf/hive-site.xml.metastore /home/hadoop/hive/conf/hive-site.xml"
ssh hadoop2 "nohup /home/hadoop/hive/bin/hive --service metastore >/dev/null 2>&1 &"
ssh hadoop3 "nohup /home/hadoop/hive/bin/hive --service metastore >/dev/null 2>&1 &"
# start hive metastore
ssh hadoop1 "mv /home/hadoop/hive/conf/hive-site.xml-hiveserver2 /home/hadoop/hive/conf/hive-site.xml"
ssh hadoop1 "nohup /home/hadoop/hive/bin/hiveserver2 >/dev/null 2>&1 &"

