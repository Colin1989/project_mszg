-module(daily_award).


-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").
-include("enum_def.hrl").
-include("business_log_def.hrl").
-include("sys_msg.hrl").
-record(sign_status, {last_sign_time, cumulate_days, last_cumulate_award_time, cumulate_status3, cumulate_status7, cumulate_status15}).
-define(award_status_sign,1).
-define(award_status_not_sign,0).
-export([proc_req_get_daily_award/1, notify_daily_award_info/0,start/0,notify_sys_time/0]).

-compile(export_all).

start()->
    packet:register(?msg_req_get_daily_award, {?MODULE, proc_req_get_daily_award}),
    ok.


proc_req_get_daily_award(#req_get_daily_award{type = Type})->
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    {SignStatus, TodaySigns, CumulateDays, NewStatus3, NewStatus7, NewStatus15} = get_continueday_and_today_status(),
    TodaySign = case Type of
		    ?daily_award ->
			TodaySigns;
		    ?cumulative_award3 ->
			NewStatus3;
		    ?cumulative_award7 ->
			NewStatus7;
		    ?cumulative_award15 ->
			NewStatus15
		end,
    case TodaySign =:= ?award_status_not_sign of
	true ->
	     case get_award(Role:level(), CumulateDays, Type) of
		 0 ->
		     sys_msg:send_to_self(?sg_daily_award_cannot_get,[]),
		     packet:send(#notify_get_daily_award_result{result  = ?common_failed, type = Type});
		 AwardId ->
		     NewStatus = update_sign_statics(SignStatus, Type, CumulateDays, NewStatus3, NewStatus7, NewStatus15),
		     give_out_award(AwardId),
		     %%{Gold, Gems, ChipId, ChipAmount} = get_gift_bag_by_id(AwardId),
		     %% case Gold of
		     %% 	 0->
		     %% 	     ok;
		     %% 	 _ ->
		     %% 	     player_role:add_gold(?st_daily_award, Gold)
		     %% end,
		     %% AllItems = make_item_tuples(Gems),
		     %% player_role:add_sculpture_frag(?st_daily_award, ChipAmount),
		     %% player_pack:add_items(?st_daily_award, AllItems),
		     packet:send(#notify_get_daily_award_result{result  = ?common_success, type = Type}),
		     notify_daily_award_info(NewStatus)
	     end;
	false ->
	    sys_msg:send_to_self(?sg_daily_award_get_already,[]),
	    packet:send(#notify_get_daily_award_result{result  = ?common_failed, type = Type})
    end.

get_today_time()->
    {erlang:date(),{0,0,0}}.

get_yesterday_time()->
    {Date, _} = datetime:gregorian_seconds_to_datetime(
    (datetime:datetime_to_gregorian_seconds(get_today_time()) - 1)),
    {Date,{0,0,0}}.


make_item_tuples(GrandItems)->
    ItemTuples=lists:map(fun(X) ->
				 {X,1}
			 end,GrandItems),
    ItemTuples.

notify_daily_award_info()->
    {_SignStatus, TodaySigns, CumulateDays, NewStatus3, NewStatus7, NewStatus15} = get_continueday_and_today_status(),
    packet:send(#nofity_continue_login_award_info{continue_login_days = CumulateDays, daily_award_status = TodaySigns, 
						  cumulative_award3_status = NewStatus3, cumulative_award7_status = NewStatus7, 
						  cumulative_award15_status = NewStatus15}).

notify_daily_award_info(NewStatus)->
    {TodaySigns, CumulateDays, NewStatus3, NewStatus7, NewStatus15} = NewStatus,
    packet:send(#nofity_continue_login_award_info{continue_login_days = CumulateDays, daily_award_status = TodaySigns, 
						  cumulative_award3_status = NewStatus3, cumulative_award7_status = NewStatus7, 
						  cumulative_award15_status = NewStatus15}).


notify_sys_time()->
    Now = datetime:localtime(),
    packet:send(#notify_sys_time{sys_time = Now}).



get_continueday_and_today_status()->
    case get_sign_statics() of
	0 ->
	    {init_status(), 0, 0, 0, 0, 0};
	#sign_status{last_sign_time = LastTime, cumulate_days = CumulateDays, last_cumulate_award_time = LastAwardTime,
		     cumulate_status3 = AwardStatus3, cumulate_status7 = AwardStatus7, cumulate_status15 = AwardStatus15} = SignStatus->
	    TodaySigns = case (datetime:datetime_to_gregorian_seconds(erlang:localtime()) - 
				   datetime:datetime_to_gregorian_seconds(LastTime)) < 86400 of
			     true ->
				 ?award_status_sign;
			     false ->
				 ?award_status_not_sign
			 end,
	    {NewCumulateDays, NewStatus3, NewStatus7, NewStatus15} = case CumulateDays of
    			       _ when (CumulateDays >= 15) and (AwardStatus15 =:= 1) ->
    				   case (datetime:datetime_to_gregorian_seconds(erlang:localtime()) - 
    				   datetime:datetime_to_gregorian_seconds(LastAwardTime)) < 86400 of
    				       false ->
    					   {0, 0, 0, 0};
    				       true ->
    					   {CumulateDays, AwardStatus3, AwardStatus7, AwardStatus15}
    				   end;
    			       _ ->
    				   {CumulateDays, AwardStatus3, AwardStatus7, AwardStatus15}
    			   end,
	    {SignStatus, TodaySigns, NewCumulateDays, NewStatus3, NewStatus7, NewStatus15}
    end.

init_status()->
    Yesterday = get_yesterday_time(),
    #sign_status{last_sign_time = Yesterday, cumulate_days = 0, last_cumulate_award_time = Yesterday,
		     cumulate_status3 = 0, cumulate_status7 = 0, cumulate_status15 = 0}.

get_sign_statics() ->
    case cache:get(sign_status, player:get_role_id()) of
	[] ->
	    0;
	[{_, Status}] ->
	    Status
    end.

update_sign_statics(OldStatus, OptType, CumulateDays, NewStatus3, NewStatus7, NewStatus15) ->
    %%NewStatus = OldStatus,
    NewStatus = case OptType of
	?daily_award ->
			OldStatus#sign_status{last_sign_time = get_today_time(), cumulate_days = CumulateDays + 1,
					      cumulate_status3 = NewStatus3, cumulate_status7 = NewStatus7, cumulate_status15 = NewStatus15};
	?cumulative_award3 ->
			OldStatus#sign_status{cumulate_days = CumulateDays,last_cumulate_award_time = get_today_time(),
					      cumulate_status3 = ?award_status_sign, cumulate_status7 = NewStatus7, cumulate_status15 = NewStatus15};
	?cumulative_award7 ->
			OldStatus#sign_status{ cumulate_days = CumulateDays,last_cumulate_award_time = get_today_time(),
					      cumulate_status3 = NewStatus3, cumulate_status7 = ?award_status_sign, cumulate_status15 = NewStatus15};
	?cumulative_award15 ->
			OldStatus#sign_status{ cumulate_days = CumulateDays,last_cumulate_award_time = get_today_time(),
					      cumulate_status3 = NewStatus3, cumulate_status7 = NewStatus7, cumulate_status15 = ?award_status_sign}
    end,
    TodaySigns = case (datetime:datetime_to_gregorian_seconds(erlang:localtime()) - 
				   datetime:datetime_to_gregorian_seconds(NewStatus#sign_status.last_sign_time)) < 86400 of
			     true ->
				 ?award_status_sign;
			     false ->
				 ?award_status_not_sign
			 end,
    cache:set(sign_status, player:get_role_id(), NewStatus),
    {TodaySigns, NewStatus#sign_status.cumulate_days, NewStatus#sign_status.cumulate_status3, 
     NewStatus#sign_status.cumulate_status7,NewStatus#sign_status.cumulate_status15}.


get_award(RoleLev, CumulativeDay, Type)->
    Datas = tplt:get_all_data(daily_award_tplt),
    [Data]  = lists:filter(fun(X) -> 
				   case X#daily_award_tplt.level_range of
				       [Min, Max] ->
					 (Min =< RoleLev) and (Max >= RoleLev);
				     [Lev] ->
					 Lev =:= RoleLev
				 end

		 end, Datas),
    case Type of
	?daily_award ->
	    Data#daily_award_tplt.days1_award;
	?cumulative_award3 ->
	    case CumulativeDay >= 3 of
		true ->
		    Data#daily_award_tplt.days3_award;
		_ ->
		    0
	    end;
	?cumulative_award7 ->
	    case CumulativeDay >= 7 of
		true ->
		    Data#daily_award_tplt.days7_award;
		_ ->
		    0
	    end;
	?cumulative_award15 ->
	    case CumulativeDay >= 15 of
		true ->
		    Data#daily_award_tplt.days15_award;
		_ ->
		    0
	    end
    end.


%% get_gift_bag_by_id(AwardId)->
%%     Data = tplt:get_data(gift_bag_tplt, AwardId),
%%     {Data#gift_bag_tplt.item_id, Data#gift_bag_tplt.item_amount}.


give_out_award(AwardId) ->
    log:create(business_log, [player:get_role_id(), 0, ?bs_daily_task, ?TASK, erlang:localtime(), erlang:localtime(), 0]),
    Data = tplt:get_data(gift_bag_tplt, AwardId),
    reward:give(Data#gift_bag_tplt.item_id, Data#gift_bag_tplt.item_amount, ?st_daily_award).

    
    
    
