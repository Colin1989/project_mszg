-module(gm_tools).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("tplt_def.hrl").

-export([start/0,proc_req_enter_game/1]).

-ifndef(release).
-compile(export_all).
-endif.

start() ->
    packet:register(?msg_req_gm_optition, {?MODULE,proc_req_enter_game}),
    ok.

-ifndef(release).
proc_req_enter_game(#req_gm_optition{opt_type = Type, value = Value})->
    case Type of
	?gm_opt_exp ->
	    player_role:add_exp(?st_gm_cmd, Value),
	    ok;
	?gm_opt_gold -> 
	    proc_gold(Value);
	?gm_opt_emoney ->
	    proc_emoney(Value);
	?gm_opt_summon_stone ->
	    proc_summon_stone(Value);
	?gm_opt_point ->
	    proc_point(Value);
	?gm_opt_honour ->
	    proc_honour(Value);
	?gm_opt_item ->
	    player_pack:add_items(?st_gm_cmd, [{Value, 1}]);
	?gm_opt_sculpture ->
	    sculpture:add(?st_gm_cmd, Value);
	    %%sculpture_pack:notify_sculpture_pack_change();
	?gm_opt_frag ->
	    proc_frag(Value);
	?gm_opt_recharge ->
	    proc_recharge(Value);
	?gm_opt_battle_soul ->
	    proc_battle_soul(Value);
	?gm_opt_friend_point ->
	    proc_friend_point(Value);
        ?gm_opt_pass_copy ->
            proc_pass_copy(Value);
	?gm_opt_ladder_match_point ->
	    proc_ladder_match_point(Value);
        ?gm_opt_vip_exp ->
            proc_vip_exp(Value);
	_ ->
	    io:format("gm_cmd_err")
    end,
    ok.
-else.
proc_req_enter_game(_)->
    ok.
-endif.
proc_vip_exp(Point) ->
    player_role:add_vip_exp(?st_gm_cmd, Point).

proc_ladder_match_point(Point) ->
    ladder_match:add_ladder_match_point(?st_gm_cmd, Point).

proc_summon_stone(Value) ->
    case Value >= 0 of
	true ->
	    player_role:add_summon_stone(?st_gm_cmd, Value);
	false ->
	    player_role:reduce_summon_stone(?st_gm_cmd, abs(Value))
    end.
proc_point(Value) ->
    case Value >= 0 of
	true ->
	    player_role:add_point(?st_gm_cmd, Value);
	false ->
	    player_role:reduce_point(?st_gm_cmd, abs(Value))
    end.
proc_honour(Value) ->
    case Value >= 0 of
	true ->
	    military_rank:add_honour(?st_gm_cmd, Value);
	false ->
	    military_rank:reduce_honour(?st_gm_cmd, abs(Value))
    end.

proc_battle_soul(Value) ->
	case Value >= 0 of
		true ->
			player_role:add_battle_soul(?st_gm_cmd, Value);
		false ->
			player_role:reduce_battle_soul(?st_gm_cmd, abs(Value))
	end.

proc_friend_point(Value) ->
	case Value >= 0 of
		true ->
			assistance:add_point(?st_gm_cmd, Value);
		false ->
			assistance:reduce_point(?st_gm_cmd, abs(Value))
	end.

proc_frag(Value) ->
    case Value >= 0 of
	true ->
	    sculpture_pack:add_frags(?st_gm_cmd, [{Value, 100}]);
	false ->
            sculpture_pack:reduce_frags(?st_gm_cmd, [{abs(Value), 100}])
    end.

proc_gold(Value) ->
    case Value >= 0 of
	true ->
	    player_role:add_gold(?st_gm_cmd, Value);
	false ->
	    player_role:reduce_gold(?st_gm_cmd, abs(Value))
    end.


proc_emoney(Value) ->
    case Value >= 0 of
	true ->
	    player_role:add_emoney(?st_gm_cmd, Value);
	false ->
	    player_role:reduce_emoney(?st_gm_cmd, abs(Value))
    end.

proc_recharge(RechargeID) ->
    UserID = player:get_player_id(),
    OrderID = uuid:gen(),
    #recharge_tplt{money = TpltMoney} = tplt:get_data(recharge_tplt, RechargeID),
    spawn(recharge, recharge, [UserID, OrderID, TpltMoney, RechargeID]).


proc_pass_copy(Value) ->
	CopyTplt = tplt:get_all_data(copy_tplt),
	case Value < 1000 of
		true -> %% 副本群
			GroupCopies = case Value =:= 0 of
											true ->
												CopyTplt;
											false ->
												lists:filter(fun(Copy) -> Copy#copy_tplt.copy_group_id =:= Value end, CopyTplt)
										end,
			io:format("GroupCopies:~p~n", [GroupCopies]),
			lists:foreach(
				fun(CopyInfo) ->
					CopyID = CopyInfo#copy_tplt.id,
					game_copy:update_pass_copy(CopyID, {1, 3})
				end, GroupCopies);
		false -> %% 副本
			FinalCopy = lists:filter(fun(CopyID) -> CopyID =:= Value end, [E#copy_tplt.id || E <- CopyTplt]),
			io:format("FinalCopy:~p~n", [FinalCopy]),
			unlock_pass_copy(FinalCopy)
	%%game_copy:update_pass_copy(Value, {1, 3})
	end.

unlock_pass_copy([]) ->
    ok;
unlock_pass_copy([CopyId|CopyIds]) ->
    case game_copy:is_copy_max_score(CopyId) of
	true ->
	    game_copy:update_pass_copy(CopyId, {1, 3}),
	    unlock_pass_copy(CopyIds);
	false ->
	    game_copy:update_pass_copy(CopyId, {1, 3}),
	    #copy_tplt{pre_copy = PrevCopys} = tplt:get_data(copy_tplt, CopyId),
	    unlock_pass_copy(CopyIds ++ PrevCopys)
    end,
    ok.

check_equipment_attr_valid()->
    AllRule = tplt:get_all_data(equipment_mf_rule_tplt),
    lists:filter(fun({_, List}) -> 
			 length(List) =/= 0
		 end, check_equipment_mf_rules_valid(AllRule)).


check_equipment_mf_rules_valid([]) ->
    [];
check_equipment_mf_rules_valid([Rule|Left]) ->
    [get_invalid_ids(Rule)|check_equipment_mf_rules_valid(Left)].

get_invalid_ids(Rule) ->
    #equipment_mf_rule_tplt{addtional_attr_ids = AddAttr, special_attr_ids = SpecAttr} = Rule,
    NewIds = lists:foldl(fun({Min, Max}, In) ->
				 In ++ get_invalid_id(Min, Max)
			 end, [], AddAttr),
    FinalIds = lists:foldl(fun({Min, Max}, In) ->
				   In ++ get_invalid_id(Min, Max)
			   end, NewIds, SpecAttr),
    {Rule#equipment_mf_rule_tplt.id, FinalIds}.



get_invalid_id(Max, Max) ->
    try 
	tplt:get_data(equipment_attr_tplt, Max),
	[]
    catch
	_:_ ->
	    [Max]
    end;
get_invalid_id(Min, Max) when Min < Max ->
    Id = try 
	     tplt:get_data(equipment_attr_tplt, Max),
	     []
	 catch
	     _:_ ->
		 [Min]
	 end,
    Id ++ get_invalid_id(Min + 1, Max).



