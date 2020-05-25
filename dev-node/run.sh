#!/bin/bash

echo "export PATH=$PATH" >> "/root/.profile"
echo "export JAVA_HOME=$JAVA_HOME" >> "/root/.profile"
echo "export HADOOP_VERSION=$HADOOP_VERSION" >> "/root/.profile"
echo "export HADOOP_HOME=$HADOOP_HOME" >> "/root/.profile"
echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" >> "/root/.profile"
echo "export HIVE_HOME=$HIVE_HOME" >> "/root/.profile"
echo "export HIVE_VERSION=$HIVE_VERSION" >> "/root/.profile"
echo "export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH" >> "/root/.profile"

# Link hive config to spark conf
ln -s /opt/hive/conf/hive-site.xml /spark/conf/hive-site.xml

# Run Airflow if it is enabled
if [ "$AIRFLOW" = "1" ]; then airflow initdb; (airflow webserver -p 8080 &) ;(airflow scheduler &); fi

# Start SSH
service ssh restart && bash

tail -f /dev/null
