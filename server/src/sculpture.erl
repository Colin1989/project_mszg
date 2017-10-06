%%% @author hongjx <>
%%% @copyright (C) 2014, hongjx
%%% @doc
%%%  符文相关操作
%%% @end
%%% Created :  5 Mar 2014 by hongjx <>

-module(sculpture).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").
-include("event_def.hrl").

-compile(export_all). %% 测试用

-export([start/0,
         notify_divine_info/0,
         set_skill_group_info/4,
         notify_skill_groups_info/0,
         get_cur_skill_group_info/0,
         init_sculpture/2,
         get_activate_group/0,
         add/2
	]).

-define(add_sculpture, 1).

start() ->
    %% 请求符文列表
    packet:register(?msg_req_sculpture_divine, {?MODULE, proc_req_sculpture_divine}),
    packet:register(?msg_req_sculpture_upgrade, {?MODULE, proc_req_sculpture_upgrade}),
    packet:register(?msg_req_sculpture_unlock, {?MODULE, proc_req_sculpture_unlock}),
    packet:register(?msg_req_sculpture_advnace, {?MODULE, proc_req_sculpture_advance}),
    packet:register(?msg_req_sculpture_puton, {?MODULE, proc_req_sculpture_puton}),
    packet:register(?msg_req_sculpture_takeoff, {?MODULE, proc_req_sculpture_takeoff}),
    packet:register(?msg_req_change_skill_group, {?MODULE, proc_req_change_skill_group}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 玩家创建角色 初始化技能相关
%% @end
%%--------------------------------------------------------------------
init_sculpture(RoleID, IDs) ->
    SkillGroups = [#skill_group_item{id1 = lists:nth(1, IDs), id2 = lists:nth(2, IDs),
                                     id3 = lists:nth(3, IDs), id4 = lists:nth(4, IDs), index = 1}],
    set_groups_info(RoleID, SkillGroups),
    redis:hset("sculpture:activate_group", RoleID, 1),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 通知占卜信息
%% @end
%%--------------------------------------------------------------------
notify_divine_info() ->
    {Count, RemainTime} = get_common_once_divined_count(),
    io_helper:format("Count:~p~n", [Count]),
    RareFreeRemainTime = get_free_rare_one_remain_time(),
    packet:send(#notify_divine_info{count=config:get(divine_common_free_time) - Count, common_remain_time=RemainTime, rare_remain_time=RareFreeRemainTime}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 获取技能组信息
%% @end
%%--------------------------------------------------------------------
notify_skill_groups_info() ->
    SkillGroups = get_groups_info(),
    packet:send(#notify_skill_groups_info{groups = SkillGroups}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 获取当前技能组信息
%% @end
%%--------------------------------------------------------------------
get_cur_skill_group_info() ->
    ActiveGroup = get_activate_group(),
    SkillGroups = get_groups_info(),
    get_skill_group_info(ActiveGroup, SkillGroups).

get_cur_skill_group_info(RoleID) ->
    case player:get_role_id() =:= RoleID of
        true ->
            get_cur_skill_group_info();
        false ->
            get_cur_skill_group_info_by_RoleID(RoleID)
    end.

get_cur_skill_group_info_by_RoleID(RoleID) ->
    ActiveGroup = get_activate_group(RoleID),
    SkillGroups = get_groups_info(RoleID),
    get_skill_group_info(ActiveGroup, SkillGroups).

get_sculpture_tempid_and_lev(TempID) ->
    case sculpture_pack:get_item_by_tempid(TempID) of
        undefined ->
            #sculpture_data{};
        SculptureInfo ->
            #sculpture_data{temp_id = TempID, level = SculptureInfo:value()}
    end.

get_sculpture_tempid_and_lev_by_role_id(RoleID,TempID) ->
    case sculpture_pack:get_item_by_tempid(RoleID, TempID) of
        undefined ->
            #sculpture_data{};
        SculptureInfo ->
            #sculpture_data{temp_id = TempID, level = SculptureInfo:value()}
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 更新缓存信息
%% @end
%%--------------------------------------------------------------------
update_cur_scuplture_info() ->
    #skill_group_item{id1 = ID1, id2 = ID2, id3 = ID3, id4 = ID4} = get_cur_skill_group_info(),
    Sculptures = [ID1, ID2, ID3, ID4],
    SculptureInfo = lists:map(
        fun(X) ->
            case X of
                0 ->
                    #sculpture_data{};
                _ ->
                    get_sculpture_tempid_and_lev(X)
            end
        end, Sculptures),
    friend:set_sculpture_update(SculptureInfo).

%%--------------------------------------------------------------------
%% @doc
%% @spec 添加技能
%% @end
%%--------------------------------------------------------------------
add(SourceType, TempID) ->
    case check_reward_skill_or_frags(TempID) of
        frags_add ->
            SkillInfo = get_tplt(TempID),
            sculpture_pack:add_frags(SourceType, [{SkillInfo#skill_tplt.unlock_need_id, SkillInfo#skill_tplt.equal_frags_amount}]);
        skill_add ->
            sculpture_pack:create_sculpture_and_save(SourceType, ?item_sculpture, TempID, 1);
        {skill_modify, OldID}->
            sculpture_pack:modify_temp_id(SourceType, OldID, TempID)
    end.

check_reward_skill_or_frags(TempID) ->
    case check_same_group_skill(TempID) of
        false ->
            skill_add;
        _SameGroupSkillID ->
%%             case SameGroupSkillID < TempID of
%%                 true ->
%%                     {skill_modify, SameGroupSkillID};
%%                 false ->
%%                     frags_add
%%             end
            frags_add
    end.

check_same_group_skill(TempID) ->
    SameGroSkills = get_same_group_skills(TempID),
    AllSkill = sculpture_pack:get_all_skill(),
    io_helper:format("AllSkill:~p~n", [AllSkill]),
    find_same_group_skill(SameGroSkills, AllSkill).

find_same_group_skill([], _AllSkill) ->
    false;
find_same_group_skill([CheckID | SameGroSkills], AllSkill) ->
    case lists:any(fun(E) -> CheckID =:= E end, AllSkill) of
        true ->
            CheckID;
        false ->
            find_same_group_skill(SameGroSkills, AllSkill)
    end.

get_same_group_skills(TempID) ->
    AllTpltSkill = tplt:get_all_data(skill_tplt),
    SkillTpltInfo = case lists:keyfind(TempID, #skill_tplt.id, AllTpltSkill) of
        false ->
             erlang:error({"skill temp_id error, id:", TempID});
        Info ->
            Info
    end,
    lists:foldl(
        fun(E, Container) ->
            case E#skill_tplt.skill_group =:= SkillTpltInfo#skill_tplt.skill_group of
                true ->
                    [E#skill_tplt.id | Container];
                false ->
                    Container
            end
        end, [], AllTpltSkill).
%%--------------------------------------------------------------------
%% @doc
%% @spec 技能占卜
%% @end
%%--------------------------------------------------------------------
proc_req_sculpture_divine(#req_sculpture_divine{type = Type}) ->
    case Type of
        ?divine_common_once ->
            NeedGold = config:get(divine_common_once_cost),
            {CurCount, RemainTime} = get_common_once_divined_count(),
            do_common_once(NeedGold, CurCount, RemainTime);
        ?divine_common_ten ->
            NeedGold = config:get(divine_common_ten_cost),
            do_common_ten(NeedGold);
        ?divine_rare_once ->
            NeedEmoney = config:get(divine_rare_once_need_emoney),
            FreeRemainTime = get_free_rare_one_remain_time(),
            do_rare_once(NeedEmoney, FreeRemainTime);
        ?divine_rare_ten ->
            NeedEmoney = config:get(divine_rare_ten_need_emoney),
            do_rare_ten(NeedEmoney)
    end,
    ok.

%% 普通单次处理------------------------
do_common_once(NeedGold, CurCount, RemainTime) ->
    case check_common_once(NeedGold ,CurCount) of
        true ->
            RewardList = gen_reward_list(1),
            do_give_rewards(RewardList, ?st_sculpture_divine),
            case RemainTime =< 0 andalso CurCount < config:get(divine_common_free_time) of
                true ->
                    set_common_once_divined_count(CurCount + 1);
                false ->
                    player_role:reduce_gold(?st_sculpture_divine, NeedGold)
            end,
            event_router:send_event_msg(#event_divine{times = 1, type = 1}),
            packet:send(#notify_sculpture_divine{result = ?common_success, reward_list = RewardList, type = ?divine_common_once});
        false ->
            packet:send(#notify_sculpture_divine{result = ?common_failed, type = ?divine_common_once})
    end,
    ok.
check_common_once(NeedGold, CurCount) ->
player_role:check_gold_enough(NeedGold) orelse CurCount < config:get(divine_common_free_time).

get_common_once_divined_count() ->
    case redis:hget("sculpture:common_once_divined", player:get_role_id()) of
        undefined ->
            {0, 0};
        {Count, DateTime} ->
            PassTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()) - datetime:datetime_to_gregorian_seconds(DateTime),
            RemainTime = case config:get(divine_common_free_interval_time) - PassTime of
                             Time when Time > 0 ->
                                 Time;
                             _ ->
                                 0
                         end,
            {Count, RemainTime}
    end.

set_common_once_divined_count(NewCount) ->
    cache_with_expire:set("sculpture:common_once_divined", player:get_role_id(), {NewCount, erlang:localtime()}, day).

%% 普通10次处理----------------------
do_common_ten(NeedGold) ->
    case check_common_ten(NeedGold) of
        true ->
            RewardList = gen_reward_list(2),
            do_give_rewards(RewardList, ?st_sculpture_divine),
            player_role:reduce_gold(?st_sculpture_divine, NeedGold),
            event_router:send_event_msg(#event_divine{times = 10, type = 1}),
            packet:send(#notify_sculpture_divine{result = ?common_success, reward_list = RewardList, type = ?divine_common_ten});
        false ->
            packet:send(#notify_sculpture_divine{result = ?common_failed, type = ?divine_common_ten})
    end,
    ok.
check_common_ten(NeedGold) ->
    player_role:check_gold_enough(NeedGold).

%% 稀有单次处理---------------------------
do_rare_once(NeedEmoney, FreeRemainTime) ->
    case check_rare_once(NeedEmoney, FreeRemainTime) of
        true ->
            DoRareCount = get_rare_count(),
            RewardList = case DoRareCount > 0 of
                             true ->
                                 gen_reward_list(3);
                             false ->
                                 redis:hset("sculpture:rare_one_count", player:get_role_id(), 1),
                                 FirstDivineInfo = get_divine_reward_tplt(99),
                                 [#reward_item{id = lists:nth(1, FirstDivineInfo#divine_reward_tplt.ids),
                                               amount = lists:nth(1, FirstDivineInfo#divine_reward_tplt.amounts)}]
                         end,
            io_helper:format("RewardList:~p~n", [RewardList]),
            do_give_rewards(RewardList, ?st_sculpture_divine),
            case FreeRemainTime > 0 of
                true ->
                    player_role:reduce_emoney(?st_sculpture_divine, NeedEmoney);
                false ->
                    set_free_rare_once_time()
            end,
            event_router:send_event_msg(#event_divine{times = 1, type = 2}),
            packet:send(#notify_sculpture_divine{result = ?common_success, reward_list = RewardList, type = ?divine_rare_once});
        false ->
            packet:send(#notify_sculpture_divine{result = ?common_failed, type = ?divine_rare_once})
    end,
    ok.

get_rare_count() ->
    case redis:hget("sculpture:rare_one_count", player:get_role_id()) of
        undefined ->
            0;
        Count ->
            Count
    end.

check_rare_once(NeedEmoney, FreeRemainTime) ->
    player_role:check_emoney_enough(NeedEmoney) orelse FreeRemainTime =:= 0.

get_free_rare_one_remain_time() ->
    case redis:hget("sculpture:free_rare_one_time", player:get_role_id()) of
        undefined ->
            0;
        DateTime ->
            PassTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()) - datetime:datetime_to_gregorian_seconds(DateTime),
            case config:get(divine_rare_free_interval_time) - PassTime of
                    Time when Time > 0 ->
                        Time;
                    _ ->
                        0
            end
    end.

set_free_rare_once_time() ->
redis:hset("sculpture:free_rare_one_time", player:get_role_id(), erlang:localtime()).

%% 稀有10次处理--------------------------
do_rare_ten(NeedEmoney) ->
    case check_rare_ten(NeedEmoney) of
        true ->
            RewardList = gen_reward_list(4),
            do_give_rewards(RewardList, ?st_sculpture_divine),
            player_role:reduce_emoney(?st_sculpture_divine, NeedEmoney),
            event_router:send_event_msg(#event_divine{times = 10, type = 2}),
            packet:send(#notify_sculpture_divine{result = ?common_success, reward_list = RewardList, type = ?divine_rare_ten});
        false ->
            packet:send(#notify_sculpture_divine{result = ?common_failed, type = ?divine_rare_ten})
    end,
    ok.
check_rare_ten(NeedEmoney) ->
    player_role:check_emoney_enough(NeedEmoney).

do_give_rewards(RewardList, Type) ->
    Rewards = lists:foldl(
        fun(E, Container) ->
            MergeID = E#reward_item.id,
            MergeAmount = E#reward_item.amount,
            [[MergeID | lists:nth(1, Container)], [MergeAmount | lists:nth(2, Container)]]
        end, [[], []], RewardList),
reward:give(lists:nth(1, Rewards), lists:nth(2, Rewards), Type).

gen_reward_list(Type) ->
    DivineTplt = tplt:get_all_data(skill_divine_tplt),
    Tplt1 = lists:filter(
        fun(E) ->
            E#skill_divine_tplt.type =:= Type
            end,
        DivineTplt
    ),
    Level = player_role:get_level(),
    List = get_group_list(Tplt1, Level),
    MergeList = gen_rewards(List),
    lists:map(
        fun(E) ->
            #reward_item{id = element(1, E), amount = element(2, E)}
        end, MergeList).

get_group_list([Tplt | TpltList], Level) ->
    MinLevel = lists:nth(1, Tplt#skill_divine_tplt.level_interval),
    MaxLevel = lists:nth(2, Tplt#skill_divine_tplt.level_interval),
    case Level >= MinLevel andalso Level =< MaxLevel of
        true ->
            Tplt#skill_divine_tplt.reward_group_list;
        false ->
            get_group_list(TpltList, Level)
    end.

gen_rewards(List) ->
    RewardList = lists:map(
        fun(E) ->
            ID = element(1, E),
            Times = element(2, E),
            get_rand_item(ID, Times)
        end,
        List
    ),
lists:flatten(RewardList).
%%    merge_item_list(List2).

merge_item_list(List) ->
    lists:foldl(
        fun(E, Container) ->
            MergeID = element(1, E),
            MergeAmount = element(2, E),
            case lists:keyfind(MergeID, 1, Container) of
                {FindID, Amount} ->
                    lists:keyreplace(FindID, 1, Container, {FindID, Amount + MergeAmount});
                false ->
                    [{MergeID, MergeAmount} | Container]
            end
        end, [], List).

get_rand_item(ID, Times) ->
    TpltInfo = get_divine_reward_tplt(ID),
    L = lists:seq(1, Times),
    lists:map(
    fun(_E) ->
        IDs = TpltInfo#divine_reward_tplt.ids,
        Amounts = TpltInfo#divine_reward_tplt.amounts,
        RateList = TpltInfo#divine_reward_tplt.rate_list,
        SumRate = lists:foldl(fun(E, Sum) -> E + Sum end, 0, RateList),
        RandNum = rand:uniform(SumRate),
        get_rand(RandNum, RateList, IDs, Amounts)
        end,
    L
    ).

get_rand(RandNum, [Rate | RateList], [ID | IDList], [Amount | AmountList]) ->
    case RandNum =< Rate of
        true ->
            {ID, Amount};
        false ->
            get_rand(RandNum - Rate, RateList, IDList, AmountList)
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec 技能升级
%% @end
%%--------------------------------------------------------------------
proc_req_sculpture_upgrade(#req_sculpture_upgrade{temp_id = TempID}) ->
    Tplt = get_tplt(TempID),
    SkillInfo = sculpture_pack:get_item_by_tempid(TempID),
    CurLevel = SkillInfo:value(),
    UpgradeID = Tplt#skill_tplt.upgrate_cost_id,
    MaxLevel = Tplt#skill_tplt.max_lev,
    UpgradeInfo = get_upgrade_tplt(UpgradeID * 100 + CurLevel),
    NeedMoney = UpgradeInfo#skill_upgrade_tplt.cost,
    case check_upgrade(NeedMoney, CurLevel, MaxLevel) of
        true ->
            SourceType = ?st_sculpture_upgrade,
            player_role:reduce_gold(SourceType, NeedMoney),
            sculpture_pack:modify_level(SourceType, TempID, CurLevel + 1),
            event_router:send_event_msg(#event_sculpture_upgrade{amount = 1}),
            %%sculpture_pack:notify_sculpture_pack_change(),
            update_cur_scuplture_info(),

            packet:send(#notify_sculpture_upgrade{result=?common_success});
        false ->
            packet:send(#notify_sculpture_upgrade{result=?common_failed})
    end,
    ok.

check_upgrade(NeedMoney, CurLevel, MaxLevel) ->
    RoleLevel = player_role:get_level(),
    player_role:check_gold_enough(NeedMoney) andalso CurLevel < MaxLevel andalso  CurLevel < RoleLevel.


%%--------------------------------------------------------------------
%% @doc
%% @spec 技能进阶
%% @end
%%--------------------------------------------------------------------
proc_req_sculpture_advance(#req_sculpture_advnace{temp_id = TempID}) ->
    Tplt = get_tplt(TempID),
    AdvanceMatID = Tplt#skill_tplt.advance_cost_id,
    AdvnaceInfo = get_advance_tplt(AdvanceMatID),
    NeedID = AdvnaceInfo#skill_advance_tplt.need_ids,
    NeedAmount = AdvnaceInfo#skill_advance_tplt.need_amount,
    NeedItems = lists:zipwith(fun(X, Y) -> {X, Y} end, NeedID, NeedAmount),
    case check_advance(NeedItems, TempID) of
        true ->
            SourceType = ?st_sculpture_advance,
            NewTempId = AdvnaceInfo#skill_advance_tplt.advanced_id,
            sculpture_pack:modify_temp_id(SourceType, TempID, NewTempId),
            sculpture_pack:reduce_frags(SourceType, NeedItems),
            update_skill_groups(TempID, NewTempId),
            update_cur_scuplture_info(),
            broadcast_advance_success(),
            packet:send(#notify_sculpture_advnace{result = ?common_success, new_temp_id = NewTempId});
        false ->
            packet:send(#notify_sculpture_advnace{result = ?common_failed})
    end,
    ok.

broadcast_advance_success() ->
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    broadcast:broadcast(?sg_broadcast_advance_skill_success, [Role:nickname()]).

update_skill_groups(TempID, NewTempID) ->
    OldGroupsInfo = get_groups_info(),
    NewSkillGroups = lists:map(
        fun(OldItem) ->
            replace_group_item_id(OldItem, TempID, NewTempID)
        end, OldGroupsInfo),
    case NewSkillGroups =:= OldGroupsInfo of
        true ->
            ok;
        false ->
            set_groups_info(NewSkillGroups),
            packet:send(#notify_skill_groups_info{groups = NewSkillGroups})
    end.

replace_group_item_id(OldGroupItem, TempID, NewTempID) ->
    [ID1,ID2,ID3,ID4] = [OldGroupItem#skill_group_item.id1,
                         OldGroupItem#skill_group_item.id2,
                         OldGroupItem#skill_group_item.id3,
                         OldGroupItem#skill_group_item.id4],
    case TempID of
        ID1 ->
            OldGroupItem#skill_group_item{id1 = NewTempID};
        ID2 ->
            OldGroupItem#skill_group_item{id2 = NewTempID};
        ID3 ->
            OldGroupItem#skill_group_item{id3 = NewTempID};
        ID4 ->
            OldGroupItem#skill_group_item{id4 = NewTempID};
        _ ->
            OldGroupItem
    end.

check_advance(NeedItems, TempID) ->
    Result = is_same_ground_skill_exist(TempID),
    Result2 = sculpture_pack:check_frag_amount(NeedItems),
    io_helper:format("Result:~p~n,Result2:~p~n", [Result, Result2]),
    io_helper:format("NeedItems:~p~n", [NeedItems]),
    Result2 andalso Result.

%%--------------------------------------------------------------------
%% @doc
%% @spec 技能解锁
%% @end
%%--------------------------------------------------------------------
proc_req_sculpture_unlock(#req_sculpture_unlock{temp_id = TempID}) ->
    TpltInfo = get_tplt(TempID),
    NeedID = TpltInfo#skill_tplt.unlock_need_id,
    NeedAmount = TpltInfo#skill_tplt.unlock_need_amount,
    case check_unlock(NeedID, NeedAmount, TempID) of
        true ->
            SourceType = ?st_sculpture_unlock,
            sculpture_pack:reduce_frags(SourceType,  [{NeedID, NeedAmount}]),
            sculpture_pack:create_sculpture_and_save(SourceType, ?item_sculpture, TempID, 1),
            packet:send(#notify_sculpture_unlock{result = ?common_success, temp_id = TempID});
        false ->
            packet:send(#notify_sculpture_unlock{result = ?common_failed})
    end,
    ok.

check_unlock(NeedID, NeedAmount, TempID) ->
    Result = is_unlock(TempID),
    io_helper:format("NeedID:~p~n,NeedAmount:~p~n", [NeedID, NeedAmount]),
    io_helper:format("Result:~p~n,Result2:~p~n", [Result, sculpture_pack:check_frag_amount([{NeedID,NeedAmount}])]),
    sculpture_pack:check_frag_amount([{NeedID,NeedAmount}]) andalso (not Result).

is_unlock(TempID) ->
    case check_same_group_skill(TempID) of
        false ->
            false;
        _ ->
            true
    end.
%%     AllSkill = sculpture_pack:get_all_skill(),
%%     io_helper:format("AllSkill:~p~n", [AllSkill]),
%%     lists:any(fun(E) -> TempID =:= E end, AllSkill).


is_same_ground_skill_exist(TempID) ->
    AllSkill = sculpture_pack:get_all_skill(),
    SkillTpltInfo = get_tplt(TempID),
    AllTpltSkill = tplt:get_all_data(skill_tplt),
    SameGroupSkillList = lists:foldl(
        fun(E, Container) ->
            case E#skill_tplt.skill_group =:= SkillTpltInfo#skill_tplt.skill_group andalso TempID =/= E of
                true ->
                    [E#skill_tplt.id | Container];
                false ->
                    Container
            end
        end, [], AllTpltSkill),
    SameCount = lists:foldl(
        fun(SkillID, Sum) ->
            case lists:any(fun(E) -> SkillID =:= E end, AllSkill) of
                true ->
                    Sum + 1;
                false ->
                    Sum
            end
        end,
        0, SameGroupSkillList),
    SameCount > 0.

%%--------------------------------------------------------------------
%% @doc
%% @spec 技能穿戴
%% @end
%%--------------------------------------------------------------------
proc_req_sculpture_puton(#req_sculpture_puton{group_index = Index, position = Pos, temp_id = TempID}) ->
    SkillGroups = get_groups_info(),
    case can_puton(Index, SkillGroups, TempID) of
        true ->
            set_skill_group_info(Index, Pos, TempID, SkillGroups),
            update_cur_scuplture_info(),
            packet:send(#notify_sculpture_puton{is_success = ?common_success, group_index=Index, position=Pos, temp_id=TempID});
        false ->
            packet:send(#notify_sculpture_puton{is_success = ?common_failed, group_index=Index, position=Pos, temp_id=TempID})
    end.

can_puton(Index, SkillGroups, CheckID) ->
    case sculpture_pack:get_item_by_tempid(CheckID) of
        undefined ->
            false;
        _ ->
            GroupInfo = get_skill_group_info(Index, SkillGroups),
            CheckIDs = [GroupInfo#skill_group_item.id1,GroupInfo#skill_group_item.id2,
                        GroupInfo#skill_group_item.id3,GroupInfo#skill_group_item.id4],
            not lists:any(fun(E) -> E =:= CheckID end, CheckIDs)
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec 技能拿下
%% @end
%%--------------------------------------------------------------------
proc_req_sculpture_takeoff(#req_sculpture_takeoff{group_index = Index, position = Pos}) ->
    SkillGroups = get_groups_info(),
    case can_takeoff(Index, Pos, SkillGroups) of
        true ->
            set_skill_group_info(Index, Pos, 0, SkillGroups),
            update_cur_scuplture_info(),
            packet:send(#notify_sculpture_takeoff{is_success = ?common_success, group_index=Index, position=Pos});
        false ->
            packet:send(#notify_sculpture_takeoff{is_success = ?common_failed, group_index=Index, position=Pos})
    end.

can_takeoff(Index, Pos, SkillGroups) ->
    get_temp_id_in_group(Index, Pos, SkillGroups) =/= 0.


get_skill_group_info(Index, SkillGroups) ->
    case lists:keyfind(Index, #skill_group_item.index, SkillGroups) of
        false ->
            #skill_group_item{index = Index};
        Info ->
            Info
    end.

get_temp_id_in_group(Index, Pos, SkillGroups) ->
    case lists:keyfind(Index, #skill_group_item.index, SkillGroups) of
        false ->
            0;
        Info ->
            element(Pos + 1, Info)
    end.

set_skill_group_info(Index, Pos, TempID, OldGroupsInfo) ->
    io_helper:format("OldGroupsInfo:~p~n", [OldGroupsInfo]),
    OldGroupItem = get_skill_group_info(Index, OldGroupsInfo),
    io_helper:format("OldGroupItem:~p~n", [OldGroupItem]),
    NewGroupItem = replace_group_skill(OldGroupItem, Pos, TempID),
    io_helper:format("NewGroupItem:~p~n", [NewGroupItem]),
    NewSkillGroups = case lists:keyfind(Index, #skill_group_item.index, OldGroupsInfo) of
                         false ->
                             [NewGroupItem | OldGroupsInfo];
                         _ ->
                             lists:keyreplace(Index, #skill_group_item.index, OldGroupsInfo, NewGroupItem)
                     end,
    set_groups_info(NewSkillGroups).

replace_group_skill(OldGroupItem, Pos, TempID) ->
    case Pos of
        1 ->
            OldGroupItem#skill_group_item{id1 = TempID};
        2 ->
            OldGroupItem#skill_group_item{id2 = TempID};
        3->
            OldGroupItem#skill_group_item{id3 = TempID};
        4 ->
            OldGroupItem#skill_group_item{id4 = TempID}
    end.

get_groups_info() ->
    case get(skill_groups_info) of
        undefined ->
            CacheInfo = get_groups_info_in_cache(),
            put(get_groups_info, CacheInfo),
            CacheInfo;
        Info ->
            Info
    end.

get_groups_info(RoleID) ->
    case redis:hget("sculpture:group_info", RoleID) of
        undefined ->
            [#skill_group_item{index = 1}];
        Info ->
            Info
    end.

set_groups_info(NewGroupsInfo) ->
    set_groups_info(player:get_role_id(), NewGroupsInfo).

set_groups_info(RoleID, NewGroupsInfo) ->
    put(skill_groups_info, NewGroupsInfo),
    redis:hset("sculpture:group_info", RoleID, NewGroupsInfo),
    ok.

get_groups_info_in_cache() ->
    case redis:hget("sculpture:group_info", player:get_role_id()) of
        undefined ->
            [#skill_group_item{index = 1}];
        Info ->
            Info
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec 更换技能组
%% @end
%%--------------------------------------------------------------------
proc_req_change_skill_group(#req_change_skill_group{group_index = Index}) when Index >= 1 andalso Index =< 3 ->
    case check_change_group() of
        true ->
            set_activate_group(Index),
            update_cur_scuplture_info(),
            packet:send(#notify_change_skill_group{result=?common_success, activate_group=Index});
        false ->
            packet:send(#notify_change_skill_group{result=?common_failed})
    end.

get_activate_group() ->
    case redis:hget("sculpture:activate_group", player:get_role_id()) of
        undefined ->
            1;
        Index ->
            Index
    end.

get_activate_group(RoleID) ->
    case redis:hget("sculpture:activate_group", RoleID) of
        undefined ->
            1;
        Index ->
            Index
    end.

set_activate_group(Index) ->
    redis:hset("sculpture:activate_group", player:get_role_id(), Index).

check_change_group() ->
    true.
%%--------------------------------------------------------------------
%% @doc
%% @spec 模板相关
%% @end
%%--------------------------------------------------------------------
get_tplt(ID) ->
    tplt:get_data(skill_tplt, ID).

get_advance_tplt(ID) ->
    tplt:get_data(skill_advance_tplt, ID).

get_upgrade_tplt(ID) ->
    tplt:get_data(skill_upgrade_tplt, ID).

get_divine_reward_tplt(ID) ->
tplt:get_data(divine_reward_tplt, ID).
