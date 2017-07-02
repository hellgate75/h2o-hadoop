#!/bin/bash

if [[ "$1" != "-daemon" ]] && [[ "$1" != "-interactive" ]]; then
  echo "H2O™ with Apache™ Hadoop® $HAHOOP_VERSION boorstrap script wrong arguments ..."
  echo "docker-start-h2o [mode]"
  echo "-daemon       run H2O™ in daemon mode"
  echo "-interactive  run H2O™ in interactive mode (command shell)"
  exit 1
fi

export CONFIGURED_BY_URL_EXIT_CODE=1

if ! [[ -z "$H2O_H2O_HADOOP_CONFIG_TGZ_URL" ]]; then
  if ! [[ -e /root/h2o_hadoop_configured ]]; then
    mkdir -p /root/uploaded/config/hadoop
    echo "Download H2O™ with Apache™ Hadoop® $HAHOOP_VERSION configuration files from : $H2O_HADOOP_CONFIG_TGZ_URL  ..."
    curl -s $H2O_HADOOP_CONFIG_TGZ_URL | tar -xz -C /root/uploaded/config/hadoop/
    export CONFIGURED_BY_URL_EXIT_CODE="$?"
    if [[ "0" == "$CONFIGURED_BY_URL_EXIT_CODE" ]]; then
      cp -f /root/uploaded/config/hadoop/* /etc/config/hadoop/

      cp -Rf $HADOOP_HOME/etc/hadoop /usr/local/spark/etc

      service ssh start
      $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
      $HADOOP_HOME/sbin/start-dfs.sh && \
      $HADOOP_HOME/bin/hdfs dfs -mkdir /user && \
      $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
      $HADOOP_HOME/sbin/stop-dfs.sh
      service ssh stop

      service ssh start
      $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      $HADOOP_HOME/sbin/start-dfs.sh && \
      $HADOOP_HOME/bin/hdfs dfs -mkdir input && \
      $HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/ input && \
      $HADOOP_HOME/sbin/stop-dfs.sh
      service ssh stop
      touch /root/h2o_hadoop_configured
      echo "H2O™ with Apache™ Hadoop® $HAHOOP_VERSION configured by URL files at : $H2O_HADOOP_CONFIG_TGZ_URL !!"
    else
      echo "H2O™ with Apache™ Hadoop® $HAHOOP_VERSION problems downaloading and extracting files from URL : $H2O_HADOOP_CONFIG_TGZ_URL !!"
    fi
  else
    echo "H2O™ with Apache™ Hadoop® $HAHOOP_VERSION already configured!!"
  fi
else
  if ! [[ -z "$(ls -latr /etc/config/hadoop/*)" ]]; then
    cp -Rf $HADOOP_HOME/etc/hadoop /usr/local/spark/etc

    if [[ "true" == "$SPARK_START_HADOOP" ]]; then
      service ssh start
      $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
      $HADOOP_HOME/sbin/start-dfs.sh && \
      $HADOOP_HOME/bin/hdfs dfs -mkdir /user && \
      $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
      $HADOOP_HOME/sbin/stop-dfs.sh
      service ssh stop

      service ssh start
      $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      $HADOOP_HOME/sbin/start-dfs.sh && \
      $HADOOP_HOME/bin/hdfs dfs -mkdir input && \
      $HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/ input && \
      $HADOOP_HOME/sbin/stop-dfs.sh
      service ssh stop
      touch /root/h2o_hadoop_configured
      echo "Apache™ Hadoop® configured by volume : /etc/config/hadoop/ !!"
      export CONFIGURED_BY_URL_EXIT_CODE=0
    else
      echo "Apache™ Hadoop® is deactivate, not configuration action provided!!"
    fi
  fi

fi

if [[ -e /etc/config/hadoop/init-hadoop-env.sh ]]; then
  echo "Boostrap environment variable into the system from file : /etc/config/hadoop/init-hadoop-env.sh !!"
  chmod +x /etc/config/hadoop/init-hadoop-env.sh
  source /etc/config/hadoop/init-hadoop-env.sh
fi

if [[ -e /root/application/bootstrap.sh ]]; then
  echo "Boostrap application script at : /root/application/bootstrap.sh !!"
  chmod +x /root/application/bootstrap.sh
  /root/application/bootstrap.sh
fi


echo "Checking files in /etc/config/hadoop folder ..."
if [[ "" != "$(ls /etc/config/hadoop/)" ]]; then
  echo "Copy new configuration files from folder /etc/config/hadoop ..."
  cp /etc/config/hadoop/* /etc/hadoop/
fi

echo "Starting Apache Hadoop $HAHOOP_VERSION ..."
if [[ $APACHE_HADOOP_SITE_HOSTNAME == "localhost" ]]; then
  export APACHE_HADOOP_SITE_HOSTNAME="$(hostname)"
  #export APACHE_HADOOP_SITE_HOSTNAME="$(ifconfig -a | grep 'inet addr:'| grep -v '127.0.0.1' | sed s/inet\ addr://g | awk 'BEGIN {FS = OFS = " "}{print $1}')"
  echo "Changed Host name :  $APACHE_HADOOP_SITE_HOSTNAME"
fi
if [[ $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME == "localhost" ]]; then
  export APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME="$(hostname)"
  #export APACHE_HADOOP_SITE_HOSTNAME="$(ifconfig -a | grep 'inet addr:'| grep -v '127.0.0.1' | sed s/inet\ addr://g | awk 'BEGIN {FS = OFS = " "}{print $1}')"
  echo "Changed Resource Manager Host name :  $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME"
fi

if [[ "yes" != "$APACHE_HADOOP_IS_CLUSTER" ]]; then
  sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/singlenode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/ > $HADOOP_HOME/etc/hadoop/core-site.xml
else
  sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/clusternode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/ > $HADOOP_HOME/etc/hadoop/core-site.xml
fi

if [[ "0" != "$CONFIGURED_BY_URL_EXIT_CODE" ]]; then

  if ! [[ -e /root/h2o_hadoop_configured ]]; then
    echo "Configuring Apache Hadoop $HAHOOP_VERSION ..."
    echo "Host name :  $APACHE_HADOOP_SITE_HOSTNAME"
    echo "Resource Manager Host name :  $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME"
    mkdir -p /user/$HADOOP_USER/data/hadoop/hdfs/namenode
    mkdir -p /user/$HADOOP_USER/data/hadoop/hdfs/checkpoint
    mkdir -p /user/$HADOOP_USER/data/hadoop/hdfs/datanode
    echo -e "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR\nexport YARN_CONF_DIR=$YARN_CONF_DIR\nexport HADOOP_USER=$HADOOP_USER\nexport HDFS_NAMENODE_USER=$HADOOP_USER\nexport HDFS_DATANODE_USER=$HADOOP_USER\nexport YARN_RESOURCEMANAGER_USER=$HADOOP_USER\nexport YARN_NODEMANAGER_USER=$HADOOP_USER\nexport HDFS_SECONDARYNAMENODE_USER=$HADOOP_USER" >> /root/.bashrc
    echo -e "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> /root/.bashrc
    source /root/.bashrc

    if [[ "yes" != "$APACHE_HADOOP_IS_CLUSTER" ]]; then
      echo "Configuring Apache Hadoop $HAHOOP_VERSION Single Node ..."
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/core-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/core-site.xml
        echo -e "Hadoop Configuration: \nMASTER_HOSTNAME: $APACHE_HADOOP_SITE_HOSTNAME\nBUFFER_SIZE: $APACHE_HADOOP_SITE_BUFFER_SIZE\n"
        sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/singlenode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/  > $HADOOP_HOME/etc/hadoop/core-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/hdfs-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/hdfs-site.xml
        echo -e "HDFS Configuration: \nREPLICATION: $APACHE_HADOOP_HDFS_REPLICATION\nHADOOP_USER: $HADOOP_USER\n"
        sed s/USERNAME/$HADOOP_USER/ $HADOOP_HOME/etc/hadoop/singlenode/hdfs-site.xml.template > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/yarn-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/yarn-site.xml
        echo -e "YARN Configuration: \nRESOURCE_MANAGER: $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME\n"
        sed s/RM_HOSTNAME/$APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME/ $HADOOP_HOME/etc/hadoop/singlenode/yarn-site.xml.template > $HADOOP_HOME/etc/hadoop/yarn-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/mapred-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/mapred-site.xml
        echo -e "Map Reduce Configuration: default\n"
        cp $HADOOP_HOME/etc/hadoop/singlenode/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
      fi
    else
      if [[ "no" != "$APACHE_HADOOP_IS_CLUSTER" ]]; then
        echo "Invalid cluster flag preference : $APACHE_HADOOP_IS_CLUSTER\nExpected: (yes/no) found : $APACHE_HADOOP_IS_CLUSTER"
        exit 1
      fi
      echo "Configuring Apache Hadoop $HAHOOP_VERSION Cluster Node ..."
      if [[ "$APACHE_HADOOP_IS_MASTER" == "yes" ]]; then
        echo "Master Cluster Node"
      else
        echo "Slave Cluster Node"
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/core-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/core-site.xml
        echo -e "Hadoop Configuration: \nMASTER_HOSTNAME: $APACHE_HADOOP_SITE_HOSTNAME\nBUFFER_SIZE: $APACHE_HADOOP_SITE_BUFFER_SIZE\n"
        sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/clusternode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/  > $HADOOP_HOME/etc/hadoop/core-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/hdfs-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/hdfs-site.xml
        echo -e "HDFS Configuration: \nREPLICATION: $APACHE_HADOOP_HDFS_REPLICATION\nHADOOP_USER: $HADOOP_USER\nBLOCK_SIZE: $APACHE_HADOOP_HDFS_BLOCKSIZE\nHADLER_COUNT: $APACHE_HADOOP_HDFS_HANDLERCOUNT\n"
        sed s/REPLICATION/$APACHE_HADOOP_HDFS_REPLICATION/ $HADOOP_HOME/etc/hadoop/clusternode/hdfs-site.xml.template | sed s/USERNAME/$HADOOP_USER/ | \
        sed s/BLOCKSIZE/$APACHE_HADOOP_HDFS_BLOCKSIZE/ | sed s/HANDLERCOUNT/$APACHE_HADOOP_HDFS_HANDLERCOUNT/ > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/yarn-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/yarn-site.xml
        if [[ "$APACHE_HADOOP_YARN_ACL_ENABLED" != 'true' ]]; then
          if [[ "$APACHE_HADOOP_YARN_ACL_ENABLED" != 'false' ]]; then
            export APACHE_HADOOP_YARN_ACL_ENABLED=false
          fi
        fi
        if [[ "$APACHE_HADOOP_YARN_LOG_AGGREGATION" != 'true' ]]; then
          if [[ "$APACHE_HADOOP_YARN_LOG_AGGREGATION" != 'false' ]]; then
            export APACHE_HADOOP_YARN_ACL_ENABLED=false
          fi
        fi
        echo -e "Yarn Configuration: \nRESOURCE_MANAGER: $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME\nACL_ENABLED: $APACHE_HADOOP_YARN_ACL_ENABLED\nADMIN_ACL: $APACHE_HADOOP_YARN_ADMIN_ACL\nLOG AGGREGATION: $APACHE_HADOOP_YARN_LOG_AGGREGATION\n"
        sed s/YANR_ACL_ENABLED/$APACHE_HADOOP_YARN_ACL_ENABLED/ $HADOOP_HOME/etc/hadoop/clusternode/yarn-site.xml.template | sed s/ADMIN_ACL/$APACHE_HADOOP_YARN_ADMIN_ACL/ | \
        sed s/LOG_AGGREGATION/$APACHE_HADOOP_YARN_LOG_AGGREGATION/ | sed s/AGGREGATION_RETAIN/$APACHE_HADOOP_YARN_AGGREGATION_RETAIN_SECONDS/ | \
        sed s/AGGREGATION_RETAIN_CHECK/$APACHE_HADOOP_YARN_AGGREGATION_RETAIN_CHECK_SECONDS/ | sed s/RM_HOSTNAME/$APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME/ > $HADOOP_HOME/etc/hadoop/yarn-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/mapred-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/mapred-site.xml
        echo -e "Map Reduce Configuration: \nMAP_MEM_MBS: $APACHE_HADOOP_MAPRED_MAP_MEMORY_MBS\nMAP_OPTS: $APACHE_HADOOP_MAPRED_MAP_JAVA_OPTS\nRED_MEM_MBS: $APACHE_HADOOP_MAPRED_RED_MEMORY_MBS\nRED_OPTS: $APACHE_HADOOP_MAPRED_RED_JAVA_OPTS\n"
        echo -e "SORT_MEM_MBS: $APACHE_HADOOP_MAPRED_SORT_MEMORY_MBS\nSORT_FACT: $APACHE_HADOOP_MAPRED_SORT_FACTOR\nSHUGGLE_COPIES: $APACHE_HADOOP_MAPRED_SHUFFLE_PARALLELCOPIES\n"
        echo -e "JOB_HISTORY_ADDR: $APACHE_HADOOP_MAPRED_JOB_HISTORY_HOSTNAME\nJOB_HISTORY_PORT: $APACHE_HADOOP_MAPRED_JOB_HISTORY_PORT\nJI_WEB_ADDR: $APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_HOSTNAME\n"
        echo -e "JI_WEB_PORT: $APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_PORT\n"
        sed s/MAPRED_MAP_MEMORY/$APACHE_HADOOP_MAPRED_MAP_MEMORY_MBS/ $HADOOP_HOME/etc/hadoop/clusternode/mapred-site.xml.template | sed s/MAPRED_MAP_JAVA_OPTS/$APACHE_HADOOP_MAPRED_MAP_JAVA_OPTS/ | \
        sed s/MAPRED_RED_JAVA_OPTS/$APACHE_HADOOP_MAPRED_RED_JAVA_OPTS/ | sed s/MAPRED_RED_MEMORY/$APACHE_HADOOP_MAPRED_RED_MEMORY_MBS/ | \
        sed s/MAPRED_SORT_MEMORY/$APACHE_HADOOP_MAPRED_SORT_MEMORY_MBS/ | sed s/MAPRED_SORT_FACTOR/$APACHE_HADOOP_MAPRED_SORT_FACTOR/ | \
        sed s/MAPRED_SHUFFLE/$APACHE_HADOOP_MAPRED_SHUFFLE_PARALLELCOPIES/ | sed s/JOB_HISTORY_HOSTNAME/$APACHE_HADOOP_MAPRED_JOB_HISTORY_HOSTNAME/ | \
        sed s/JOB_HISTORY_PORT/$APACHE_HADOOP_MAPRED_JOB_HISTORY_PORT/ | sed s/JOB_HISTORY_WEBUI_HOSTNAME/$APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_HOSTNAME/ | \
        sed s/JOB_HISTORY_WEBUI_PORT/$APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_PORT/ > $HADOOP_HOME/etc/hadoop/mapred-site.xml
      fi
    fi
    if [[ -e /usr/share/zoneinfo/$MACHINE_TIMEZONE ]]; then
      ln -fs /usr/share/zoneinfo/$MACHINE_TIMEZONE /etc/localtime
      echo "Current Timezone: $(cat /etc/timezone)"
      dpkg-reconfigure tzdata
    fi

    service ssh start
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir /user && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
    $HADOOP_HOME/sbin/stop-dfs.sh
    service ssh stop

    service ssh start
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir input && \
    $HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/ input && \
    $HADOOP_HOME/sbin/stop-dfs.sh
    service ssh stop
    touch /root/h2o_hadoop_configured
  else
    echo "H2O™ with Apache™ Hadoop® $HAHOOP_VERSION already configured!!"
  fi

fi

if [[ $1 == "-daemon" ]]; then
  /etc/bootstrap.sh -d
else
  if [[ $1 == "-interactive" ]]; then
    /etc/bootstrap.sh -bash
  else
    echo "H2O™ with Apache™ Hadoop® $HAHOOP_VERSION boorstrap script wrong arguments ..."
    echo "docker-start-h2o [mode]"
    echo "-daemon       run H2O™ in daemon mode"
    echo "-interactive  run H2O™ in interactive mode (command shell)"
    exit 1
  fi
fi
