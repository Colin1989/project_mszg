-module(roleinfo_manager).

-include("record_def.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").

-export([get_roleinfo/1, 
	 get_roleinfo/0,
	 set_roleinfo/2,
	 upgrade_data/2,
	 put_roleinfo/1,
	 remake_roleinfo_detail/2]).









%%获取的角色信息
get_roleinfo() ->
    RoleId = player:get_role_id(),
    get_roleinfo(RoleId).


%%取数据，进程字典里取不到就到缓存里取出
get_roleinfo(RoleId) ->
    case player:get_role_id() of
	RoleId ->
	    case get(roleinfo) of
		undefined ->
		    Result = get_roleinfo_from_cache(RoleId),
		    put(roleinfo, Result),
		    Result;
		RoleInfo ->
		    %%io:format("RRRR:~p~n", [RoleInfo]),
		    RoleInfo
	    end;
	_ ->
	    get_roleinfo_from_cache(RoleId)
    end.


set_roleinfo(RoleId, RoleInfo) ->
    case player:get_role_id() of
	RoleId ->
	    put(roleinfo, RoleInfo),
	    redis:hset(role_info_detail, RoleId, RoleInfo);
	_ ->
	    redis:hset(role_info_detail, RoleId, RoleInfo)
    end.

put_roleinfo(RoleInfo) ->
    put(roleinfo, RoleInfo).
    


%%从缓存取出角色数据
get_roleinfo_from_cache(RoleId) ->
    RoleInfo = redis:hget(role_info_detail, RoleId),
    upgrade_data(RoleId, RoleInfo).


%%升级数据
upgrade_data(RoleId, RoleInfo) ->
    %%io:format("!!!!!!!!!!!!!!!!!2~n"),
    case check_data_valid(RoleInfo) of
	true ->
	    RoleInfo;
	_ ->
	    remake_roleinfo_detail(RoleId)
    end.

%%查看玩家属性是否合法
check_data_valid(RoleInfo) ->
    case is_record(RoleInfo, role_info_detail) of
	true ->
	    case is_record(RoleInfo#role_info_detail.battle_prop,role_attr_detail) of
		true ->
		    BattleProp = RoleInfo#role_info_detail.battle_prop,

		    Equipments = BattleProp#role_attr_detail.equipments,
		    Sculptures = BattleProp#role_attr_detail.sculptures,
		    case valid_equipment_info(Equipments) of
			true ->
			    valid_sculpture_info(Sculptures);
			false ->
			    false
		    end;
		false ->

		    false
	    end;
	false ->
	    false
    end.


%%查看装备信息是否合法
valid_equipment_info(Equipment) ->
    case Equipment of
	[] ->
	    true;
	[Index|Left] ->
	    case is_record(Index, equipmentinfo) of
		true ->
		    valid_equipment_info(Left);
		false ->
		    false
	    end;
	_ ->
	    false
    end.

%%查看符文信息是否合法
valid_sculpture_info(Sculptures) ->
    case Sculptures of
	[] ->
	    true;
	[Index|Left] ->
	    case is_record(Index, sculpture_data) of
		true ->
		    valid_sculpture_info(Left);
		false ->
		    false
	    end
    end.



%%重新生成角色信息
remake_roleinfo_detail(RoleId) ->
    remake_roleinfo_detail(RoleId, ?offline).

%%重新生成角色信息
remake_roleinfo_detail(Id,Status)->
    %%io:format("!!!!!!!!!!!!!!!!!1~n"),
    case player_role:get_db_role(Id) of
	undefined -> 
	    io_helper:format("~n########Cann't make roleinfo_detail for ~p##########~n",[Id]),
	    %%redis:srem(all_roleid_set, [Id]),
	    %%redis:srem(lists:concat([role,'_friends:',player:get_role_id()]),[Id]),
	    undefined;
	Role ->
	    Sculptures = get_sculpture_tempids([Role:sculpture1(),Role:sculpture2(),Role:sculpture3(),Role:sculpture4()]),
	    AttrProp = battle_power:get_role_battle_prop(Role),
	    BattleProp = #role_attr_detail{sculptures = Sculptures,life = AttrProp#battle_prop.life, speed = AttrProp#battle_prop.speed,
				     atk = AttrProp#battle_prop.atk, hit_ratio = AttrProp#battle_prop.hit_ratio,
				     miss_ratio = AttrProp#battle_prop.miss_ratio, critical_ratio = AttrProp#battle_prop.critical_ratio,
				     tenacity = AttrProp#battle_prop.tenacity, battle_power = AttrProp#battle_prop.power},
	    FriendInfo=#role_info_detail{status=Status,type=Role:role_type(),nickname=Role:nickname(),
				    level=Role:level(),public="test",battle_prop=BattleProp},
	    cache:set(role_info_detail, Id, FriendInfo),
	    FriendInfo
    end.

%%获取符文ID和等级
get_sculpture_tempids(Sculptures)->
    lists:map(fun(X) -> 
		      case X of
			  0 ->
			      #sculpture_data{};
			  _ ->
			      sculpture:get_sculpture_tempid_and_lev(X)
		      end
	      end,Sculptures).



