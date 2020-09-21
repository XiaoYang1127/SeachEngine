# 问题和解决办法

## 1. 允许对索引进行读写

```python
#插入索引数据的时候
response = {
  "error" : {
    "root_cause" : [
      {
        "type" : "cluster_block_exception",
        "reason" : "blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];"
      }
    ],
    "type" : "cluster_block_exception",
    "reason" : "blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];"
    },
    "status" : 403
}
```

```python
#解决办法
curl -i -X PUT "http://192.168.33.11:9201/paper/_settings?pretty" -H 'Content-Type: application/json' -d'
{
   "index.blocks.read_only_allow_delete" : "false"
}
'
```

## 2. 修改索引查询返回的数量上限

```python
curl -i -X PUT "http://192.168.33.11:9201/paper/_settings?pretty" -H 'Content-Type: application/json' -d'
{
   "index.max_result_window" : 2147483647
}
'
```

## 3. 测试分析器

```python
curl -X GET "http://192.168.122.128:9201/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "analyzer": "standard",
  "text": "国家人工智能组开始研究"
}
'

curl -X GET "http://192.168.122.128:9201/paper/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "field": "paper_sentence",
  "text": "国家人工智能组开始研究"
}
'
```
