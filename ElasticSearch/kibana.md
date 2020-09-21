# kibana

## 1. 介绍

- Kibana 是一个开源的分析和可视化平台，设计用于和 Elasticsearch 一起工作
- 你用 Kibana 来搜索，查看，并和存储在 Elasticsearch 索引中的数据进行交互
- 你可以轻松地执行高级数据分析，并且以各种图标、表格和地图的形式可视化数据
- Kibana 使得理解大量数据变得很容易
- 它简单的、基于浏览器的界面使你能够快速创建和共享动态仪表板，实时显示 Elasticsearch 查询的变化

## 2. 安装

- 请见https://github.com/XiaoYang1127/shell/tree/master/es

## 3. 配置

- https://www.elastic.co/guide/en/kibana/current/settings.html
-

## 4. 访问

- Kibana 是一个 Web 应用程序，你可以通过 5601 来访问它
- 当访问 Kibana 时，默认情况下，Discover 页面加载时选择了默认索引模式。时间过滤器设置为最近 15 分钟，搜索查询设置为 match-all(\*)

## 5. 检查 kibana 状态

- http://localhost:5601/status
- http://192.168.101.5:5601/api/status 返回 JSON 格式状态信息

## 6. 使用 ES 连接 kibanna
