-module(assistance).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("record_def.hrl").

-export([start/0]).

-export([proc_req_assistance_list/1,proc_req_select_donor/1,insert_role_info/1]).

-compile(export_all).

start()->
    packet:register(?msg_req_assistance_list,{?MODULE,proc_req_assistance_list}),
    packet:register(?msg_req_select_donor,{?MODULE,proc_req_select_donor}),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% @请求援助列表
%% @end
%%--------------------------------------------------------------------
proc_req_assistance_list(Packet)->
    io_helper:format("~p~n",[Packet]),
    List = get_assistance_list(),
    packet:send(#notify_assistance_list{donors = List}),
    save_donor_list(List),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% @选择援助
%% @end
%%--------------------------------------------------------------------
proc_req_select_donor(#req_select_donor{donor_id = DonorId} = Packet)->
    io_helper:format("~p~n",[Packet]),
    case get_donor_list() of
	undefined ->
	    sys_msg:send_to_self(?sg_assistance_no_req_list,[]),
	    packet:send(#notify_select_donor_result{result=?common_error});
	List ->
	    case lists:filter(fun(X)->X#donor.role_id=:=DonorId end,List) of
		[] ->
		    sys_msg:send_to_self(?sg_assistance_select_id_not_in_list,[]),
		    packet:send(#notify_select_donor_result{result=?common_error});
		[Donor] ->
		    save_assistance_info(Donor),
		    packet:send(#notify_select_donor_result{result=?common_success})
	    end
    end.



%%--------------------------------------------------------------------
%% @doc
%% @生成援助列表
%% @end
%%--------------------------------------------------------------------
get_assistance_list()->
    RoleId = player:get_role_id(),
    FriendList = redis_extend:srand_members_info(lists:concat([role,'_friends:',RoleId]),role_info_detail,config:get(friend_assistance_amount)),
    Length = config:get(total_assistance_amount) - length(FriendList),
    HelperList = lists:filter(fun({Id,_})-> (Id=/=RoleId) and (not find_id_exist(Id,FriendList)) end, 
			      redis_extend:srand_members_info(all_roleid_set,role_info_detail,Length)),
    lists:filter(fun(X) -> 
			 X#donor.role_id =/= 0
		 end, make_donor_list(friend,get_assist_times(friend), FriendList) ++ make_donor_list(other,get_assist_times(other), HelperList)).


find_id_exist(Id,Array)->
    case lists:filter(fun({ID,_})-> Id=:=ID end,Array) of
	[] ->
	    false ;
	_ ->
	    true
    end.


%%--------------------------------------------------------------------
%% @doc
%% @转化成[T::#donor{}]
%% @end
%%--------------------------------------------------------------------
make_donor_list(_Type,_Times, []) ->
    [];
make_donor_list(Type,Times, [Donor|Donors]) ->
    [make_donor(Type, Times, Donor)|make_donor_list(Type,Times, Donors)].


make_donor(Type, Times, {Id,Data})->
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
	    #donor{role_id = Id, level = Info#role_info_detail.level, role_type = Info#role_info_detail.type, nick_name=Info#role_info_detail.nickname,
			  friend_point=get_friend_point(Type,Times), power=Info#role_info_detail.battle_prop#role_attr_detail.battle_power, 
			  sculpture = rand_sculpture(Info#role_info_detail.type,Info#role_info_detail.battle_prop#role_attr_detail.sculptures),rel=Relation}
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
rand_sculpture(Type,List)->
    CuList = lists:filter(fun(X)-> X =/= #sculpture_data{} end,List),
    case length(CuList) of
	0 ->
	    player_role:get_default_sculpture_by_role_type(Type);
	Len ->
	    lists:nth(rand:uniform(Len),CuList)
    end.

%%--------------------------------------------------------------------
%% @doc
%% @获取可获得的好友点数
%% @end
%%--------------------------------------------------------------------
get_friend_point(Type,Times)->
    case Times >= 1 of
	true ->
	    1;
	false ->
	    case Type of
		friend ->
		    20;
		other ->
		    10
	    end
    end.


%%--------------------------------------------------------------------
%% @doc
%% @获取对应类别今天的援助次数
%% @end
%%--------------------------------------------------------------------
get_assist_times(Type)->
    Times=case cache_with_expire:get(list_to_atom(lists:concat([assist_by_,Type])),player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.


%%--------------------------------------------------------------------
%% @doc
%% @累加今天的援助次数
%% @end
%%--------------------------------------------------------------------
increase_assist_times(Type)->
    cache_with_expire:increase(list_to_atom(lists:concat([assist_by_,Type])),player:get_role_id(),day).
    

%%--------------------------------------------------------------------
%% @doc
%% @存入角色信息，供随机使用
%% @end
%%--------------------------------------------------------------------
insert_role_info(RoleId)->
    case RoleId of
	undefined ->
	    ok;
	_ ->
	   redis:sadd(all_roleid_set,[RoleId]) 
    end.

%%--------------------------------------------------------------------
%% @doc
%% @援助结算
%% @end
%%--------------------------------------------------------------------
assistance_settle(Result,Type)->
    case Result of 
	?game_win ->
	    case get_assistance_info() of
		[] ->
		    ok;
		[{_, #donor{rel = Relation, friend_point=Point}}] ->
		    case Relation of
			?friend ->
			    increase_assist_times(friend);
			?other ->
			    increase_assist_times(other)
		    end,
		    player_role:add_point(Type, Point)
	    end;
	    %%[{_, #donor{rel = Relation, friend_point=Point}}] = get_assistance_info(),
	    
	_ ->
	    ok
    end,
    delete_assistance_info().
    
%%--------------------------------------------------------------------
%% @doc
%% @援助信息增删改
%% @end
%%--------------------------------------------------------------------
delete_assistance_info()->
    cache:delete(role_assistance_info,player:get_role_id()).

save_assistance_info(Info)->
    cache:set(role_assistance_info,player:get_role_id(),Info).

get_assistance_info()->
    cache:get(role_assistance_info,player:get_role_id()).
%%--------------------------------------------------------------------
%% @doc
%% @援助列表信息增删改
%% @end
%%--------------------------------------------------------------------
save_donor_list(List)->
    put(donor_list,List).

get_donor_list()->
    get(donor_list).
    

