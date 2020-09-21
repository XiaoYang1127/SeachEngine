#!/usr/bash

IP_STR=192.168.122.128
IP_ADDR=$IP_STR:2181,$IP_STR:2182,$IP_STR:2183

install_path=/opt/solrcloud
exec_path=$install_path/solr_01/server/scripts/cloud-scripts
save_path=/opt/solrcloud/myconfig

if [ ! -d $save_path ]; then
    sudo mkdir -p save_path
fi

if [ $# -ne 2 ]; then
    echo "Usage: sh solr_config.sh (download|upload|reload) CollectionName"
    exit 1
fi
conf_name=$2

download() {
    cd $exec_path
    sh zkcli.sh -zkhost $IP_ADDR -cmd getfile /configs/$conf_name/managed-schema /opt/solrcloud/myconfig/managed-schema
    sh zkcli.sh -zkhost $IP_ADDR -cmd getfile /configs/$conf_name/solrconfig.xml /opt/solrcloud/myconfig/solrconfig.xml
}

upload() {
    cd $exec_path
    sh zkcli.sh -zkhost $IP_ADDR -cmd putfile /configs/$conf_name/managed-schema /opt/solrcloud/myconfig/managed-schema
    sh zkcli.sh -zkhost $IP_ADDR -cmd putfile /configs/$conf_name/solrconfig.xml /opt/solrcloud/myconfig/solrconfig.xml
}

reload() {
    #记得修改CollectionName和$IP_STR
    echo "open with browser http://$IP_STR:8983/solr/admin/collections?action=RELOAD&name=$conf_name"
}

case "$1" in
download)
    download
    ;;
upload)
    upload
    ;;
reload)
    reload
    ;;
*)
    echo "Usage: sh solr_config.sh (download|upload|reload) CollectionName"
    exit 1
    ;;
esac
