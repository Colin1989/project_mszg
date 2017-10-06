%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  数据库更新模块
%%% @end
%%% Created : 27 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(db_update).

-export([start/0]).


start() ->
    create_table(),
    Path = code:where_is_file("db_update.sql"),
    {ok, Updates} = file:consult(Path),
    update_db(Updates).

update_db(Updates) ->
    HistoryCount = get_history_count(),
    migrate(Updates, 1, HistoryCount).

migrate([], _Index, _HistoryCount) ->
    ok;
migrate([{Comment, Sql}|Updates], Index, HistoryCount) when Index > HistoryCount ->
    io:format("db update: ~p~n", [Comment]),
    F = fun() ->
		Result = db:execute(Sql),
		io:format("##Result:~p~n", [Result]),
		db:execute(["insert into db_update_history set comment='", Comment, "'"])
	end,
    db:transaction(F),
    migrate(Updates, Index+1, HistoryCount);
migrate([_|Updates], Index, HistoryCount) ->
    migrate(Updates, Index+1, HistoryCount).
    
create_table() ->
    Sql = "CREATE TABLE IF NOT EXISTS db_update_history("
	"id int NOT NULL AUTO_INCREMENT ,"
	"COMMENT varchar( 256 ) NOT NULL ,"
	"create_time timestamp NOT NULL DEFAULT NOW(),"
	"PRIMARY KEY ( id ) ) ENGINE = innodb",
    db:execute(Sql).

get_history_count() ->
    Sql = "select count(*) from db_update_history",
    {data, Result} = db:execute(Sql),
    [Rows] = mysql:get_result_rows(Result),
    hd(Rows).
    
    
    
