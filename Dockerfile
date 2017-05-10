# CentOS with JDK 7 hadoop zookeeper spark
# Author	qf

# build a new hadoop image with basic  centos 
FROM centos
# who is the author  
MAINTAINER qf

# install some important softwares
RUN yum -y install openssh-server openssh-clients  net-tools  which

####################user##########################################
RUN groupadd hadoop
RUN useradd hadoop -g hadoop -p hadoop

####################Configurate JDK################################
# make a new directory to store the jdk files
RUN mkdir /usr/local/java

# copy the jdk  archive to the image,and it will automaticlly unzip the tar file
#ADD jdk-7u79-linux-x64.tar.gz /usr/local/java/
ADD jdk-8u121-linux-x64.gz /usr/local/java/

# make a symbol link 
RUN ln -s /usr/local/java/jdk1.8.0_121 /usr/local/jdk

###################Configurate SSH#################################
#generate key files
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''

# login localhost without password
RUN ssh-keygen -f /root/.ssh/id_rsa -N ''
# local ssh
COPY authorized_keys /root/.ssh/authorized_keys

RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

##################git##########################
RUN yum install -y git

USER hadoop
#RUN mkdir /home/hadoop/.ssh
RUN ssh-keygen -f /home/hadoop/.ssh/id_rsa -N ''
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys

###################Configurate Hadoop##############################
# copy the hadoop  archive to the image,and it will automaticlly unzip the tar file
ADD hadoop-2.7.1.tar.gz /home/hadoop/

# make a symbol link
RUN ln -s /home/hadoop/hadoop-2.7.1 /home/hadoop/hadoop

# copy the configuration file to image
COPY hadoop-env.sh /home/hadoop/hadoop/etc/hadoop/
COPY core-site.xml /home/hadoop/hadoop/etc/hadoop/
COPY hdfs-site.xml /home/hadoop/hadoop/etc/hadoop/
COPY mapred-site.xml /home/hadoop/hadoop/etc/hadoop/
COPY yarn-site.xml /home/hadoop/hadoop/etc/hadoop/
COPY slaves /home/hadoop/hadoop/etc/hadoop/
COPY topology.sh /home/hadoop/hadoop/etc/hadoop/
COPY topology.data /home/hadoop/hadoop/etc/hadoop/
COPY startHadoop.sh /home/hadoop/

############################zookeeper#############################
ADD zookeeper-3.4.7.tar.gz /home/hadoop
RUN ln -s /home/hadoop/zookeeper-3.4.7 /home/hadoop/zookeeper
COPY zoo.cfg /home/hadoop/zookeeper/conf/

##################hive#######################################
ADD apache-hive-1.2.1-bin.tar.gz /home/hadoop/

RUN ln -s /home/hadoop/apache-hive-1.2.1-bin /home/hadoop/hive

COPY hive-env.sh /home/hadoop/hive/conf/
COPY hive-site.xml /home/hadoop/hive/conf/
COPY mysql-connector-java-5.1.28.jar /home/hadoop/hive/lib/


##################spark#######################################
ADD spark-2.1.0-bin-hadoop2.7.tgz /home/hadoop/
RUN ln -s /home/hadoop/spark-2.1.0-bin-hadoop2.7 /home/hadoop/spark
COPY hdfs-site.xml /home/hadoop/spark/conf/
COPY core-site.xml /home/hadoop/spark/conf/
COPY spark-env.sh /home/hadoop/spark/conf/
COPY slaves /home/hadoop/spark/conf/
COPY spark-defaults.conf /home/hadoop/spark/conf/
COPY hive-site.xml /home/hadoop/spark/conf/
COPY mysql-connector-java-5.1.28.jar /home/hadoop/spark/lib/


#######################sqoop##################################
ADD sqoop-1.4.6.bin__hadoop-2.0.4-alpha.tar.gz /home/hadoop/
RUN ln -s /home/hadoop/sqoop-1.4.6.bin__hadoop-2.0.4-alpha /home/hadoop/sqoop
COPY sqoop-env.sh /home/hadoop/sqoop/conf/
COPY mysql-connector-java-5.1.28.jar /home/hadoop/sqoop/lib/
COPY ojdbc14-10.2.0.5.0.jar /home/hadoop/sqoop/lib/

#######################elasticsearch##########################
ADD elasticsearch-5.3.1.tar.gz /home/hadoop/
RUN ln -s /home/hadoop/elasticsearch-5.3.1 /home/hadoop/elasticsearch
COPY elasticsearch.yml /home/hadoop/elasticsearch/config/
#VOLUME ["/home/hadoop/elasticsearch/config"]
COPY startES.sh /home/hadoop/

################### Integration configuration #######################
# set environment variables
ENV JAVA_HOME /usr/local/jdk
ENV JRE_HOME ${JAVA_HOME}/jre
ENV CLASSPATH .:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV HADOOP_HOME /home/hadoop/hadoop
ENV PATH ${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${JAVA_HOME}/bin:$PATH

RUN echo "JAVA_HOME=/usr/local/jdk" >> /home/hadoop/.bash_profile
RUN echo "JRE_HOME=\${JAVA_HOME}/jre" >> /home/hadoop/.bash_profile
RUN echo "CLASSPATH=.:\${JAVA_HOME}/lib:\${JRE_HOME}/lib" >> /home/hadoop/.bash_profile
RUN echo "HADOOP_HOME=/home/hadoop/hadoop" >> /home/hadoop/.bash_profile
RUN echo "SPARK_HOME=/home/hadoop/spark" >> /home/hadoop/.bash_profile
RUN echo "HIVE_HOME=/home/hadoop/hive" >> /home/hadoop/.bash_profile
RUN echo "SQOOP_HOME=/home/hadoop/sqoop" >> /home/hadoop/.bash_profile
RUN echo "PATH=\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin:\${JAVA_HOME}/bin:\$SPARK_HOME/bin:\$SPARK_HOME/sbin:\$SQOOP_HOME/bin:\$HIVE_HOME/bin:\$PATH" >> /home/hadoop/.bash_profile

USER root
##########################root##########################
RUN chmod 777 /home/hadoop/hadoop/etc/hadoop/topology.sh
RUN chmod 777 /home/hadoop/hadoop/etc/hadoop/topology.data
RUN mkdir -p /data/zookeeper/data
RUN mkdir -p /data/hadoop/namenode
RUN mkdir -p /data/es
RUN chmod -R 777 /data
RUN chown -R hadoop /home/hadoop/zookeeper-3.4.7
RUN chown -R hadoop /home/hadoop/hadoop-2.7.1
RUN chown -R hadoop /home/hadoop/apache-hive-1.2.1-bin
RUN chown -R hadoop /home/hadoop/spark-2.1.0-bin-hadoop2.7
RUN chown -R hadoop /home/hadoop/sqoop-1.4.6.bin__hadoop-2.0.4-alpha
RUN chown -R hadoop /home/hadoop/elasticsearch-5.3.1

RUN chgrp -R hadoop /home/hadoop/zookeeper-3.4.7
RUN chgrp -R hadoop /home/hadoop/hadoop-2.7.1
RUN chgrp -R hadoop /home/hadoop/apache-hive-1.2.1-bin
RUN chgrp -R hadoop /home/hadoop/spark-2.1.0-bin-hadoop2.7
RUN chgrp -R hadoop /home/hadoop/sqoop-1.4.6.bin__hadoop-2.0.4-alpha
RUN chgrp -R hadoop /home/hadoop/elasticsearch-5.3.1

RUN /home/hadoop/elasticsearch/bin/elasticsearch-plugin install x-pack


###########################change es limit######################
RUN echo "* hard nofile 65536" >> /etc/security/limits.conf
RUN echo "* soft nofile 65536" >> /etc/security/limits.conf
RUN echo "vm.max_map_count=262144" >> /etc/sysctl.conf

# change hadoop environment variables
RUN sed -i "s?JAVA_HOME=\${JAVA_HOME}?JAVA_HOME=/usr/local/jdk?g" /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh

RUN echo "JAVA_HOME=/usr/local/jdk" >> /etc/bashrc
RUN echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/bashrc

#更新系统时区
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "Asia/Shanghai" >> /etc/timezone
RUN yum -y install ntp
#ENTRYPOINT /usr/sbin/ntpdate asia.pool.ntp.org && hwclock -w

# set password of root
RUN echo "root:root" | chpasswd
# when start a container it will be executed
#CMD ["/usr/sbin/sshd","-D"]
RUN mkdir /var/run/sshd
ADD run.sh /usr/local/sbin/run.sh
RUN chmod 755 /usr/local/sbin/run.sh

EXPOSE 22
CMD ["/usr/local/sbin/run.sh"]
#ENTRYPOINT  /usr/local/sbin/run.sh
