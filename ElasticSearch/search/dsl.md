# 领域特定查询语言（Query DSL）

- Elasticsearch 中强大灵活的查询语言

### Term query

- 使用 term 查询根据精确的值（例如价格，产品 ID 或用户名）查找文档
- 避免 term 对 text 字段使用查询

```python
body = {
    "query": {
        "term": {                       ##Field you wish to search
            "user": {                   ##field名
                "value": "Kimchy",      ##待搜索的值
                "boost": 1.0            ##用于减少或增加查询的相关性分数的浮点数 。默认为1.0
            }
        }
    }
}
```

### Wildcard query

- 返回包含与通配符模式匹配的术语的文档
- ?，它与任何单个字符匹配
- \*，可以匹配零个或多个字符，包括一个空字符
- 避免使用\* 或 开头模式?。这会增加查找匹配项所需的迭代次数，并降低搜索性能

```python
body = {
    "query": {
        "wildcard": {
            "user": {                           ##field名
                "value": "ki*y",                ##以开头ki和结尾的术语y。这些匹配条件可以包括kiy，kity或kimchy
                "boost": 1.0,
                "rewrite": "constant_score"
            }
        }
    }
}
```

### Match query

- 返回与提供的文本，数字，日期或布尔值匹配的文档
- 匹配之前分析提供的文本
- 用于执行全文搜索（包括模糊匹配选项）的标准查询

```python
body = {
    "query": {
        "match" : {
            "message" : {
                "query" : "this is a test",
                "operator" : "and",
                "zero_terms_query": "all",
                "auto_generate_synonyms_phrase_query" : False,
            }
        }
    }
}
"""
    "analyzer": None                                ##用于将query值中的文本转换为标记
    "fuzziness":0,                                  ##匹配允许的最大编辑距离
    "max_expansions":50,                            ##查询将扩展到的最大术语数
    "prefix_length":0,                              ##为模糊匹配保留的起始字符数
    "transpositions":True,                          ##模糊匹配的编辑内容包括两个相邻字符的转置（ab→ba）
    "fuzzy_rewrite": {                              ##用于重写查询的方法，如果fuzziness参数不是0，则match查询默认使用的rewrite方法
        fuzzy, prefix, query_string, regexp, wildcard
    },
    "minimum_should_match": "75%"                   ##返回的文档必须匹配的最小子句数
    "lenient": False                                ##将忽略基于格式的错误，例如为数字字段提供文本 query值
    "operator" : {
        "OR" : "capital of Hungary"                 ##capital OR of OR Hungary
        #"AND": "capital of Hungary"                ##capital AND of AND Hungary
    }
    "zero_terms_query" : {                          ##指示如果analyzer 删除所有标记（例如使用stop过滤器时），是否不返回任何文档
        "none",                                     ##如果analyzer删除所有标记，则不会返回任何文档
        #"all",                                     ##返回所有文档，类似于match_all 查询
    }
    "auto_generate_synonyms_phrase_query" : True,   ##会自动为多个术语同义词创建匹配词组查询
"""
```

### Match phrase query

```python
## 首先将查询字符串解析成一个词项列表，然后对这些词项进行搜索，但只保留那些包含全部搜索词项，且位置与搜索词项相同的文档
    ## quick 、 brown 和 fox 需要全部出现在域中
    ## brown 的位置应该比 quick 的位置大 1
    ## fox 的位置应该比 quick 的位置大 2
    ## 上面任何一个选项不成立，则该文档不能认定为匹配
## slop 参数告诉match_phrase查询词条相隔多远时仍然能将文档视为匹配
body = {
    "query": {
        "match_phrase" : {
            "title" : "quick brown fox"
             "slop" : 10，
        }
    }
}
```

### Multi-match query

```python
# best_fields (默认)
## 在搜索同一字段中找到的多个最佳单词时最有用
##如果tie_breaker指定了该分数，则它将按以下方式计算分数：
##    最佳匹配领域的分数
##    加上tie_breaker * _score所有其他匹配字段
body = {
    "query": {
        "multi_match" : {
            "query":      "brown fox",
            "type":       "best_fields",
            "fields":     [ "subject", "message" ],
            "tie_breaker": 0.3
        }
    }
}

body = {
    "query": {
        "dis_max": {
            "queries": [
                { "match": { "subject": "brown fox" }},
                { "match": { "message": "brown fox" }}
            ],
        "tie_breaker": 0.3
        }
    }
}
```

```python
# most_field
## 当查询包含以不同方式分析的相同文本的多个字段时，该类型最有用
## 每个match子句的分数相加，然后除以match子句数
body = {
    "query": {
        "multi_match" : {
            "query":      "quick brown fox",
            "type":       "most_fields",
            "fields":     [ "title", "title.original", "title.shingles" ]
        }
    }
}

body = {
    "query": {
        "bool": {
            "should": [
                { "match": { "title":          "quick brown fox" }},
                { "match": { "title.original": "quick brown fox" }},
                { "match": { "title.shingles": "quick brown fox" }}
            ]
        }
    }
}
```

```python
# phrase 和 phrase_prefix
## 该phrase和phrase_prefix类型的行为很像best_fields，但它们使用match_phrase或match_phrase_prefix查询，而不是一个的match查询
body = {
    "query": {
        "multi_match" : {
            "query":      "quick brown f",
            "type":       "phrase_prefix",
            "fields":     ["subject", "message"]
        }
    }
}

body = {
    "query": {
        "dis_max": {
            "queries": [
                { "match_phrase_prefix": { "subject": "quick brown f" }},
                { "match_phrase_prefix": { "message": "quick brown f" }}
            ]
        }
    }
}
```

```python
# cross_fiel
## 对于结构化文档（其中多个字段应匹配）特别有用
## +(first_name:will  last_name:will)
## +(first_name:smith last_name:smith)
body = {
    "query": {
        "multi_match" : {
            "query":      "Will Smith",
            "type":       "cross_fields",
            "fields":     [ "first_name", "last_name" ],
            "operator":   "and"
        }
    }
}
```
