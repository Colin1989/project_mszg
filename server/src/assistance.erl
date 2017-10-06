-module(assistance).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("record_def.hrl").
-include("tplt_def.hrl").

-define(add_friend_point, 1).
-define(dec_friend_point, 2).

-export([start/0]).

-export([proc_req_assistance_list/1,
		 proc_req_select_donor/1,
		 insert_role_info/1,
		 notify_assistance_info/0,
		 get_point/0]).

-compile(export_all).

start() ->
	packet:register(?msg_req_assistance_list, {?MODULE, proc_req_assistance_list}),
	packet:register(?msg_req_select_donor, {?MODULE, proc_req_select_donor}),
	packet:register(?msg_req_refresh_assistance_list, {?MODULE, proc_refresh_assistance_list}),
	packet:register(?msg_req_friend_point_lottery, {?MODULE, proc_req_friend_point_lottery}),
	packet:register(?msg_req_fresh_lottery_list, {?MODULE, proc_req_fresh_lottery_list}),
	ok.


%%--------------------------------------------------------------------
%% @doc
%% @请求援助列表
%% @end
%%--------------------------------------------------------------------
proc_req_assistance_list(Packet) ->
	io_helper:format("~p~n", [Packet]),
	List = get_assistance_list(),
	packet:send(#notify_assistance_list{donors = List}),
	ok.


%%--------------------------------------------------------------------
%% @doc
%% @选择援助
%% @end
%%--------------------------------------------------------------------
proc_req_select_donor(#req_select_donor{donor_id = DonorId} = Packet) ->
	io_helper:format("~p~n", [Packet]),
	case get_assistance_list() of
		undefined ->
			sys_msg:send_to_self(?sg_assistance_no_req_list, []),
			packet:send(#notify_select_donor_result{result = ?common_error});
		List ->
			case lists:filter(fun(X) -> X#donor.role_id =:= DonorId end, List) of
				[] ->
					sys_msg:send_to_self(?sg_assistance_select_id_not_in_list, []),
					packet:send(#notify_select_donor_result{result = ?common_error});
				[Donor] ->
					save_assistance_info(Donor),
					update_assistanced_list(Donor#donor.role_id),
					packet:send(#notify_select_donor_result{result = ?common_success})
			end
	end.

get_assistanced_list() ->
    {_Year, _Month, Day} = erlang:date(),
	case get(assistanced_list) of
		undefined ->
		    reset_assistanced_list_in_dict(Day);
	    {AssistancedList, RecordDay} ->
			case RecordDay =:= Day of
			     true ->
				 AssistancedList;
			    false ->
				reset_assistanced_list_in_dict(Day)
			end

	end.

reset_assistanced_list_in_dict(Day) ->
    List = get_assistanced_list_in_cache(),
    put(assistanced_list, {List, Day}),
    List.

get_assistanced_list_in_cache() ->
	case cache_with_expire:get('assistance:assistanced_list', player:get_role_id()) of
		[] ->
			[];
		[{_, Value}] ->
			Value
	end.

update_assistanced_list(AssistanceID) ->
	OldList = get_assistanced_list(),
	case lists:any(fun(E) -> AssistanceID =:= E end, OldList) of
		true ->
			ok;
		false ->
			RoleID = player:get_role_id(),
			NewList = [AssistanceID | OldList],
		    	{_Year, _Month, Day} = erlang:date(),
			put(assistanced_list, {NewList, Day}),
			cache_with_expire:set('assistance:assistanced_list', RoleID, NewList, day)
	end.
%%--------------------------------------------------------------------
%% @doc
%% @生成援助列表
%% @end
%%--------------------------------------------------------------------
notify_assistance_info() ->
	packet:send(#notify_assistance_info{lottery_times = get_lottery_times(), refresh_times = get_refresh_times()}).


%%--------------------------------------------------------------------
%% @doc
%% @生成援助列表
%% @end
%%--------------------------------------------------------------------
get_assistance_list() ->
	case check_is_need_fresh_list() of
		true ->
			get_new_list();
		false ->
			get_assistance_list_in_cache()
	end.

get_new_list() ->
	RoleId = player:get_role_id(),
	FriendList = redis_extend:srand_members_info(lists:concat([role, '_friends:', RoleId]), role_info_detail, config:get(friend_assistance_amount)),

	Length = config:get(total_assistance_amount) - length(FriendList),
	HelperList = lists:filter(fun({Id, _}) -> (Id =/= RoleId) and (not find_id_exist(Id, FriendList)) end,
							  redis_extend:srand_members_info(all_roleid_set, role_info_detail, Length)),

	AssistanceList = lists:filter(fun(X) ->
		X#donor.role_id =/= 0
								  end,
								  make_donor_list(friend, get_assist_times(friend), FriendList) ++ make_donor_list(other, get_assist_times(other), HelperList)),

	RobotList = gen_robot_list(config:get(total_assistance_amount) - length(AssistanceList), []),
	FixAssistanceList = AssistanceList ++ RobotList,
	cache_with_expire:set('assistance:assistance_list', RoleId, FixAssistanceList, day),
	FixAssistanceList.

gen_robot_list(Num, ListContainer) when Num =< 0 ->
	ListContainer;
gen_robot_list(Num, ListContainer) ->
	NickName = rand_nickname:rand_nickname(),
	Type = rand:uniform(4),
	RoleTplt = tplt:get_data(role_tplt,Type),
	Donor = #donor{role_id = uuid:gen(), rel = ?other, level = 1, role_type = Type, nick_name = NickName, friend_point = config:get(first_time_other_point),
				   power = 0, sculpture = #sculpture_data{temp_id=RoleTplt#role_tplt.default_sculpture, level=1},
				   potence_level = 100, advanced_level = 1,
				   is_used = 0, is_robot = 1},
	gen_robot_list(Num - 1, [Donor | ListContainer]).

set_assistancce_role_has_used(Donor) ->
	AssistanceList = get_assistance_list_in_cache(),
	NewList = lists:keyreplace(Donor#donor.role_id, #donor.role_id, AssistanceList, Donor#donor{is_used = 1}),
	cache_with_expire:set('assistance:assistance_list', player:get_role_id(), NewList, day).

check_is_need_fresh_list() ->
	case get_assistance_list_in_cache() of
		[] ->
			true;
		AssistanceList ->
			lists:all(fun(E) -> E#donor.is_used =:= 1 end, AssistanceList)
	end.

get_assistance_list_in_cache() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('assistance:assistance_list', RoleID) of
		[] ->
			[];
		[{_Key, Value}] ->
			Value
	end.

find_id_exist(Id, Array) ->
	case lists:filter(fun({ID, _}) -> Id =:= ID end, Array) of
		[] ->
			false;
		_ ->
			true
	end.


%%--------------------------------------------------------------------
%% @doc
%% @转化成[T::#donor{}]
%% @end
%%--------------------------------------------------------------------
make_donor_list(_Type, _Times, []) ->
	[];
make_donor_list(Type, Times, [Donor | Donors]) ->
	[make_donor(Type, Times, Donor) | make_donor_list(Type, Times, Donors)].


make_donor(Type, _Times, {Id, Data}) ->
	Relation = case Type of
				   friend ->
					   ?friend;
				   _ ->
					   ?other
			   end,
	case roleinfo_manager:upgrade_data(Id, Data) of
		undefined ->
			#donor{role_id = 0};
		Info ->
			#donor{role_id = Id, level = Info#role_info_detail.level, role_type = Info#role_info_detail.type, nick_name = Info#role_info_detail.nickname,
				   friend_point = get_friend_point(Id, Type), power = Info#role_info_detail.battle_prop#role_attr_detail.battle_power,
				   sculpture = rand_sculpture(Info#role_info_detail.type, Info#role_info_detail.battle_prop#role_attr_detail.sculptures),
				   potence_level = Info#role_info_detail.potence_level, advanced_level = Info#role_info_detail.advanced_level, rel = Relation}
	end.

%% case Data of
%% 	_ when not is_record(Data,friend_data) orelse (not is_record(Data#friend_data.battle_prop,battle_info))->
%% 	    Info=roleinfo_manager:upgrade_data(Id, Data),%%(Id),
%% 	    case Info of
%% 		undefined ->
%% 		    #donor{role_id = 0};
%% 		_ ->
%% 		    #donor{role_id = Id, level = Info#friend_data.level, role_type = Info#friend_data.head, nick_name=Info#friend_data.nickname,
%% 			  friend_point=get_friend_point(Type,Times), power=Info#friend_data.battle_prop#battle_info.power,
%% 			  sculpture = rand_sculpture(Info#friend_data.head,Info#friend_data.battle_prop#battle_info.sculpture),rel=Relation}
%% 	    end;
%% 	_ ->
%% 	    #donor{role_id = Id, level = Data#friend_data.level, role_type = Data#friend_data.head, nick_name=Data#friend_data.nickname,
%% 		   friend_point=get_friend_point(Type,Times), power=Data#friend_data.battle_prop#battle_info.power,
%% 		   sculpture = rand_sculpture(Data#friend_data.head,Data#friend_data.battle_prop#battle_info.sculpture),rel=Relation}
%% end.

%%--------------------------------------------------------------------
%% @doc
%% @随机选择符文
%% @end
%%--------------------------------------------------------------------
rand_sculpture(Type, List) ->
	CuList = lists:filter(fun(X) -> X =/= #sculpture_data{} end, List),
	case length(CuList) of
		0 ->
			player_role:get_default_sculpture_by_role_type(Type);
		Len ->
			lists:nth(rand:uniform(Len), CuList)
	end.

%%--------------------------------------------------------------------
%% @doc
%% @ 友情点相关
%% @end
%%--------------------------------------------------------------------
get_point() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('assistance:point', RoleID) of
		[] ->
			0;
		[{_Key, Value}] ->
			Value
	end.

add_point(Type, Point) ->
	RoleID = player:get_role_id(),
	CurPoint = get_point(),
	update_point(RoleID, CurPoint + Point),
	player_log:create(RoleID, ?friend_point, Type, ?add_friend_point, 0, 0, Point, CurPoint + Point).

reduce_point(Type, Point) ->
	RoleID = player:get_role_id(),
	CurPoint = get_point(),
	update_point(RoleID, CurPoint - Point),
	player_log:create(RoleID, ?friend_point, Type, ?dec_friend_point, 0, 0, Point, CurPoint - Point).

update_point(RoleID, Point) ->
	case Point < 0 of
		false ->
			cache_with_expire:set('assistance:point', RoleID, Point, day),
			packet:send(#notify_role_info_change{type = "friend_point", new_value = Point});
		true ->
			ok
	end.
%%--------------------------------------------------------------------
%% @doc
%% @获取可获得的好友点数
%% @end
%%--------------------------------------------------------------------
%% get_friend_point(Type, Times) ->
%% 	case Times >= 1 of
%% 		true ->
%% 			1;
%% 		false ->
%% 			case Type of
%% 				friend ->
%% 					10;
%% 				other ->
%% 					5
%% 			end
%% 	end.

get_friend_point(AssistanceID, Type) ->
	case lists:any(fun(E) -> AssistanceID =:= E end, get_assistanced_list()) of
		true ->
			config:get(second_time_assistance_point);
		false ->
			case Type of
				friend ->
					config:get(first_time_friend_point);
				other ->
					config:get(first_time_other_point)
			end
	end.
%%--------------------------------------------------------------------
%% @doc
%% @获取对应类别今天的援助次数
%% @end
%%--------------------------------------------------------------------
get_assist_times(Type) ->
	Times = case cache_with_expire:get(list_to_atom(lists:concat([assist_by_, Type])), player:get_role_id()) of
				[] -> 0;
				[Timeds | _] -> element(2, Timeds)
			end,
	Times.


%%--------------------------------------------------------------------
%% @doc
%% @累加今天的援助次数
%% @end
%%--------------------------------------------------------------------
increase_assist_times(Type) ->
	cache_with_expire:increase(list_to_atom(lists:concat([assist_by_, Type])), player:get_role_id(), day).


%%--------------------------------------------------------------------
%% @doc
%% @存入角色信息，供随机使用
%% @end
%%--------------------------------------------------------------------
insert_role_info(RoleId) ->
	case RoleId of
		undefined ->
			ok;
		_ ->
			redis:sadd(all_roleid_set, [RoleId])
	end.

%%--------------------------------------------------------------------
%% @doc
%% @援助结算
%% @end
%%--------------------------------------------------------------------
assistance_settle(_Result, Type) ->
	case get_assistance_info() of
		[] ->
			ok;
		[{_, Donor}] ->
			case Donor#donor.rel of
				?friend ->
					increase_assist_times(friend);
				?other ->
					increase_assist_times(other)
			end,
			set_assistancce_role_has_used(Donor),
			%%player_role:add_point(Type, Point)
			add_point(Type, Donor#donor.friend_point)
	end.
	%%delete_assistance_info().

%%--------------------------------------------------------------------
%% @doc
%% @援助信息增删改
%% @end
%%--------------------------------------------------------------------
delete_assistance_info() ->
	cache:delete(role_assistance_info, player:get_role_id()).

save_assistance_info(Info) ->
	cache:set(role_assistance_info, player:get_role_id(), Info).

get_assistance_info() ->
	cache:get(role_assistance_info, player:get_role_id()).


%%--------------------------------------------------------------------
%% @doc
%% @ 刷新列表相关
%% @end
%%--------------------------------------------------------------------
proc_refresh_assistance_list(Packet) ->
	io_helper:format("Packet:~p~n", [Packet]),
	RefreshTimes = get_refresh_times(),
	case RefreshTimes >= config:get(free_refresh_assistance_list_times) of
		true ->
			Emoney = player_role:get_emoney(),
			NeedEmoney = config:get(refresh_assistance_list_emoney),
			case Emoney >= NeedEmoney of
				true ->
					player_role:reduce_emoney(?st_assistance, NeedEmoney),
					increase_refresh_times(),
					NewList = get_new_list(),
					packet:send(#notify_assistance_list{donors = NewList}),
					packet:send(#notify_refresh_assistance_list_result{result = ?common_success});
				false ->
					packet:send(#notify_refresh_assistance_list_result{result = ?common_failed})
			end;
		false ->
			increase_refresh_times(),
			packet:send(#notify_assistance_info{lottery_times = get_lottery_times(), refresh_times = RefreshTimes + 1}),
			NewList = get_new_list(),
			packet:send(#notify_assistance_list{donors = NewList}),
			packet:send(#notify_refresh_assistance_list_result{result = ?common_success})
	end.

get_refresh_times() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('assistance:refresh_times', RoleID) of
		[] ->
			0;
		[{_Key, Value}] ->
			Value
	end.

increase_refresh_times() ->
	cache_with_expire:increase('assistance:refresh_times', player:get_role_id(), day).

%%--------------------------------------------------------------------
%% @doc
%% @ 请求刷新摇奖列表
%% @end
%%--------------------------------------------------------------------
proc_req_fresh_lottery_list(Packet) ->
	io_helper:format("Packet:~p~n", [Packet]),
	ItemTpltList = tplt:get_all_data(friend_point_lottery_item_tplt),
	TotalRate = lists:foldl(fun(T, Sum) -> T#friend_point_lottery_item_tplt.rate + Sum end, 0, ItemTpltList),
	FinalItem = get_final_item(rand:uniform(TotalRate), ItemTpltList),
	cache_with_expire:set('assistance:lottery_item', player:get_role_id(),
						  {FinalItem#friend_point_lottery_item_tplt.itemd_id, FinalItem#friend_point_lottery_item_tplt.amount}, day),
	RemainItemList = rand:rand_members_from_list_not_repeat(ItemTpltList -- [FinalItem], 7),
	LotteryItems = rand:rand_members_from_list_not_repeat(RemainItemList ++ [FinalItem], 8), %% 将顺序打乱

	FixLotteryItems = lists:foldl(
		fun(T, Container) ->
			[#friend_point_lottery_item{id = T#friend_point_lottery_item_tplt.itemd_id,
										amount = T#friend_point_lottery_item_tplt.amount} | Container]
		end, [], LotteryItems),
	packet:send(#notify_fresh_lottery_list{lottery_items = FixLotteryItems}).

get_final_item(RandResult, [Item | ItemTpltList]) ->
	case RandResult =< Item#friend_point_lottery_item_tplt.rate of
		true ->
			Item;
		false ->
			get_final_item(RandResult - Item#friend_point_lottery_item_tplt.rate, ItemTpltList)
	end.

%%--------------------------------------------------------------------
%% @doc
%% @ 请求摇奖
%% @end
%%--------------------------------------------------------------------
proc_req_friend_point_lottery(Packet) ->
	io_helper:format("Packet:~p~n", [Packet]),
	LottryTimes = get_lottery_times(),
	LotteryInfo = case LottryTimes of
					Times when Times >= 11 ->
						get_tplt(11);
					  Other ->
						  get_tplt(Other + 1)
				  end,
	FriendPoint = get_point(),
	NeedFriendPoint = LotteryInfo#friend_point_lottery_tplt.need_point,

	case NeedFriendPoint > FriendPoint of
		true ->
			packet:send(#notify_friend_point_lottery_result{result = ?common_failed});
		false ->
		    	case cache_with_expire:get('assistance:lottery_item', player:get_role_id()) of
			    [{_Key, {FinalItem, Amount}}]  ->
				cache:delete('assistance:lottery_item', player:get_role_id()),
				reward:give([FinalItem], [Amount], ?st_assistance),
				reduce_point(?st_assistance, NeedFriendPoint),
				increase_lottery_times(),
				%%activeness_task:update_activeness_task_status(friend_lottery),
				packet:send(#notify_friend_point_lottery_result{result = ?common_success, amount = Amount, id = FinalItem}),
				packet:send(#notify_assistance_info{lottery_times = LottryTimes + 1, refresh_times = get_refresh_times()});
			    _ ->
				sys_msg:send_to_self(?sg_assistance_get_lottery_item_err, []),
				packet:send(#notify_friend_point_lottery_result{result = ?common_failed})
			end
	end.

get_lottery_times() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('assistance:lottery_times', RoleID) of
		[] ->
			0;
		[{_Key, Value}] ->
			Value
	end.

increase_lottery_times() ->
	cache_with_expire:increase('assistance:lottery_times', player:get_role_id(), day).
%%--------------------------------------------------------------------
%% @doc
%% @ 奖励模版相关
%% @end
%%--------------------------------------------------------------------
get_tplt(ID) ->
	tplt:get_data(friend_point_lottery_tplt, ID).

get_tplt_need_point(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#friend_point_lottery_tplt.need_point.

get_tplt_times(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#friend_point_lottery_tplt.times.

get_lottery_item_tplt(ID) ->
	tplt:get_data(friend_point_lottery_item_tplt, ID).
