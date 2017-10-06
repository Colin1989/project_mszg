%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created :  7 Jul 2014 by whl <>
%%%-------------------------------------------------------------------
-module(role_advance).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").

%% API
-export([start/0,
  get_role_potence_info/1]).

-compile(export_all).
%%%===================================================================
%%% API
%%%===================================================================
start() ->
  packet:register(?msg_req_potence_advance, {?MODULE, proc_req_potence_advance}),
  ok.

get_role_potence_info(PotenceLevel) ->
  Atk = get_potence_atk(PotenceLevel),
  Life = get_potence_life(PotenceLevel),
  Power = get_potence_power(PotenceLevel),
  {Atk, Life, Power}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
proc_req_potence_advance(#req_potence_advance{is_use_amulet = _IsUseAmulet}) ->
%%   case check_amulet(IsUseAmulet) of
  case true of
    true ->
      CurPotenceLevel = player_role:get_potence_level(),
      case check_is_max(CurPotenceLevel) of
        true ->
          packet:send(#notify_potence_advance_result{result = ?common_failed});
        false ->
          CurAdvancedLevel = player_role:get_advanced_level(), %% 1 2 3 4 5
          CurBattleSoul = player_role:get_battle_soul(),
          NextLevelLimit = get_potence_level_limit(CurPotenceLevel + 1),
          case NextLevelLimit > player_role:get_level() of
            true -> %% 等级不足不进行潜能升级
              io_helper:format("NextLevelLimit:~p~n", [NextLevelLimit]),
              packet:send(#notify_potence_advance_result{result = ?common_failed});
            false ->
              NeedBattleSoul = get_potence_battle_soul(CurPotenceLevel + 1),
              case NeedBattleSoul =< CurBattleSoul of
                true ->
%%                   Rate = get_potence_rate(CurPotenceLevel + 1),
%%                   case rand:uniform(100) =< Rate orelse IsUseAmulet =:= 1 of
                  case true of
                    true ->
                      NewPotenceLevel = CurPotenceLevel + 1,
                      player_role:increase_potence_level(),
                      player_role:reduce_battle_soul(?st_role_advance, NeedBattleSoul),
                      FixAdvancedLevel = case CurAdvancedLevel >= config:get(max_advance_level) of
                                           true ->
                                             config:get(max_advance_level);
                                           false ->
                                             NextAdvanceID = player_role:get_role_type() * 100 + CurAdvancedLevel + 1,
                                             case get_role_min_potence_level(NextAdvanceID) =< NewPotenceLevel of
                                               true ->
                                                 player_role:increase_advanced_level(),
                                                 broadcast_advance_success(),
                                                 CurAdvancedLevel + 1;
                                               false ->
                                                 CurAdvancedLevel
                                             end
                                         end,
                      io_helper:format("NewPotenceLevel:~p~n", [NewPotenceLevel]),
                      friend:set_myinfo_update(),
                      packet:send(#notify_potence_advance_result{result = ?common_success, potence_level = NewPotenceLevel,
                        advanced_level = FixAdvancedLevel})
%%                     false ->
%%                       io_helper:format("Rate:~p~n", [Rate]),
%%                       case IsUseAmulet of
%%                         1 ->
%%                           ok;
%%                         0 ->
%%                           player_role:reduce_battle_soul(?st_role_advance, NeedBattleSoul)
%%                       end,
%%                       packet:send(#notify_potence_advance_result{result = ?common_failed})
                  end;
                false ->
                  io_helper:format("NeedBattleSoul:~p~n", [NeedBattleSoul]),
                  packet:send(#notify_potence_advance_result{result = ?common_failed})
              end
          end
      end;

    false ->
      io_helper:format("not_enough_amulet~n"),
      packet:send(#notify_potence_advance_result{result = ?common_failed})
  end.

broadcast_advance_success() ->
  Role = player_role:get_role_info_by_roleid(player:get_role_id()),
  broadcast:broadcast(?sg_broadcast_advance_role_success, [Role:nickname()]).

check_is_max(CurPotenceLevel) ->
  AllInfo = tplt:get_all_data(potence_tplt),
  LastInfo = lists:nth(length(AllInfo), AllInfo),
  LastInfo#potence_tplt.id =< CurPotenceLevel.

check_amulet(IsUseAmulet) ->
  case IsUseAmulet of
    1 ->
      [{_, Amount}] = player_pack:get_items_count([config:get(role_advance_amulet_id)]),
      case Amount - 1 >= 0 of
        true ->
          player_pack:delete_items(?st_role_advance, [{config:get(role_advance_amulet_id), 1}]),
          true;
        false ->
          false
      end;
    0 ->
      true
  end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 模版相关
%% @end
%%--------------------------------------------------------------------

get_potence_tplt(ID) ->
  tplt:get_data(potence_tplt, ID).
get_potence_level_limit(ID) ->
  TpltInfo = get_potence_tplt(ID),
  TpltInfo#potence_tplt.level_limit.
get_potence_battle_soul(ID) ->
  TpltInfo = get_potence_tplt(ID),
  TpltInfo#potence_tplt.battle_soul.
get_potence_rate(ID) ->
  TpltInfo = get_potence_tplt(ID),
  TpltInfo#potence_tplt.rate.
get_potence_atk(ID) ->
  TpltInfo = get_potence_tplt(ID),
  TpltInfo#potence_tplt.attack.
get_potence_life(ID) ->
  TpltInfo = get_potence_tplt(ID),
  TpltInfo#potence_tplt.life.
get_potence_power(ID) ->
  TpltInfo = get_potence_tplt(ID),
  TpltInfo#potence_tplt.power.

get_role_advance_tplt(ID) ->
  tplt:get_data(role_advance_tplt, ID).

get_role_min_potence_level(ID) ->
  TpltInfo = get_role_advance_tplt(ID),
  TpltInfo#role_advance_tplt.potence_level.