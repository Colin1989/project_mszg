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
         get_item_tplt_temp_id/1,
         check_tplt_data/0,
	 merge2give/3,
	 merge_rewards/2]).

%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec ���ͽ���
%% @end
%%--------------------------------------------------------------------
give([], [], _Type) ->
    player_pack:do_notify_pack_change();
    %%sculpture_pack:notify_sculpture_pack_change();
give([ID | IDs], [Amount | Amounts], Type) ->
    send_reward(ID, Amount, Type),
    give(IDs, Amounts, Type).

give_not_notify([], [], _Type) ->
    ok;
give_not_notify([ID | IDs], [Amount | Amounts], Type) ->
    send_reward(ID, Amount, Type),
    give_not_notify(IDs, Amounts, Type).


merge2give(Ids, Amounts, Type)->
    {NewIds, NewAmounts} = merge_rewards(Ids, Amounts),
    give(NewIds, NewAmounts, Type).


merge_rewards(Ids, Amounts)->
    R = lists:reverse(lists:foldl(fun({TempID, Amount}, In) -> 
			case lists:keyfind(TempID, 1, In) of
			    false ->
				[{TempID, Amount}|In];
			    {_, Org} ->
				lists:keyreplace(TempID, 1, In, {TempID, Org + Amount})
			end
			      end, [], lists:zip(Ids,Amounts))),
    
    lists:unzip(R).

%%--------------------------------------------------------------------
%% @doc
%% @spec ��ʼ���������ģ���
%% @end
%%--------------------------------------------------------------------
check_tplt_data() ->
    TpltInfo = tplt:get_all_data(reward_item_tplt),
    lists:map(
        fun(Item) ->
            [IDInfo] = Item#reward_item_tplt.temp_id,
            case IDInfo of
                TempID when is_integer(TempID) ->
                    Item;
                IDTuple ->
                    IDList = tuple_to_list(IDTuple),
                    case length(IDList) =:= 4 of
                        true ->
                            Key = Item#reward_item_tplt.id,
                            NewTempIDs = sort_temp_ids(IDList, Key),
                            NewData = #reward_item_tplt{id = Key,
                                                        type = Item#reward_item_tplt.type,
                                                        temp_id = [NewTempIDs],
                                                        description = Item#reward_item_tplt.description},
                            ets:insert(reward_item_tplt, {Key, NewData});
                        false ->
                            erlang:error({"reward temp_id error, id:", Item#reward_item_tplt.id})
                    end

            end
        end, TpltInfo).

sort_temp_ids(IDList, Key) ->
    Tuple1 = lists:map(
        fun(TempID) ->
            RoleType = item:get_role_type(TempID),
            {RoleType, TempID}
        end, IDList),
    Tuple2 = lists:keysort(1,Tuple1),
    lists:foreach(
        fun(Index) ->
            case lists:keyfind(Index,1, Tuple2) of
                false ->
                    erlang:error({"reward temp_id error, miss one or more role_type, id:", Key});
                _ ->
                    ok
            end
        end,
        [1,2,3,4]
    ),
    ListID = lists:map(
        fun(Item) ->
            element(2, Item)
        end, Tuple2),
    list_to_tuple(ListID).

%%%===================================================================
%%% Internal functions
%%%===================================================================
send_reward(ID, Amount, SourceType) ->
    %%RoleID = player:get_role_id(),
    {Type, TempID} = get_type_and_temp_id(ID),
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
	    sculpture:add(SourceType, TempID);
	9 -> %% �ٻ�ʯ
	    player_role:add_summon_stone(SourceType, Amount);
	10 -> %%��������ҩˮ�ɳ���
	    power_hp:add_power_hp(SourceType, Amount);
	11 -> %%���ݻ���
      ok;
	    %ladder_match:add_ladder_match_point(SourceType, Amount);
	12 -> %%ս��ֵ
	    player_role:add_battle_soul(SourceType, Amount);
	13 -> %% ������Ƭ
	    sculpture_pack:add_frags(SourceType, [{TempID, Amount}]);
	14 -> %% vip����
	    player_role:add_vip_exp(SourceType, Amount)
    end.

get_item_tplt(ID) ->
    tplt:get_data(reward_item_tplt, ID).

get_item_tplt_type(ID) ->
    ItemInfo = get_item_tplt(ID),
    ItemInfo#reward_item_tplt.type.

get_item_tplt_temp_id(ID) ->
    
    ItemInfo = get_item_tplt(ID),
    [IDInfo] = ItemInfo#reward_item_tplt.temp_id,
    case IDInfo of
	TempID when is_integer(TempID) ->
	    TempID;
	IDTuple ->
	    Type = player_role:get_role_type(),
	    element(Type, IDTuple)
    end.

get_type_and_temp_id(ID) ->
    ItemInfo = get_item_tplt(ID),
    Type = ItemInfo#reward_item_tplt.type,

    [IDInfo] = ItemInfo#reward_item_tplt.temp_id,
    Temp_ID = case IDInfo of
                  TempID when is_integer(TempID) ->
                      TempID;
                  IDTuple ->
                      RoleType = player_role:get_role_type(),
                      element(RoleType, IDTuple)
              end,
    {Type, Temp_ID}.

