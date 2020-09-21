# 搜索结果解析

```python
{
    "took": 68,                 ##执行整个搜索请求耗费了多少毫秒
    "timed_out": false,         ##查询是否超时
    "_shards": {                ##在查询中参与分片的总数，以及这些分片成功了多少个失败了多少个
        "total": 1,
        "successful": 1,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": {
            "value": 1913,      ##匹配到的文档总数
            "relation": "eq"
        },
        "max_score": 1.0,       ##与查询所匹配文档的 _score 的最大值
        "hits": [
            {                   ##每个结果包含文档的 _index 、 _type 、 _id ，加上 _source 字段
                "_index": "paper",
                "_type": "_doc",
                "_id": "dv2ZE28B6ODVg4A_oKRW",
                "_score": 1.0,
                "_source": {
                    "paper_id": 2,
                    "paper_index": 1,
                    "paper_title": "人工智能时代的制度安排与法律规制",
                    "paper_sentence": "文章编号:1674－5205(2017)"
                }
            },
            {
                "_index": "paper",
                "_type": "_doc",
                "_id": "d_2ZE28B6ODVg4A_oKRW",
                "_score": 1.0,
                "_source": {
                    "paper_id": 2,
                    "paper_index": 2,
                    "paper_title": "人工智能时代的制度安排与法律规制",
                    "paper_sentence": "05-0128-(009)收稿日期:20"
                }
            },
        ]
    },
}
```
