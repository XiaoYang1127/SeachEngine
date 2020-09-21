# solr 命令

## 1. 创建核心

- ./solr create -c CollectionName -d sample_techproducts_configs -shards 2 -replicationFactor 3

```
-c (name) 要创建的collection名称
-d (configdir) 配置文件目录 (查看/opt/solrcloud/solr_01/server/solr/configsets以确定用什么配置)
-p (port) 发送 create 命令的本地 Solr 实例的端口；默认情况下，脚本尝试通过查找正在运行的 Solr 实例来检测端口
-s or -shards 分片数
-rf or -replicationFactor 每个分片要创建的副本数，建议为奇数
-force 如果尝试以“root”用户身份运行create，则脚本将退出，并显示警告，可以用 -force 参数覆盖此警告
```

## 2. 删除核心

- ./solr delete -c CollectionName -deleteConfig true

```
-c (name)       要删除的核心/集合的名称
-deleteConfig   是否也应该从zookeeper中删除配置
```

## 3. 启动

- ./solr start

```
-cloud:   以SolrCloud模式启动Solr
-v:       将log4j的日志记录级别从INFO更改为DEBUG，具有相同的效果
-q:       将log4j的日志记录级别从INFO更改为WARN
-force:   如果尝试以root用户身份启动Solr，脚本将退出，并显示警告，将Solr作为“root”运行可能会导致问题
```

## 4. 关闭

- ./solr stop -all

## 5. 状态

- ./solr status
