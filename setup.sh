#!/usr/bin/env bash

set -e
set -x

USR_HOME=/home/spark
SPARK_HOME=/home/spark/spark

cd $USR_HOME

#
# configure ssh
#

cp /etc/ssh/ssh_host_rsa_key.pub .ssh/
cp /etc/ssh/ssh_host_rsa_key .ssh/
chown spark:spark .ssh/*
chmod 600 .ssh/*

echo 'eval `ssh-agent -s`' >> .bashrc
cat >> .bashrc <<EOF
ssh-add $USR_HOME/.ssh/ssh_host_rsa_key
EOF

#
# install spark
#

wget http://mirrors.sonic.net/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
tar -xzf spark-2.2.0-bin-hadoop2.7.tgz
mv spark-2.2.0-bin-hadoop2.7 spark
rm spark-2.2.0-bin-hadoop2.7.tgz

#
# configure spark
#

cat >> $USR_HOME/.bashrc <<EOF
export JAVA_HOME=/usr/lib/jvm/default-java
export SPARK_HOME=$SPARK_HOME
export PATH=$PATH:$SPARK_HOME/bin 
EOF

cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh

cat >> $SPARK_HOME/conf/spark-env.sh <<EOF
export JAVA_HOME=/usr/lib/jvm/default-java
export SPARK_WORKER_CORES=$(nproc --all)
EOF

# add slaves

cat >> $SPARK_HOME/conf/slaves <<EOF
bci-slave-fra1-01
bci-slave-fra1-02
bci-slave-fra1-03
bci-slave-fra1-04
EOF

# package config for slaves

tar -czf spark.tar.gz spark

#
# fin
#

cd - > /dev/null
