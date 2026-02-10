#!/bin/bash

# Python WordCount using Hadoop Streaming

HADOOP_STREAMING_JAR=$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar

INPUT_DIR=/logs/source/logfiles.log
OUTPUT_DIR=logs/python_wordcount_output

echo "===== Starting Python WordCount Job ====="

echo "Cleaning old output directory if it exists..."
hdfs dfs -rm -r $OUTPUT_DIR 2>/dev/null

echo "Submitting Hadoop Streaming job..."

hadoop jar $HADOOP_STREAMING_JAR \
  -input $INPUT_DIR \
  -output $OUTPUT_DIR \
  -mapper word_mapper.py \
  -reducer word_reducer.py \
  -file word_mapper.py \
  -file word_reducer.py

if [ $? -ne 0 ]; then
  echo "❌ Hadoop Streaming Job FAILED"
  exit 1
fi

echo "===== WordCount Output (Sample) ====="
hdfs dfs -cat $OUTPUT_DIR/part-00000 | head -20

echo "===== Hadoop Streaming Job Completed Successfully ====="

#performance comparison
#Python Hadoop Streaming has higher execution overhead because it runs mapper and reducer as external processes, unlike built-in Java MapReduce which runs inside the JVM.

#Flexibilty comparison
#The Python WordCount implementation using Hadoop Streaming is more flexible than the built-in WordCount because it allows easy modification and rapid development without recompiling Java code.

#Execution Overhead comparison
#The built-in word count has lower execution overhead because it won't create new processes whereas the python streaming has more overhead.