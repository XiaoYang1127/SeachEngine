#!/usr/bash

USER_NAME=riak
TOOLS_PATH=/tmp/tools/es
INSTALL_PATH=/opt/elasticsearch
LOCAL_HOST=192.168.122.128
CLUSTER_NUM=3

install_es() {
    #cd $TOOLS_PATH
    #wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.0-linux-x86_64.tar.gz

    rm -rf $INSTALL_PATH
    mkdir $INSTALL_PATH
    cd $INSTALL_PATH
    tar -zxvf $TOOLS_PATH/elasticsearch-7.2.0-linux-x86_64.tar.gz

    for i in $(seq 1 $CLUSTER_NUM); do
        cluster_name=es_0$i
        mkdir $cluster_name
        cp -rf elasticsearch-7.2.0/* $cluster_name
        mkdir $cluster_name/data
        if [ $i = 1 ]; then
            cat >$cluster_name/config/elasticsearch.yml <<EOF
#
# ---------------------------------- Cluster -----------------------------------
#
cluster.name: xiaoyang
node.name: node-01
node.master: true
node.data: true
path.data: $INSTALL_PATH/$cluster_name/data
path.logs: $INSTALL_PATH/$cluster_name/logs
bootstrap.memory_lock: true
network.host: $LOCAL_HOST
http.port: 9201
transport.tcp.port: 9301
# 显式指定那些可以成为master节点的名称或者IP地址
cluster.initial_master_nodes: ["node-01"]
EOF
        else
            cat >$cluster_name/config/elasticsearch.yml <<EOF
cluster.name: xiaoyang
node.name: node-0$i
node.data: true
path.data: $INSTALL_PATH/$cluster_name/data
path.logs: $INSTALL_PATH/$cluster_name/logs
bootstrap.memory_lock: true
network.host: $LOCAL_HOST
http.port: 920$i
transport.tcp.port: 930$i
discovery.seed_hosts: ["$LOCAL_HOST:9301"]
EOF
        fi
    done

    chown -R $USER_NAME:$USER_NAME $INSTALL_PATH
}

sys_config() {
    #only do once
    cd /etc/security
    cat >>limits.conf <<EOF
* soft nofile 655350
* hard nofile 655350
* soft nproc 65535
* hard nproc 65535
EOF

    cd /etc
    cat >>sysctl.conf <<EOF
fs.file-max=65536
vm.max_map_count=262144
EOF
    sysctl -p
}

mk_shell() {
    cd $INSTALL_PATH
    shell_name="es.sh"
    rm -rf $shell_name
    touch $shell_name

    cat >$shell_name <<EOF
#!/usr/bash
#start/stop es-cluster

case "\$1" in
start)
   for i in \$(seq 1 $CLUSTER_NUM)
   do
       es_name=es_0\$i
       $INSTALL_PATH/\$es_name/bin/elasticsearch -d -p $INSTALL_PATH/\$es_name/data/es.pid
   done
   ;;

stop)
   for i in \$(seq 1 $CLUSTER_NUM)
   do
       es_name=es_0\$i
       PID=\$(cat $INSTALL_PATH/\$es_name/data/es.pid)
       kill -9 \$PID
   done
   ;;

*)
   echo "Usage sh es.sh (start|stop)"
   exit 1
   ;;

esac
EOF
    chmod +x $shell_name
    chown -R $USER_NAME:$USER_NAME $INSTALL_PATH/$shell_name
}

install_es
mk_shell
