# CentOS with Impala yum
# Author	qf

# build a new hadoop image with basic  centos 
FROM centos:7
# who is the author  
MAINTAINER qf

# install some important softwares
RUN yum -y install httpd openssh-server openssh-clients  net-tools  which

######################Impala####################################
ADD cdh5.7.6-centos7.tar.gz /opt
RUN ln -s /opt/cdh/5.7.6/ /var/www/html/cdh57
COPY startImpala.sh /root
COPY config /etc/selinux

###################Configurate SSH#################################
#generate key files
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''

RUN mkdir /var/run/sshd
ADD run.sh /usr/local/sbin/run.sh
RUN chmod 755 /usr/local/sbin/run.sh

EXPOSE 22
CMD ["/usr/local/sbin/run.sh"]
#ENTRYPOINT  /usr/local/sbin/run.sh