*. �ڵ���Ϊ1@ip��ʽ, ����1Ϊserver id, Ŀǰuuidģ���ʹ�õ�
*. ���в�����������ʹ��make test ����rebar ct ���� rebar ct suites=uuid(�����ָ������uuit_SUITE.erlģ��)
*. ���ʹ��rebar ct ����rebar ct suites=uuid, ��ȷ��������ģ���б���, �ұ���ͨ��
*. �л�Ŀ¼��boss_db(./deps/boss_db), �����Ҫͬ���ٷ�boss_db����, ��ʹ��git pull
*. observer:start(). ���ܺ�ǿ��, �������Կ�
*. ���ݿ��Զ�����, ֻ��Ҫά��ebin/db_update.txt����, ��д�ṹ��{Comment, Sql}.
*. event_routerΪ�¼�ģ��, pub/sub����, �����¼���ע���뷢�ʹ���
*. dbg_helperģ�����������򻯵���, dbg_helper:debug(), �������ģ��, dbg_helper:debug(Module), ���ָ��ģ��disable()����ȡ�����
*. ��Դ�����ͷ������ %% coding: utf-8 , ����ָ��Դ�ļ��ı��뷽ʽ, Ŀǰ֧��latin-1��utf-8


���ݿ�ʹ��: 
item.erl
-module(item, [Id, Name, RoleId]).
-table("item").  %% ָ��mysql��, �������
-columns([{attribute1, "my_column_name"}]). %%�����������ݿ�����ֶε�ӳ��
-belongs_to(role).  %% ��ʾ���item������role, һ��role����ӵ��һ�����߶��item

role.erl
-module(role, [Id, Account, Password, Name, Age]).
-table("role").
-has({items, all}). %% ��ʾӵ�ж��item, ͨ������Role:items().��ö�Ӧ�Ķ��item

����ʹ�÷����μ�http://www.chicagoboss.org/api-record.html



Shell 
�� unicode �����£����Ļᱻ����Ϊ [20013,22269,20154] ������˫�ֽ����֣�
�� latin1 �����£����Ļᱻ����Ϊ [228,184,173,229,155,189,228,186,186] �����ĵ��ֽ����֣�

������ unicode ��������Ҫ�� [\x{4e00}-\x{9fff}] ��ƥ�䣬��˫�ֽڵı��ʽ��
latin ��������Ҫ�� [\x81-\xfe][\x40-\xfe] ��ƥ�䣬�ǵ��ֽڵı��ʽ��
Ȼ�� windows ���棬cmd Ĭ���� latin1 ������werl.exe Ĭ���� unicode ������