# encoding:utf-8
"""
    配置zookeeper + solrcloud + 伪分布式 + 中文分词
    zookeeper: zookeeper-3.4.14.tar.gz
    solr: solr-8.2.0.tgz
"""

import os
import sys


TOOLS_PATH = "/tmp/solr"
BASE_PATH = "/opt"
INSTALL_NAME = "solrcloud"
INSTALL_PATH = BASE_PATH + "/" + INSTALL_NAME
LOCALHOST = "192.168.122.128"
MAX_SOLR = 5
MAX_ZK = 4


def Find_Zookeeper_version():
    for _name in os.listdir(TOOLS_PATH):
        if "zookeeper" in _name and _name.endswith(".tar.gz"):
            return _name
    return None


def Config_Zookeeper():
    # 先删除旧的配置
    try:
        os.system("rm -rf %s/zookeeper*" % INSTALL_PATH)
    except:
        pass

    version = Find_Zookeeper_version()
    if not version:
        print "can't find zookeeper-*.tar.gz"
        return
    zookeeper_path = TOOLS_PATH + "/" + version
    zookeeper_name = version[:len(version) - 7]

    # 进入安装目录
    if not os.path.exists(INSTALL_PATH):
        os.chdir(BASE_PATH)
        os.system("mkdir %s" % INSTALL_NAME)
    os.chdir(INSTALL_PATH)

    # 配置zookeeper集群
    os.system("tar -zxvf %s" % zookeeper_path)
    for i in xrange(1, MAX_ZK):
        cluster = "zookeeper_0%s" % i
        os.system("mkdir %s" % cluster)
        os.system("cp -r %s/* %s/" % (zookeeper_name, cluster))

        # 创建myid
        os.chdir("%s/%s" % (INSTALL_PATH, cluster))
        os.mkdir("log")
        os.mkdir("data")
        os.chdir("%s/%s/data" % (INSTALL_PATH, cluster))
        os.system("touch myid && echo %s >> myid" % i)

        # 修改配置
        os.chdir("%s/%s/conf" % (INSTALL_PATH, cluster))
        try:
            old_fp = open("zoo_sample.cfg", "r")
            new_fp = open("zoo.cfg", "w+")
            for line in old_fp.readlines():
                if "clientPort=" in line:
                    line = "clientPort=218%s\n" % i
                elif "dataDir=" in line:
                    line = "dataDir=%s/%s/data\n" % (INSTALL_PATH, cluster)
                    line += "dataLogDir=%s/%s/log\n" % (INSTALL_PATH, cluster)
                elif "dataLogDir=" in line:
                    continue
                new_fp.write(line)

            # 集群配置
            zk_host = "server.1=%s:2881:3881\nserver.2=%s:2882:3882\nserver.3=%s:2883:3883\n" % (LOCALHOST, LOCALHOST, LOCALHOST)
            new_fp.write(zk_host)
        except:
            print "%s alter zoo_sample.cfg failed" % cluster
            break

        os.chdir(INSTALL_PATH)

    # 清理
    os.system("rm -rf %s" % zookeeper_name)
    Zookeeper_Shell()


def Zookeeper_Shell():
    usage = """
#!/bin/sh
#start zookeeper cluster

case "$1" in
 start)
  echo -n "starting zookeeper"
  for i in $(seq 1 %s)
  do
     %s/zookeeper_0$i/bin/zkServer.sh start
  done
 ;;

 stop)
  echo -n "stopping zookeeper"
  for i in $(seq 1 %s)
  do
     %s/zookeeper_0$i/bin/zkServer.sh stop
  done
  ;;

 status)
  echo -n "zookeeper status"
  for i in $(seq 1 %s)
  do
     %s/zookeeper_0$i/bin/zkServer.sh status
  done
  ;;

 *)
  echo "Usage: sh zookeeper.sh (start|stop|status)"
  exit 1
  ;;
esac
""" % (MAX_ZK - 1, INSTALL_PATH, MAX_ZK - 1, INSTALL_PATH, MAX_ZK - 1, INSTALL_PATH)

    os.chdir(INSTALL_PATH)
    os.system("touch zookeeper.sh")
    with open("zookeeper.sh", 'w+') as fp:
        fp.write(usage)
        fp.close()
    os.system("chmod +x zookeeper.sh")


def Find_Solrcloud_version():
    for _name in os.listdir(TOOLS_PATH):
        if "solr" in _name and _name.endswith(".tgz"):
            return _name
    return None


def Config_Solrcloud():
    # 先删除旧的配置
    try:
        os.system("rm -rf %s/solr*" % INSTALL_PATH)
    except:
        pass

    version = Find_Solrcloud_version()
    if not version:
        print "can't find solr-*.tgz"
        return

    solr_path = TOOLS_PATH + "/" + version
    solr_name = version[:len(version) - 4]

    # 进入安装目录
    if not os.path.exists(INSTALL_PATH):
        os.chdir(BASE_PATH)
        os.system("mkdir %s" % INSTALL_NAME)
    os.chdir(INSTALL_PATH)

    # 配置solrcloud集群
    os.system("tar -zxvf %s" % solr_path)
    for i in xrange(1, MAX_SOLR):
        cluster = "solr_0%s" % i
        os.system("mkdir %s" % cluster)
        os.system("cp -r %s/* %s/" % (solr_name, cluster))

        # 修改配置
        os.chdir("%s/bin" % cluster)
        os.system("cp solr.in.sh solr.in.sh.backup")
        os.system("rm solr.in.sh")
        old_fp = open("solr.in.sh.backup", 'r')
        new_fp = open("solr.in.sh", 'w+')
        for line in old_fp.readlines():
            if "ZK_HOST=" in line:
                new_line = 'ZK_HOST="%s:2181,%s:2182,%s:2183"\n' % (LOCALHOST, LOCALHOST, LOCALHOST)
            elif "SOLR_HOST=" in line:
                new_line = 'SOLR_HOST="%s"\n' % LOCALHOST
            elif "SOLR_PORT=" in line:
                new_line = 'SOLR_PORT=898%s\n' % (i + 2)
            elif "SOLR_TIMEZONE=" in line:
                new_line = 'SOLR_TIMEZONE="UTC+08:00"\n'
            else:
                new_line = line
            new_fp.write(new_line)

        os.chdir(INSTALL_PATH)

    # 清理
    os.system("rm -rf %s" % solr_name)
    Solrcloud_Shell()
    Config_IKAnalyzer()


def Solrcloud_Shell():
    usage = """
#!/bin/sh
#start solrcloud
case "$1" in
 start)
  echo -n "starting solr"
  for i in $(seq 1 %s)
  do
    %s/solr_0$i/bin/solr start -cloud -force
  done
  ;;

 stop)
  echo -n "stopping solr"
  for i in $(seq 1 %s)
  do
    %s/solr_0$i/bin/solr stop -all
  done
  ;;

 status)
 echo -n "solr status"
  for i in $(seq 1 %s)
  do
    %s/solr_0$i/bin/solr status
  done
  ;;

 *)
 echo "Usage: sh solr.sh (start|stop|status)"
 exit 1
 ;;
esac
""" % (MAX_SOLR - 1, INSTALL_PATH, MAX_SOLR - 1, INSTALL_PATH, MAX_SOLR - 1, INSTALL_PATH)
    os.chdir(INSTALL_PATH)
    os.system("touch solr.sh")
    with open("solr.sh", 'w+') as fp:
        fp.write(usage)
        fp.close()
    os.system("chmod +x solr.sh")


# 中文分词
def Config_IKAnalyzer():
    ikanalyzer_name = "ik-analyzer-8.2.0.jar"
    ikanalyzer_path = TOOLS_PATH + "/" + ikanalyzer_name

    for i in xrange(1, MAX_SOLR):
        cluster = "solr_0%s" % i
        if not os.path.exists("%s/%s" % (INSTALL_PATH, cluster)):
            print "cluster %s not exists" % cluster
            continue
        ik_path = "%s/%s/server/solr-webapp/webapp/WEB-INF" % (INSTALL_PATH, cluster)
        os.system("cp %s %s/lib" % (ikanalyzer_path, ik_path))


if __name__ == "__main__":
    if not os.path.exists(TOOLS_PATH):
        os.system("mkdir %s" % TOOLS_PATH)
    Config_Zookeeper()
    Config_Solrcloud()
