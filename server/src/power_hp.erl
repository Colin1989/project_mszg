%%%-------------------------------------------------------------------
%%% @author lixc <>
%%% @copyright (C) 2014, lixc
%%% @doc
%%%
%%% @end
%%% Created :  3 Jan 2014 by lixc <>
%%%-------------------------------------------------------------------
-module(power_hp).

-include("common_def.hrl").
-include("packet_def.hrl").


-define(add_power, 1).

%% API
-export([get_power_hp_time/1,
	 get_power_hp_time_left/1,
	 %%get_standby_hp/1,
	 get_power_hp/0,
	 get_power_hp/1,
	 get_power_info/1,
	 check_hp/1,
	 %%check_standby_hp/1,
	 cost_hp/2,
	 cost_hp/3,
	 recover_all_pwoer_hp/0,
	 get_true_max_power_hp/0,
	 add_power_hp_limit/2,
	 add_power_hp/2
	]).

%%%===================================================================
%%% API
%%%===================================================================
get_power_info(RoleID) ->
    case redis:hget("power_hp", RoleID) of
	undefined ->
	    Hp = config:get(base_power_hp),
	    PowerInfo = db_power_hp:new(id, RoleID, Hp, erlang:localtime()),
	    save_power_info(RoleID, PowerInfo),
	    PowerInfo;
        Data ->
	     Data
    end.

save_power_info(RoleID, PowerInfo) ->
    redis:hset("power_hp", RoleID, PowerInfo).

%%%===================================================================
%%% 获取回复体力的时间
%%%===================================================================
get_power_hp_time(RoleId) ->
    PowerInfo = get_power_info(RoleId),
    PowerInfo:power_hp_time().
%%%===================================================================
%%% 获取下次回复时间
%%%===================================================================
get_power_hp_time_left(RoleId)->
    PowerInfo = get_power_info(RoleId),
    NowTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
    PowerHpTime = config:get(power_hp_time),
    BackHpTime = datetime:datetime_to_gregorian_seconds(PowerInfo:power_hp_time()),
    TimePass=(NowTime - BackHpTime) rem PowerHpTime,
    PowerHpTime-TimePass.


%%--------------------------------------------------------------------
%% @doc
%% @判断体力值不超过上限
%% @Hp :要更新的体力值
%% @end
%%--------------------------------------------------------------------
power_hp(Hp) ->
    MaxHp = get_max_power_hp(player:get_role_id()),%%config:get(max_power_hp),
    case Hp >= MaxHp of
	true ->
	    MaxHp;
	false ->
	    Hp
    end.

%%--------------------------------------------------------------------
%% @doc
%% @判断备份体力不超过上限
%% @Hp :要更新的备份体力值
%% @end
%%--------------------------------------------------------------------
%%standby_hp(Hp) ->
%%    MaxStandbyHP = config:get(max_standby_hp),
%%    case Hp >= MaxStandbyHP of
%%	true ->
%%	    MaxStandbyHP;
%%	false ->
%%	    Hp
%%    end.


%%%===================================================================
%%% 获取备用体力
%%%===================================================================
%%get_standby_hp(RoleId) ->
%%    [Data] = get_power_info(RoleId),
%%    MaxHp = config:get(max_power_hp),
    %% 当前体力值已满，计算备份体力
%%    case Data:power_hp() >= MaxHp of
%%	true ->
%%	    check_standby_hp(Data);
%%	_ ->
%%	    Data:standby_hp()
%%    end.
	    

%%--------------------------------------------------------------------
%% @doc
%% @返回当角色的体力
%% @RoleId :角色id
%% @end
%%--------------------------------------------------------------------
get_power_hp()->
    RoleId=player:get_role_id(),
    get_power_hp(RoleId).
get_power_hp(RoleId) when is_integer(RoleId) ->
    PowerInfo = get_power_info(RoleId),
    check_hp(PowerInfo).

%%--------------------------------------------------------------------
%% @doc
%% @恢复所有体力
%% @end
%%--------------------------------------------------------------------
recover_all_pwoer_hp()->
    RoleId=player:get_role_id(),
    MaxHp = get_max_power_hp(RoleId),%%config:get(max_power_hp),
    Info = set_power_hp(RoleId,MaxHp),
    packet:send(#notify_role_info_change{type = "power_hp", new_value = Info:power_hp()}),
    Info.


add_power_hp_limit(Type, Amount) ->
    RoleId = player:get_role_id(),
    CurPower = get_power_hp(RoleId),
    Max = get_max_power_hp(RoleId),
    case CurPower + Amount > Max of
	true ->
	    player_log:create(RoleId, ?power_hp, Type, ?add_power, 0, 0, Amount, CurPower),
	    set_power_hp(RoleId, Max),
	    packet:send(#notify_role_info_change{type = "power_hp", new_value = Max});
	false ->
	    player_log:create(RoleId, ?power_hp, Type, ?add_power, 0, 0, Amount, CurPower),
	    set_power_hp(RoleId, CurPower + Amount),
	    packet:send(#notify_role_info_change{type = "power_hp", new_value = CurPower + Amount})
    end,
    ok.

add_power_hp(Type, Amount) ->
    RoleId = player:get_role_id(),
    CurPower = get_power_hp(RoleId),
    Max  = config:get(max_power_hp_val),
    case CurPower + Amount > Max of
	true ->
	    player_log:create(RoleId, ?power_hp, Type, ?add_power, 0, 0, Amount, CurPower),
	    set_power_hp(RoleId, Max),
	    packet:send(#notify_role_info_change{type = "power_hp", new_value = Max});
	false ->
	    player_log:create(RoleId, ?power_hp, Type, ?add_power, 0, 0, Amount, CurPower),
	    set_power_hp(RoleId, CurPower + Amount),
	    packet:send(#notify_role_info_change{type = "power_hp", new_value = CurPower + Amount})
    end,
    ok.
    
set_power_hp(RoleId, PowerHp)->
    PowerInfo = get_power_info(RoleId),
    case PowerInfo:power_hp() >= PowerHp of
	true ->
	   PowerInfo;
	false ->
	    NPowerInfo = PowerInfo:set([{power_hp, PowerHp}]),
	    save_power_info(RoleId, NPowerInfo),
	    NPowerInfo
	    %%packet:send(#notify_role_info_change{type = "power_hp", new_value = PowerHp})
    end.
%%--------------------------------------------------------------------
%% @doc
%% @计算当前体力
%% @Data :角色体力数据
%% @end
%%--------------------------------------------------------------------
check_hp(PowerInfo) ->
    RoleId = player:get_role_id(),
    MaxHp = get_max_power_hp(RoleId),%%config:get(max_power_hp),
    Hp =  PowerInfo:power_hp(),
    NowTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
    PowerHpTime = config:get(power_hp_time),
    BackHpTime = datetime:datetime_to_gregorian_seconds(PowerInfo:power_hp_time()),
    AddHp = ((NowTime-BackHpTime) div PowerHpTime) * config:get(recover_power_hp_amount),
    RemTime = (NowTime-BackHpTime) rem PowerHpTime,
    case(Hp >= MaxHp) of
	true ->
	    case AddHp of
		0 ->ok;
		_ ->
		    NPowerInfo = PowerInfo:set([{power_hp_time,datetime:gregorian_seconds_to_datetime(NowTime-RemTime)}]),
		    save_power_info(RoleId, NPowerInfo)
	    end,
	    MaxHp;
	false ->
	    
	    NewHp = power_hp(Hp + AddHp),
	    case AddHp of
		0 ->ok;
		_ ->
		    NPowerInfo = PowerInfo:set([{power_hp,NewHp},{power_hp_time,datetime:gregorian_seconds_to_datetime(NowTime-RemTime)}]),
		    save_power_info(RoleId, NPowerInfo)
	    end,
	    NewHp
	    
    end.

%%--------------------------------------------------------------------
%% @doc
%% @根据时间计算备份体力
%% @Data:角色体力数据
%% @end
%%--------------------------------------------------------------------
%%check_standby_hp(Data) ->
%%    MaxStandbyHP = config:get(max_standby_hp),
%%    StandbyHp = Data:standby_hp(),
%%    NowTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()),%取当前时间戳
%%    case StandbyHp >= MaxStandbyHP of
%%	false ->
%%	    StandbyHpTime = config:get(standby_hp_time),
%%	    BackHpTime = datetime:datetime_to_gregorian_seconds(Data:power_hp_time()),
%%	    AddHp = (NowTime - BackHpTime) div StandbyHpTime,
%%	    RemTime = (NowTime - BackHpTime) rem StandbyHpTime,
%%	    NewHp = standby_hp(StandbyHp+AddHp),
%%	    NewData = Data:set([{power_hp_time,datetime:gregorian_seconds_to_datetime(NowTime-RemTime)},{standby_hp,NewHp}]),
%%	    NewData:save(),
%%	    NewHp;
%%	true ->
%%	    MaxStandbyHP
%%    end.


%%--------------------------------------------------------------------
%% @doc
%% @扣除体力
%% @RoleId 角色id, CostHp 消耗的体力
%% @end
%%--------------------------------------------------------------------
cost_hp(RoleId, CostHp) ->
    PowerHp = get_power_hp(RoleId),
    case PowerHp >= CostHp of
	true ->
	    PowerInfo = get_power_info(RoleId),
	    NewHp = PowerHp - CostHp,
	    NPowerInfo = PowerInfo:set([{power_hp,NewHp}]),
	    save_power_info(RoleId, NPowerInfo),
	    {1,NewHp};
	false ->
	    {0,PowerHp}
    end.


cost_hp(cost,RoleId,CostHp) -> 
    PowerHp = get_power_hp(RoleId),
    io_helper:format("PowerHP:~p, CostHP:~p~n", [PowerHp, CostHp]),
    case PowerHp >= CostHp of
	true ->
	    PowerInfo = get_power_info(RoleId),
	    NewHp = PowerHp - CostHp,
	    NPowerInfo = PowerInfo:set([{power_hp,NewHp}]),
	    save_power_info(RoleId, NPowerInfo),
	    NewHp
    end.


get_max_power_hp(RoleId)->
    Base = config:get(base_power_hp),
    case RoleId of
	undefined ->
	    Base;
	_ ->
	    case  player_role:get_role_info_by_roleid(RoleId) of
		undefined ->
		    Base;
		Role ->
		    LevAddition = (Role:level()-1) * config:get(power_hp_add_by_level),
		    Max = Base + LevAddition,
		    PowerInfo = get_power_info(RoleId),
		    case PowerInfo:power_hp() > Max of
			true ->
			    PowerInfo:power_hp();
			false ->
			    Max
		    end
	    end
    end.


get_true_max_power_hp()->
    config:get(max_power_hp_val).
