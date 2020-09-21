# solrcloud 索引

## 1. 添加一个新的字段

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"sell-by",
     "type":"pdate",
     "stored":true },
  "add-field":{
     "name":"location",
     "type":"string",
     "stored":true },
}' http://localhost:8983/solr/CollectionName/schema
```

## 2. 删除一个字段

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" : { "name":"sell-by" }
}' http://localhost:8983/solr/CollectionName/schema
```

## 3. 替换一个字段的定义

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "replace-field":{
     "name":"sell-by",
     "type":"date",
     "stored":false }
}' http://localhost:8983/solr/CollectionName/schema
```

## 4. 添加动态字段

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":{
     "name":"*_s",
     "type":"string",
     "stored":true }
}' http://localhost:8983/solr/CollectionName/schema
```

## 5. 删除动态字段

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":{ "name":"*_s" }
}' http://localhost:8983/solr/CollectionName/schema
```

## 6. 替换动态字段

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "replace-dynamic-field":{
     "name":"*_s",
     "type":"text_general",
     "stored":false }
}' http://localhost:8983/solr/CollectionName/schema
```

## 7. 添加复制字段

- source: 源字段。该参数是必需的
- dest: 源字段将被复制到的字段或字段数组。该参数是必需的
- maxChars: int 参数，用于在构造添加到目标字段的值时，为要从源值复制的字符数建立一个上限
- 复制是在流源级别完成的，并且不复制到另一个副本中，即不能从 here 复制到 there 然后从 there 复制到 elsewhere
- 复制可以将相同的源字段复制到多个目标字段

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source":"shelf",
     "dest":[ "location", "catchall" ]}
}' http://localhost:8983/solr/CollectionName/schema
```

## 8. 删除复制字段

```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{ "source":"shelf", "dest":"location" }
}' http://localhost:8983/solr/CollectionName/schema
```
