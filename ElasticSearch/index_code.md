# es 索引操作

## 1. 插入索引

### indices.create(self, index, body=None, params=None)

- 创建索引，索引的名字是 my-index,如果已经存在了，就返回个 400，
- 这个索引可以现在创建，也可以在后面插入数据的时候再临时创建
- index: 索引名称
- body: 文档数据

## 2. 插入数据

### create(self, index, id, body, doc_type="\_doc", params=None)

- 必须指定待查询的 index、type、id 和查询体 body
- index: 索引名称
- id: 文档 id
- body：文档

### index(self, index, body, doc_type="\_doc", id=None, params=None)

- index: 索引名称
- body: 文档
- id: 文档 id，可选，如果指定，则该文档的 id 就是指定值，若不指定，则系统会自动生成一个全局唯一的 id 赋给该文档

```python
body = {
    "any":"data01",
    "timestamp":datetime.now()
}
es.index(index="my-index",doc_type="test-type",id=01,body=body)
```

## 3. 更新数据

### update(self, index, id, doc_type="\_doc", body=None, params=None)

- 跟新指定 index、type、id 所对应的文档
- index: 索引名称
- id: 文档 id
- body: 待更新的字段，字典类型

### update_by_query(self, index, body=None, params=None)

- 更新满足条件的所有数据
- index: 索引名称
- body: 符合 DLS 格式的字典数据

```python
query = {
    "script" : {
        "source": "ctx._source.counter += params.count",
        "lang": "painless",
        "params" : {
            "count" : 4
        }
    },
    "query": {
     "term": {
      "user": "kimchy"
    }
  }
}

es.update_by_query(index='indexName', body=query, doc_type='typeName')
```

## 4. 删除数据

### delete(self, index, id, doc_type="\_doc", params=None)

- 删除指定 index、type、id 的文档
- index: 索引名称
- id: 文档 id

### delete_by_query(self, index, body, params=None)

- 删除满足条件的所有数据，查询条件必须符合 DLS 格式
- index: 索引名称
- body: 符合 DLS 格式的字典数据

```python
#删除性别为女性的所有文档
query = {'query': {'match': {'sex': 'famale'}}}

#删除年龄小于11的所有文档
query = {'query': {'range': {'age': {'lt': 11}}}}

es.delete_by_query(index='indexName', body=query, doc_type='typeName')
```

## 5. 查询数据

### count(self, doc_type=None, index=None, body=None, params=None)

- index: 索引名称
- body: 待查询的字段，字典类型

```python
# 获取数据量
es.count(index="my_index",doc_type="test_type")
```

### get(self, index, id, doc_type="\_doc", params=None)

- 获取指定 index、type、id 所对应的文档
- index: 索引名称
- id: 文档 id

### search(self, index=None, body=None, params=None)

- 查询满足条件的所有文档
- index: 索引名称
- body: 待查询的字段，字典类型

```python
#查找所有文档
query = {'query': {'match_all': {}}}
query = None

#查找名字叫做jack的所有文档
query = {'query': {'term': {'name': 'jack'}}}

#查找年龄大于11的所有文档
query = {'query': {'range': {'age': {'gt': 11}}}}

allDoc = es.search(index='indexName', doc_type='typeName', body=query)
```

### term & terms

```python
# term
body = {
    "query":{
        "term":{
            "name":"python"
        }
    }
}
# 查询name="python"的所有数据
es.search(index="my_index",doc_type="test_type",body=body)
```

```python
# terms
body = {
    "query":{
        "terms":{
            "name":[
                "python","android"
            ]
        }
    }
}
# 搜索出name="python"或name="android"的所有数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### match \* multi_match

```python
# match
body = {
    "query":{
        "match":{
            "name":"python"
        }
    }
}
# 查询name包含python关键字的数据
es.search(index="my_index",doc_type="test_type",body=body)
```

```python
# multi_match
body = {
    "query":{
        "multi_match":{
            "query":"深圳",
            "fields":["name","addr"]
        }
    }
}

# 查询name和addr包含"深圳"关键字的数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### ids

```python
body = {
    "query":{
        "ids":{
            "type":"test_type",
            "values":[
                "1","2"
            ]
        }
    }
}

# 搜索出id为1或2d的所有数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### 复杂查询 bool

- must: 都满足
- should: 其中一个满足
- must_not: 都不满足

```python
body = {
    "query":{
        "bool":{
            "must":[
                {
                    "term":{
                        "name":"python"
                    }
                },
                {
                    "term":{
                        "age":18
                    }
                }
            ]
        }
    }
}

# 获取name="python"并且age=18的所有数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### 分页查询

```python
body = {
    "query":{
        "match_all":{}
    }
    "from":2
    "size":4
}

# 从第2条数据开始，获取4条数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### 范围式查询

```python
body = {
    "query":{
        "range":{
            "age":{
                "gte":18,
                "lte":30
            }
        }
    }
}

# 查询18<=age<=30的所有数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### 前缀式查询

```python
body = {
    "query":{
        "prefix":{
            "name":"p"
        }
    }
}

# 查询name前缀为"p"的所有数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### 通配符查询

```python
body = {
    "query":{
        "wildcard":{
            "name":"*id"
        }
    }
}
# 查询name以id为后缀的所有数据
es.search(index="my_index",doc_type="test_type",body=body)
```

### 排序

```python
body = {
    "query":{
        "match_all":{}
    }
    "sort":{
        "age":{
            "order":"asc"
        }
    }
}
# 查询结果根据age的升序显示
```

### filter_path

```python
# 只需要获取_id数据,多个条件用逗号隔开
es.search(index="my_index",doc_type="test_type",filter_path=["hits.hits._id"])

# 获取所有数据
es.search(index="my_index",doc_type="test_type",filter_path=["hits.hits._*"])
```

### 聚合

```python
# 获取最小值
body = {
    "query":{
        "match_all":{}
    },
    "aggs":{                        # 聚合查询
        "min_age":{                 # 最小值的key
            "min":{                 # 最小
                "field":"age"       # 查询"age"的最小值
            }
        }
    }
}

# 搜索所有数据，并获取age最小的值
es.search(index="my_index",doc_type="test_type",body=body)
```

```python
# 获取最大值
body = {
    "query":{
        "match_all":{}
    },
    "aggs":{                        # 聚合查询
        "max_age":{                 # 最大值的key
            "max":{                 # 最大
                "field":"age"       # 查询"age"的最大值
            }
        }
    }
}

# 搜索所有数据，并获取age最大的值
es.search(index="my_index",doc_type="test_type",body=body)
```

```python
# 获取和
body = {
    "query":{
        "match_all":{}
    },
    "aggs":{                        # 聚合查询
        "sum_age":{                 # 和的key
            "sum":{                 # 和
                "field":"age"       # 获取所有age的和
            }
        }
    }
}

# 搜索所有数据，并获取所有age的和
es.search(index="my_index",doc_type="test_type",body=body)
```

```python
# 获取平均值
body = {
    "query":{
        "match_all":{}
    },
    "aggs":{                        # 聚合查询
        "avg_age":{                 # 平均值的key
            "sum":{                 # 平均值
                "field":"age"       # 获取所有age的平均值
            }
        }
    }
}

# 搜索所有数据，获取所有age的平均值
es.search(index="my_index",doc_type="test_type",body=body)
```
