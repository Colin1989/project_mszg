%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created : 16 Jun 2014 by whl <>
%%%-------------------------------------------------------------------
-module(military_rank).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("event_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").

%% API
-export([start/0,
		 notify_military_rank_info/0,
		 get_level/0,
		 back_up_honour_rank/0,
		 add_honour/2,
		 reduce_honour/2,
		 get_honour/0]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
	packet:register(?msg_req_military_rank_info, {?MODULE, proc_req_military_rank_info}), %% 请获取奖励
	packet:register(?msg_req_military_rank_reward, {?MODULE, proc_give_reward}), %% 请获取奖励
	ok.

notify_military_rank_info() ->
	Level = get_level(),
	IsReward = is_reward(),
	packet:send(#notify_military_rank_info{level = Level, is_rewarded = IsReward}).
%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec 获取军衔 本周荣誉值
%% @end
%%--------------------------------------------------------------------
proc_req_military_rank_info(#req_military_rank_info{}) ->
	notify_military_rank_info().

%%--------------------------------------------------------------------
%% @doc
%% @spec 增加荣誉值
%% @end
%%--------------------------------------------------------------------
add_honour(Type, Honour) when Honour >= 0 ->
	RoleID = player:get_role_id(),
	OldHonour = get_honour(),
	NewHonour = Honour + OldHonour,
	set_honour(RoleID, NewHonour),
	player_log:create(RoleID, ?honour, Type, 1, 0, 0, Honour, NewHonour).

%%--------------------------------------------------------------------
%% @doc
%% @spec 增加荣誉值
%% @end
%%--------------------------------------------------------------------
reduce_honour(Type, Honour) when Honour >= 0 ->
	RoleID = player:get_role_id(),
	OldHonour = get_honour(),
	NewHonour = Honour - OldHonour,
	set_honour(RoleID, NewHonour),
	player_log:create(RoleID, ?honour, Type, 1, 0, 0, Honour, NewHonour).

%%--------------------------------------------------------------------
%% @doc
%% @spec 设置荣誉值
%% @end
%%--------------------------------------------------------------------
set_honour(RoleID, Honour) ->
	honour_rank(RoleID, Honour),
	cache:set('military_rank:honour', RoleID, {Honour, erlang:localtime()}),
	packet:send(#notify_role_info_change{type = "honour", new_value = Honour}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 获取荣誉值
%% @end
%%--------------------------------------------------------------------
get_honour() ->
	case cache_with_expire:get('military_rank:honour', player:get_role_id()) of
		[] ->
			0;
		[{_, Value}] ->
			element(1, Value)
	end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 获取军衔等级
%% @end
%%--------------------------------------------------------------------
get_level() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('military_rank:level', RoleID) of
		[] ->
			case cache_with_expire:get('military_rank:honour', RoleID) of
				[] ->
					0;
				[{_, Value}] ->
					Time = element(2, Value),
					Honour = element(1, Value),
					ReduceMinHoonour = config:get(reduce_min_honour),
					PassWeeks = get_pass_weeks_of_update(Time),
					PreWeekHonour = get_pre_week_honour(PassWeeks, Honour),

					ThisWeekHonour = case PreWeekHonour * config:get(honour_reduce_ratio) > ReduceMinHoonour of
										 true ->
											 PreWeekHonour * config:get(honour_reduce_ratio);
										 false ->
											 ReduceMinHoonour
									 end,
					set_honour(RoleID, ThisWeekHonour),

					Level = calucate_level(PreWeekHonour),
					cache_with_expire:set('military_rank:level', player:get_role_id(), Level, week),
					Level
			end;
		[{_, Value}] ->
			Value
	end.

get_pre_week_honour(PassWeeks, Honour) ->
	case PassWeeks - 1 of
		0 ->
			Honour;
		RedcueWeek ->
			ReducedHonour = reduce_honour_proc(Honour, RedcueWeek, config:get(honour_reduce_ratio)),
			case ReducedHonour < config:get(reduce_min_honour) of
				true ->
					config:get(reduce_min_honour);
				false ->
					ReducedHonour
			end
	end.

reduce_honour_proc(Hounour, 0, _ReduceRatio) ->
	trunc(Hounour);
reduce_honour_proc(Hounour, RedcueWeek, ReduceRatio) ->
	reduce_honour_proc(Hounour * ReduceRatio, RedcueWeek - 1, ReduceRatio).

get_pass_weeks_of_update(Time) ->
	TotalDays = (datetime:datetime_to_gregorian_seconds(get_week_day_time()) - datetime:datetime_to_gregorian_seconds(Time)) div 86400,
	TotalDays div 7 + 1.

get_week_day_time() ->
	Weekday = calendar:day_of_the_week(erlang:date()),
	{Date, _Time} = calendar:gregorian_seconds_to_datetime(calendar:datetime_to_gregorian_seconds(erlang:localtime()) - 86400 * (Weekday - 1)),
	{Date, {0, 0, 0}}.


%%--------------------------------------------------------------------
%% @doc
%% @spec 计算榜外军衔等级
%% @end
%%--------------------------------------------------------------------
calucate_level(Honour) ->
	TpltList = tplt:get_all_data(military_rank_tplt),
	FixTpltList = lists:filter(fun(E) -> length(E#military_rank_tplt.need_rank) =:= 0 end, TpltList),
	calucate_level_proc(FixTpltList, Honour, 0).

calucate_level_proc([],  _Honour, CurLevel) ->
	CurLevel;
calucate_level_proc([TpltInfo | FixTpltList], Honour, CurLevel) ->
	case TpltInfo#military_rank_tplt.need_honour > Honour of
		true ->
			CurLevel;
		false ->
			calucate_level_proc(FixTpltList, Honour, TpltInfo#military_rank_tplt.id)
	end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 排名榜玩家军衔计算
%% @end
%%--------------------------------------------------------------------
set_top_hundred_level() ->
	RankList = get_honour_rank_list(),
	FixTplt = get_fix_tplt_info(),
	role_rank_to_level(RankList, FixTplt),
	ok.

role_rank_to_level([], _) ->
    ok;
role_rank_to_level(_, []) ->
    ok;

role_rank_to_level(RankList, [{_,_,0}|FixTpltList])->
    role_rank_to_level(RankList, FixTpltList);

role_rank_to_level([RoleInfo | Left] = RankList, [{Level, LevelNeedHonour, RemainCount} | FixTpltList])->
    RoleHonour = element(2, RoleInfo),
    case RoleHonour >= LevelNeedHonour of
	true ->
	    RoleID = element(1, RoleInfo),
	    cache_with_expire:set('military_rank:level', RoleID, Level, week),
	    role_rank_to_level(Left, [{Level, LevelNeedHonour, RemainCount-1} | FixTpltList]);
	false ->
	    role_rank_to_level(RankList, FixTpltList)
    end.
    

get_fix_tplt_info() ->
	TpltList = tplt:get_all_data(military_rank_tplt),
	RevTpltList = lists:reverse(TpltList),
	L1 = lists:filter(fun(E) -> length(E#military_rank_tplt.need_rank) =/= 0 end, RevTpltList),
	lists:map(
		fun(E) ->
			NeedRank = E#military_rank_tplt.need_rank,
			Count = lists:nth(2, NeedRank) - lists:nth(1, NeedRank) + 1,
			{E#military_rank_tplt.id, E#military_rank_tplt.need_honour, Count}
		end,
		L1).

%%--------------------------------------------------------------------
%% @doc
%% @spec 发送奖励
%% @end
%%--------------------------------------------------------------------
proc_give_reward(#req_military_rank_reward{}) ->
	case is_reward() of
		0 ->
			Level = get_level(),
			TpltInfo = get_tplt(Level),
			reward:give(TpltInfo#military_rank_tplt.reward_ids, TpltInfo#military_rank_tplt.reward_amounts, ?st_military_rank),
			cache_with_expire:set('military_rank:is_rewarded_today', player:get_role_id(), 1, day),
			packet:send(#notify_military_rank_reward_result{result = ?common_success});
		1 ->
			packet:send(#notify_military_rank_reward_result{result = ?common_failed})
	end.

is_reward() ->
	case cache_with_expire:get('military_rank:is_rewarded_today', player:get_role_id()) of
		[] ->
			0;
		[{_, IsReward}] ->
			IsReward
	end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 模版相关
%% @end
%%--------------------------------------------------------------------
get_tplt(ID) ->
	tplt:get_data(military_rank_tplt, ID).

get_tplt_need_honour(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#military_rank_tplt.need_honour.

%%--------------------------------------------------------------------
%% @doc
%% @spec 排名相关
%% @end
%%--------------------------------------------------------------------
test_add(Num) ->
	circle_add(Num).

circle_add(0) ->
	ok;
circle_add(Number) ->
	Honour = 2500 + rand:uniform(1000),
	RoleID = 100 + Number,
	honour_rank(RoleID, Honour),
	circle_add(Number - 1).

honour_rank(RoleID, Honour) ->
	RankMinHonour = config:get(rank_min_honour),
	case Honour < RankMinHonour of
		true ->
			ok;
		false ->
			redis_extend:add_in_rank_with_limit_count(honour_rank, [Honour, RoleID], 0, -101)
%% 			redis:zadd(honour_rank, [Honour, RoleID]),
%% 			redis:zremrangebyrank(honour_rank, 0, -101)
	end.

back_up_honour_rank() ->
	io_helper:format("begin to back_up_honour_rank~n"),
	BackKeyName = get_honour_rank_list_name(),
	redis:zunionstore(BackKeyName, 2, [BackKeyName, honour_rank]), %% 一周排名备份，留作排名榜
	redis:expire(BackKeyName, 86400 * 7),

	set_top_hundred_level(), %% 设置排名榜军衔

	%% 新的一周排名榜处理
	RankList = redis:zrevrange(honour_rank, 0, 99, true),
	lists:map(
		fun(RankData) ->
			RoleID = element(1, RankData),
			OldScore = element(2, RankData),
			ReduceMinHonour = config:get(reduce_min_honour),
			ReduceRatio = config:get(honour_reduce_ratio),
			NewScore = case OldScore * ReduceRatio >= ReduceMinHonour of
						   true ->
							   trunc(OldScore * ReduceRatio);
						   false ->
							   ReduceMinHonour
					   end,
			set_honour(RoleID, NewScore),
			redis:zadd(honour_rank, [NewScore, RoleID])
		end,
		RankList
	),
	%%redis:zremrangebyscore(honour_rank, 0, config:get(rank_min_honour)), %% 清除所需排名最低分以下的用户
	ok.

get_honour_rank_list() ->
	RankName = get_honour_rank_list_name(),
	case redis:zrevrange(RankName, 0, 99, true) of
		[] ->
			[];
		RankList ->
			RankList
	end.

get_honour_rank_list_name() ->
	Weekday = calendar:day_of_the_week(erlang:date()),
	{Date, _Time} = calendar:gregorian_seconds_to_datetime(calendar:datetime_to_gregorian_seconds(erlang:localtime()) - 86400 * (Weekday - 1)),
	{Year, Month, Day} = Date,
	lists:concat([honour_rank, "_", Year, "-", Month, "-", Day]).

%% get_role_honour_rank(RoleID) ->
%% 	redis:zrevrank(get_honour_rank_list_name(), RoleID).

