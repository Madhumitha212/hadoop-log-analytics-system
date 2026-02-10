#!/bin/bash

HADOOP_STREAMING_JAR=$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar

INPUT_PATH=/logs/source/logfiles.log
OUTPUT_PATH=/logs/error_analysis_output

echo "=======Starting error count job======"

echo "cleaning old directory if it exists==="
hdfs dfs -rm -r $OUTPUT_PATH 2>/dev/null

echo "submitting hadoop streaming job"
hadoop jar $HADOOP_STREAMING_JAR \
  -input $INPUT_PATH \
  -output $OUTPUT_PATH \
  -mapper "python3 log_mapper.py" \
  -reducer "python3 log_reducer.py" \
  -file log_mapper.py \
  -file log_reducer.py

echo "===== WordCount Output (Sample) ====="
hdfs dfs -cat $OUTPUT_PATH/part-00000 | head -20

echo "Hadoop streaming job completed successfully"

#Justify mapper and reducer design decisions
#Mapper generates a key value pair only when the status code is greater than 400 and this reduces volume of data given to the shuffle and sort.
#Reducer aggregates the mapper output by counting the status code, and error generating code.So the design is scalable by having 2 separate responsibilities.

#filtering impacts on job performance
#As the mapper filters the dataset , it will emit only fewer key-value pairs so the shuffle and sort has only few data to process.
#The reducer also have small amount of data to process which makes faster execution time and lower execuion overhead.
