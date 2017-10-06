*. 节点名为1@ip格式, 其中1为server id, 目前uuid模块会使用到
*. 运行测试用例可以使用make test 或者rebar ct 或者 rebar ct suites=uuid(这个会指定运行uuit_SUITE.erl模块)
*. 如果使用rebar ct 或者rebar ct suites=uuid, 请确保被测试模块有保存, 且编译通过
*. 切换目录到boss_db(./deps/boss_db), 如果需要同步官方boss_db代码, 请使用git pull
*. observer:start(). 功能很强大, 可以试试看
*. 数据库自动更新, 只需要维护ebin/db_update.txt即可, 编写结构是{Comment, Sql}.
*. event_router为事件模块, pub/sub类型, 用于事件的注册与发送处理
*. dbg_helper模块用来帮助简化调试, dbg_helper:debug(), 监控所有模块, dbg_helper:debug(Module), 监控指定模块disable()用于取消监控
*. 在源代码的头部增加 %% coding: utf-8 , 可以指定源文件的编码方式, 目前支持latin-1和utf-8


数据库使用: 
item.erl
-module(item, [Id, Name, RoleId]).
-table("item").  %% 指定mysql中, 表的名字
-columns([{attribute1, "my_column_name"}]). %%做属性与数据库表中字段的映射
-belongs_to(role).  %% 表示这个item依附于role, 一个role可以拥有一个或者多个item

role.erl
-module(role, [Id, Account, Password, Name, Age]).
-table("role").
-has({items, all}). %% 表示拥有多个item, 通过调用Role:items().获得对应的多个item

其他使用方法参见http://www.chicagoboss.org/api-record.html



Shell 
在 unicode 环境下，中文会被编译为 [20013,22269,20154] 这样的双字节数字，
在 latin1 环境下，中文会被编译为 [228,184,173,229,155,189,228,186,186] 这样的单字节数字，

所以在 unicode 环境下需要用 [\x{4e00}-\x{9fff}] 来匹配，是双字节的表达式，
latin 环境下需要用 [\x81-\xfe][\x40-\xfe] 来匹配，是单字节的表达式。
然后 windows 下面，cmd 默认是 latin1 环境，werl.exe 默认是 unicode 环境。