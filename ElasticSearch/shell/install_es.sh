#!/usr/bash

USER_NAME=riak
TOOLS_PATH=/tmp/tools/es
INSTALL_PATH=/opt/elasticsearch
LOCAL_HOST=192.168.122.128

install_es() {
    if [! -d $TOOLS_PATH ]; then
        mkdir -p $TOOLS_PATH
    fi

    #cd $TOOLS_PATH
    #wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.0-linux-x86_64.tar.gz

    rm -rf $INSTALL_PATH
    mkdir $INSTALL_PATH

    cd $INSTALL_PATH
    tar -zxvf $TOOLS_PATH/elasticsearch-7.2.0-linux-x86_64.tar.gz

    es_path=elasticsearch
    ln -s $INSTALL_PATH/elasticsearch-7.2.0 $es_path
    mkdir $es_path/data
    cat >>$es_path/config/elasticsearch.yml <<EOF
#
# ---------------------------------- Cluster -----------------------------------
#
cluster.name: xiaoyang
node.name: node-01
node.master: true
node.data: true
path.data: $INSTALL_PATH/$es_path/data
path.logs: $INSTALL_PATH/$es_path/logs
bootstrap.memory_lock: true
network.host: $LOCAL_HOST
http.port: 9201
transport.tcp.port: 9301
# 显式指定那些可以成为master节点的名称或者IP地址
cluster.initial_master_nodes: ["node-01"]
EOF

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

install_ik() {
    # it wiil make ES slower
    cd $TOOLS_PATH
    wget https://codeload.github.com/medcl/elasticsearch-analysis-ik/zip/master

    cd $INSTALL_PATH/plugins
    mkdir ik
    cd ik
    unzip $TOOLS_PATH/elasticsearch-analysis-ik-7.2.0
}

make_es_shell() {
    cd $INSTALL_PATH
    shell_name="es.sh"
    rm -rf $shell_name
    touch $shell_name

    cat >$shell_name <<EOF
#!/usr/bash
### BEGIN INIT INFO
# Provides: lsb-ourdb
# Required-Start: $local_fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop OurDB
# Description: OurDB is a very fast and reliable database
#    engine used for illustrating init scripts
### END INIT INFO

es_name=elasticsearch
case "\$1" in
start)
    $INSTALL_PATH/\$es_name/bin/elasticsearch -d -p $INSTALL_PATH/\$es_name/data/es.pid
   ;;

stop)
    PID=\$(cat $INSTALL_PATH/\$es_name/data/es.pid)
    kill -9 \$PID
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

install_kibana() {
    #cd $TOOLS_PATH
    #wget https://artifacts.elastic.co/downloads/kibana/kibana-7.2.0-linux-x86_64.tar.gz

    cd $INSTALL_PATH
    tar -zxvf $TOOLS_PATH/kibana-7.2.0-linux-x86_64.tar.gz
    ln -s $INSTALL_PATH/kibana-7.2.0-linux-x86_64 kibana

    config_name=$INSTALL_PATH/kibana/config/kibana.yml
    cat >>$config_name <<EOF
server.name: "kibana"
server.port: 5601
server.host: "$LOCAL_HOST"
logging.verbose: true
elasticsearch.ssl.verificationMode: none
elasticsearch.username: riak
elasticsearch.password: riak
elasticsearch.requestHeadersWhitelist: ['authorization', 'sgtenant']
elasticsearch.hosts: ["http://$LOCAL_HOST:9201"]
i18n.locale: zh-CN
EOF

    chown -R $USER_NAME:$USER_NAME $INSTALL_PATH
}

make_kibana_shell() {
    cd $INSTALL_PATH
    shell_name="kibana.sh"
    rm -rf $shell_name
    touch $shell_name

    cat >$shell_name <<EOF
#!/usr/bash
### BEGIN INIT INFO
# Provides: lsb-ourdb
# Required-Start: $local_fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop OurDB
# Description: OurDB is a very fast and reliable database
#    engine used for illustrating init scripts
### END INIT INFO

kibana_path=kibana
exe_name=kibana
case "\$1" in
  start)
    nohup $INSTALL_PATH/\$kibana_path/bin/\$exe_name &
   ;;

  stop)
    pidarr=\$(ps x | grep \$exe_name | awk '{print \$1}')
    kill -9 \$pidarr
   ;;

  *)
   echo "Usage sh \$shell_name (start|stop)"
   exit 1
   ;;

esac
EOF
    chmod +x $shell_name
    chown -R $USER_NAME:$USER_NAME $INSTALL_PATH/$shell_name
}

install_es
make_es_shell
install_kibana
make_kibana_shell
