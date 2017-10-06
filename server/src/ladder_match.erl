%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created :  2 Jul 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(ladder_match).

-include("tplt_def.hrl").
-include("packet_def.hrl").
-include("record_def.hrl").
-include("common_def.hrl").
-include("enum_def.hrl").
-include("business_log_def.hrl").
-include("sys_msg.hrl").
-include("event_def.hrl").

-define(is_robot, 1).
-define(is_player, 2).

%% API
-export([start/0,
         notify_ladder_match_info/0
]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc
%% @spec   Module Init Function
%% @end
%%--------------------------------------------------------------------
start() ->
    packet:register(?msg_req_ladder_match_info, {?MODULE, proc_req_ladder_match_info}),
    packet:register(?msg_req_ladder_role_list, {?MODULE, proc_req_ladder_role_list}),
    packet:register(?msg_req_ladder_teammate, {?MODULE, proc_req_ladder_teammate}),
    packet:register(?msg_req_reselect_ladder_teammate, {?MODULE, proc_req_reselect_ladder_teammate}),
    packet:register(?msg_req_ladder_match_battle, {?MODULE, proc_req_ladder_match_battle}),
    packet:register(?msg_req_settle_ladder_match, {?MODULE, proc_req_settle_ladder_match}),
    packet:register(?msg_req_reset_ladder_match, {?MODULE, proc_req_reset_ladder_match}),
    packet:register(?msg_req_recover_teammate_life, {?MODULE, proc_req_recover_teammate_life}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec   通知分组赛相关信息
%% @end
%%--------------------------------------------------------------------
proc_req_ladder_match_info(#req_ladder_match_info{}) ->
    notify_ladder_match_info().

notify_ladder_match_info() ->
    OldInfo = get_ladder_match_info(),
    #notify_ladder_match_info{pass_level = PassLevel, is_failed = IsFailed} = OldInfo,
    FixInfo = case PassLevel =:= 0 andalso IsFailed =:= 0 of
                  true ->
                      io_helper:format("PassLevel:~p~n", [PassLevel]),
                      NewInfo = init_my_life(OldInfo),
                      set_ladder_match_info(NewInfo),
                      NewInfo;
                  false ->
                      OldInfo
              end,
    packet:send(FixInfo).

get_ladder_match_info() ->
    {_Year, _Month, Day} = erlang:date(),
    case get(ladder_match_info) of
        undefined ->
            reset_ladder_match_info_in_dict(Day);
        {MatchInfo, RecordDay} ->
            case RecordDay =:= Day of
                true ->
                    MatchInfo;
                false ->
                    reset_ladder_match_info_in_dict(Day)
            end

    end.
reset_ladder_match_info_in_dict(Day) ->
    Info = get_ladder_match_info_in_cache(),
    put(ladder_match_info, {Info, Day}),
    Info.
get_ladder_match_info_in_cache() ->
    case cache_with_expire:get('ladder_match:ladder_match_info', player:get_role_id()) of
        [] ->
            init_ladder_match_info(0);
        [{_, Value}] ->
            Value#notify_ladder_match_info{reset_count = get_reset_count()}
    end.

init_ladder_match_info(ResetCount) ->
    Info1 = init_my_life(#notify_ladder_match_info{}),
    NewInfo = Info1#notify_ladder_match_info{reset_count = ResetCount},
    set_ladder_match_info(NewInfo),
    NewInfo.

init_my_life(MatchInfo) ->
    friend:set_myinfo_update(),
    RoleInfo = roleinfo_manager:get_roleinfo_from_cache(player:get_role_id()),
    RoleLife = RoleInfo#role_info_detail.battle_prop#role_attr_detail.life,
    MatchInfo#notify_ladder_match_info{cur_life = RoleLife}.

set_ladder_match_info(NewInfo) ->
    {_Year, _Month, Day} = erlang:date(),
    put(ladder_match_info, {NewInfo, Day}),
    redis:hset('ladder_match:ladder_match_info', player:get_role_id(), NewInfo).
%%--------------------------------------------------------------------
%% @doc
%% @spec   get ladder role list
%% @end
%%--------------------------------------------------------------------
proc_req_ladder_role_list(#req_ladder_role_list{}) ->
    notify_ladder_role_list().

notify_ladder_role_list() ->
    #notify_ladder_role_list{opponent = OpponetList, teammate = TeammateList} = get_ladder_role_list(),
    case OpponetList =:= [] of
        true ->
            NewOpponetList = init_opponent(TeammateList),
            packet:send(#notify_ladder_role_list{opponent = NewOpponetList, teammate = TeammateList});
        false ->
            packet:send(#notify_ladder_role_list{opponent = OpponetList, teammate = TeammateList})
    end.

get_ladder_role_list() ->
    {_Year, _Month, Day} = erlang:date(),
    case get(ladder_role_list) of
        undefined ->
            reset_ladder_role_list_in_dict(Day);
        {RoleList, RecordDay} ->
            case RecordDay =:= Day of
                true ->
                    RoleList;
                false ->
                    reset_ladder_role_list_in_dict(Day)
            end

    end.
reset_ladder_role_list_in_dict(Day) ->
    List = get_ladder_role_list_in_cache(),
    put(ladder_role_list, {List, Day}),
    List.
get_ladder_role_list_in_cache() ->
    case cache_with_expire:get('ladder_match:ladder_role_list', player:get_role_id()) of
        [] ->
            #notify_ladder_role_list{};
        [{_, Value}] ->
            Value
    end.

init_opponent(OrgsRoles) ->
    OrgIDs = get_ids_in_ladder_roles(OrgsRoles),
    Opponents = get_opponets_info(OrgIDs ++ [player:get_role_id()], 3),
    set_ladder_role_list(opponet, Opponents),
    Opponents.

get_opponets_info(OrgIDs, Num) ->
    RoleLev = player_role:get_level(),
    OpponentLevel = get_tplt_opponent_level(get_cur_level() + 1),
    FixLevel = case RoleLev + OpponentLevel > config:get(player_max_lev) of
                   true ->
                       config:get(player_max_lev);
                   false ->
                       RoleLev + OpponentLevel
               end,
    RandIDs = rand_role_by_lev(FixLevel, Num),
    ConfirmIDs = RandIDs -- OrgIDs,
    RoleList = gen_player_role_info(ConfirmIDs),
    RobotList = case Num - length(ConfirmIDs) of
                    RobotCount when RobotCount > 0 ->
                        gen_robot_roles_info(FixLevel, RobotCount);
                    _ ->
                        []
                end,
    RoleList ++ RobotList.

rand_role_by_lev(Lev, Amount)->
    Levels = get_enable_lev_list(Lev),
    Amounts = redis_extend:mget_bucket_card('train_match:role_lev_bucket', Levels),
    RandTuple = training_match:make_rand_tuple(Levels, [Amounts]),
    MaxNumber = lists:foldl(fun(X, In) -> X + In end, 0, [Amounts]),
    RandList = lists:foldl(fun(X, In) ->
        case lists:keyfind(X, 1, In) of
            false ->
                [{X, 1}|In];
            Tuple ->
                lists:keyreplace(X, 1, In, {X, element(2, Tuple) + 1})
        end
                           end, [], training_match:get_rand_result(Amount, RandTuple, MaxNumber)),
    %%io:format("~p~n",[RandList]),
    redis_extend:mrand_bucket_member('train_match:role_lev_bucket', RandList).

get_enable_lev_list(Lev) ->
    [Lev].

gen_robot_roles_info(Level, Num) ->
    lists:foldl(fun(_, CurList) ->
        NickName = rand_nickname:rand_nickname(),
        Type = rand:uniform(4),
        BattleInfo = training_match:gen_robot_attr(Level, Type),
        RoleInfo = #ladder_role_info{role_id = uuid:gen(),
                                     data_type = ?is_robot,
                                     curHp = BattleInfo#battle_info.life, nickname = NickName,
                                     battle_power = BattleInfo#battle_info.power, type = Type, level = Level,
                                     battle_prop = BattleInfo,
                                     potence_level = 100, advanced_level = 1,
                                     talent_list = []},
        [RoleInfo | CurList]
                end, [], lists:seq(1, Num)).

gen_player_role_info([]) ->
    [];
gen_player_role_info(RoleIDs) ->
    lists:foldl(fun(RoleID, CurList) ->
        Info = redis:hget(role_info_detail, RoleID),
        NewInfo = roleinfo_manager:upgrade_data(RoleID, Info),
        BattleProp = friend:make_battle_info(NewInfo#role_info_detail.battle_prop),
        RoleInfo = #ladder_role_info{
            role_id = RoleID,
            data_type = ?is_player,
            curHp = BattleProp#battle_info.life,
            battle_prop = BattleProp,
            nickname = NewInfo#role_info_detail.nickname,
            battle_power = NewInfo#role_info_detail.battle_prop#role_attr_detail.battle_power,
            type = NewInfo#role_info_detail.type,
            level = NewInfo#role_info_detail.level,
            potence_level = NewInfo#role_info_detail.potence_level,
            advanced_level = NewInfo#role_info_detail.advanced_level,
            talent_list = talent:get_talent_record_list_by_role_id(RoleID)},
        [RoleInfo | CurList]
                end, [], RoleIDs).

get_cur_level() -> %%获取当前关卡记录
    #notify_ladder_match_info{pass_level = CurLev} = get_ladder_match_info(),
    CurLev.

set_ladder_role_list(NewList) ->
    {_Year, _Month, Day} = erlang:date(),
    put(ladder_role_list, {NewList, Day}),
    redis:hset('ladder_match:ladder_role_list', player:get_role_id(), NewList),
    NewList.

set_ladder_role_list(opponet, Opponet_list) ->
    OldList = get_ladder_role_list(),
    NewList = OldList#notify_ladder_role_list{opponent = Opponet_list},
    set_ladder_role_list(NewList);

set_ladder_role_list(teammate, Teammates) ->
    OldList = get_ladder_role_list(),
    NewList = OldList#notify_ladder_role_list{teammate = Teammates},
    set_ladder_role_list(NewList).


%%--------------------------------------------------------------------
%% @doc
%% @spec   gen teammate
%% @end
%%--------------------------------------------------------------------
proc_req_ladder_teammate(_Packet) ->
    case check_is_unlock() of
        true ->
            case check_teammate_is_full() of
                true ->
                    packet:send(#notify_req_ladder_teammate_result{result = ?common_failed});
                {false, OrgIDs} ->
                    TeammateInfo = gen_teammate_info(OrgIDs  ++ [player:get_role_id()]),
                    add_to_teammate_list(TeammateInfo),
                    packet:send(#notify_req_ladder_teammate_result{result = ?common_success, teammate_info = TeammateInfo})
            end;
        false ->
            packet:send(#notify_req_ladder_teammate_result{result = ?common_failed})
    end.

check_teammate_is_full() ->
    #notify_ladder_role_list{teammate = TeamMates, opponent = Opponets} = get_ladder_role_list(),
    case length(TeamMates) >= 2 of
        true ->
            true;
        false ->
            {false, get_ids_in_ladder_roles(TeamMates ++ Opponets)}
    end.

get_ids_in_ladder_roles(RolesInfo) ->
    case RolesInfo of
        [] ->
            [];
        _ ->
            [RoleId || #ladder_role_info{role_id = RoleId} <- RolesInfo]
    end.

add_to_teammate_list(TeammateInfo) ->
    #notify_ladder_role_list{teammate = TeamMates, opponent = Opponets} = get_ladder_role_list(),
    NewList = #notify_ladder_role_list{teammate = [TeammateInfo | TeamMates], opponent = Opponets},
    set_ladder_role_list(NewList).

%%--------------------------------------------------------------------
%% @doc
%% @spec   reslect teammate
%% @end
%%--------------------------------------------------------------------
proc_req_reselect_ladder_teammate(#req_reselect_ladder_teammate{role_id = RoleID}) ->
    case check_is_unlock() of
        true ->
            #notify_ladder_role_list{teammate = TeamMates, opponent = Opponets} = get_ladder_role_list(),
            NeedMoney = config:get(ladder_match_change_partner_cost),
            case check_can_reselect(RoleID, TeamMates, NeedMoney)  of
                false ->
                    packet:send(#notify_reselect_ladder_teammate_result{});
                true ->
                    Orgids = get_ids_in_ladder_roles(Opponets ++ TeamMates),
                    TeammateInfo = gen_teammate_info(Orgids  ++ [player:get_role_id()]),
                    NewMates = lists:keyreplace(RoleID, #ladder_role_info.role_id, TeamMates, TeammateInfo),
                    set_ladder_role_list(teammate, NewMates),
                    player_role:reduce_emoney(?st_ladder_role_reselect, config:get(ladder_match_change_partner_cost)),
                    packet:send(#notify_reselect_ladder_teammate_result{teammate_info = TeammateInfo})
            end;
        false ->
            packet:send(#notify_reselect_ladder_teammate_result{})
    end.

check_can_reselect(RoleID, TeamMates, NeedMoney) ->
    case check_teammate_in_list(RoleID, TeamMates) andalso (not is_played()) of
        true ->
            case player_role:check_emoney_enough(NeedMoney) of
                true ->
                    true;
                false ->
                    false
            end;
        false ->
            false
    end.

is_played() ->
    #notify_ladder_match_info{pass_level = PassLevel, is_failed = IsFaield} = get_ladder_match_info(),
    PassLevel + IsFaield > 0.

gen_teammate_info(OrgIDs) ->
    RoleLev = player_role:get_level(),
    RandIDs = training_match:rand_role_by_lev(RoleLev, 1),
    ConfirmIDs = RandIDs -- OrgIDs,
    RoleList = case ConfirmIDs of
                    [] ->
                        gen_robot_roles_info(RoleLev, 1);
                    _ ->
                        gen_player_role_info(ConfirmIDs)
                end,
    lists:nth(1, RoleList).

check_teammate_in_list(RoleID, TeamMates) ->
    case lists:keyfind(RoleID, #ladder_role_info.role_id, TeamMates) of
        false ->
            false;
        _ ->
            true
    end.

check_is_unlock() ->
    NeedPassCopyID = game_copy:get_func_unlock_need_copy_id(21),
    game_copy:check_copy_has_passed(NeedPassCopyID).


%%--------------------------------------------------------------------
%% @doc
%% @spec   请求分组赛战斗
%% @end
%%--------------------------------------------------------------------
proc_req_ladder_match_battle(_Packet) ->
    case check_is_unlock() of
        true ->
            case check_can_play() of
                true ->
                    LadderRoles =  #notify_ladder_role_list{teammate=Teammates, opponent=Opponents} = get_ladder_role_list(),
                    RoleInfo = player_role:get_db_role(player:get_role_id()),
                    Copy = challenge:get_ranking_copy(RoleInfo:level()),
                    Map = get_ranking_map_info(Copy, LadderRoles),
                    GameId = uuid:gen(),
                    RoleIDs = get_ids_in_ladder_roles(Opponents ++ Teammates),
                    set_cur_train_info({GameId, RoleIDs}, Map),
                    OldInfo = get_ladder_match_info(),
                    set_ladder_match_info(OldInfo#notify_ladder_match_info{is_failed = 1}),
                    packet:send(#notify_ladder_match_battle_result{map = [Map], result = ?common_success, game_id = GameId});
                false ->
                    sys_msg:send_to_self(?sg_ladder_match_times_exceeded, []),
                    packet:send(#notify_ladder_match_battle_result{result = ?common_failed})
            end;
        false ->
            packet:send(#notify_ladder_match_battle_result{result = ?common_failed}),
            sys_msg:send_to_self(?sg_game_copy_not_pass, [])
    end.

get_ranking_map_info(CopyInfo, LadderRoles) ->
    Mostters = challenge:get_monsters(CopyInfo),
    [Scene] = rand:rand_members_from_list(CopyInfo#ranking_copy_tplt.scene, 1),
    Traps = challenge:get_traps(CopyInfo),
    Friends = challenge:get_friends(CopyInfo),
    Awards = challenge:get_awards(CopyInfo),
    #notify_ladder_role_list{teammate=Teammates, opponent=Opponents} = LadderRoles,
    MyMates = tran_to_senemy(Teammates, 0, 0),
    LeaderInfo = lists:nth(1, Opponents),
    MyOpponents = tran_to_senemy(Opponents, 1, LeaderInfo#ladder_role_info.role_id),
    Enemies = MyMates ++ MyOpponents,
    game_copy:create_ranking_copy(Mostters, Traps, Friends, Awards,
                                  Scene, CopyInfo#ranking_copy_tplt.barrier_amount, Enemies).

tran_to_senemy(LadderRoles, TeamTag, LeaderID) ->
    lists:foldl(
        fun(RoleInfo, CurList) ->
            IsLeader = case LeaderID =:= RoleInfo#ladder_role_info.role_id of
                           true ->
                               1;
                           false ->
                               0
                       end,
            Senemy = #senemy{
                role_id = RoleInfo#ladder_role_info.role_id,
                name = RoleInfo#ladder_role_info.nickname,
                type = RoleInfo#ladder_role_info.type,
                level = RoleInfo#ladder_role_info.level,
                cur_life = RoleInfo#ladder_role_info.curHp,
                battle_prop = RoleInfo#ladder_role_info.battle_prop,
                potence_level = RoleInfo#ladder_role_info.potence_level,
                advanced_level = RoleInfo#ladder_role_info.advanced_level,
                talent_list = RoleInfo#ladder_role_info.talent_list,
                id_leader = IsLeader,
                team_tag = TeamTag},
            [Senemy | CurList]
        end, [], LadderRoles).

set_cur_train_info(ExtraInfo, Info) ->
    cache:set('ladder_match:map_information', player:get_role_id(), {ExtraInfo, Info}).

check_can_play() ->
    Max = length(tplt:get_all_data(ladder_match_level_tplt)),
    #notify_ladder_match_info{is_failed = IsFailed, pass_level = PassLev} = get_ladder_match_info(),
    IsFailed =:= 0 andalso PassLev < Max.
%% false.
%%--------------------------------------------------------------------
%% @doc
%% @spec   请求分组赛结算
%% @end
%%--------------------------------------------------------------------
proc_req_settle_ladder_match(#req_settle_ladder_match{game_id = GameID, life_info = LifeInfo, result = Result}) ->
    case check_is_unlock() of
        true ->
            event_router:send_event_msg(#event_ladder_match{result = Result}),
            case check_if_legal(GameID, Result) of
                {true, {{_, EnemyIds}, MapInfo}} ->
                    activeness_task:update_activeness_task_status(ladder_match),
                    {IDs, Amounts} = settle_ladder_against(GameID, Result, EnemyIds, MapInfo, LifeInfo),
                    packet:send(#notify_settle_ladder_match{result = Result, reward_ids = IDs, reward_amounts = Amounts}),
                    clear_cur_train_info(),
                    log:create(business_log, [player:get_role_id(), 0, ?bs_ladder_match, ?PVP, erlang:localtime(), erlang:localtime(), 0]),
                    ok;
                Result1 ->
                    packet:send(#notify_settle_ladder_match{result = Result1})
            end
    end.

settle_ladder_against(_GameId, Result, _EnemyIds, _MapInfo, LifeInfo) ->
    CurLadderInfo = get_ladder_match_info(),
    RoleList = get_ladder_role_list(),
    check_life_info(LifeInfo, RoleList),
    %%FixLifeInfo = fix_life_info(LifeInfo),
    {IDs, Amounts} = case Result of
                         ?game_win ->
                             NewLevel = CurLadderInfo#notify_ladder_match_info.pass_level + 1,
                             update_ladder_match_info(CurLadderInfo, LifeInfo, 0, NewLevel),
                             give_reward(NewLevel);
                         ?game_lost ->
                             update_ladder_match_info(CurLadderInfo, LifeInfo, 1, CurLadderInfo#notify_ladder_match_info.pass_level),
                             {[], []}
                     end,
    update_ladder_role_hp(LifeInfo, Result, RoleList),
    {IDs, Amounts}.

check_life_info(LifeInfo, RoleList) ->
    #notify_ladder_role_list{teammate = OldMates} = RoleList,
    lists:map(
        fun(RoleInfo) ->
            case lists:keyfind(RoleInfo#ladder_role_info.role_id, #role_life_info.role_id, LifeInfo) of
                false ->
                    erlang:error({role_life_info, lack_life, RoleInfo#ladder_role_info.role_id});
                CurLifeItem ->
                    case CurLifeItem#role_life_info.cur_life =< RoleInfo#ladder_role_info.battle_prop#battle_info.life of
                        true ->
                            ok;
                        false ->
                            erlang:error({role_life_info, life_error, RoleInfo#ladder_role_info.role_id})
                    end
            end
        end, OldMates).

%% fix_life_info(Info) ->
%%     RecoverRate = config:get(ladder_match_recover_rate),
%%     lists:map(
%%         fun(X) ->
%%             case X#role_life_info.cur_life of
%%                 0 ->
%%                     X#role_life_info{cur_life = 1};
%%                 _ ->
%%                     X#role_life_info{cur_life = trunc(X#role_life_info.cur_life * (1 + RecoverRate))}
%%             end
%%         end, Info).

give_reward(LevelID) ->
    {IDs, Amounts} = get_reward_info(LevelID),
    reward:give(IDs, Amounts, ?st_ladder_against_win),
    {IDs, Amounts}.

get_reward_info(LevelID) ->
    AllTplt = tplt:get_all_data(ladder_match_reward_tplt),
    LevelRewards = filter_list_in_role_level(#ladder_match_reward_tplt.role_level_range, player_role:get_level(), AllTplt),
    [#ladder_match_reward_tplt{ids = Ids, amounts = Amounts}] = filter_list_by_level(#ladder_match_reward_tplt.level_id, LevelID, LevelRewards),
    {Ids, Amounts}.

filter_list_in_role_level(Index, RoleLevel, List) ->
    lists:filter(
        fun(X) ->
            [Min, Max] = element(Index, X),
            RoleLevel >= Min andalso RoleLevel =< Max
        end,
        List).

filter_list_by_level(Index, LevelID, List) ->
    lists:filter(
        fun(X) ->
            LevelID =:= element(Index, X)
        end,
        List).

update_ladder_match_info(CurLadderInfo, LifeInfo, IsFailed, NewLevel) ->
    MyLife = cal_my_cur_life(player:get_role_id(), LifeInfo),
    NewMatchInfo = CurLadderInfo#notify_ladder_match_info{
        cur_life = MyLife,
        is_failed = IsFailed,
        pass_level = NewLevel},
    set_ladder_match_info(NewMatchInfo),
    packet:send(NewMatchInfo).

cal_my_cur_life(RoleID, LifeInfoList) ->
    case lists:keyfind(RoleID, #role_life_info.role_id, LifeInfoList) of
        false ->
            erlang:error({role_life_info, id, RoleID});
        LifeInfo ->
            RoleInfo = roleinfo_manager:get_roleinfo_from_cache(player:get_role_id()),
            RoleLife = RoleInfo#role_info_detail.battle_prop#role_attr_detail.life,
            cal_recover_life(LifeInfo#role_life_info.cur_life, RoleLife)
    end.

update_ladder_role_hp(LifeInfo, Result, RoleList) ->
    #notify_ladder_role_list{teammate = OldMates, opponent = OldOps} = RoleList,
    NewMates = lists:foldl(
        fun(RoleInfo, CurList) ->
            case lists:keyfind(RoleInfo#ladder_role_info.role_id, #role_life_info.role_id, LifeInfo) of
                false ->
                    [RoleInfo | CurList];
                CurLifeItem ->
                    CurLife = cal_recover_life(CurLifeItem#role_life_info.cur_life, RoleInfo#ladder_role_info.battle_prop#battle_info.life),
%%                     CurLife = case CurLifeItem#role_life_info.cur_life =< RoleInfo#ladder_role_info.battle_prop#battle_info.life of
%%                                   true ->
%%                                       CurLifeItem#role_life_info.cur_life;
%%                                   false ->
%%                                       RoleInfo#ladder_role_info.battle_prop#battle_info.life
%%                               end,
                    NewRole = RoleInfo#ladder_role_info{curHp = CurLife},
                    [NewRole | CurList]
            end
        end, [], OldMates),
    NewList = case Result of
                  ?game_win ->
                      IDs =get_ids_in_ladder_roles(OldMates),
                      NewOppoents = init_opponent(IDs ++ [player:get_role_id()]),
                      #notify_ladder_role_list{teammate = NewMates, opponent = NewOppoents};
                  ?game_lost ->
                      #notify_ladder_role_list{teammate = NewMates, opponent = OldOps}
              end,
    set_ladder_role_list(NewList),
    packet:send(NewList).

cal_recover_life(CurLife, MaxLife) ->
    RecoverdLife = CurLife + trunc(MaxLife * config:get(ladder_match_recover_rate)),
    FinalLife = case CurLife =:= 0 of
                    true ->
                        1;
                    false ->
                        case RecoverdLife > MaxLife of
                            true ->
                                MaxLife;
                            false ->
                                RecoverdLife
                        end
                end,
    io_helper:format("CurLife:~p  MaxLife:~p  FinalLife:~p~n", [CurLife, MaxLife, FinalLife]),
    FinalLife.

check_if_legal(GameId, _Result) ->
    case get_cur_train_info() of
        [] ->
            sys_msg:send_to_self(?sg_ladder_match_settle_error, []),
            ?game_error;
        {{GameId, RoleIDs}, Info} ->
            {true, {{GameId, RoleIDs}, Info}};
        _ ->
            sys_msg:send_to_self(?sg_ladder_match_settle_error, []),
            clear_cur_train_info(),
            ?game_error
    end.

get_cur_train_info() ->
    case cache:get('ladder_match:map_information', player:get_role_id()) of
        [Result] ->
            element(2, Result);
        Other ->
            Other
    end.


clear_cur_train_info() ->
    cache:delete('ladder_match:map_information', player:get_role_id()).

%%--------------------------------------------------------------------
%% @doc
%% @spec   请求分组赛重置
%% @end
%%--------------------------------------------------------------------
proc_req_reset_ladder_match(#req_reset_ladder_match{}) ->
   case  check_can_reset() of
       {true, Count} ->
%%            case NeedEmoney > 0  of
%%                true ->
%%                    player_role:reduce_emoney(?st_ladder_match_reset, NeedEmoney);
%%                false ->
%%                    ok
%%            end,
%%            set_reset_count(Count + 1),
           process_reset_ladder(Count + 1),
           packet:send(#notify_reset_ladder_match_result{result = ?common_success});
       false ->
           packet:send(#notify_reset_ladder_match_result{result = ?common_failed})
   end.

process_reset_ladder(NewCount) ->
    MatchInfo = init_ladder_match_info(NewCount),
    set_reset_count(NewCount),
    set_ladder_match_info(MatchInfo),
    packet:send(MatchInfo),

    Ops = get_opponets_info([player:get_role_id()],3),
    NewList = #notify_ladder_role_list{opponent = Ops},
    set_ladder_role_list(NewList),
    packet:send(NewList).

check_can_reset() ->
    %%#notify_ladder_match_info{reset_count = Count} = get_ladder_match_info(),
    Count = get_reset_count(),
    case Count >= config:get(ladder_match_can_reset_free_count) + vip:get_privilege_count(3) of
        true ->
%%             case vip:get_level() > 0  andalso Count < config:get(ladder_match_vip_can_reset_count) of
%%                 true ->
%%                     NeedMoney = config:get(ladder_match_reset_need_emoney),
%%                     case player_role:check_emoney_enough(NeedMoney) of
%%                         true ->
%%                             {true, Count, NeedMoney};
%%                         false ->
%%                             false
%%                     end;
%%                 false ->
%%                     false
%%             end;
            false;
        false ->
            {true, Count}
    end.

get_reset_count() ->
    case cache_with_expire:get('ladder_match:reset_count', player:get_role_id()) of
        [] ->
            0;
        [{_, Value}] ->
            Value
    end.

set_reset_count(Count) ->
    cache_with_expire:set('ladder_match:reset_count', player:get_role_id(), Count, day).

%%--------------------------------------------------------------------
%% @doc
%% @spec   请求恢复全员生命
%% @end
%%--------------------------------------------------------------------
proc_req_recover_teammate_life(#req_recover_teammate_life{}) ->
    case  check_can_recover() of
        {true, NeedEmoney, CurCount} ->
            case NeedEmoney > 0  of
                true ->
                    player_role:reduce_emoney(?st_ladder_role_recover_life, NeedEmoney);
                false ->
                    ok
            end,
            set_recover_count_and_recover_life(CurCount + 1),
            packet:send(#notify_recover_teammate_life_result{result = ?common_success});
        false ->
            packet:send(#notify_recover_teammate_life_result{result = ?common_failed})
    end.

check_can_recover() ->
    CurCount = get_recover_count(),
    case CurCount >= config:get(ladder_match_recover_free_count) of
        true ->
            NeedEmoney = config:get(ladder_match_recover_need_emoney),
            PlayerEmoney = player_role:get_emoney(),
            case PlayerEmoney >= NeedEmoney of
                true ->
                    {true, NeedEmoney, CurCount};
                false ->
                    false
            end;
        false ->
            {true,0, CurCount}
    end.

get_recover_count() ->
    #notify_ladder_match_info{recover_count = Recount} = get_ladder_match_info(),
    Recount.

set_recover_count_and_recover_life(Count) ->
    MatchInfo = get_ladder_match_info(),
    MatchInfo2 = init_my_life(MatchInfo),
    NewMatchInfo = MatchInfo2#notify_ladder_match_info{recover_count = Count},
    set_ladder_match_info(NewMatchInfo),
    packet:send(NewMatchInfo),

    #notify_ladder_role_list{teammate = OldTeammates} = get_ladder_role_list(),
    NewTeammates = lists:foldl(
        fun(Role, CurList) ->
            NewRole = Role#ladder_role_info{curHp = Role#ladder_role_info.battle_prop#battle_info.life},
            [NewRole | CurList]
        end, [], OldTeammates),

    NewList = set_ladder_role_list(teammate, lists:reverse(NewTeammates)),
    packet:send(NewList).

%%--------------------------------------------------------------------
%% @doc
%% @spec   模板相关
%% @end
%%--------------------------------------------------------------------

get_tplt(ID) ->
    tplt:get_data(ladder_match_level_tplt, ID).

get_tplt_opponent_level(ID) ->
    TpltInfo = try
                   get_tplt(ID)
               catch
                   _:_Reason ->
                       lists:max(tplt:get_all_data(ladder_match_level_tplt))
               end,
    TpltInfo#ladder_match_level_tplt.match_opponent_level.

del() ->
    lists:foreach(
        fun(Number)->
            Name = list_to_atom(lists:concat(['train_match:role_lev_bucket:bucket:', Number])),
            cache:delete(Name)
        end,
        lists:seq(1,1000)),
    ok.