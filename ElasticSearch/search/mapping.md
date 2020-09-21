# 映射（Mapping）

- 描述数据在每个字段内如何存储

## 精确值

- 精确值如它们听起来那样精确。例如日期或者用户 ID，但字符串也可以表示精确值，例如用户名或邮箱地址。
- 对于精确值来讲，Foo 和 foo 是不同的，2014 和 2014-09-15 也是不同的

## 全文

- 指文本数据（通常以人类容易识别的语言书写），例如一个推文的内容或一封邮件的内容
- 该文档与给定查询的相关性如何

## string 类型

```python
#index:
## analyzed: 首先分析字符串，然后索引它。换句话说，以全文索引这个域（默认值）
## not_analyzed: 索引这个域，所以它能够被搜索，但索引的是精确值。不会对它进行分析
## no: 不索引这个域。这个域不会被搜索到

#analyzed
## 默认使用standard分析器，但你可以指定一个内置的分析器替代它，例如whitespace、simple和english
{
    "tag": {
        "type":     "string",
        "index":    "not_analyzed"
    }
}

{
    "tweet": {
        "type":     "string",
        "analyzer": "english"
    }
}
```
