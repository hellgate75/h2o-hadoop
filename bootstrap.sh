#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}

$HADOOP_HOME/etc/hadoop/hadoop-env.sh

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [[ -e /etc/config/spark/init-hadoop-env.sh ]]; then
  source /etc/config/spark/init-hadoop-env.sh
fi


service ssh start

mkdir -p $HADOOP_HOME/logs

HADOOP_RUNNING="$(ps -eaf|grep java| grep hadoop)"

if [[ -z "$SPARK_RUNNING" ]]; then
  $HADOOP_HOME/sbin/stop-all.sh && \
  $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
  $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
  $HADOOP_HOME/sbin/start-dfs.sh && \
  $HADOOP_HOME/sbin/start-yarn.sh
  nohup run-h2o &
fi

echo "Waiting for product start-up ...."
sleep 30
netstat aux
echo ""
echo "H2O logs :"
cat /opt/nohup.out

if [[ $1 == "-d" ]]; then
  tail -f /dev/null
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
