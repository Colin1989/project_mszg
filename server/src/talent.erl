%%%-------------------------------------------------------------------
%%% @author Jack <yebin.xm@gmail.com>
%%% @copyright (C) 2014, Jack
%%% @doc
%%%
%%% @end
%%% Created : 21 Oct 2014 by Jack <yebin.xm@gmail.com>
%%%-------------------------------------------------------------------
-module(talent).
-include("enum_def.hrl").
-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
%% API
-export([start/0,
         unlock/1,
         talent_login_init/0,
         proc_actived_talent/1,
         proc_reset_talent/1,
         proc_level_up_talent/1,
         get_talent_record_list_by_role_id/1 
         %% gm_unlock_talent/1,
         %% gm_active_talent/1,
         %% gm_level_up_talet/1
        ]).
%%-compile(export_all).
%%%===================================================================
%%% API
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc
%% @spec talent system start function
%% @end
%%--------------------------------------------------------------------
start() ->
    %%packet:regist(?msg_req_get_talent_active_info,{?MODULE,proc_get_talent_active_info}),
    %%packet:regist(?msg_req_get_reset_active_time,{?MODULE,proce_get_reset_active_time}),
    packet:register(?msg_req_actived_talent,{?MODULE,proc_actived_talent}),
    packet:register(?msg_req_level_up_talent,{?MODULE,proc_level_up_talent}),
    packet:register(?msg_req_reset_talent,{?MODULE,proc_reset_talent}).


%%--------------------------------------------------------------------
%% @doc
%% @spec send the talent data to the client on login
%% @end
%%--------------------------------------------------------------------
talent_login_init()->
    packet:send(#notify_get_talent_active_info{active_talent_ids = get_actived_talent_id_list(),
                                               reset_active_hours = get_return_hours(get_reset_active_time()-get_current_second())}).
%%--------------------------------------------------------------------
%% @doc
%% @spec  talent unlock call function
%% @end
%%--------------------------------------------------------------------     
unlock(AdvancedLevel)->
    %%io:format("copyId: ~p~n",[CopyId]),
    save_talent_by_layer(AdvancedLevel).
    %% case State of 
    %%     false ->
    %%         ok;
    %%     true ->
    %%         case is_unlock_layer(CopyId) of
    %%             {true,UnlockLayer} ->
    %%                 save_talent_by_layer(UnlockLayer),
    %%                 ok;
    %%             false ->false
    %%         end
    %% end. 

%%--------------------------------------------------------------------
%% @doc
%% @spec base on the role's id to get talent list [{talent_id,level}..]
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_record_list_by_role_id(integer())->list()).
get_talent_record_list_by_role_id(RoleId)->
    case redis:hget("talent:level",RoleId) of
        undefined -> [];
        List -> 
            case is_list(List) of
                true -> [#talent{talent_id = Id,level = Level}||{Id,Level} <- List];
                false ->
                    io_helper:format("Talent bug inlegal data last time saved the date is:{role_id:~p,redis_data:~p}",[player:get_role_id(),List]), 
                    []
            end
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec active a talent callback function
%% @end
%%--------------------------------------------------------------------
proc_actived_talent(#req_actived_talent{talent_id = TalentId})->
    %% io_helper:format("proc_actived_talent:~p~n",[TalentId]),
    case is_job_match(TalentId) of
        true ->
            case check_talent_unlock(TalentId) of 
                true ->
                    case save_talent_actived(TalentId) of
                        {false,is_actived} ->
                            sys_msg:send_to_self(?sg_talent_actived,[]),
                            packet:send(#notify_actived_talent{talent_id = TalentId,is_success = ?common_failed});
                        true ->
                            packet:send(#notify_actived_talent{talent_id = TalentId,is_success = ?common_success});
                        {false,active_multy_a_layer} ->
                            sys_msg:send_to_self(?sg_talent_actived_two,[]),
                            packet:send(#notify_actived_talent{talent_id = TalentId,is_success = ?common_failed})
                    end;
                false ->
                    sys_msg:send_to_self(?sg_talent_layer_unlock,[]),
                    packet:send(#notify_actived_talent{talent_id = TalentId,is_success = ?common_failed})
            end;
        false ->
            sys_msg:send_to_self(?sg_talent_server_error,[]),
            io_helper:format("role type error,user:~p,talent :~p",[player_role:get_role_type(),get_tplt_job]),
            packet:send(#notify_actived_talent{talent_id = TalentId,is_success = ?common_failed})
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec talent level up callback function
%% @end
%%--------------------------------------------------------------------
proc_level_up_talent(#req_level_up_talent{talent_id = TalentId})->
    case check_talent_unlock(TalentId) of
        true ->
            OldLevel = get_talent_old_level(TalentId),
            case OldLevel < get_tplt_max_level(TalentId) of
                true ->
                    case is_skill_piece_enough(TalentId,OldLevel) of
                        true ->
                            case save_talent_actived_level(TalentId,OldLevel+1) of 
                                true ->
                                    sculpture_pack:reduce_frags(?item_frag,[get_tplt_skill_piece_id_num(TalentId,OldLevel)]),
                                    sculpture_pack:modify_level(?item_talent,TalentId,OldLevel+1),
                                    packet:send(#notify_level_up_talent{is_success = ?common_success});
                                false ->
                                    sys_msg:send_to_self(?sg_talent_unactived,[]),
                                    packet:send(#notify_level_up_talent{is_success = ?common_failed})   
                            end;
                        false ->
                            sys_msg:send_to_self(?sg_talent_not_enough_frag,[]),
                            packet:send(#notify_level_up_talent{is_success = ?common_failed})
                    end;
                false ->
                    sys_msg:send_to_self(?sg_talent_max_level,[]), 
                    packet:send(#notify_level_up_talent{is_success = ?common_failed}) %%to or over the max level

            end;
        {false} ->
            sys_msg:send_to_self(?sg_talent_layer_unlock,[]),
            packet:send(#notify_level_up_talent{is_success = ?common_failed})
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec reset the talent callback function
%% @end
%%--------------------------------------------------------------------
proc_reset_talent(#req_reset_talent{}) ->
    CuttentTime = get_current_second(),
    case get_actived_talent_id_list() of
        [] ->  sys_msg:send_to_self(?sg_talent_actived_reseted,[]),
               packet:send(#notify_reset_talent{is_success = ?common_failed});
        _Any -> 
            case is_reset_active_time_expired(CuttentTime) of
                true ->
                    case reset_talent_actived_list() of
                        true ->
                            case save_reseat_active_time(CuttentTime) of 
                                true ->  packet:send(#notify_reset_talent{is_success = ?common_success});     
                                false ->
                                    sys_msg:send_to_self(?sg_talent_server_error,[]),
                                    packet:send(#notify_reset_talent{is_success = ?common_failed})
                            end;
                        false -> 
                            sys_msg:send_to_self(?sg_talent_server_error,[]),
                            packet:send(#notify_reset_talent{is_success = ?common_failed})
                    end;
                false ->
                    case is_emoney_enough() of 
                        true -> 
                            case reset_talent_actived_list() of
                                true -> 
                                    player_role:reduce_emoney(?st_actived_talent,get_talent_reset_spend_emoney()),
                                    packet:send(#notify_reset_talent{is_success = ?common_success});     
                                false -> 
                                    sys_msg:send_to_self(?sg_talent_server_error,[]),
                                    packet:send(#notify_reset_talent{is_success = ?common_failed})
                            end;
                        false ->
                            sys_msg:send_to_self(?sg_talent_emoney_not_enough,[]),
                            packet:send(#notify_reset_talent{is_success = ?common_failed})
                    end
            end
    end.

%%--------------------------------------------------------------------
%% @doc
%% @specget get the actived talent list
%% @end
%%--------------------------------------------------------------------
-spec(get_actived_talent_id_list()->list()).
get_actived_talent_id_list()->
    case redis:hget("talent:level",player:get_role_id()) of
        undefined -> [];
        [] -> [];
        List -> 
            case is_list(List) of
                true -> 
                    to_id_list(List);
                false ->
                    io_helper:format("Talent bug inlegal data last time saved the date is:{role_id:~p,redis_data:~p}",[player:get_role_id(),List]), 
                    []
            end
    end.


%%%%%%%%%%%%%%%%%%%%%%%%% States check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%--------------------------------------------------------------------
%% @doc
%% @spec check the talent layer is unlocked by talent_id
%% @end
%%--------------------------------------------------------------------
%% -spec(is_talent_layer_unlock(integer())->boolean()).
%% is_talent_layer_unlock(TalentId)->
%%     case get_tplt_unlock_copy_id(TalentId) of
%%         undefined -> 
%%             io_helper:format("The talent_tplt read error,talentId:~p",[TalentId]),
%%             {false,tplt_error};
%%         CopyId ->
%%             case game_copy:check_copy_has_passed(CopyId) of
%%                 true -> 
%%                     case sculpture_pack:get_item_by_tempid(TalentId) of
%%                         undefined -> 
%%                             sculpture_pack:create_sculpture_and_save(?talent,?item_talent,TalentId,1),
%%                             true;
%%                         _ -> true
%%                     end;
%%                 false -> {false,copy_unpassed}
%%             end      
%%     end.

%%--------------------------------------------------------------------
%% @doc
%% @spec check the user have enough emoney to reset talent
%% @end
%%--------------------------------------------------------------------
-spec(is_emoney_enough() -> boolean()).
is_emoney_enough()->
    get_player_emoney() >= get_talent_reset_spend_emoney().

%%--------------------------------------------------------------------
%% @doc
%% @spec check the skill piece is enough to update talent level is 
%%     current talent level 
%%--------------------------------------------------------------------
-spec(is_skill_piece_enough(integer(),integer())->boolean()).
is_skill_piece_enough(TalentId,Level)->
    sculpture_pack:check_frag_amount([get_tplt_skill_piece_id_num(TalentId,Level)]).


%%--------------------------------------------------------------------
%% @doc
%% @spec check passing the copy is the conditiong to unlock talent layer.
%% @end
%%--------------------------------------------------------------------
%% -spec(is_unlock_layer(integer())->boolean()|{true,integer()}).
%% is_unlock_layer(CopyId)->
%%     Data = tplt:get_all_data(talent_tplt),
%%     case lists:keysearch(CopyId,9,Data) of
%%         {value,{talent_tplt,_Id,_Name,_Icon,_Level,_Job,_Position,Layer,UnlockCopyId,_LevelUpId}} ->
%%             case CopyId =:= UnlockCopyId of 
%%                 true ->
%%                     {true,Layer};
%%                 false -> false1
%%             end;
%%         false -> false
%%     end.

%%--------------------------------------------------------------------
%% @doc
%% @spec check the reset active is expired or not
%% @end
%%--------------------------------------------------------------------
-spec(is_reset_active_time_expired(integer())->boolean()).
is_reset_active_time_expired(CuttentTime)->
    (get_reset_active_time() - CuttentTime) =< 0.

is_job_match(TalentId)->
    get_tplt_job(TalentId) =:= player_role:get_role_type(). 

%%%%%%%%%%%%%%%%%%%%%%%%% Data Saved %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%--------------------------------------------------------------------
%% @doc
%% @spec save the actived talent list
%% @end
%%--------------------------------------------------------------------
-spec(reset_talent_actived_list()->boolean()).
reset_talent_actived_list()->
    case redis:hset("talent:level",player:get_role_id(),[]) of
        1->true;
        0->true;
        _->false
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec  save the actived talent id and level to redis tuple list
%% @end
%%--------------------------------------------------------------------

-spec(save_talent_actived_level(integer(),integer())->boolean()).
save_talent_actived_level(TalentId,NewLevel)->
    %%io_helper:format("Talent:~p,~p~n",[TalentId,NewLevel]),
    case redis:hget("talent:level",player:get_role_id()) of
        undefined -> 
            faslse;
        List ->
            %%io_helper:format("Talent:~p~n",[List]),
            case lists:keysearch(TalentId,1,List) of
                false ->
                    false;
                {value,{TalentId,Level}} ->
                    case NewLevel > Level of
                        true ->
                            redis:hset("talent:level",player:get_role_id(),lists:keyreplace(TalentId,1,List,{TalentId,Level+1})),
                            true;
                        false -> io_helper:format("~p's wrong level saved,old level:~p;new
    leve:~p~n",[TalentId,Level,NewLevel]),
                                 false
                    end
            end
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec save a new active talent to the actived talents
%% @end
%%--------------------------------------------------------------------
-spec(save_talent_actived(integer())->boolean()|{boolean(),atom()}).
save_talent_actived(TalentId)->
    TalentList = get_talent_tuple_list(),
    %% io_helper:format("save_talent_actived:~p~n",[TalentList]),
    case lists:keymember(TalentId,1,TalentList) of
        true -> {false,is_actived};
        false ->
            ListLayer = lists:map(fun({Id,_Level}) -> get_tplt_layer(Id) end,TalentList),
            case lists:member(get_tplt_layer(TalentId),ListLayer) of
                true ->
                    {false,active_multy_a_layer};
                false -> 
                    redis:hset("talent:level",player:get_role_id(),[to_id_level_tuple(TalentId)|TalentList]),
                    true
            end
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec save palyer's talent reset active time to redis.
%% @end
%%--------------------------------------------------------------------
save_reseat_active_time(CuttentTime)->
    case redis:hset("talent:reset_time",player:get_role_id(),CuttentTime + get_talent_reset_time_config()*3600) of
        0 -> true;
        1 -> true;
        _ -> false
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec save unloacked layer's talent to the underlying.
%% @end
%%--------------------------------------------------------------------
save_talent_by_layer(UnlockLayer)->  
    lists:foreach(fun(X)-> save_new_talent_by_id(X) end, get_talent_by_layer(UnlockLayer)).

%%--------------------------------------------------------------------
%% @doc
%% @spec save the talent to the underlying using the Sculpture_pack:
%%  create_sculpture_and_save(sourceTypdId,sculptureType,itemId)
%%--------------------------------------------------------------------
-spec(save_new_talent_by_id(integer())->ok).
save_new_talent_by_id(TalentId)->
    case sculpture_pack:get_item_by_tempid(TalentId) of
        undefined ->
            sculpture_pack:create_sculpture_and_save(?st_unlock_talent,?item_talent,TalentId,1);
        _Item -> ok
    end.


%%%%%%%%%%%%%%%%%%%%%%%%% Inner Tool %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%--------------------------------------------------------------------
%% @doc
%% @spec db and cache to get the talent leve.
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_old_level(integer())->integer()).
get_talent_old_level(TalentId) ->
    %% io_helper:format("get_talent_old_level:~p~n",[TalentId]),
    case sculpture_pack:get_item_by_tempid(TalentId) of
        undefined ->
            save_new_talent_by_id(TalentId),
            1;
        Item ->
            sculpture_pack:level(Item)
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec get the talent [{id,level}..] list from redis 
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_tuple_list()->list()).
get_talent_tuple_list()->    
    case redis:hget("talent:level",player:get_role_id()) of
        undefined -> [];
        List -> 
            case is_list(List) of
                true -> List;
                false ->
                    io_helper:format("Talent bug inlegal data last time saved the date is:{role_id:~p,redis_data:~p}",[player:get_role_id(),List]), 
                    []
            end
    end.

%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @spec get the skill piece num by talent Id and current talent level
%% %% @end
%% %%--------------------------------------------------------------------
%% get_skill_piece_num(TalentId,Level)->
%%     sculpture_pack:get_item_by_tempid(get_tplt_skill_piece_id_num(TalentId,Level)).

%%--------------------------------------------------------------------
%% @doc
%% @spec Auxiliary function for reset time return hours
%% @end
%%--------------------------------------------------------------------
-spec(get_return_hours(integer())->integer()).
get_return_hours(Time)->
    case Time =< 0 of 
        true -> 0;
        false ->
            case Time rem 3600 > 0 of
                true ->  Time div 3600 + 1;
                false -> Time div 3600 + 0
            end    
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get the reest time in the config.cfg itemt is talent_reseat_hours
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_reset_time_config()->integer()).
get_talent_reset_time_config()->
    config:get(talent_reseat_hours).

%%--------------------------------------------------------------------
%% @doc
%% @spec get the emoney spend to reset talent
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_reset_spend_emoney()->integer()).
get_talent_reset_spend_emoney()->
    config:get(talent_reset_emoney).

%%--------------------------------------------------------------------
%% @doc   
%% @spec  get the talent reset active time(hours)
%% @end
%%--------------------------------------------------------------------
-spec(get_reset_active_time()->integer()).
get_reset_active_time()->
    case redis:hget("talent:reset_time",player:get_role_id()) of
        undefined -> 0;
        ResetTime ->
            case ResetTime >= get_current_second() of
                true -> ResetTime;
                false -> 0
            end
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec  read the talent_tplt xml config and some function to 
%%       get one someone detail of the function
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_tplt(integer())->boolean()|{true,tuple()}).
get_talent_tplt(TalentId)->
    try
	TpltInfo = tplt:get_data(talent_tplt, TalentId),
	{true, TpltInfo}
    catch
	_ : _ ->
	    false
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get the talent_level_up_tplt.xml data to a list
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_level_up_tplt(integer(),integer())->{true,integer()}|boolean()).
get_talent_level_up_tplt(TalentId,Level)->
    try
	LevelUpInfo = tplt:get_data(talent_level_up_tplt, get_tplt_level_up_id(TalentId,Level)),
        %% io:format("talentId:~p,level:~p,info:~p~n",[TalentId,Level,LevelUpInfo]),%%debug the tplt config
	{true, LevelUpInfo}
    catch
	_ : _ ->
	    false
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get the talent belons to layer
%% @end
%%--------------------------------------------------------------------
-spec(get_tplt_layer(integer())->undefined|integer()).
get_tplt_layer(TalentId)->
    case get_talent_tplt(TalentId) of
        {true,#talent_tplt{layer = Layer}} -> Layer;
        false -> undefined
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get unlock the talent copy id
%% @end
%%--------------------------------------------------------------------
%%-spec(get_tplt_unlock_copy_id(integer())->undefined|integer()).
%% get_tplt_unlock_copy_id(TalentId) ->
%%     case get_talent_tplt(TalentId) of
%%         {true,#talent_tplt{unlock_copy_id = UnlockCopyId}} ->
%%             UnlockCopyId;
%%         false -> undefined
%%     end.
check_talent_unlock(TalentId) ->
    case get_talent_tplt(TalentId) of
        {true,#talent_tplt{layer = AdvanceLevel}} ->
            player_role:get_advanced_level() >= AdvanceLevel;
        false -> false
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get the talent max Level
%% @end
%%--------------------------------------------------------------------
-spec(get_tplt_max_level(integer())->undefined|integer()).
get_tplt_max_level(TalentId)->
    case get_talent_tplt(TalentId) of
        {true,#talent_tplt{max_level = MaxLevel}} ->
            MaxLevel;
        false -> undefined
    end.
-spec(get_tplt_job(integer())->integer()|undefined).
get_tplt_job(TalentId)->
    case get_talent_tplt(TalentId) of
        {true,#talent_tplt{job = Job}} ->
            Job;
        false -> undefined
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get unlock the talent's copy id
%% @end
%%--------------------------------------------------------------------
-spec(get_tplt_level_up_id(integer(),integer()) -> undefined|integer()).
get_tplt_level_up_id(TalentId,Level) ->
    case get_talent_tplt(TalentId) of
        {true,#talent_tplt{level_up_id = LevelUpId}} ->
            LevelUpId*100+Level;
        false -> undefined
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get update talent to a Level need skill piece's Id
%% @end
%%--------------------------------------------------------------------
%%-spec(get_tplt_skill_piece_id(integer(),integer())->undefined|[integer(),integer()]).
%%get_tplt_skill_piece_id(TalentId,Level)->
%% case get_talent_level_up_tplt(TalentId,Level)of 
%%     {true,#talent_level_up_tplt{skill_piece_id = SkillPieceId}} -> SkillPieceId;
%%     false ->   
%%         %%io_helper:format("tplt_error,talentId is ~p,level:~p~n",[TalentId,Level]),
%%         undefined   
%% end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get update talent to a Level need skill piece id and number.
%% @end
%%--------------------------------------------------------------------
-spec(get_tplt_skill_piece_id_num(integer(),integer())->undefined|{integer(),integer()}).
get_tplt_skill_piece_id_num(TalentId,Level)->
    case get_talent_level_up_tplt(TalentId,Level)of 
        {true,#talent_level_up_tplt{skill_piece_id = SkillPieceId,skill_piece_num = SkillPieceNum}} ->
            %%io_helper:format("get_tplt_skill_piece_id_num:~p~n",[{SkillPieceId,SkillPieceNum}]),
            {SkillPieceId,SkillPieceNum};
        false -> 
            %% io_helper:format("tplt_error,talentId is ~p,level:~p~n",[TalentId,Level]),
            undefined       
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec get the talent List of a layer
%% @end
%%--------------------------------------------------------------------
-spec(get_talent_by_layer(list())->list()).
get_talent_by_layer(FilterLayer)->
    Data = lists:map(
             fun(#talent_tplt{id = Id, layer = Layer}) ->
                     case FilterLayer =:=Layer of 
                         true -> Id;
                         false -> -1 end 
             end,
             tplt:get_all_data(talent_tplt)),
    lists:filter(fun(X) -> X =/= -1 end,Data).
%%--------------------------------------------------------------------
%% @doc
%% @spec inner date function to get the Hours now().
%% @end return  {Year,Month,Day,Hour}
%%--------------------------------------------------------------------
-spec(get_current_second()->integer()).
get_current_second()->    
    calendar:datetime_to_gregorian_seconds(calendar:local_time()).

%%--------------------------------------------------------------------
%% @doc
%% @spec  get the emoney user had.
%% @end
%%--------------------------------------------------------------------
-spec(get_player_emoney()->integer()).
get_player_emoney()->
    player_role:get_emoney().


%%--------------------------------------------------------------------
%% @doc
%% @spec translate a tuple [{id,level}..] list to a id [id..] list 
%% @end
%%--------------------------------------------------------------------
-spec(to_id_list(list())->list()).
to_id_list(TupleList)->
    lists:map(fun({TalentId,_Level}) -> TalentId end,TupleList).
%%--------------------------------------------------------------------
%% @doc
%% @spec  change a talent id to {id,level} tuple struction
%% @end
%%--------------------------------------------------------------------
-spec(to_id_level_tuple(integer())->{integer(),integer()}).
to_id_level_tuple(TalentId)->
    {TalentId,get_talent_old_level(TalentId)}.




%%%%%%%%%%%%%%%%%%%%%%%% GM TOOL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% gm_unlock_talent(TalentId)->
%%     case get_tplt_unlock_copy_id(TalentId) of
%%         undefined -> false;
%%         CopyId ->
%%             case game_copy:check_copy_has_passed(CopyId) of 
%%                 false->
%%                     gm_tools:proc_pass_copy(CopyId),
%%                     save_talent_by_layer(get_tplt_layer(TalentId)),
%%                     true;
%%                 true -> true
%%             end
%%     end.


%% gm_active_talent(TalentId)->
%%     gm_unlock_talent(TalentId),
%%     save_talent_actived(TalentId).

%% gm_level_up_talet(TalentId)->
%%     gm_unlock_talent(TalentId),
%%     OldLevel = get_talent_old_level(TalentId),
%%     case OldLevel < get_tplt_max_level(TalentId) of
%%         true ->
%%             case is_skill_piece_enough(TalentId,OldLevel) of
%%                 true ->
%%                     save_talent_actived_level(TalentId,OldLevel+1);
%%                 false ->
%%                     false
%%             end;
%%         false ->
%%             false
%%     end.
