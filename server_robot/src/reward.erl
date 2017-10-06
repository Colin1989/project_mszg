%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created :  4 May 2014 by whl <>
%%%-------------------------------------------------------------------
-module(reward).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("event_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").

-compile(export_all).
%% API
-export([give/3,
         get_item_tplt_type/1,
         get_item_tplt_temp_id/1]).

%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec ���ͽ���
%% @end
%%--------------------------------------------------------------------
give([], [], _Type) ->
    player_pack:do_notify_pack_change(),
    sculpture_pack:notify_sculpture_pack_change();
give([ID | IDs], [Amount | Amounts], Type) ->
    send_reward(ID, Amount, Type),
    give(IDs, Amounts, Type).

give_not_notify([], [], _Type) ->
    ok;
give_not_notify([ID | IDs], [Amount | Amounts], Type) ->
    send_reward(ID, Amount, Type),
    give_not_notify(IDs, Amounts, Type).



%%%===================================================================
%%% Internal functions
%%%===================================================================
send_reward(ID, Amount, SourceType) ->
    %%RoleID = player:get_role_id(),
    Type = get_item_tplt_type(ID),
    TempID = get_item_tplt_temp_id(ID),
    case Type of
	1 -> %% ���
	    player_role:add_gold(SourceType, Amount);
	2 -> %% ����
	    %%[Role|_] = db:find(db_role, [{role_id, 'equals', RoleID}]),
	    player_role:add_exp(SourceType, Amount);
	3 -> %% ħʯ
	    player_role:add_emoney(SourceType, Amount);
	4 -> %% ����
	    power_hp:add_power_hp_limit(SourceType, Amount);
	5 -> %% ����
	    player_role:add_point(SourceType, Amount);
	6 -> %% ����
		military_rank:add_honour(SourceType, Amount);
	7 -> %% ��Ʒ
	    player_pack:add_item(SourceType, TempID, Amount);
	8 -> %% ����
	    sculpture_pack:add_sculptures(SourceType, [{TempID, Amount}]);
	9 -> %% �ٻ�ʯ
	    player_role:add_summon_stone(SourceType, Amount);
	10 -> %%��������ҩˮ�ɳ���
	    power_hp:add_power_hp(SourceType, Amount)
  end.

get_item_tplt(ID) ->
  tplt:get_data(reward_item_tplt, ID).

get_item_tplt_type(ID) ->
  ItemInfo = get_item_tplt(ID),
  ItemInfo#reward_item_tplt.type.

get_item_tplt_temp_id(ID) ->
  ItemInfo = get_item_tplt(ID),
  ItemInfo#reward_item_tplt.temp_id.
