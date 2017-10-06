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
	    sculpture_pack:add_sculptures(?st_gm_cmd, [{Value, 1}]),
	    sculpture_pack:notify_sculpture_pack_change();
	?gm_opt_frag ->
	    proc_frag(Value);
	_ ->
	    io:format("gm_cmd_err")
    end,
    ok.
-else.
proc_req_enter_game(_)->
    ok.
-endif.
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
proc_frag(Value) ->
    case Value >= 0 of
	true ->
	    player_role:add_sculpture_frag(?st_gm_cmd, Value);
	false ->
	    player_role:reduce_sculpture_frag(?st_gm_cmd, abs(Value))
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



