%%%-------------------------------------------------------------------
%%% @author wanghl
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%     抽奖活动
%%% @end
%%% Created : 15. 一月 2015 10:56
%%%-------------------------------------------------------------------
-module(activity_lottery).
-author("wanghl").

-include("event_def.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").

%% API
-export([start/0,
         init_notify/0,
         proc_req_act_lottery/1,
         proc_moon_card_user/0]).

-compile(export_all).

start() ->
    packet:register(?msg_req_act_lottery, {?MODULE, proc_req_act_lottery}),

    event_router:register(event_login, {?MODULE, proc_daily_login}),
    event_router:register(event_game_copy, {?MODULE, proc_game_copy}),
    event_router:register(event_activity_copy, {?MODULE, proc_activity_copy}),
    event_router:register(event_push_tower, {?MODULE, proc_push_tower}),
    event_router:register(event_train_match, {?MODULE, proc_train_match}),
    event_router:register(event_ladder_match, {?MODULE, proc_ladder_match}),
    event_router:register(event_challenge, {?MODULE, proc_challenge}),
    event_router:register(event_divine, {?MODULE, proc_divine}),
    ok.

init_notify() ->
    Info = get_act_lottery_info(),
    packet:send(Info).

%%--------------------------------------------------------------------
%% @doc
%% @spec 缓存存储相关信息
%% @end
%%--------------------------------------------------------------------

get_act_lottery_info() ->
    case get(act_lottery_info) of
        undefined ->
            reset_lottery_info_in_dict();
        LotteryInfo ->
            LotteryInfo
    end.
reset_lottery_info_in_dict() ->
    Info = get_lottery_info_in_cache(),
    put(act_lottery_info, Info),
    Info.

get_lottery_info_in_cache() ->
    case cache_with_expire:get('activity_lottery:lottery_info', player:get_role_id()) of
        [] ->
            ProgreList = init_progre_list(),
            #notify_act_lottery_info{progress_list = ProgreList};
        [{_, Value}] ->
            Value
    end.

init_progre_list() ->
    AllTplt = tplt:get_all_data(act_lottery_tplt),
    [#lottery_progress_item{id = X#act_lottery_tplt.id, cur_count = 0} || X <- AllTplt].

set_lottery_info(NewInfo) ->
    put(act_lottery_info, NewInfo),
    cache:set('activity_lottery:lottery_info', player:get_role_id(), NewInfo, activities:get_act_remain_second(activity_lottery)).

set_lottery_info(NewInfo, notify) ->
    set_lottery_info(NewInfo),
    packet:send(NewInfo).

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求摇奖
%% @end
%%--------------------------------------------------------------------
proc_req_act_lottery(#req_act_lottery{}) ->
    case check_can_lottery() of
        {true, RemainCount, OldInfo} ->
            update_remain_count(RemainCount - 1, OldInfo),
            RewardID = proc_lottery(),
            packet:send(#notify_act_lottery_result{result = ?common_success, reward_id = RewardID});
        false ->
            packet:send(#notify_act_lottery_result{result = ?common_failed})
    end.

proc_lottery() ->
    AllReward = tplt:get_all_data(act_lottery_reward_tplt),
    TotalRate = lists:foldl(fun(X, CurSum) -> X#act_lottery_reward_tplt.rate + CurSum end, 0, AllReward),
    RandNum = rand:uniform(TotalRate),
    RewardInfo = get_reward_info(RandNum, AllReward),
    reward:give(RewardInfo#act_lottery_reward_tplt.ids, RewardInfo#act_lottery_reward_tplt.amounts, ?st_act_lottery),
    RewardInfo#act_lottery_reward_tplt.id.

get_reward_info(_RandNum, []) ->
    erlang:error({act_lottery, get_reward_id, error});
get_reward_info(RandNum, [RewardInfo | AllReward]) ->
    case RandNum =< RewardInfo#act_lottery_reward_tplt.rate of
        true ->
            RewardInfo;
        false ->
            get_reward_info(RandNum - RewardInfo#act_lottery_reward_tplt.rate, AllReward)
    end.

update_remain_count(NewCount, OldInfo) ->
    NewInfo = OldInfo#notify_act_lottery_info{remain_count = NewCount},
    set_lottery_info(NewInfo, notify).

check_can_lottery() ->
    Info = get_act_lottery_info(),
    RemainCount = Info#notify_act_lottery_info.remain_count,
    case RemainCount > 0 andalso is_open() of
        true ->
            {true, RemainCount, Info};
        false ->
            false
    end.

%% 每日登录 ----------------------------------
proc_daily_login(#event_login{}) ->
    case is_open() of
        true ->
            case is_remark_login_today() of
                false ->
                    set_remark_login_today(),
                    ID = 1,
                    process_update(ID, 1);
                true ->
                    ok
            end;
        false ->
            ok
    end.

is_remark_login_today() ->
    get_remark_login_today().
get_remark_login_today() ->
    case cache_with_expire:get('activity_lottery:remark_login_today', player:get_role_id()) of
        [] ->
            false;
        [{_, _Value}] ->
            true
    end.
set_remark_login_today() ->
    cache_with_expire:set('activity_lottery:remark_login_today', player:get_role_id(), 1, day).

%% 月卡用户 ----------------------------------
proc_moon_card_user() ->
    case is_open() of
        true ->
            case is_remark_moon_card_today() of
                false ->
                    case mooncard:is_mooncard_player() of
                        true ->
                            set_remark_moon_card(),
                            ID = 2,
                            process_update(ID, 1);
                        false ->
                            ok
                    end;
                true ->
                    ok
            end;
        false ->
            ok
    end.

is_remark_moon_card_today() ->
    get_remark_moon_card_today().
get_remark_moon_card_today() ->
    case cache_with_expire:get('activity_lottery:remark_moon_card', player:get_role_id()) of
        [] ->
            false;
        [{_, _Value}] ->
            true
    end.
set_remark_moon_card() ->
    cache_with_expire:set('activity_lottery:remark_moon_card', player:get_role_id(), 1, day).

%% 通关1次BOSS挑战 ----------------------------------
proc_game_copy(#event_game_copy{copy_id = CopyId}) ->
    case is_open() of
        true ->
            ID = 3,
            CopyInfo = game_copy:get_copy_info(CopyId),
            case CopyInfo#copy_tplt.type of
            3 -> %% boss
                    process_update(ID, 1);
                _ ->
                    ok
            end;
        false ->
            ok
    end.

%% 通关1次虚空之门 ----------------------------------
proc_activity_copy(#event_activity_copy{result = Rsult}) ->
    case is_open() of
        true ->
            ID = 4,
            case Rsult of
                ?game_win ->
                    process_update(ID, 1);
                _ ->
                    ok
            end;
        false ->
            ok
    end.
%% 通关1次魔塔挑战 ----------------------------------
proc_push_tower(#event_push_tower{result = Rsult}) ->
    case is_open() of
        true ->
            ID = 5,
            case Rsult of
                ?game_win ->
                    process_update(ID, 1);
                _ ->
                    ok
            end;
        false ->
            ok
    end.

%% 训练赛获胜1次 ----------------------------------
proc_train_match(#event_train_match{result = Rsult}) ->
    case is_open() of
        true ->
            ID = 6,
            case Rsult of
                ?game_win ->
                    process_update(ID, 1);
                _ ->
                    ok
            end;
        false ->
            ok
    end.

%% 分组赛获胜1次 ----------------------------------
proc_ladder_match(#event_ladder_match{result = Rsult}) ->
    case is_open() of
        true ->
            ID = 7,
            case Rsult of
                ?game_win ->
                    process_update(ID, 1);
                _ ->
                    ok
            end;
        false ->
            ok
    end.

%% 排位赛获胜1次 ----------------------------------
proc_challenge(#event_challenge{result = Rsult}) ->
    case is_open() of
        true ->
            ID = 8,
            case Rsult of
                ?game_win ->
                    process_update(ID, 1);
                _ ->
                    ok
            end;
        false ->
            ok
    end.

%% 魔石召唤1次 -- 金币召唤10次：当前次数1 ----------------------------------
proc_divine(#event_divine{type = Type, times = Times}) ->
    case is_open() of
        true ->
            ID = case Type of
                     2 ->
                         9;
                     1 ->
                         10
                 end,
            process_update(ID, Times);
        false ->
            ok
    end.

process_update(ID, FinishCount) ->
    Info = get_act_lottery_info(),
    OldCount = get_cur_progress_count(Info, ID),
    TpltInfo = get_tplt(ID),
    NeedCount = TpltInfo#act_lottery_tplt.need_times,
    CurCount = OldCount + FinishCount,
    AddLotteryCount = CurCount div NeedCount,
    NewProcessCount = CurCount rem NeedCount,

    NewItem = #lottery_progress_item{id = ID, cur_count = NewProcessCount},
    NewProsList = modify_item_in_list(#lottery_progress_item.id, Info#notify_act_lottery_info.progress_list, NewItem),
    update_lottery_info(Info#notify_act_lottery_info.remain_count + AddLotteryCount, NewProsList).
%%     case AddLotteryCount of
%%         0 ->
%%
%%          _ ->
%%             NewItem = #lottery_progress_item{id = ID, cur_count = NewProcessCount},
%%             NewProsList = modify_item_in_list(#lottery_progress_item.id, Info#notify_act_lottery_info.progress_list, NewItem),
%%             update_lottery_info(Info#notify_act_lottery_info.remain_count + AddLotteryCount, NewProsList)
%%     end.

update_lottery_info(RemainCount, NewProsList) ->
    set_lottery_info(#notify_act_lottery_info{remain_count = RemainCount, progress_list = NewProsList}, notify).

modify_item_in_list(Index, List, NewItem) ->
    KeyValue = element(Index, NewItem),
    lists:keyreplace(KeyValue, Index, List, NewItem).

get_cur_progress_count(Info, ID) ->
    #notify_act_lottery_info{progress_list = List} = Info,
    case lists:keyfind(ID, #lottery_progress_item.id, List) of
        false ->
            erlang:error({"can't find lottery_progress_item in cache, id:", ID});
        Item ->
            Item#lottery_progress_item.cur_count
    end.

is_open() ->
    activities:is_open(activities:module_to_index(activity_lottery)).

get_tplt(ID) ->
    tplt:get_data(act_lottery_tplt, ID).
