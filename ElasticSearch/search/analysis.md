# 分析（Analysis）

- 全文是如何处理使之可以被搜索的

## 1. 倒排索引

- 首先将每个文档的 content 域拆分成单独的词（我们称它为词条或 tokens），创建一个包含所有不重复词条的排序列表
- 然后列出每个词条出现在哪个文档

## 2. 分析和分析器

- 首先将一块文本分成适合于倒排索引的独立的词条
- 之后将这些词条统一化为标准格式以提高它们的“可搜索性”

## 3. 分析过程

- 字符过滤器(character filters): 如 html 清除等
- 分词器(tokenizer): 把一个字符串根据单词边界分解成单个词条，并且移除掉大部分的标点符号
- 词单元过滤器(token filters): 如 lowercase, stop 词过滤器

## 4. Analyzer

### standard Analyzer

- 根据 standardUnicode 文本分段算法的定义，分析器将文本划分为单词边界上的多个术语。它删除大多数标点符号，小写术语，并支持删除停用词
- max_token_length: 最大 token 长度。如果看到 token 超过此长度，则将其 max_token_length 间隔分割。默认为 255。
- stopwords: 预定义的停用词列表，例如*english*或包含停用词列表的数组。默认为*none*。
- stopwords_path: 包含停用词的文件的路径。
- type: 内置分析器的名称，如 standard,simple 等

```python
## code
curl -X PUT ""http://192.168.122.128:9201/paper?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "type": "standard",
          "max_token_length": 5,
          "stopwords": "_english_"
        }
      }
    }
  }
}
'
## test
curl -X POST ""http://192.168.122.128:9201/paper/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "analyzer": "my_analyzer",
  "text": "The 2 QUICK Brown-Foxes jumped over the lazy dog\u0027s bone."
}
'
## result
## [ 2, quick, brown, foxes, jumpe, d, over, lazy, dog's, bone ]
```

### Custom Analyzer

- tokenizer: 内置或自定义的标记器。（需要）
- char_filter: 内置或自定义字符过滤器的可选数组，0 个或者多个
- filter: 内置或自定义 token filter 的可选数组，0 个或者多个

```python
## code
body = {
    "settings" : {
        "analysis": {
            "char_filter": {
                "my_char_filter": {
                    "type":       "mapping",
                    "mappings": [ "&=> and "]
            }},
            "filter": {
                "my_stopwords": {
                    "type":             "stop",
                    #"stopwords":       "_english_ ",
                    "stopwords_path":   "stopwords/zh.txt",                #config目录下
                    "ignore_case":      True,
            }},
            "analyzer": {
                "my_analyzer": {
                    "type":         "custom",                              #设置type为custom告诉Elasticsearch, 我们正在定义一个定制分析器
                    "char_filter":  [ "html_strip", "my_char_filter" ],    #使用html清除字符过滤器和一个自定义的映射字符过滤器把 & 替换为 " and "
                    "tokenizer":    "standard",                            #使用标准分词器分词
                    "filter":       [ "lowercase", "my_stopwords" ]        #小写词条和自定义停止词过滤器处理
            }},
        }
   }
}

body = {
    "settings": {
        "analysis": {
            "analyzer"   : {
                "my_custom_analyzer": {
                    "type"       : "custom",
                    "char_filter": ["emoticons"],
                    "tokenizer"  : "punctuation",
                    "filter"     : [
                        "lowercase"
                        "english_stop"
                    ]
            }},
            "tokenizer"  : {
                "punctuation": {
                    "type"   : "pattern",
                    "pattern": "[ .,!?]"
            }},
            "char_filter": {
                "emoticons": {
                    "type"    : "mapping",
                    "mappings": [
                        ":) => _happy_",
                        ":( => _sad_"
                    ]
            }},
            "filter"     : {
                "english_stop": {
                    "type"     : "stop",
                    "stopwords": "_english_"
            }}
        }
    }
}
```

## 5. 分词器, tokenizers

### standard tokenizer

- 提供基于语法的分词（基于 Unicode 标准附件＃29 中指定的 Unicode 文本分段算法 ），并且适用于大多数语言
- max_token_length: 最大 token 长度。如果看到令牌超过此长度，则将其 max_token_length 间隔分割。默认为 255

```python
## code
curl -X PUT "http://192.168.122.128:9201/paper?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "my_tokenizer"
        }
      },
      "tokenizer": {
        "my_tokenizer": {
          "type": "standard",
          "max_token_length": 5
        }
      }
    }
  }
}
'
## test
curl -X POST "http://192.168.122.128:9201/paper/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "analyzer": "my_analyzer",
  "text": "The 2 QUICK Brown-Foxes jumped over the lazy dog\u0027s bone."
}
'
## result
## [ The, 2, QUICK, Brown, Foxes, jumpe, d, over, the, lazy, dog's, bone ]
```

## 6. 词单元过滤器, token filter

### stop 词过滤器

- stopwords: 要使用的停用词列表。默认为*english*停用词。
- stopwords_path: config 停用词文件配置的路径（相对于位置或绝对路径）。每个停用词应位于其自己的“行”中（以换行符分隔）。该文件必须为 UTF-8 编码。
- ignore_case: 首先将 true 所有单词设置为小写。默认为 false。
- remove_trailing: 设置为 false，如果它是一个停用词，则不忽略搜索的最后一项。这对于完成建议器非常有用，因为即使您通常删除停用词，查询 green a 也可以扩展到 green apple。默认为 true。

```python
## code
curl -X PUT "http://192.168.122.128:9201/paper?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_stop_analyzer": {
          "type": "stop",
          "stopwords": ["the", "over"]
        }
      }
    }
  }
}
'
## test
curl -X POST "http://192.168.122.128:9201/paper/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "analyzer": "my_stop_analyzer",
  "text": "The 2 QUICK Brown-Foxes jumped over the lazy dog\u0027s bone."
}
'
## result
## [ 2 QUICK Brown-Foxes jumped lazy dog\u0027s bone.]
```

## 7. character filters

### html_strip character

- 去除文本的 HTML 元素和内容替换 HTML 与他们的解码值的实体
- escaped_tags: 不应从原始文本中剥离的 HTML 标记数组

```python
## code
curl -X PUT "http://192.168.122.128:9201/my_index?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "keyword",
          "char_filter": ["my_char_filter"]
        }
      },
      "char_filter": {
        "my_char_filter": {
          "type": "html_strip",
          "escaped_tags": ["b"]
        }
      }
    }
  }
}
'
## test
curl -X POST "http://192.168.122.128:9201/my_index/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "analyzer": "my_analyzer",
  "text": "<p>I&apos;m so <b>happy</b>!</p>"
}
'
## result
## [ \nI'm so <b>happy</b>!\n ]
```

### mapping character filter

- 接受 mappings 上的键和值的。每当遇到与键相同的字符串时，它将用与该键关联的值替换它们
- mappings: 映射数组，每个元素的形式为 key => value。
- mappings_path: config 包含 key => value 每行映射的 UTF-8 编码文本映射文件的 绝对路径或相对于目录的路径。

```python
## code
curl -X PUT "http://192.168.122.128:9201/my_index?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "keyword",
          "char_filter": [
            "my_char_filter"
          ]
        }
      },
      "char_filter": {
        "my_char_filter": {
          "type": "mapping",
          "mappings": [
            "٠ => 0",
            "١ => 1",
            "٢ => 2",
            "٣ => 3",
            "٤ => 4",
            "٥ => 5",
            "٦ => 6",
            "٧ => 7",
            "٨ => 8",
            "٩ => 9"
          ]
        }
      }
    }
  }
}
'
## test
curl -X POST "http://192.168.122.128:9201/my_index/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "analyzer": "my_analyzer",
  "text": "My license plate is ٢٥٠١٥"
}
'
## result
## [ My license plate is 25015 ]
```

### pattern_replace character filter

- 使用一个正则表达式匹配应该与指定替换字符串替换字符。替换字符串可以引用正则表达式中的捕获组
- pattern: 一个 Java 的正则表达式
- replacement: 替换字符串
- flags: Java 正则表达式标志。标记应以管道分隔，例如"CASE_INSENSITIVE|COMMENTS"。

```python
## code
curl -X PUT "http://192.168.122.128:9201/my_index?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "standard",
          "char_filter": [
            "my_char_filter"
          ]
        }
      },
      "char_filter": {
        "my_char_filter": {
          "type": "pattern_replace",
          "pattern": "(\\d+)-(?=\\d)",
          "replacement": "$1_"
        }
      }
    }
  }
}
'
## test
curl -X POST "http://192.168.122.128:9201/my_index/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "analyzer": "my_analyzer",
  "text": "My credit card is 123-456-789"
}
'
## result
## [ My, credit, card, is, 123_456_789 ]
```
