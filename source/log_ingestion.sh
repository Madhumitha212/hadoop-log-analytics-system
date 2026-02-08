#!/bin/bash

# Phase 2: Log Ingestion and HDFS Block Analysis
# Task 2: Small Log File Storage

# 1. Define variables
LOCAL_FILE="/mnt/d/hadoop-log-analytics-system/source/logfiles.log"
HDFS_DIR="/logs/source"
HDFS_FILE="$HDFS_DIR/logfiles.log"

# 2. Create HDFS directory (if not exists)
echo "Creating HDFS directory $HDFS_DIR..."
hdfs dfs -mkdir -p $HDFS_DIR

# 3. Upload the small log file to HDFS
echo "Uploading $LOCAL_FILE to HDFS..."
hdfs dfs -put -f $LOCAL_FILE $HDFS_FILE

# 4. List files in HDFS directory
echo "Listing files in $HDFS_DIR..."
hdfs dfs -ls $HDFS_DIR

# 5. Run fsck to check block details
echo "Running HDFS fsck on $HDFS_FILE..."
hdfs fsck $HDFS_FILE -files -blocks

# 6. Analysis message
echo "Analysis:"
echo "- It creates 2 blocks, 1st block is 128MB size and 2nd block is less than 128MB."
echo "- HDFS still allocates a full block even if the file is smaller, leading to inefficiency."
echo "- Many small files increase NameNode metadata overhead and waste block capacity."
ech0 "- YARN must manage and schedule a large number of tasks for small files, which increases scheduling overhead and reduces cluster throughput."
