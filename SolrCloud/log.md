# solrcloud 日志

## 日志记录地方

- server/resources/log4j2.xml

## 记录慢查询

- 设置一个等待时间阈值，在该阈值之上，请求被视为慢速，并在 WARN 级别记录该请求，以帮助您识别应用程序中的慢速查询

```
  <slowQueryThresholdMillis>1000</slowQueryThresholdMillis>
```
