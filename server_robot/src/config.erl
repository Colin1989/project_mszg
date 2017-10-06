%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2014, linyibin
%%% @doc
%%% 配置信息
%%% @end
%%% Created :  3 Jan 2014 by linyibin <>
%%%-------------------------------------------------------------------
-module(config).

%% API
-export([start/0,
	 reload/0,
	 get/1,
	 get_server_config/1]).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    FilePath = get_file_path(),
    Configs = get_config(FilePath),
    ets:new(config, [ordered_set, public, named_table]),
    save(Configs),
    FilePath1 = get_server_config_path(),
    ServerConfigs = get_config(FilePath1),
    ets:new(server_config, [ordered_set, public, named_table]),
    save_server_config(ServerConfigs).


reload() ->
    FilePath = get_file_path(),
    Configs = get_config(FilePath),
    save(Configs).

%%--------------------------------------------------------------------
%% @doc
%% @获取配置信息
%% @end
%%--------------------------------------------------------------------
get(Key) ->
    [{Key, Value}] = ets:lookup(config, Key),
    Value.


get_server_config(Key) ->
    [{Key, Value}] = ets:lookup(server_config, Key),
    Value.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @保存配置文件
%% @end
%%--------------------------------------------------------------------
save([]) ->
    ok;
save([{Key, Value}|Configs]) ->
    ets:insert(config, {Key, Value}),
    save(Configs).


save_server_config([]) ->
    ok;
save_server_config([{Key, Value}|Configs]) ->
    ets:insert(server_config, {Key, Value}),
    save_server_config(Configs). 

%%--------------------------------------------------------------------
%% @doc
%% @获取文件路径
%% @end
%%--------------------------------------------------------------------
get_file_path() ->
    FilePath = case os:getenv("template") of
	       false -> "./template/"
	   end,
    FilePath ++ "config.cfg".


get_server_config_path() ->
    FilePath = case os:getenv("template") of
	       false -> "./template/"
	   end,
    FilePath ++ "server_config.cfg".

%%--------------------------------------------------------------------
%% @doc
%% @获取配置信息
%% @end
%%--------------------------------------------------------------------
get_config(FilePath) ->
    {ok, [List]} = file:consult(FilePath),
    List.
