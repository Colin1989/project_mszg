%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%% 玩家角色
%%% @end
%%% Created : 27 Dec 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(player_role).
-include("record_def.hrl").
-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").

-define(add_coin, 1).
-define(dec_coin, 2).

-define(add_emoney, 1).
-define(dec_emoney, 2).

-define(add_summon_stone, 1).
-define(dec_summon_stone, 2).

-define(add_point, 1).
-define(dec_point, 2).


-define(add_honour, 1).
-define(dec_honour, 2).

-define(add_friend_point, 1).
-define(dec_friend_point, 2).


-define(add_sculpture_frag, 1).
-define(dec_sculpture_frag, 2).

-define(add_exp, 1).

%% API
-export([create/9,
	 %%get_equipment/0,
	 %%get_equipment/1,
	 %%get_equipment_prop/0,
	 check_gold_enough/1,
	 check_emoney_enough/1,
	 check_point_enough/1,
	 reduce_gold/2,
	 add_gold/2,
	 get_gold/0,
	 reduce_emoney/2,
	 add_emoney/2,
	 get_emoney/0,
	 reduce_friend_point/2,
	 reduce_point/2,
	 add_point/2,
	 add_friend_point/2,
	 get_friend_point/0,
	 get_level_by_exp/2,
	 get_role_info/3,
	 get_role_info/1,
	 get_role_info_by_roleid/1,
	 notify_role_info/3,
	 notify_role_info/1,
	 get_role_battle_info/0,
	 init_role_battle_info/0,
	 clear_role_battle_info/0,
	 get_role_by_nickname/1,
	 add_exp/2,
	 %%battle_prop_info_addition/2,
	 %%get_role_battle_prop/0,
	 %%get_role_battle_prop/1,
	 get_default_sculpture_by_role_type/1,
	 role_online/0,
	 role_offline/0,
	 check_summon_stone_enough/1,
	 add_summon_stone/2,
	 reduce_summon_stone/2,
	 get_summon_stone/0,
	 add_sculpture_frag/2,
	 reduce_sculpture_frag/2,
	 get_sculpture_frag/0,
	 get_role_type/0,
	 get_db_role/1,
	 save_my_db_role/1
	]).

%%%===================================================================
%%% API
%%%===================================================================
%%取我的角色表信息
get_db_role(RoleId) ->
    case player:get_role_id() of
	RoleId  ->
	    case get(my_db_role) of
		undefined ->
		    [Role] = db:find(db_role, [{role_id, 'equals', RoleId}]),
		    put(my_db_role, Role),
		    Role;
		 DbRole->
		    DbRole
	    end;
	_ ->
	    case db:find(db_role, [{role_id, 'equals', RoleId}]) of
		[] ->
		    undefined;
		[Role] ->
		    Role
	    end
    end.


%%保存我的角色信息
save_my_db_role(DbRole)->
    MyId = player:get_role_id(),
    {ok, DbRole} = DbRole:save(),
    case DbRole:role_id() of
	MyId ->
	    put(my_db_role, DbRole);
	_ ->
	    ok
    end,
    DbRole.


role_online()->
    %%Ip = get(ip),
    put(login_time, erlang:localtime()),
    cache:set(role_online_tbl, player:get_role_id(), datetime:local_time()),
    redis:sadd(online_roleid_set, [player:get_role_id()]).
    %%login_logout_log:create(player:get_player_id(), player:get_role_id(), Ip, 1).

role_offline() ->
    Ip = get(ip),
    cache:delete(role_online_tbl, player:get_role_id()),
    redis:srem(online_roleid_set, [player:get_role_id()]),
    log:create(login_logout_log, [player:get_player_id(), player:get_role_id(), Ip, get(login_time), erlang:localtime()]).

get_role_info_by_roleid(RoleId) ->
    get_db_role(RoleId).
    %% case db:find(db_role,[{role_id,'equals',RoleId}]) of
    %% 	[] ->
    %% 	    undefined;
    %% 	[Role]->
    %% 	    Role
    %% end.

add_exp(Type, Exp) when is_integer(Type)->
    Role = get_role_info_by_roleid(player:get_role_id()),
    NewExp = Exp + Role:exp(),
    NewLevel = get_level_by_exp(Role:level(), NewExp),
    NewRole = Role:set([{level,NewLevel},{exp,NewExp}]),
    save_my_db_role(NewRole),
    packet:send(#notify_role_info_change{type = "exp", new_value = NewExp}),
    player_log:create(player:get_role_id(), ?exp, Type, ?add_exp, 0, 0, Exp, Role:exp()),
    case NewLevel =:= Role:level() of
	false ->
	    packet:send(#notify_role_info_change{type = "level", new_value = NewLevel}),
	    PH = power_hp:recover_all_pwoer_hp(),
	    packet:send(#notify_role_info_change{type = "power_hp", new_value = PH:power_hp()});
	true ->
	    ok
    end;
    
add_exp(Role, TotalExp)->
    NewExp=TotalExp+Role:exp(),                           %%更新经验和等级
    NewLevel=get_level_by_exp(Role:level(),NewExp),
    NewRole=Role:set([{level,NewLevel},{exp,NewExp}]),
    NR = save_my_db_role(NewRole),
    case NewLevel =:= Role:level() of
	true ->
	    ok;
	false ->
	    friend:set_myinfo_update(),
	    power_hp:recover_all_pwoer_hp()
    end,
    {ok, NR}.
%%--------------------------------------------------------------------
%% @doc
%% @通过角色昵称获取角色信息
%% @end
%%--------------------------------------------------------------------
get_role_by_nickname(NickName)->
    db:find(db_role,[{nickname,'equals',NickName}]).
%%--------------------------------------------------------------------
%% @doc
%% @创建用户角色
%% @end
%%--------------------------------------------------------------------
create(RoleID, NickName, PlayerID, RoleType, ArmorInstId, WeaponInstId, Skill1, Skill2, InitSculpture) ->
    %%UserKey = db:generate_key("db_user", PlayerID),
    Role=db_role:new(id,RoleID, NickName, PlayerID, 1, RoleType, ArmorInstId, WeaponInstId, 0, 0, 0, 0,
		     Skill1, Skill2, InitSculpture, 0, 0, 0, 1, 0, config:get(init_gold), config:get(init_summon_stone),
		     0, config:get(init_point), config:get(init_honour), 
		     config:get(init_sculpture_frag_amount), config:get(pack_space_init),datetime:local_time()),
    {ok, NewRole} = Role:save(),
    NewRole.

%%--------------------------------------------------------------------
%% @doc
%% @进入游戏前初始化角色基本战斗数据用于以后校验
%% @end
%%--------------------------------------------------------------------
init_role_battle_info()->
    RoleId=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = get_db_role(RoleId),
    RoleInfo=#role_battle_info{armor=get_Temp_Info(Role:armor()),
			       weapon=get_Temp_Info(Role:weapon()),
			       medal=get_Temp_Info(Role:medal()),
			       jewelry=get_Temp_Info(Role:jewelry()),
			       sculpture1=sculpture:get_temp_id(Role:sculpture1()),
			       sculpture2=sculpture:get_temp_id(Role:sculpture2()),
			       sculpture3=sculpture:get_temp_id(Role:sculpture3()),
			       sculpture4=sculpture:get_temp_id(Role:sculpture4()),
			       level=Role:level()},
    set_role_battle_info(RoleInfo).
set_role_battle_info(RoleInfo)->
    RoleId=player:get_role_id(),
    cache:set(role_battle_info,RoleId,RoleInfo).
    %%ets:insert(role_battle_info,{RoleId,RoleInfo}).

%%--------------------------------------------------------------------
%% @doc
%% @游戏结束后获取进游戏前角色的属性进行写库
%% @end
%%--------------------------------------------------------------------
get_role_battle_info( )->
    RoleId=player:get_role_id(),
    case cache:get(role_battle_info,RoleId) of
	[{_Key,Value}]->
	    Value;
	_ ->undefined
    end.

clear_role_battle_info()->
    RoleId=player:get_role_id(),
    cache:delete(role_battle_info,RoleId).


%%--------------------------------------------------------------------
%% @doc
%% @把角色属性转换为#notify_roleinfo_msg结构
%% @end
%%--------------------------------------------------------------------
get_role_info(Role,Power,TimeLeft) ->
    %%RoleId=db:get_IntegerKey(Role:id()),
    RoleId=Role:role_id(),
    #notify_roleinfo_msg{id=RoleId,
			 nickname=Role:nickname(),
			 roletype=Role:role_type(),
			 armor=Role:armor(),
			 weapon=Role:weapon(),
			 medal= Role:medal(),
			 jewelry= Role:jewelry(),
			 ring = Role:ring(),
			 necklace = Role:necklace(),
			 skill1=Role:skill1(),
			 skill2=Role:skill2(),
			 level=Role:level(),
			 divine_level1=sculpture:db_get_divine_level(RoleId, 1), % 金币占卜
			 divine_level2=sculpture:db_get_divine_level(RoleId, 2), % 代币
			 divine_level3=sculpture:db_get_divine_level(RoleId, 3), % 友情币
			 exp=Role:exp(),
			 sculpture3=Role:sculpture3(),
			 sculpture2=Role:sculpture2(),
			 sculpture1=Role:sculpture1(),
			 sculpture4=Role:sculpture4(),
			 gold=Role:gold(),
			 emoney=get_emoney(),
			 summon_stone=Role:summon_stone(),
			 friend_point=Role:friend_point(),
			 point = Role:point(),
			 honour = military_rank:get_honour(),
			 recover_time_left=TimeLeft,
			 power_hp=Power,
			 power_hp_buy_times=player_power_hp:get_buy_times(),
			 pack_space=Role:pack_space(),
			 sculpture_frag = Role:sculpture_frag(),
			 battle_power = friend:get_battle_power()}.

notify_role_info(Role,Power,TimeLeft)->
    Packet=get_role_info(Role,Power,TimeLeft),
    packet:send(Packet).
%%--------------------------------------------------------------------
%% @doc
%% @把角色属性转换为#notify_roleinfo_msg结构
%% @end
%%--------------------------------------------------------------------
get_role_info(Role) ->
    RoleId=Role:role_id(),
    Power=power_hp:get_power_hp(RoleId),
    TimeLeft=power_hp:get_power_hp_time_left(RoleId),
    get_role_info(Role,Power,TimeLeft).

notify_role_info(Role)->
    Packet=get_role_info(Role),
    packet:send(Packet).



%%--------------------------------------------------------------------
%% @doc
%% @获取玩家战斗属性
%% @end
%%--------------------------------------------------------------------

%% get_role_battle_prop()->
%%     get_role_battle_prop(player:get_role_id()).

%% get_role_battle_prop(RoleId) when is_integer(RoleId)->
%%     [Role] = db:find(db_role,[{role_id,'equals',RoleId}]),
%%     get_role_battle_prop(Role);

%% get_role_battle_prop(RoleInfo) ->
%%     EuqipmentProp = get_equipment_prop(RoleInfo),
%%     BaseProp = get_role_base_battle_prop(RoleInfo:role_type(),RoleInfo:level()),
%%     battle_power:battle_prop_info_addition(EuqipmentProp,BaseProp).
    

%% get_role_base_battle_prop(RoleType,Level)->
%%     Id = RoleType*1000 + Level,
%%     Info = tplt:get_data(role_upgrad_tplt,Id),
%%     #battle_prop{life = Info#role_upgrad_tplt.life,
%% 		atk = Info#role_upgrad_tplt.atk,
%% 		speed = Info#role_upgrad_tplt.speed,
%% 		hit_ratio = Info#role_upgrad_tplt.hit_ratio,
%% 		critical_ratio = Info#role_upgrad_tplt.critical_ratio,
%% 		miss_ratio = Info#role_upgrad_tplt.miss_ratio,
%% 		tenacity = Info#role_upgrad_tplt.tenacity,
%% 		power = Info#role_upgrad_tplt.combat_effectiveness}.

%%--------------------------------------------------------------------
%% @doc
%% @获取玩家装备的属性
%% @end
%%--------------------------------------------------------------------

%% get_equipment_prop()->
%%     EquipmentInsts=get_equipment(),
%%     count_equip_prop(EquipmentInsts,#battle_prop{}).


%% get_equipment_prop(RoleInfo)->
%%     EquipmentInsts=get_equipment(RoleInfo),
%%     count_equip_prop(EquipmentInsts,#battle_prop{}).
%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @计算玩家的装备属性
%% %% @end
%% %%--------------------------------------------------------------------
%% count_equip_prop([],Prop)->
%%     Prop;
%% count_equip_prop([EquipmentInst|EquipmentInsts],Prop)->
%%     %%Item=equipment:get_equipment_info(EquipmentInst),%%player_pack:get_item(EquipmentInst),
%%     %%Equipment=equipment:get_equipment_prop(item:get_sub_id(Item:temp_id())),
%%     count_equip_prop(EquipmentInsts,equip_prop_accumulation(EquipmentInst, Prop)).
%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @玩家装备属性累加
%% %% equip_prop_accumulation(Equipment::#equipment_tplt{},Prop::#equip_prop{})->NewProp=#equip_prop{}
%% %% Equipment:装备,Prop:当前累计属性,NewProp:新累计属性,NewProp=Equipment+Prop
%% %% @end
%% %%--------------------------------------------------------------------
%% equip_prop_accumulation(EquipmentInst, Prop)->
%%     case EquipmentInst of
%% 	0 ->
%% 	    Prop;
%% 	_ ->
%% 	    EquipmentProp = equipment:get_equipment_battle_info(EquipmentInst),
%% 	    battle_power:battle_prop_info_addition(EquipmentProp, Prop)
%%     end.



%%--------------------------------------------------------------------
%% @doc
%% @spec判断金币是否足够
%% @end
%%--------------------------------------------------------------------
check_gold_enough(Gold)->
    RoleId=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = get_db_role(RoleId),
    MyGold=Role:gold(),
    Gold=<MyGold.

%%--------------------------------------------------------------------
%% @doc
%% @spec判断代币是否足够
%% @end
%%--------------------------------------------------------------------
check_emoney_enough(Emoney)->
    UserId=player:get_player_id(),
    [User]=db:find(db_user,[{user_id,'equals',UserId}]),
    MyEmoney=User:emoney(),
    Emoney=<MyEmoney.

%%--------------------------------------------------------------------
%% @doc
%% @spec判断积分是否足够
%% @end
%%--------------------------------------------------------------------
check_point_enough(Point)->
    RoleId=player:get_role_id(),
    Role = get_db_role(RoleId),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    MyPoint=Role:point(),
    Point=<MyPoint.

%%--------------------------------------------------------------------
%% @doc
%% @spec减少金币
%% @end
%%--------------------------------------------------------------------
reduce_gold(Type, Gold) when Gold>=0 ->
    RoleID=player:get_role_id(),
    Role = get_db_role(RoleID),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    update_gold(Role, -Gold),
    player_log:create(RoleID, ?coin, Type, ?dec_coin, 0, 0, Gold, Role:gold()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加金币
%% @end
%%--------------------------------------------------------------------
add_gold(Type, Gold) when Gold>=0 ->
    RoleID=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_gold(Role, Gold),
    player_log:create(RoleID, ?coin, Type, ?add_coin, 0, 0, Gold, Role:gold()).


%%--------------------------------------------------------------------
%% @doc
%% @spec减少代币
%% @end
%%--------------------------------------------------------------------
reduce_emoney(Type, Emoney) when Emoney>=0 ->
    UserID=player:get_player_id(),
    [User]=db:find(db_user,[{user_id,'equals',UserID}]),
    update_emoney(User, -Emoney),
    player_log:create(player:get_role_id(), ?emoney, Type, ?dec_emoney, 0, 0, Emoney, User:emoney()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加代币
%% @end
%%--------------------------------------------------------------------
add_emoney(Type, Emoney) when Emoney>=0 ->
    UserID=player:get_player_id(),
    [User]=db:find(db_user,[{user_id,'equals',UserID}]),
    update_emoney(User, Emoney),
    player_log:create(player:get_role_id(), ?emoney, Type, ?add_emoney, 0, 0, Emoney, User:emoney()).



%%--------------------------------------------------------------------
%% @doc
%% @spec减少积分
%% @end
%%--------------------------------------------------------------------
reduce_sculpture_frag(Type, Sculpture) when Sculpture>=0 ->
    RoleID=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    Role = get_db_role(RoleID),
    update_sculpture_frag(Role, -Sculpture),
    player_log:create(RoleID, ?sculpture_frag, Type, ?dec_sculpture_frag, 0, 0, Sculpture, Role:sculpture_frag()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加积分
%% @end
%%--------------------------------------------------------------------
add_sculpture_frag(Type, Sculpture) when Sculpture>=0 ->
    RoleID=player:get_role_id(),
    Role = get_db_role(RoleID),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    update_sculpture_frag(Role, Sculpture),
    player_log:create(RoleID, ?sculpture_frag, Type, ?add_sculpture_frag, 0, 0, Sculpture, Role:sculpture_frag()).

%%--------------------------------------------------------------------
%% @doc
%% @spec更新积分
%% @end
%%--------------------------------------------------------------------
update_sculpture_frag(Role, Sculpture)->
    case Sculpture =:= 0 of
	false ->
	    MySculpture=Role:sculpture_frag()+Sculpture,
	    NewRole=Role:set([{sculpture_frag,MySculpture}]),
	    save_my_db_role(NewRole),
	    packet:send(#notify_role_info_change{type = "sculpture_frag", new_value=MySculpture}),
	    NewRole;
	true ->
	    ok
    end.


get_sculpture_frag()->
    RoleId = player:get_role_id(),
    Role = get_db_role(RoleId),
    %%[Role|_] = db:find(db_role,[{role_id, 'equals', RoleId}]),
    Role:sculpture_frag().


get_role_type()->
    case get(role_type) of
	undefined ->
	    RoleId = player:get_role_id(),
	    %%[Role|_] = db:find(db_role,[{role_id, 'equals', RoleId}]),
	    Role = get_db_role(RoleId),
	    RoleType = Role:role_type(),
	    put(role_type, RoleType),
	    RoleType;
	Type ->
	    Type

    end. 


%%--------------------------------------------------------------------
%% @doc
%% @spec减少积分
%% @end
%%--------------------------------------------------------------------
reduce_point(Type, Point) when Point>=0 ->
    RoleID=player:get_role_id(),
    Role = get_db_role(RoleID),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    update_point(Role, -Point),
    player_log:create(RoleID, ?point, Type, ?dec_point, 0, 0, Point, Role:point()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加积分
%% @end
%%--------------------------------------------------------------------
add_point(Type, Point) when Point>=0 ->
    RoleID=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_point(Role, Point),
    player_log:create(RoleID, ?point, Type, ?add_point, 0, 0, Point, Role:point()).

%%--------------------------------------------------------------------
%% @doc
%% @spec更新积分
%% @end
%%--------------------------------------------------------------------
update_point(Role, Point)->
    case Point =:= 0 of
	false ->
	    MyPoint=Role:point()+Point,
	    NewRole=Role:set([{point,MyPoint}]),
	    save_my_db_role(NewRole),
	    packet:send(#notify_role_info_change{type = "point", new_value=MyPoint}),
	    NewRole;
	true ->
	    ok
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec减少友情点
%% @end
%%--------------------------------------------------------------------
reduce_friend_point(Type, FriendPoint) when FriendPoint>=0 ->
    RoleID=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_friend_point(Role, -FriendPoint),
    player_log:create(RoleID, ?friend_point, Type, ?dec_friend_point, 0, 0, FriendPoint, Role:friend_point()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加友情点
%% @end
%%--------------------------------------------------------------------
add_friend_point(Type, FriendPoint) when FriendPoint>=0 ->
    RoleID=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_friend_point(Role, FriendPoint),
    player_log:create(RoleID, ?friend_point, Type, ?add_friend_point, 0, 0, FriendPoint, Role:friend_point()).

%%--------------------------------------------------------------------
%% @doc
%% @spec获取金币
%% @end
%%--------------------------------------------------------------------
get_gold()->
    RoleId=player:get_role_id(),
    Role = player_role:get_db_role(RoleId),
    Role:gold().
    %% case db:find(db_role,[{role_id,'equals',RoleId}]) of
    %% 	[Role|_]->
    %% 	    Role:gold()
    %% end.

%%--------------------------------------------------------------------
%% @doc
%% @spec获取代币币
%% @end
%%--------------------------------------------------------------------
get_emoney()->
    UserId=player:get_player_id(),
    case db:find(db_user,[{user_id,'equals',UserId}]) of
	[User]->
	    User:emoney()
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec获取代币币
%% @end
%%--------------------------------------------------------------------
get_friend_point()->
    RoleId=player:get_role_id(),
    Role = player_role:get_db_role(RoleId),
    Role:friend_point().
    %% case db:find(db_role,[{role_id,'equals',RoleId}]) of
    %% 	[Role|_]->
    %% 	    Role:friend_point()
    %% end.

%%--------------------------------------------------------------------
%% @doc
%% @get_level_by_exp(Level::int,Exp::int)获取当前等级
%% @end
%%--------------------------------------------------------------------
get_level_by_exp(Level,Exp)->
    try 
	ExpLevel=tplt:get_data(role_exp_tplt,Level),
	ExpInt=ExpLevel#role_exp_tplt.exp,
	case ExpInt=<Exp of
	    true->
		get_level_by_exp(Level+1,Exp);
	    false ->
		Level
	end
    catch
	_:_ -> Level-1
    end.

%%--------------------------------------------------------------------
%% @doc
%% @ 召唤石相关
%% @end
%%--------------------------------------------------------------------
get_summon_stone() ->
    RoleID = player:get_role_id(),
    Role = player_role:get_db_role(RoleID),
    Role:summon_stone().
    %% case db:find(db_role, [{role_id, 'equals', RoleID}]) of
    %% 	[Role] ->
    %% 	    Role:summon_stone()
    %% end.

check_summon_stone_enough(Amount) ->
   get_summon_stone() >= Amount.

reduce_summon_stone(Type, Amount) when Amount >= 0 ->
    RoleID = player:get_role_id(),
    %%[Role] = db:find(db_role, [{role_id, 'equals', RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_summon_stone(Role, -Amount),
    case Amount =/= 0 of
	true ->
	    player_log:create(player:get_role_id(), ?summon_stone, Type, ?dec_summon_stone, 0, 0, Amount, Role:summon_stone());
	_ ->
	    ok
    end.

add_summon_stone(Type, Amount) when Amount >= 0 ->
    RoleID = player:get_role_id(),
    %%[Role] = db:find(db_role, [{role_id, 'equals', RoleID}]),
    Role = Role = player_role:get_db_role(RoleID),
    update_summon_stone(Role, Amount),
    case Amount =/= 0 of
	true ->
	    player_log:create(player:get_role_id(), ?summon_stone, Type, ?add_summon_stone, 0, 0, Amount, Role:summon_stone());
	_ ->
	    ok
    end.

update_summon_stone(Role, Amount) ->
  case Amount =:= 0 of
    false ->
      NewAmount = Role:summon_stone() + Amount,
      NewUser = Role:set([{summon_stone, NewAmount}]),
      save_my_db_role(NewUser),
      packet:send(#notify_role_info_change{type = "summon_stone", new_value = NewAmount}),
      NewUser;
    true ->
      ok
  end.
%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec更新金币
%% @end
%%--------------------------------------------------------------------
update_gold(Role, Gold)->
    case Gold=:=0 of
	true ->
	    ok;
	false ->
	    MyGold=Role:gold()+Gold,
	    NewRole=Role:set([{gold,MyGold}]),
	    save_my_db_role(NewRole),
	    packet:send(#notify_gold_update{gold=MyGold}),
	    NewRole
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec更新代币
%% @end
%%--------------------------------------------------------------------
update_emoney(User, Emoney)->
    case Emoney =:= 0 of
	false ->
	    MyEmoney=User:emoney()+Emoney,
	    NewUser=User:set([{emoney,MyEmoney}]),
	    NewUser:save(),
	    packet:send(#notify_emoney_update{emoney=MyEmoney}),
	    NewUser;
	true ->
	    ok
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec更新代币
%% @end
%%--------------------------------------------------------------------
update_friend_point(Role, FriendPoint)->
    case FriendPoint =:= 0 of
	false ->
	    MyPoint=Role:friend_point()+FriendPoint,
	    NewRole=Role:set([{friend_point,MyPoint}]),
	    save_my_db_role(NewRole),
	    packet:send(#notify_role_info_change{type="friend_point",new_value=MyPoint}),
	    NewRole;
	true ->
	    ok
    end.
%%--------------------------------------------------------------------
%% @doc
%% @获取物品的模板ID
%% @end
%%--------------------------------------------------------------------
%% get_TempId(0)->
%%     0;
%% get_TempId(InstID) ->
%%     Item=player_pack:get_item(InstID),
%%     Item:item_id().

%%--------------------------------------------------------------------
%% @doc
%% @获取装备信息
%% @end
%%--------------------------------------------------------------------
get_Temp_Info(0)->
    #equip_extra_info{};
get_Temp_Info(InstID) ->
    Equipment=equipment:get_equipment_extra_info(InstID),
    Equipment.
    %%Item=player_pack:get_item(InstID),
    %%Equipment#equip_extra_info{temp_id=Item:item_id()}.



get_default_sculpture_by_role_type(Type)->
    Data = tplt:get_data(role_tplt,Type),
    #sculpture_data{temp_id = Data#role_tplt.default_sculpture,level =  0}.
    
