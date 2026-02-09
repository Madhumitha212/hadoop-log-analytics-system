#!/bin/bash

# Phase 3: Built-in WordCount

echo "Starting Built-in WordCount Job..."

# Step 1: Check Hadoop services
echo "Checking Hadoop services..."
jps

# Step 2: Remove output directory if it already exists
echo "Removing old output directory (if exists)..."
hdfs dfs -rm -r /logs/output 2>/dev/null

# Step 3: Run Hadoop built-in WordCount
echo "Running Hadoop built-in WordCount..."

hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
wordcount \
/logs/source/large_log.log \
/logs/output

# Step 4: Verify output directory
echo "Listing output files..."
hdfs dfs -ls /logs/output

# Step 5: Display sample output
echo "Showing first few lines of WordCount output..."
hdfs dfs -head /logs/output/part-r-00000

echo "WordCount Job Completed Successfully!"


