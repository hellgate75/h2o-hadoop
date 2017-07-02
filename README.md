# H2O™ integrated with Apache Hadoop Docker image


Docker Image for H2O™ integrated with Apache™ Hadoop® Single/Cluster Node


Provided Apache™ Hadoop® H2O docker images:
* [H2O™ with Apache™ Hadoop® 2.8.0](https://github.com/hellgate75/h2o-hadoop/tree/3.10.5.3)
* [H2O™ with Apache™ Hadoop® 3.0.0-alpha3](https://github.com/hellgate75/h2o-hadoop/tree/3.10.5.3-alpha3)
* [H2O™ with Apache™ Hadoop® latest](https://github.com/hellgate75/h2o-hadoop) (with Apache™ Hadoop® 2.8.0)


*NOTE:*

Bug on H2O with Apache 3.0.0-alpha3
More on following link : [H2O JIRA BORAD Bug #SW-487](https://0xdata.atlassian.net/projects/SW/issues/SW-487?filter=allopenissues)


### Attention ###

H2O™ needs CUDA drivers, in the Apache™ Hadoop® configuration.

In this release we have built this Docker image with server built-in card :
Ndivia™ GeForce® 375

Here some more info on H2O™ for Apache™ Hadoop® configuration :
http://docs.h2o.ai/h2o/latest-stable/h2o-docs/welcome.html#accessing-s3-data-from-hadoop

You can build your version from repository with following actions:
```bash
    git clone http://github.com/hellgate75/h2o-hadoop.git
    cd h2o-hadoop
    docker build  --rm --force-rm --tag h2o-hadoop:latest ./
```
You can run your image with following actions:
```bash
    docker run -it --name my-h2o-hadoop -p 8088:8088 -p 9000:9000  -p 54321:54321 \
    -p 54322:54322 -p 55555:55555 h2o-hadoop:latest
```


### Introduction ###

H2O™ is a Machine learning engine, working as standa-alone node or on a clustered (cloud) mode.

Here some more info on H2O™ :
http://docs.h2o.ai/h2o/latest-stable/h2o-docs/index.html


### About Apache™ Hadoop® ###


The Apache™ Hadoop® project develops open-source software for reliable, scalable, distributed computing.

The Apache Hadoop software library is a framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models. It is designed to scale up from single servers to thousands of machines, each offering local computation and storage. Rather than rely on hardware to deliver high-availability, the library itself is designed to detect and handle failures at the application layer, so delivering a highly-available service on top of a cluster of computers, each of which may be prone to failures.


The project includes these modules:

* Hadoop Common: The common utilities that support the other Hadoop modules.
* Hadoop Distributed File System (HDFS™): A distributed file system that provides high-throughput access to application data.
* Hadoop YARN: A framework for job scheduling and cluster resource management.
* Hadoop MapReduce: A YARN-based system for parallel processing of large data sets.


Here some more info on Apache Hadoop :
http://hadoop.apache.org/


### Goals ###

This docker images has been designed to be a test, development, integration, production environment for H2O™ with Apache™ Hadoop® single node and cluster instances.
*No warranties for production use.*


### H2O™ Docker Image features ###


Here some information :

Volumes : /data , /flows

Data Volume is used to store logs and archives.

Flows volumes is used to store or import flows files.

Ports: 54321, 54322, 55555

Port 54321 is default http port

Port 54322 is default rest service port

Port 55555 is ssh port


### Apache™ Hadoop® Docker Image features ###

Here some information :

Volumes : /user/root/data/hadoop/hdfs/datanode, /user/root/data/hadoop/hdfs/namenode, /user/root/data/hadoop/hdfs/checkpoint, /etc/config/hadoop

`/user/root/data/hadoop/hdfs/datanode` :

DataNode storage folder.

`/user/root/data/hadoop/hdfs/namenode` :

NameNode storage folder.

`/user/root/data/hadoop/hdfs/checkpoint`:

Check Point and Check Point Edits storage folder.

`/etc/config/hadoop`:

Configuration folder, and expected/suitable files are :

* `core-site.xml`: Core Site custmized configuration file
* `yarn-site.xml`: Yarn Site custmized configuration file
* `hdfs-site.xml`: HDFS Site custmized configuration file
* `mapred-site.xml`: Map Reduce Site custmized configuration file


Ports:

HDFS ports :

50010 50020 50070 50075 50090 8020 9000


MAP Reduce ports :

10020 19888


YARN ports:

8030 8031 8032 8033 8040 8042 8088


Other Apache Hadoop ports:

49707 2122


### Docker Environment Variable ###

Here H2O™ container environment variables :

* `H2O_HADOOP_CONFIG_TGZ_URL` : Url of a tar gz file within H2O™ and Apache™ Hadoop® configuration files. If this archive contains a shell script named `bootstrap.sh`, it will be executed before to start Apache™ Hadoop® (default: "")
* `MACHINE_TIMEZONE` : Set Machine timezone ([See Timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))
* `H2O_JVM_HEAP_SIZE` : To set the total heap size for an H2O node, configure the memory allocation option -Xmx. When launching nodes, we recommend allocating a total of four times the memory of your data. (default: 4G, reccomended minimum: 1G)
* `H2O_CLOUD_NAME` : Assign a name to the H2O instance in the cloud (where <H2OCloudName> is the name of the cloud). Nodes with the same cloud name will form an H2O cloud (also known as an H2O cluster).
* `H2O_FLAT_FILE_IPS` : Specify a flatfile of IP address for faster cloud formation
* `H2O_REST_API_PORT` : Specify a PORT used for REST API. The communication port will be the port with value +1 higher.
* `H2O_MACHINE_IP`specifies IP for the machine other than the default localhost, for example: IPv4: -ip 178.16.2.223 and  IPv6: -ip 2001:db8:1234:0:0:0:0:1 (Short version of IPv6 with :: is not supported.) Note: If you are selecting a link-local address fe80::/96, it is necessary to specify the zone index (e.g., %en0 for fe80::2acf:e9ff:fe15:e0f3%en0) in order to select the right interface. default(localhost)
* `H2O_BASE_PORT` : Specifies starting port to find a free port for REST API, the internal communication port will be port with value +1 higher.
* `H2O_DISCOVERY_CID` :  (`<ip_address/subnet_mask>`) Specify an IP addresses with a subnet mask. The IP address discovery code binds to the first interface that matches one of the networks in the comma-separated list; to specify an IP address, use -network. To specify a range, use a comma to separate the IP addresses: `123.45.67.0/22,123.45.68.0/24`. For example, 10.1.2.0/24 supports 256 possibilities. IPv4 and IPv6 addresses are supported.
* `H2O_DEDICATED_MAX_THREADS` : Specify the maximum number of threads in the low-priority batch work queue. (default: 5)
* `H2O_CLIENT_MODE` : Launch H2O node in client mode. This is used mostly for running Sparkling Water. (yes/no, default: no)


Here Apache™ Hadoop® single mode container environment variables :

* `APACHE_HADOOP_SITE_BUFFER_SIZE` : Set Hadoop Buffer Size (default: 131072)
* `APACHE_HADOOP_SITE_HOSTNAME`: Set Hadoop master site hostname, as default `localhost` will be replaced with machine hostname

For more information about values : [Apache Hadoop Single Node](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html)


Here Apache™ Hadoop® cluster mode container environment variables :

* `APACHE_HADOOP_IS_CLUSTER` : Set cluster mode (yes/no)
* `APACHE_HADOOP_IS_MASTER` : Does this node lead cluster workers as the cluter master node? (yes/no)
* `APACHE_HADOOP_SITE_BUFFER_SIZE` : Set Hadoop Buffer Size (default: 131072)
* `APACHE_HADOOP_SITE_HOSTNAME`: Set Hadoop master site hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_HDFS_REPLICATION`: Set HDFS Replication factor  (default: 1)
* `APACHE_HADOOP_HDFS_BLOCKSIZE`: Set HDFS Block Size (default: 268435456)
* `APACHE_HADOOP_HDFS_HANDLERCOUNT`: Set HDFS Header Count (default: 100)
* `APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME`: Set Yarn Resource Manager hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_YARN_ACL_ENABLED`: Set Yarn ACL Enabled (default: false values: true|false)
* `APACHE_HADOOP_YARN_ADMIN_ACL`: Set Admin ACL Name (default: `*`)
* `APACHE_HADOOP_YARN_AGGREGATION_RETAIN_SECONDS`: Set Yarn Log aggregation retain time in seconds (default: 60)
* `APACHE_HADOOP_YARN_AGGREGATION_RETAIN_CHECK_SECONDS`: Set Yarn Log aggregation retain chack time in seconds (default: 120)
* `APACHE_HADOOP_YARN_LOG_AGGREGATION`: Set Yarn Log Aggregation enabled (default: false values: true|false)
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_HOSTNAME`: Set Job History Server Address/Hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_PORT`: Set Job History Server Port (default: 10020)
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_HOSTNAME`: Set Job History Web UI Server Address/Hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_PORT`:Set Job History Web UI Server Port (default: 19888)
* `APACHE_HADOOP_MAPRED_MAP_MEMORY_MBS`: Set Map Reduce Map allocated Memory in MBs (default: 1536)
* `APACHE_HADOOP_MAPRED_MAP_JAVA_OPTS`: Set Map Reduce Map Java options  (default: `-Xmx1024M`)
* `APACHE_HADOOP_MAPRED_RED_MEMORY_MBS`: Set Map Reduce Reduce allocated Memory in MBs (default: 3072)
* `APACHE_HADOOP_MAPRED_RED_JAVA_OPTS`: Set Map Reduce Reduce Java options (default: `-Xmx2560M`)
* `APACHE_HADOOP_MAPRED_SORT_MEMORY_MBS`: Set Map Reduce Sort allocated Memory in MBs (default: 512)
* `APACHE_HADOOP_MAPRED_SORT_FACTOR`: Set Map Reduce Sort factor (default: 100)
* `APACHE_HADOOP_MAPRED_SHUFFLE_PARALLELCOPIES`: Set Map Reduce Shuffle parallel copies limit (default: 50)

For more information about values : [Apache Hadoop Cluster Setup](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html)


### Sample command ###

Here a sample command to run Apache Hadoop container:

```bash
docker run -d -p 49707:49707 -p 2122:2122 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8040:8040 -p 8042:8042 \
       -p 8088:8088 -p 10020:10020 -p 19888:19888  -p 50010:50010  -p 50020:50020  -p 50070:50070  -p 50075:50075  -p 50090:50090 \
       -p 8020:8020  -p 9000:9000  -p 54321:54321 -p 54322:54322 -p 55555:55555 \
       -v my/datanode/dir:/user/root/data/hadoop/hdfs/datanode -v my/namenode/dir:/user/root/data/hadoop/hdfs/namenode \
         -v my/checkpoint/dir:/user/root/data/hadoop/hdfs/checkpoint --name my-apache-hadoop hellgate75/apache-hadoop:latest
```


### Test YARN console ###

In order to access to yarn console you can use a web browser and type :
```bash
    http://{hostname or ip address}:8088
    eg.:
    http://localhost:8088 for a local container
```
For H2O :
```bash
    http://{hostname or ip address}:54321
    eg.:
    http://localhost:54321 for a local container
```

### License ###

[LGPL 3](/LICENSE)
