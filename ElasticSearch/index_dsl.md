# ElasticSearch 的索引

## 1. 分片

- 一个分片是一个底层的工作单元 ，它仅保存了全部数据中的一部分
- 一个分片是一个 Lucene 的实例，以及它本身就是一个完整的搜索引擎
- 分片是数据的容器，文档保存在分片内，分片又被分配到集群内的各个节点里
- 一个分片可以是主分片或者副本分片。
- 索引内任意一个文档都归属于一个主分片，所以主分片的数目决定着索引能够保存的最大数据量
- 一个副本分片只是一个主分片的拷贝。 副本分片作为硬件故障时保护数据不丢失的冗余备份，并为搜索和返回文档等读操作提供服务
- 当你的集群规模扩大或者缩小时， Elasticsearch 会自动的在各节点中迁移分片，使得数据仍然均匀分布在集群里

## 2. 文档元数据

### \_index

- 文档在哪存放
- 一个索引应该是因共同的特性被分组到一起的文档集合
- 索引的名字必须小写，不能以下划线开头，不能包含逗号

### \_type

- 文档表示的对象类别
- 数据可能在索引中只是松散的组合在一起，但是通常明确定义一些数据中的子分区是很有用的
- 所有的产品都放在一个索引中，但是你有许多不同的产品类别，比如 "electronics"、"kitchen"和"lawn-care"
- 命名可以是大写或者小写，但是不能以下划线或者句号开头，不应该包含逗号， 并且长度限制为 256 个字符

### \_id

- 文档唯一标识
- 当它和\_index 以及\_type 组合就可以唯一确定 Elasticsearch 中的一个文档
- 当你创建一个新的文档，要么提供自己的\_id ，要么让 Elasticsearch 帮你生成

## 创建索引

- 索引名为 yzs_test
- 1 个主分片, 对应 1 个复制分片

```python
curl -i -X PUT "http://192.168.122.128:9201/yzs_test?pretty" -H 'Content-Type: application/json' -d'
{
   "settings" : {
      "number_of_shards" : 1,
      "number_of_replicas" : 1,
      "analysis": {
            "char_filter": {
                "&_to_and": {
                    "type":       "mapping",
                    "mappings": [ "&=> and "]
            }},
            "filter": {
                "my_stopwords": {
                    "type":       "stop",
                    "stopwords": [ "the", "a" ]
            }},
            "analyzer": {
                "my_analyzer": { ##自定义分析器
                    "type":         "custom",
                    "char_filter":  [ "html_strip", "&_to_and"],    #使用html清除字符过滤器和一个自定义的映射字符过滤器把 & 替换为 " and "
                    "tokenizer":    "standard",                     #使用标准分词器分词
                    "filter":       [ "lowercase", "my_stopwords"]  #小写词条，使用小写词和自定义停止词过滤器处理
            }},
        }
   },
   "mapping" : {
       "first_name": {
           "type" : "string",
           "index": "not_analyzed",
        },
        "last_name": {
            "type" : "string",
           "analyzer": "my_analyzer",
        },
        "age": {
            "type" : "long"
        },
        "about": {
            "type" : "text",
            "analyzer": "standard"
        },
       "interests": {
           "type" : "string"
        },
   },
}
'
```

## 3. 修改复制分片的个数

- 1 个主分片, 对应 2 个复制分片

```shell
curl -i -X PUT "http://192.168.122.128:9201/yzs_test/_settings?pretty" -H 'Content-Type: application/json' -d'
{
   "number_of_replicas" : 2
}
'
```

## 4. 索引操作

```shell
# 索引定义
curl -X GET "http://192.168.122.128:9201/yzs_test/_mapping?pretty"

# 删除索引
curl -i -X DELETE "http://192.168.122.128:9201/yzs_test/yzs_type/1?pretty"
curl -i -X DELETE "http://192.168.122.128:9201/yzs_test"

# 已建立的索引
curl -i 'http://192.168.122.128:9201/_cat/indices?v'
```

## 5. 任务

```shell
# 查看正在执行的重建任务
curl -i -X GET "http://192.168.122.128:9201/_tasks?detailed=true&actions=*reindex&pretty"

# 查看正在执行的删除任务
curl -i -X "http://192.168.122.128:9201/_tasks?detailed=true&actions=*/delete/byquery&pretty"

# 查看某个任务详细信息
curl -i -X "http://192.168.122.128:9201/_tasks/{task_id}&pretty"

# 取消某个任务
curl -i -X "http://192.168.122.128:9201/_tasks/{task_id}/_cancel"
```

## 6. 添加数据

- yzs_test: 索引名称
- yzs_type: 类型名称
- ID

```shell
curl -i -X PUT "http://192.168.122.128:9201/yzs_test/yzs_type/1?pretty" -H 'Content-Type: application/json' -d'
{
    "first_name" : "John",
    "last_name" :  "Smith",
    "age" :        25,
    "about" :      "I love to go rock climbing",
    "interests": [ "sports", "music" ]
}
'
curl -i -X PUT "http://192.168.122.128:9201/yzs_test/yzs_type/2?pretty" -H 'Content-Type: application/json' -d'
{
    "first_name" :  "Jane",
    "last_name" :   "Smith",
    "age" :         32,
    "about" :       "I like to collect rock albums",
    "interests":  [ "music" ]
}
'
curl -i -X PUT "http://192.168.122.128:9201/yzs_test/yzs_type/3?pretty" -H 'Content-Type: application/json' -d'
{
    "first_name" :  "Douglas",
    "last_name" :   "Fir",
    "age" :         35,
    "about":        "I like to build cabinets",
    "interests":  [ "forestry" ]
}
'
```

## 7. 文档

```shell
# 根据id搜索文档
curl -i -X GET "http://192.168.122.128:9201/yzs_test/yzs_type/1?pretty"

# 搜索所有文档
curl -i -X GET "http://192.168.122.128:9201/yzs_test/yzs_type/_search?pretty"

# 查看文档部分字段
curl -X GET "http://192.168.122.128:9201/yzs_test/yzs_type/1?_source=first_name,text&pretty"

# 检查文档是否存在
curl -i -XHEAD "http://192.168.122.128:9201/yzs_test/yzs_type/1"
```
