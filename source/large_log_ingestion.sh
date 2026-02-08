#!/bin/bash

# Phase 2: Log Ingestion and HDFS Block Analysis
# Task 3: Large Log File Storage (3.26 GB with 128 MB block size)

# 1. Define variables
LOCAL_FILE="/mnt/d/hadoop-log-analytics-system/source/large_logfile.log"
HDFS_DIR="/logs/source"
HDFS_FILE="$HDFS_DIR/large_log.log"

# 2. Create HDFS directory (if not exists)
echo "Creating HDFS directory $HDFS_DIR..."
hdfs dfs -mkdir -p $HDFS_DIR

# 3. Upload the large log file to HDFS with block size constraint
echo "Uploading $LOCAL_FILE to HDFS with block size = 128 MB..."
hdfs dfs -Ddfs.blocksize=134217728 -put -f $LOCAL_FILE $HDFS_FILE

# 4. List files in HDFS directory
echo "Listing files in $HDFS_DIR..."
hdfs dfs -ls $HDFS_DIR

# 5. Run fsck to check block details
echo "Running HDFS fsck on $HDFS_FILE..."
hdfs fsck $HDFS_FILE -files -blocks

# 6. Analysis message
echo "Analysis:"
echo "- File size: 3.26 GB"
echo "- Constraint: HDFS block size = 128 MB"
echo "- Expected blocks: 26 (25 full blocks of 128 MB + 1 partial block of ~44 MB)."
echo "- Parallelism: Up to 26 mappers can process blocks simultaneously in MapReduce."
echo "- Fault tolerance: Each block is replicated (default factor = 3), ensuring recovery if a DataNode fails."
echo "- A larger block size improves storage efficiency and reduces metadata overhead, while still enabling sufficient parallelism and fault tolerance for large-scale data processing.."
