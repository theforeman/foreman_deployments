# Examples and usecases

## Solr installation


### Description of the system:

Solr is Lucene-based text index. As an internal implementation it uses  Apache Zookeeper to store its configuration. Zookeeper can be set up as a  cluster, it has its own master election mechanism. After the zookeepers  are up and running, Solr configuration should be uploaded to the  Zookeepers, Jetty servers should be set up to serve as Solr shards, and  pointed to the zookeeper "ensemble" to get their config from there.


### Let's divide the problem to two main parts:

1. Installing Zookeeper ring
2. Installing Solr shards.


### Part 1: Installing zookeepers.

I am basing my analysis on [http://zookeeper.apache.org/doc/r3.3.3/zookeeperAdmin.html#sc_zkMulitServerSetup](http://zookeeper.apache.org/doc/r3.3.3/zookeeperAdmin.html#sc_zkMulitServerSetup)


1. The machine should be a basic one, with 4GB of memory,
2. It needs JDK on it.
3. Set up the correct java params (heap size)
4. Download the zookeeper.tar.gz and extract it to its folder.
5. Assign ID to each node - the ID should be a number from 1 to 255 without repeating itself
6. Create a config file which points to the extracted dir, and has addresses and id's of all nodes
    in the ensmble.
7. Start the zookeeper by running "$ java -cp zookeeper.jar:lib/log4j-1.2.15.jar:conf \ org.apache.zookeeper.server.quorum.QuorumPeerMain zoo.cfg" where zoo.cfg is the config file we created.


Puppetized version, based on puppet modules from here: [https://github.com/deric/puppet-zookeeper](https://github.com/deric/puppet-zookeeper)
use zookeeper class with the following params

```
id => <<server id>>
servers => [ <<server1:port1:port2>>, <<server2:port1:port2>> ...]
packages => ['zookeeper'],
install_java => true,
java_package => 'openjdk-7-jre-headless',
client_ip => $::ipaddress_eth0
```

### Part 2: Installing Solr shards

I am basing my analysis on [http://systemsarchitect.net/painless-guide-to-solr-cloud-configuration/](http://systemsarchitect.net/painless-guide-to-solr-cloud-configuration/) and [http://andres.jaimes.net/878/setup-lucene-solr-centos-tomcat/](http://andres.jaimes.net/878/setup-lucene-solr-centos-tomcat/)

1. Each machine should have enough memory - it will run the index
2. It needs JDK
3. It needs tomcat6 tomcat6-webapps tomcat6-admin-webapps
4. Download common logging, and unpack it to /usr/share/tomcat6/lib
5. Download SLF4J, and unpack it to /usr/share/tomcat6/lib
6. Download Solr archive, and unpack solr.war to /usr/share/tomcat6/webapps/
7. Upload base config to zookeeper (it should be up now):
```
$ cloud-scripts/zkcli.sh -cmd upconfig -zkhost <zookeeper instance ip>:2181 -d solr/collection1/conf/ -n default1
$ cloud-scripts/zkcli.sh -cmd linkconfig -zkhost <zookeeper instance ip>:2181 -collection collection1 -confname default1 -solrhome solr
$ cloud-scripts/zkcli.sh -cmd bootstrap -zkhost <zookeeper instance ip>:2181 -solrhome solr
```
8. Create solr.xml file in your tomcat home directory

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context path="/solr/home"
     docBase="/home/lukasz/solr-4.2.1/example/webapps/solr.war"
     allowlinking="true"
     crosscontext="true"
     debug="0"
     antiResourceLocking="false"
     privileged="true">

     <Environment name="solr/home" override="true" type="java.lang.String" value="/home/lukasz/solr-4.2.1/example/solr" />
</Context>
```

9. Edit another solr.xml file that is in the solr directory, set the tag solr to match: `<solr persistent="true" zkHost="<zookeeper1 ip>:2181, <zookeeper2 ip>:2181 ...">`
10. Change another node in the same XML: set cores to match: `<cores adminPath="/admin/cores" defaultCoreName="collection1" host="${host:}" hostPort="8080">`
11. Restart tomcat


### Resulting stack

Based on the analysis we designed the following stack:
* [png version](diagrams/solr_usecase.png)
* [svg version](diagrams/solr_usecase.svg)
