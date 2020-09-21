#!/usr/bash

USER_NAME=riak
TOOLS_PATH=/tmp/tools/solr
INSTALL_PATH=/opt/java
JAVA_PATH=""
JAVA_NAME=""

getdir() {
    for element in $(ls $1); do
        result=$(echo $element | grep "$2")
        if [ "$result" != "" ]; then
            JAVA_PATH=$element
            break
        fi
    done
}

install_java() {
    if [ ! -d $INSTALL_PATH ]; then
        sudo mkdir -p $INSTALL_PATH
    else
        sudo rm -rf $INSTALL_PATH/*
    fi

    cd $TOOLS_PATH
    #wget "https://download.oracle.com/otn/java/jdk/11.0.5+10/e51269e04165492b90fa15af5b4eb1a5/jdk-11.0.5_linux-x64_bin.tar.gz"
    getdir . jdk

    cd $INSTALL_PATH
    JAVA_NAME=${JAVA_PATH%_linux-x64_bin.tar.gz}
    sudo tar -zxvf $TOOLS_PATH/$JAVA_PATH
    sudo cat >>/etc/profile <<EOF

#JAVA
export JAVA_HOME=$INSTALL_PATH/$JAVA_NAME
export JRE_HOME=\$JAVA_HOME/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
}

install_java
