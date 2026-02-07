#!/bin/bash

echo "========== STARTING HADOOP =========="

# Load environment variables
source ~/.bashrc

# Safety check
if [ -z "$HADOOP_HOME" ]; then
    echo " HADOOP_HOME not set. Run setup.sh first."
    exit 1
fi

# Start SSH (only if not running)
if ! pgrep -x "sshd" >/dev/null; then
    echo " Starting SSH service..."
    sudo service ssh start
else
    echo "SSH already running"
fi

# Start HDFS
echo " Starting HDFS..."
start-dfs.sh

# Start YARN
echo " Starting YARN..."
start-yarn.sh

echo "========== HADOOP STARTED =========="

# Verify
echo " Running Hadoop services:"
jps
