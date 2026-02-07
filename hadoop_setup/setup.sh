#!/bin/bash

echo "HADOOP SETUP STARTED "

# STEP 1: CHECK JAVA 8

echo " Checking Java..."

if command -v java >/dev/null 2>&1; then
    java -version
    echo " Java already installed"
else
    echo " Installing Java 8..."
    sudo apt update -y
    sudo apt install openjdk-8-jdk -y
fi

# STEP 2: SET JAVA_HOME (ONLY IF MISSING)

if ! grep -q "JAVA_HOME" ~/.bashrc; then
    echo " Setting JAVA_HOME"
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bashrc
else
    echo " JAVA_HOME already set"
fi

source ~/.bashrc

# STEP 3: CHECK HADOOP

echo " Checking Hadoop..."

if [ -n "$HADOOP_HOME" ] && [ -d "$HADOOP_HOME" ]; then
    echo " Hadoop found at $HADOOP_HOME"
elif [ -d "/mnt/d/hadoop" ]; then
    echo " Hadoop found at /mnt/d/hadoop"
    export HADOOP_HOME=/mnt/d/hadoop
else
    echo " Hadoop not found. Downloading..."
    cd ~
    wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
    mv hadoop-3.3.6.tar.gz /mnt/d/
    cd /mnt/d
    tar -xvzf hadoop-3.3.6.tar.gz
    mv hadoop-3.3.6 hadoop
    sudo chown -R $USER:$USER /mnt/d/hadoop
    export HADOOP_HOME=/mnt/d/hadoop
fi

# STEP 4: SET HADOOP ENV (ONLY IF MISSING)

if ! grep -q "HADOOP_HOME" ~/.bashrc; then
    echo " Setting HADOOP_HOME"
    echo "export HADOOP_HOME=/mnt/d/hadoop" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc
else
    echo " HADOOP_HOME already set"
fi

source ~/.bashrc

# STEP 5: CLEAN & CREATE DATA DIRECTORIES

echo " Preparing Hadoop data directories..."

if [ -d "/mnt/d/hadoop/data" ]; then
    echo "🧹 Removing old Hadoop data directory"
    sudo rm -rf /mnt/d/hadoop/data
fi

mkdir -p ~/hadoop-data/namenode
mkdir -p ~/hadoop-data/datanode

# STEP 6: CONFIGURE core-site.xml

CORE_SITE=$HADOOP_HOME/etc/hadoop/core-site.xml

if ! grep -q "fs.defaultFS" $CORE_SITE 2>/dev/null; then
cat <<EOF > $CORE_SITE
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF
    echo " core-site.xml configured"
else
    echo " core-site.xml already configured"
fi

# STEP 7: CONFIGURE hdfs-site.xml

HDFS_SITE=$HADOOP_HOME/etc/hadoop/hdfs-site.xml

if ! grep -q "dfs.replication" $HDFS_SITE 2>/dev/null; then
cat <<EOF > $HDFS_SITE
<configuration>

  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>

  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:/mnt/d/hadoop/data/namenode</value>
  </property>

  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:/mnt/d/hadoop/data/datanode</value>
  </property>

</configuration>
EOF
    echo " hdfs-site.xml configured"
else
    echo " hdfs-site.xml already configured"
fi

# STEP 8: CONFIGURE mapred-site.xml

MAPRED_SITE=$HADOOP_HOME/etc/hadoop/mapred-site.xml

if [ ! -f "$MAPRED_SITE" ]; then
cat <<EOF > $MAPRED_SITE
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
EOF
    echo " mapred-site.xml configured"
else
    echo " mapred-site.xml already exists"
fi

# STEP 9: CONFIGURE yarn-site.xml

YARN_SITE=$HADOOP_HOME/etc/hadoop/yarn-site.xml

if ! grep -q "mapreduce_shuffle" $YARN_SITE 2>/dev/null; then
cat <<EOF > $YARN_SITE
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
EOF
    echo " yarn-site.xml configured"
else
    echo " yarn-site.xml already configured"
fi

# STEP 10: CHECK & SETUP SSH

echo " Checking SSH..."

if command -v ssh >/dev/null 2>&1; then
    echo " SSH already installed"
else
    sudo apt update -y
    sudo apt install -y openssh-server
fi

if ! service ssh status >/dev/null 2>&1; then
    sudo service ssh start
    echo "🚀 SSH service started"
else
    echo " SSH service running"
fi

if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    echo " Passwordless SSH configured"
else
    echo " SSH key already exists"
fi

# STEP 11: FORMAT NAMENODE (ONLY ONCE)

if [ ! -d "/mnt/d/hadoop/data/namenode/current" ]; then
    echo " Formatting NameNode (first time only)"
    hdfs namenode -format
else
    echo " NameNode already formatted"
fi

echo " HADOOP SETUP COMPLETED"
