#!/bin/bash

USER=riak
TOOLS_PATH=/tmp/tools/solr

install_solr() {
    cd $TOOLS_PATH
    wget http://archive.apache.org/dist/lucene/solr/8.2.0/solr-8.2.0.tgz
    wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
    wget https://download.oracle.com/otn-pub/java/jdk/13+33/5b8a42f3905b406298b72d750b6919f6/jdk-13_linux-x64_bin.tar.gz
}

install_solr
python config_solrcloud.py

#zk起服失败的原因：
##修改ip
##chmod +x zookeeper.sh; chmod +x solr.sh
##chown -R riak:riak $INSTALL_PATH

#java二进制安装，直接去官网下，但是很慢
