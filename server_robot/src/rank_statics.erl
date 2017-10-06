%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 28 Apr 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(rank_statics).
-define(bak_time,3).
%%-record(rank_data,{rank = 0, role_id = 0, score = 0}).
%% API
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("record_def.hrl").

-export([start/0]).
-export([back_rank_info/1]).
-export([update_rank/3,proc_req_get_rank_infos/1]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
start()->
    packet:register(?msg_req_get_rank_infos,{?MODULE,proc_req_get_rank_infos}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

proc_req_get_rank_infos(#req_get_rank_infos{type = Type})->
    Rank = get_rank_top_n(role_lev_rank,config:get(level_rank_amount)),
    
    case Type of
	?battle_power_rank ->
	    packet:send(#notify_rank_infos{type = Type, myrank = get_role_rank(battle_power_rank, player:get_role_id()),
									      top_hundred = get_rank_top_n(battle_power_rank,
													   config:get(battle_power_rank_amount))});
	?role_level_rank ->
	    packet:send(#notify_rank_infos{type = Type, myrank = get_role_rank(role_lev_rank, player:get_role_id()),
									      top_hundred = Rank})
    end.
back_rank_info(AimHour)->
    %%io:format("AimHour:~p,CurTime:~p~n", [AimHour,erlang:localtime()]),
    {RYear, RMonth, RDay} = get_rank_date(AimHour),
    lists:foreach(fun(X) ->  
			  Key = format_key(X, RYear, RMonth, RDay),
			  case redis:hget(rank_bak_done_status, Key) of
			      1 ->
				  ok;
			      _ ->
				  do_back_rank_info(Key, X)
			  end
		  end, get_all_rank_name()).


update_rank(RankType, RoleId, Score)->
    training_match:update_rank(RankType, RoleId, Score),
    redis_extend:update_rank(RankType, RoleId, pack_score(Score)).

%%%===================================================================
%%% Internal functions
%%%===================================================================
pack_score(Score) ->
    Score * 10000 + get_suffix_by_day().

unpack_score(Score) ->
    Score div 10000.

get_suffix_by_day()->
    TotalDay = calendar:datetime_to_gregorian_seconds(erlang:localtime()) div 86400,
    10000 - (TotalDay rem 10000).





get_rank_date(AimHour)->
    {{Year, Month, Day}, {Hour, _Minute, _Second}} = erlang:localtime(),
    case Hour < AimHour  of
	true ->
	    get_the_day_before_yesterday(Year, Month, Day);
	false ->
	    get_yesterday(Year, Month, Day)
    end.

do_back_rank_info(Key, SourceKey)->
    case redis:exists(Key) of
	0 ->
	    PreTime = calendar:datetime_to_gregorian_seconds(erlang:localtime()),
	    redis:zunionstore(Key, 2, [Key,SourceKey]),
	    redis:hset(rank_bak_done_status, Key, 1),
	    redis:expire(Key, 86400),
	    NeedTime = calendar:datetime_to_gregorian_seconds(erlang:localtime()) - PreTime,
	    io:format("rank_bak_waste:~p~n", [NeedTime]);
	_ ->
	    ok
    end.

    %%io:format("DestKey:~p,SourceKey~p~n", [Key, SourceKey]).

get_role_rank(RankType, RoleId)->
    {Year, Month, Day} = get_rank_date(?bak_time),
    Key = format_key(RankType, Year, Month, Day),
    case redis:zrevrank(Key, RoleId) of
	undefined ->
	    0;
	Rank ->
	    Rank + 1
    end.

get_rank_top_n(RankType, N)->
    {Year, Month, Day} = get_rank_date(?bak_time),
    Key = format_key(RankType, Year, Month, Day),
    List = redis:zrevrange(Key, 0, N-1, true),
    RoleInfos = case length(List) of
		    0 ->[];
		    _ ->lists:filter(fun({FId, Data}) -> 
					     roleinfo_manager:upgrade_data(FId, Data) =/= undefined
				     end, redis:hmget(role_info_detail, [X || {X,_} <- List]))
		end,
    {_, RResult} = lists:foldl(fun({Id, Score}, {Index, Result}) -> 
				       case proplists:lookup(Id, RoleInfos) of
					   none  ->
					       io:format("rand_err:~p", [Id]),
					       {Index, Result};
					   {_, RoleInfo} ->
					       {Index + 1, [#rank_data{rank = Index, role_id = Id, value = unpack_score(Score),
								      name = RoleInfo#role_info_detail.nickname, type = RoleInfo#role_info_detail.type,
								      public = RoleInfo#role_info_detail.public}
							    |Result]}
				       end
			       end, {1, []}, List),
    lists:reverse(RResult).







format_key(RankType,Year, Month, Day)->
    lists:concat([RankType,"_",Year,"-",Month,"-",Day]).

get_yesterday(Year, Month, Day)->
    {Date,_Time}=calendar:gregorian_seconds_to_datetime(calendar:datetime_to_gregorian_seconds({{Year, Month, Day}, {0, 0, 0}}) - 86400),
    Date.

get_the_day_before_yesterday(Year, Month, Day)->
    {Date,_Time}=calendar:gregorian_seconds_to_datetime(calendar:datetime_to_gregorian_seconds({{Year, Month, Day}, {0, 0, 0}}) - 86400 * 2),
    Date.

get_all_rank_name()->
    [battle_power_rank, role_lev_rank].




init_test_data(0)->
    ok;
init_test_data(Index) ->
    %%redis:zadd(test, [rand:uniform(1),Index]),
    update_rank(test,Index,rand:uniform(10000)),
    init_test_data(Index - 1).


    

test_back_info()->
    do_back_rank_info(test_back, test).

