%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2014, linyibin
%%% @doc
%%% 玩家包裹
%%% @end
%%% Created :  3 Jan 2014 by linyibin <>
%%%-------------------------------------------------------------------
-module(player_pack).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").

-define(add_item, 1).
-define(delete_item, 2).
-define(modify_item, 3).

%% API
-export([add_item/2,
	 add_item/3,
	 add_item/4,
	 add_items/2,
	 get_item/1,
	 set_item/3,
	 delete_items/2,
	 delete_items_by_insts_and_amount/2,
	 delete_item/2,
	 delete_item/3,
	 delete_item_and_other/2,
	 delete_item_notify/2,
	 get_items_count/1,
	 is_exist/1,
	 is_exist_by_temp_id/1,
	 is_space_exceeded/0,
	 remain_space_count/0, %% 剩余几格
	 check_space_enough/1
	]).

-export([get_my_pack/0,get_my_pack/1,transform_items/2,start/0,proc_req_extend_pack/1,proc_req_sale_item/1,proc_req_sale_items/1]).

-export([notify_append_items/1,notify_delete_items/1,notify_modify_items/1,do_notify_pack_change/0, notify_init_player_pack/0,
	proc_req_use_props/1]).

%%-export([compound_same_item/1]).
%%-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    packet:register(?msg_req_extend_pack,{?MODULE,proc_req_extend_pack}),
    packet:register(?msg_req_sale_item,{?MODULE,proc_req_sale_item}),
    packet:register(?msg_req_sale_items, {?MODULE,proc_req_sale_items}),
    packet:register(?msg_req_use_props, {?MODULE, proc_req_use_props}),
    %%packet:register(?msg_req_test,{?MODULE,proc_req_test}),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @测试
%% @end
%%--------------------------------------------------------------------
%%proc_req_test(_Pack)->
    %%proc_req_sale_item(#req_sale_item{inst_id=72057594038393938}),
  %%  add_items(?st_test,[{100,5},{101,1},{101,2},{104,3},{102,2}]),
    %%proc_req_sale_item(#req_sale_item{inst_id=72057594038393946}),
    %%ok.

proc_req_use_props(#req_use_props{inst_id = InstId} = Packet)->
    io_helper:format("~p~n", [Packet]),
    case get_item(InstId) of
	undefined ->
	    packet:send(#notify_use_props_result{result=?common_failed}),
	    sys_msg:send_to_self(?sg_use_props_not_exists,[]);
	Item -> 
	    case Item:item_type() of
		?props ->
		    SubId = item:get_sub_id(Item:item_id()),
		    do_delete_item_by_inst_id_and_amount(InstId, 1, ?st_use_prop),
		    proc_use_prop(SubId),
		    packet:send(#notify_use_props_result{result=?common_success, reward_id = SubId}),
		    do_move_items_to_pack(),
		    do_notify_pack_change(),
		    %%sculpture_pack:notify_sculpture_pack_change(),
		    ok;
		?rand_props ->
		    SubId = item:get_sub_id(Item:item_id()),
		    do_delete_item_by_inst_id_and_amount(InstId, 1, ?st_use_prop),
		    NewSubId = proc_use_randprop(SubId),
		    packet:send(#notify_use_props_result{result=?common_success, reward_id = NewSubId}),
		    do_move_items_to_pack(),
		    do_notify_pack_change(),
		    %%sculpture_pack:notify_sculpture_pack_change(),
		    ok;
		_ ->
		    packet:send(#notify_use_props_result{result=?common_failed}),
		    sys_msg:send_to_self(?sg_use_props_not_props,[])
	    end
    end.

proc_use_prop(AwardId) ->
    Data = tplt:get_data(gift_bag_tplt, AwardId),
    reward:give_not_notify(Data#gift_bag_tplt.item_id, Data#gift_bag_tplt.item_amount, ?st_use_prop).

proc_use_randprop(AwardId)->
    Data = tplt:get_data(randon_gift_bag_tplt, AwardId),
    Res = rand:uniform(lists:sum(Data#randon_gift_bag_tplt.radios)),
    GiftBagId = get_gift_bag_id(Data#randon_gift_bag_tplt.gift_bag_ids, Data#randon_gift_bag_tplt.radios, Res),
    proc_use_prop(GiftBagId),
    GiftBagId.

get_gift_bag_id([Id|Ids], [Radio|Radios], Left)->
    case Radio < Left of
	true ->
	    get_gift_bag_id(Ids, Radios, Left - Radio);
	false ->
	    Id
    end.

%%--------------------------------------------------------------------
%% @doc
%% @扩充背包
%% @end
%%--------------------------------------------------------------------
proc_req_extend_pack(Packet)->
    io_helper:format("proc req login: Packet:~p~n", [Packet]),
    RoleId = player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    CurSpace = Role:pack_space(),
    Times = get_extend_times(CurSpace),
    Price = get_extend_pack_price(Times+1),
    case player_role:check_emoney_enough(Price) of
	true ->
	    Max=config:get(pack_space_max),
	    Per=config:get(pack_extend_count),
	    case Max > CurSpace of
		true -> 
		    NewSpace = case CurSpace+Per >= Max of
				   true -> 
				       Max;
				   false ->
				       CurSpace+Per
			       end,
		    process_backpack_extend(Price,Role,NewSpace),
		    packet:send(#notify_extend_pack_result{result=?common_success});
		false ->
		    packet:send(#notify_extend_pack_result{result=?common_failed}),
		    sys_msg:send_to_self(?sg_extend_pack_is_max,[])
	    end;
	    
	false ->
	    packet:send(#notify_extend_pack_result{result=?common_failed}),
	    sys_msg:send_to_self(?sg_extend_pack_emoney_not_enough,[])
    end.
%%--------------------------------------------------------------------
%% @doc
%% @获取扩充次数
%% @end
%%--------------------------------------------------------------------
get_extend_times(CurSpace)->
    Per=config:get(pack_extend_count),
    Org=config:get(pack_space_init),
    (CurSpace-Org) div Per.
%%--------------------------------------------------------------------
%% @doc
%% @获取扩充价格
%% @end
%%--------------------------------------------------------------------
get_extend_pack_price(TheTime)->
    PriceInfo=tplt:get_data(extend_pack_price,TheTime),
    PriceInfo#extend_pack_price.price.
%%--------------------------------------------------------------------
%% @doc
%% @扩充
%% @end
%%--------------------------------------------------------------------
process_backpack_extend(Price,Role,NewSpace)->
    NRole=Role:set([{pack_space,NewSpace}]),
    player_role:save_my_db_role(NRole),
    player_role:reduce_emoney(?st_pack_extend,Price),
    put(role_pack_space,NewSpace),
    do_move_items_to_pack(),
    do_notify_pack_change(),
    ok.
    
%%--------------------------------------------------------------------
%% @doc
%% @物品出售
%% @end
%%--------------------------------------------------------------------
proc_req_sale_item(#req_sale_item{inst_id=InstID, amount=Amount}=Packet)->
    io_helper:format("proc req:Packet:~p~n",[Packet]),
    case get_item(InstID) of
	undefined ->
	    packet:send(#notify_sale_item_result{result=?common_failed}),
	    sys_msg:send_to_self(?sg_pack_sale_not_exists,[]);
	Item -> 
	    Price=item:get_sell_price(Item:item_id()),
	    
	    Count=Item:amount(),
	    case (Amount =< Count) andalso (Amount > 0) of
		true -> 
		    ExtraPrice = get_extra_price(Item),
		    do_delete_item_by_inst_id_and_amount(InstID, Amount, ?st_pack_sale),
		    player_role:add_gold(?st_pack_sale,ExtraPrice + Price*Amount),
		    do_move_items_to_pack(),
		    do_notify_pack_change(),
		    packet:send(#notify_sale_item_result{result=?common_success,gold=ExtraPrice + Price*Amount});
		false ->
		    sys_msg:send_to_self(?sg_pack_sale_amount_error,[]),
		    packet:send(#notify_sale_item_result{result=?common_failed})
	    end
    end.

proc_req_sale_items(#req_sale_items{inst_id = InstIds})->
    EquipmentIDs = get_equimentids([], InstIds),
    equipment:proc_equipment_resolve(#req_equipment_resolve{inst_id = EquipmentIDs}),

    {Gold, ErrId} = process_sale_items(InstIds),
    lists:foreach(fun(X) -> 
			  Item = get_item(X),
			  do_delete_item_by_inst_id_and_amount(X, Item:amount(), ?st_pack_sale) 
		  end, lists:takewhile(fun(X) -> X =/=ErrId end, InstIds)),
    %%sculpture_pack:del_sculptures_by_inst(?st_pack_sale, lists:takewhile(fun(X) -> X =/=Errid end, InstIds)),
    player_role:add_gold(?st_pack_sale, Gold),
    case ErrId of
	0 ->
	    packet:send(#notify_sale_items_result{result = ?common_success, gold = Gold});
	_ ->
	    packet:send(#notify_sale_items_result{result = ?common_failed, gold = Gold, err_id = ErrId})
    end,
    do_move_items_to_pack(),
    do_notify_pack_change(),
    ok.

get_equimentids(ComfirmIDs, []) ->
    ComfirmIDs;
get_equimentids(ComfirmIDs, [InstId|InstIds]) ->
    case equipment:get_equipment_info(InstId) of
        undefined ->
            get_equimentids(ComfirmIDs, InstIds);
        _Inst ->
            get_equimentids([InstId | ComfirmIDs], InstIds)
    end.

process_sale_items([])->
    {0, 0};
process_sale_items([InstId|InstIds]) -> 
    case get_item(InstId) of
	undefined ->
	    sys_msg:send_to_self(?sg_pack_sale_not_exists,[]),
	    {0, InstId};
	Inst ->
	    Price=item:get_sell_price(Inst:item_id()),
	    ExtraPrice = get_extra_price(Inst),
	    %%#sculpture_tplt{grade=Grade} = tplt:get_data(sculpture_tplt, Inst:temp_id()),
	    %%Price = get_sale_sculpture_price(Inst:level(), Grade),
	    {TotalPrice, ErrId} = process_sale_items(InstIds),
	    {TotalPrice + Price * Inst:amount() + ExtraPrice, ErrId}
	%%sculpture_pack:del_sculptures_by_inst(?st_sale_sculpture, [InstId]);
    end.

get_extra_price(Item)->
    ItemId=Item:item_id(),
    case item:get_type(ItemId)of
	?equipment->
	    case equipment:get_equipment_info(Item:inst_id()) of
		undefined ->
		    0;
		Equipment ->
		    Gems = equipment:get_mounted_gems(Equipment),
		    Attrs = equipment:get_attach_info(Equipment),
		    GemsPrice = equipment:get_equipment_extra_value_by_gems(Gems),
		    %% GemsPrice = lists:foldl(fun(X, In)->
		    %% 				    item:get_sell_price(X) + In
		    %% 			    end,0,Gems),
		    LevPrice = equipment:get_equipment_extra_value_by_level(ItemId, Equipment:level()),
		    AttrsPrice = equipment:get_equipment_extra_value_by_attrs(Attrs),
		    GemsPrice + LevPrice + AttrsPrice
	    end;
	_ ->
	    0
    end.

notify_init_player_pack() ->
    PlayerPack=transform_items(player_pack:get_my_pack(),[]),
    packet:send(#notify_player_pack{type=?init,pack_items=PlayerPack}).
%%--------------------------------------------------------------------
%% @doc
%% @通知增加物品
%% @end
%%--------------------------------------------------------------------
notify_append_items(Items) ->
    case Items of
	[] ->ok;
	_ ->
	    packet:send(#notify_player_pack{type=?append,pack_items=Items})
    end.

%%--------------------------------------------------------------------
%% @doc
%% @通知删除物品
%% @end
%%--------------------------------------------------------------------
notify_delete_items(Items) ->
    case Items of
	[] ->ok;
	_ ->
	    packet:send(#notify_player_pack{type=?delete,pack_items=Items})
	    %%packet:send(#notify_player_pack_exceeded{new_extra=Items})
	    
    end.

%%--------------------------------------------------------------------
%% @doc
%% @通知修改物品
%% @end
%%--------------------------------------------------------------------
notify_modify_items(Items) ->
    case Items of
	[] ->ok;
	_ ->
	    packet:send(#notify_player_pack{type=?modify,pack_items=Items})
    end.


%%--------------------------------------------------------------------
%% @doc
%% @通知新增缓存物品
%% @end
%%--------------------------------------------------------------------
notify_add_cache_items(Items) ->
    case Items of
	[] ->ok;
	_ ->
	    NItems=lists:foldr(fun(X, In) -> 
				       [#extra_item{item_id=element(2,X),count=element(3,X)}|In]
			       end,[],Items),
	    packet:send(#notify_player_pack_exceeded{new_extra=NItems})
	    
    end.



%%--------------------------------------------------------------------
%% @doc
%% @增加物品
%% Item:物品, #item{temp_id=1001, inst_id=100001}
%% RoleID:角色ID
%% @end
%%--------------------------------------------------------------------
add_items(Items) ->
    %%Items = compound_same_item(NItems),
    lists:foldl(fun(X, _In) ->
			add_item(element(1,X), element(2,X), element(3,X))
		end,[],Items).
    %%do_notify_pack_change().
add_items(SourceType,NItems) ->
    Items = compound_same_item(NItems),
    lists:foldl(fun(X, _In) ->
			add_item(SourceType, element(1,X), element(2,X))
		end,[],Items),
    do_notify_pack_change().
add_item(SourceType, TempID) when is_integer(TempID) ->
    RoleID = player:get_role_id(),
    ItemType = item:get_type(TempID),
    Item=add_item(RoleID, SourceType, TempID, ItemType, 1),
    %%do_notify_pack_change(),
    Item. 
   
add_item(whole,Item,SourceType)->
    {ok,NPack}=Item:save(),
    player_log:create(NPack:role_id(), ?item, SourceType, ?add_item, NPack:inst_id(), NPack:item_id(), 1, ""),
    pack_add_msg_add(NPack),
    do_notify_pack_change();

add_item(notify,SourceType, TempID) when is_integer(TempID) ->
    RoleID = player:get_role_id(),
    ItemType = item:get_type(TempID),
    Item=add_item(RoleID, SourceType, TempID, ItemType, 1),
    do_notify_pack_change(),
    Item;

add_item(SourceType, TempID, Count) when is_integer(TempID) ->
    RoleID = player:get_role_id(),
    ItemType = item:get_type(TempID),
    Item=add_item(RoleID, SourceType, TempID, ItemType, Count),
    %%do_notify_pack_change(),
    Item.

add_item(notify,SourceType, TempID, Count) when is_integer(TempID) ->
    RoleID = player:get_role_id(),
    ItemType = item:get_type(TempID),
    Item=add_item(RoleID, SourceType, TempID, ItemType, Count),
    do_notify_pack_change(),
    Item;

add_item(RoleID, SourceType, TempID, Count) when is_integer(TempID) ->
    ItemType = item:get_type(TempID),
    Item=add_item(RoleID, SourceType, TempID, ItemType, Count),
    %%do_notify_pack_change(),
    clear_pack_modify_info(),
    Item.



%%--------------------------------------------------------------------
%% @doc
%% @获取所有物品
%% @end
%%--------------------------------------------------------------------
get_items() ->
    RoleID = player:get_role_id(),
    db:find(db_pack, [{role_id, 'equals', RoleID}]).

%%get_items(ItemType) ->
%%    RoleID = player:get_role_id(),
%%    db:find(db_pack, [{role_id, 'equals', RoleID}, {item_type, 'equals', ItemType}]).

%%--------------------------------------------------------------------
%% @doc
%% @获取物品的数量
%% 请求:player_pack:get_items_count([100, 101, 102]).
%% 回复:[{102,0},{101,1},{100,2}]
%% @end
%%--------------------------------------------------------------------
get_items_count(TempIDs) ->
    %%RoleID = player:get_role_id(),
    PackItems = get_my_pack(),
    get_items_count(TempIDs, PackItems, []).
	
%%--------------------------------------------------------------------
%% @doc
%% @根据实例ID获取物品
%% @end
%%--------------------------------------------------------------------
get_item(InstID) ->
    Pack = get_my_pack(),
    Item = case lists:filter(fun(X) -> X:inst_id()=:=InstID end, Pack) of
	       [] -> undefined;
	       [NItem] -> NItem
	   end,
    %%[Item|_] = lists:filter(fun(X) -> X:inst_id()=:=InstID end, Pack),
    %%[Item|_]=db:find(db_pack, [{inst_id, 'equals', InstID}]),
    Item.

%%--------------------------------------------------------------------
%% @doc
%% @设置物品的模板表ID
%% @end
%%--------------------------------------------------------------------
set_item(SourceType, InstID, TempID) ->
    RoleID = player:get_role_id(),
    case get_item(InstID) of
	undefined ->
	    undefined;
	    %%throw({error, item_not_exist});
	PackItem ->
	    NPackItem = PackItem:set([{item_id, TempID}]),
	    NPackItem:save(),
	    pack_modify_msg_add(NPackItem),
	    do_notify_pack_change(),
	    player_log:create(RoleID, ?item, SourceType, ?modify_item, InstID, TempID, 1, "")
    end.

%%--------------------------------------------------------------------
%% @doc
%% @删除物品
%% player_pack:delete_items(2, [{103, 5}]).
%% @end
%%--------------------------------------------------------------------
delete_items(SourceType, ItemsCount) ->
    RoleID = player:get_role_id(),
    PackItems = lists:reverse(get_my_pack()),
    lists:foldl(fun({TempID, Count}, NPackItems) ->
			do_delete_item(RoleID, SourceType, TempID, NPackItems, Count)
		end, PackItems, ItemsCount),
    do_move_items_to_pack(),
    do_notify_pack_change().
%%--------------------------------------------------------------------
%% @doc
%% @删除物品
%% player_pack:delete_items_by_insts_and_amount(2, [{103, 5}]).
%% @end
%%--------------------------------------------------------------------
delete_items_by_insts_and_amount(SourceType, ItemTuples) ->
    lists:foreach(fun({InstID, Count})-> 
			  do_delete_item_by_inst_id_and_amount(InstID, Count, SourceType)
		  end, ItemTuples),
    do_move_items_to_pack(),
    do_notify_pack_change().

delete_item(InstId, SourceType)->
    do_delete_item_by_inst_id(InstId, SourceType, nodeleteother).
delete_item(InstId, Amount, SourceType)->
    do_delete_item_by_inst_id_and_amount(InstId, Amount, SourceType),
    do_move_items_to_pack(),
    do_notify_pack_change().
delete_item_notify(InstId, SourceType)->
    do_delete_item_by_inst_id(InstId, SourceType, nodeleteother),
    do_move_items_to_pack(),
    do_notify_pack_change().

delete_item_and_other(InstId, SourceType)->
    do_delete_item_by_inst_id(InstId, SourceType),
    do_move_items_to_pack(),
    do_notify_pack_change().

%%--------------------------------------------------------------------
%% @doc
%% @根据实例ID判断物品是否存在
%% @end
%%--------------------------------------------------------------------
is_exist(InstID) ->
    %%RoleID = player:get_role_id(),
    Pack = get_my_pack(),
    case lists:filter(fun(X) -> X:inst_id()=:=InstID end, Pack) of
	[] ->
	    false;
	_  ->
	    true
	    %%case RoleID == Pack:role_id() of
	    %%	true ->
	    %%	    true;
            %%		false ->
	    %%	    false
	    %%end
    end.

%%--------------------------------------------------------------------
%% @doc
%% @根据模板表ID判断物品是否存在
%% @end
%%--------------------------------------------------------------------
is_exist_by_temp_id(TempID) ->
    Pack = get_my_pack(),
    Result = lists:filter(fun(X) -> X:temp_id()=:=TempID end, Pack),
    %%Result = db:find(db_pack, [{role_id, 'equals', RoleID}, {TempID, 'equals', TempID}]),
    case Result of
	[] ->
	    false;
	_ ->
	    true
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @增加物品
%% @end
%%--------------------------------------------------------------------



add_item(RoleID, SourceType, TempID, ItemType, Count)->
    MyId=player:get_role_id(),
    PackItems = case MyId =:= RoleID of
		    true -> get_my_pack(TempID);
		    false -> get_items()
		end,
    %%PackItems = get_my_pack(ItemType),
    IsOverlay = item:is_overlay(TempID),
    %% 如果不能叠加
    case IsOverlay of
	false ->
	    create(RoleID, SourceType, TempID, ItemType, Count);
	true ->
	    %% 如果没有该物品
	    case PackItems of
		[] ->
		    create(RoleID, SourceType, TempID, ItemType, Count);
		_ ->
		    PackItem = get_overlay_item(PackItems),
		    %% 是否有堆叠的物品没有满的
		    case PackItem of
			[] ->
			    create(RoleID, SourceType, TempID, ItemType, Count);
			_ ->
			    create_from_overlay_item(RoleID, SourceType, TempID, ItemType, Count, PackItem)
		    end
	    end

    end.

%%--------------------------------------------------------------------
%% @doc
%% @旧有可叠加的物品中增加
%% @end
%%--------------------------------------------------------------------
create_from_overlay_item(RoleID, SourceType, TempID, ItemType, Count, PackItem) ->
    CurrItemCount = PackItem:amount(),
    TotalCount = CurrItemCount+Count,
    OverlayCount = item:get_overlay_count(TempID),
    case TotalCount > OverlayCount of
	true ->
	    NPackItem = PackItem:set([{amount, OverlayCount}]),
	    NPackItem:save(),
	    pack_modify_msg_add(NPackItem),
	    player_log:create(RoleID, ?item, SourceType, ?add_item, PackItem:inst_id(), TempID, OverlayCount, ""),
	    create(RoleID, SourceType, TempID, ItemType, TotalCount-OverlayCount);
	false ->
	    NPackItem = PackItem:set([{amount, CurrItemCount+Count}]),
	    NPackItem:save(),
	    pack_modify_msg_add(NPackItem),
	    player_log:create(RoleID, ?item, SourceType, ?add_item, PackItem:inst_id(), TempID, Count, ""),
	    NPackItem
    end.

%%--------------------------------------------------------------------
%% @doc
%% @创建物品
%% @end
%%--------------------------------------------------------------------
create(RoleID, SourceType, TempID, ItemType, 1) ->
    InstID = item:get_inst_id(item:make(TempID)),
    save(RoleID, SourceType, InstID, TempID, ItemType, 1);
create(RoleID, SourceType, TempID, ItemType, Count) ->
    OverlayCount = item:get_overlay_count(TempID),
    InstID = item:get_inst_id(item:make(TempID)),
    case Count > OverlayCount of
	true ->
	    save(RoleID, SourceType, InstID, TempID, ItemType, OverlayCount),
	    create(RoleID, SourceType, TempID, ItemType, Count-OverlayCount);
	false ->
	    save(RoleID, SourceType, InstID, TempID, ItemType, Count)
    end.

%%--------------------------------------------------------------------
%% @doc
%% @保存物品
%% @end
%%--------------------------------------------------------------------
save(RoleID, SourceType, InstID, TempID, ItemType, Count) ->
    case is_space_exceeded() of
	false -> 
	    Pack = db_pack:new(id, RoleID, InstID, TempID, ItemType , Count, erlang:localtime()),
	    {ok,NPack}=Pack:save(),
	    save_other_info(NPack),
	    case player:get_role_id() of
		RoleID -> pack_add_msg_add(NPack);
		_ -> pack_add_msg_add(NPack)
	    end,
	    player_log:create(RoleID, ?item, SourceType, ?add_item, InstID, TempID, Count, ""),
	    NPack;
	true ->
	    do_move_items_to_cache(RoleID,{SourceType,TempID,Count})
    end.


save_other_info(Item)->
    %%Item=player_pack:add_item(notify, ?st_game_settle, ItemId),
    ItemId=Item:item_id(),
    case item:get_type(ItemId)of
	?equipment->
	    Equipment=equipment:create_equipment_and_save(ItemId,Item:inst_id()),
	    EquipmentInfo=#equipmentinfo{equipment_id=Equipment:equipment_id(),temp_id=Equipment:temp_id(),strengthen_level=Equipment:level(),
					 gem_extra=Equipment:addition_gem(),attr_ids=Equipment:attach_info(),bindtype = Equipment:bind_type(),
					bindstatus = Equipment:bind_status()},
	    
	    pack_equipment_add_msg_add(EquipmentInfo);
	?sculpture-> %% 符文
	    io_helper:format("save_other_info_err");
	_ ->ok
    end.

%%--------------------------------------------------------------------
%% @doc
%% @获取可堆叠的物品
%% @end
%%--------------------------------------------------------------------
get_overlay_item([]) ->
    [];
get_overlay_item([PackItem|PackItems]) ->
    TempID = PackItem:item_id(),
    Count = PackItem:amount(),
    OverlayCount = item:get_overlay_count(TempID),
    case OverlayCount > Count of
	true ->
	    PackItem;
	false ->
	    get_overlay_item(PackItems)
    end.


%%--------------------------------------------------------------------
%% @doc
%% @获取物品的数量
%% @end
%%--------------------------------------------------------------------
get_items_count([], _PackItems, ItemsCount) ->
    lists:reverse(ItemsCount);
get_items_count([TempID|TempIDs], PackItems, ItemsCount) ->
    TotalCount = 
	lists:foldl(fun(PackItem, Count) ->
			    case TempID == PackItem:item_id() of
				true ->
				    Count + PackItem:amount();
				false ->
				    Count
			    end
		    end, 0, PackItems),
    get_items_count(TempIDs, PackItems, [{TempID, TotalCount}|ItemsCount]).

%%--------------------------------------------------------------------
%% @doc
%% @删除物品
%% @end
%%--------------------------------------------------------------------
do_delete_item(_RoleID, _SourceType, _TempID, PackItems, 0) ->
    PackItems;
do_delete_item(RoleID, SourceType, TempID, PackItems, Count) ->
    PackItem = lists:keyfind(TempID, 5, PackItems),
    InstID =PackItem:id(),
    %% 物品的数量是否足够,
    %% 如果足够更新数量
    %% 如果不够则删除该实例并且继续往下删
    case PackItem:amount() > Count of
	true ->
	    NPackItem = PackItem:set([{amount, PackItem:amount()-Count}]),
	    NPackItem:save(),
	    pack_modify_msg_add(NPackItem),
	    player_log:create(RoleID, ?item, SourceType, ?delete_item, PackItem:inst_id(), TempID, Count, ""),
	    lists:keyreplace(InstID, 2, PackItems, NPackItem);
	false ->
	    LeftCount = Count - PackItem:amount(),
	    db:delete(InstID),
	    delete_other_info(PackItem),
	    pack_del_msg_add(PackItem:inst_id()),
	    player_log:create(RoleID, ?item, SourceType, ?delete_item, PackItem:inst_id(), TempID, PackItem:amount(), ""),
	    NPackItems = lists:keydelete(InstID, 2, PackItems),
	    do_delete_item(RoleID, SourceType, TempID, NPackItems, LeftCount)
    end.
do_delete_item_by_inst_id_and_amount(InstId, Amount, SourceType)->
    Item =  get_item(InstId),
    case Item:amount() =:= Amount of
	true ->
	    db:delete(Item:id()),
	    delete_other_info(Item),
	    pack_del_msg_add(InstId),
	    player_log:create(player:get_role_id(), ?item, SourceType, ?delete_item, InstId, Item:item_id(), Amount, "");
	false ->
	    NPackItem = Item:set([{amount, Item:amount()-Amount}]),
	    NPackItem:save(),
	    pack_modify_msg_add(NPackItem),
	    player_log:create(player:get_role_id(), ?item, SourceType, ?delete_item, InstId, Item:item_id(), Amount, "")
    end.
do_delete_item_by_inst_id(InstId, SourceType) ->
    case get_item(InstId) of
	undefined ->
	    not_exist;
	Item -> 
	    db:delete(Item:id()),
	    delete_other_info(Item),
	    pack_del_msg_add(InstId),
	    player_log:create(player:get_role_id(), ?item, SourceType, ?delete_item, InstId, Item:item_id(), 1, "")
    end.

do_delete_item_by_inst_id(InstId, SourceType, nodeleteother) ->
    case get_item(InstId) of
	undefined ->
	    not_exist;
	Item -> 
	    db:delete(Item:id()),
	    pack_del_msg_add(InstId),
	    player_log:create(player:get_role_id(), ?item, SourceType, ?delete_item, InstId, Item:item_id(), 1, "")
    end.

delete_other_info(Item)->
    %%Item=player_pack:add_item(notify, ?st_game_settle, ItemId),
    ItemId=Item:item_id(),
    case item:get_type(ItemId)of
	?equipment-> %% 删装备
	    equipment:equipment_delete(Item:inst_id());
	    %% case db:find(db_equipment,[{equipment_id,'equals',Item:inst_id()}]) of
	    %% 	[] ->
	    %% 	    ok;
	    %% 	[Equipment] ->
	    %% 	    db:delete(Equipment:id())
	    %% end;
	?sculpture -> %% 删符文
	    %% case db:find(db_sculpture,[{sculpture_id,'equals',Item:inst_id()}]) of
	    %% 	[] ->
	    %% 	    ok;
	    %% 	[Sculpture] ->
	    %% 	    db:delete(Sculpture:id())
	    %% end;
	    io_helper:format("del_error");
	_ ->ok
    end.

%%--------------------------------------------------------------------
%% @doc
%% @获取背包
%% @end
%%--------------------------------------------------------------------
get_my_pack()->
    case get(role_pack) of
	undefined -> 
	    MyPack=get_items(),
	    RoleId=player:get_role_id(),
	    Space=case player_role:get_db_role(RoleId) of%%case db:find(db_role,[{role_id,'equals',RoleId}]) of
		      undefined -> 
			  config:get(pack_space_init);
		      Role ->
			  Role:pack_space()
		  end,
	    put(role_pack_space,Space),
	    put(role_pack_item_extra,[]),
	    put(role_pack,MyPack),
	    put(pack_del,[]),
	    put(pack_add,[]),
	    put(pack_equipment_add,[]),
	    %%put(pack_sculpture_add,[]),
	    put(pack_modify,[]),
	    put(pack_extra,[]),
	    MyPack;
	Pack ->
	    Pack
    end.

get_my_pack_space()->
    case get(role_pack_space) of
	undefined ->
	    RoleId=player:get_role_id(),
	    %%case db:find(db_role,[{role_id,'equals',RoleId}]) of
	    case player_role :get_db_role(RoleId) of
		undefined ->
		    put(role_pack_space,config:get(pack_space_init));
		Role ->
		    put(role_pack_space,Role:pack_space())
	    end,
	    get(role_pack_space);
	    %%Role:pack_space(); 
	Space ->
	    Space
    end.

get_my_pack(TempId)->
    Pack=get_my_pack(),
    lists:filter(fun(X) -> X:item_id()=:=TempId end,Pack).

%%--------------------------------------------------------------------
%% @doc
%% @获取背包已用格子数
%% @end
%%--------------------------------------------------------------------
%%get_my_pack_item_amount(ItemType)->
%%    length(get_my_pack(ItemType)).

get_my_pack_item_amount()->
    length(get_my_pack()).

update_my_pack(Pack)->
    put(role_pack,Pack).


%%--------------------------------------------------------------------
%% @doc
%% @通知业务逻辑照成的数据修改
%% @end
%%--------------------------------------------------------------------
do_notify_pack_change()->    
    {DelItems,AddItems,ModifyItems,CacheItems,
     EquipmentItems}=unique_modify_pack(),
    clear_pack_modify_info(),
    notify_delete_items(get_item_del_infos(DelItems)),
    notify_append_items(get_item_infos(AddItems)),
    notify_modify_items(get_item_infos(ModifyItems)),
    equipment:append_equipment_infos(EquipmentItems),
    %%sculpture:append_sculpture_infos(SculptureItems),
    notify_add_cache_items(CacheItems).
    
%%--------------------------------------------------------------------
%% @doc
%% @去重
%% @end
%%--------------------------------------------------------------------
unique_modify_pack()->
    Del=get(pack_del),
    AddItems=get(pack_add),
    ModifyItems=get(pack_modify),
    CacheItems=get_cahche_item(),
    EquipmentItems=get(pack_equipment_add),
    %%SculptureItems=get(pack_sculpture_add),
    %%Pack=get_my_pack(),
    NewAdd=unique_items(AddItems,Del),
    NewModify=unique_items(unique_items(ModifyItems,Del),AddItems),
    {Del,NewAdd,NewModify,CacheItems,EquipmentItems}.

unique_items(ItemList1,ItemList2)->
    NewList=ItemList1--ItemList2,
    case length(NewList) =:= length(ItemList1) of
	true -> NewList;
	false -> unique_items(NewList,ItemList2)
    end.

%%--------------------------------------------------------------------
%% @doc
%% 获取物品信息
%% @end
%%--------------------------------------------------------------------
get_item_del_infos(Dels)->
    ItemInfos=lists:foldl(fun(X,In) ->
				  %%Item=get_item(X),
				  [#pack_item{id=X}|In]
			  end
			 ,[],Dels),    
    ItemInfos.
get_item_infos(Items)->
    ItemInfos=lists:foldl(fun(X,In) ->
				  Item=get_item(X),
				  [#pack_item{id=Item:inst_id(),itemid=Item:item_id(),itemtype=Item:item_type(),amount=Item:amount()}|In]
			  end
			 ,[],Items),    
    ItemInfos.
%%--------------------------------------------------------------------
%% @doc
%% @清空改动信息
%% @end
%%--------------------------------------------------------------------
clear_pack_modify_info()->
    put(pack_del,[]),
    put(pack_add,[]),
    put(pack_modify,[]),
    put(pack_equipment_add,[]),
    %%put(pack_sculpture_add,[]),

    put(pack_extra,[]).

%%--------------------------------------------------------------------
%% @doc
%% @转成发给客户端的数据
%% @end
%%--------------------------------------------------------------------
transform_items([],NewItems)->
    lists:reverse(NewItems);

transform_items([Item|Items],NewItems)->
    transform_items(Items,[#pack_item{id=Item:inst_id(),itemid=Item:item_id(),itemtype=Item:item_type(),amount=Item:amount()}|NewItems]).


%%--------------------------------------------------------------------
%% @doc
%% @保存改动信息并维护背包
%% @end
%%--------------------------------------------------------------------
pack_extra_msg_add(Item)->
    CurPack=get(pack_extra),
    put(pack_extra,lists:reverse([Item|lists:reverse(CurPack)])).

pack_equipment_add_msg_add(Equipment)->
    
    CurPack=get(pack_equipment_add),
    put(pack_equipment_add,[Equipment|CurPack]).

%% pack_sculpture_add_msg_add(Sculpture)->
    
%%     CurPack=get(pack_sculpture_add),
%%     put(pack_sculpture_add,[Sculpture|CurPack]).


pack_add_msg_add(NPackItem)->
    
    CurPack=get(pack_add),
    MyPack=lists:filter(fun(X)-> 
				X:inst_id() =/= NPackItem:inst_id()
			end,
			get_my_pack()),
    update_my_pack(lists:reverse([NPackItem|lists:reverse(MyPack)])),
    put(pack_add,[NPackItem:inst_id()|(CurPack--[NPackItem:inst_id()])]).

pack_del_msg_add(InstId)->
    CurPack=get(pack_del),
    MyPack=lists:filter(fun(X)-> 
				X:inst_id() =/= InstId
			end,
			get_my_pack()),
    update_my_pack(MyPack),
    put(pack_del,[InstId|(CurPack--[InstId])]).

pack_modify_msg_add(NPackItem)->
    CurPack=get(pack_modify),
    MyPack=lists:foldr(fun(X, In) ->
			       case X:inst_id() =:= NPackItem:inst_id() of
				   true ->[NPackItem|In];
				   false ->[X|In]
			       end
		       end,[],get_my_pack()),
    update_my_pack(MyPack),
    put(pack_modify,[NPackItem:inst_id()|(CurPack--[NPackItem:inst_id()])]).


%%--------------------------------------------------------------------
%% @doc
%% @添加缓存的东西到背包
%% @end
%%--------------------------------------------------------------------
do_move_items_to_pack()->
    PackSpace = get_my_pack_space(),
    CurCount = get_my_pack_item_amount(),
    Items = get(role_pack_item_extra),
    case PackSpace > CurCount of
	true ->
	    case length(Items) of
		0 -> ok;
		_ ->
		    put(role_pack_item_extra,[]),
		    add_items(Items),
		    put(pack_extra,[])
	    end;
	false ->
	    ok
    end.
%%--------------------------------------------------------------------
%% @doc
%% @超出的东西放到缓存
%% @end
%%--------------------------------------------------------------------
do_move_items_to_cache(RoleID,Item)->
    case player:get_role_id() of
	RoleID -> 
	    Items = get(role_pack_item_extra),
	    put(role_pack_item_extra,lists:reverse([Item|lists:reverse(Items)])),
	    pack_extra_msg_add(Item);
	    %%put(pack_extra,lists:reverse([Item|lists:reverse(get(pack_extra))]));
	_ -> ok
    end.
%%--------------------------------------------------------------------
%% @doc
%% @获取新增到缓存的物品
%% @end
%%--------------------------------------------------------------------
get_cahche_item()->				    
    NewCacheItems=get(pack_extra),
    NewCacheItems.
    
%%--------------------------------------------------------------------
%% @doc
%% @判断背包格子是否已满
%% @end
%%--------------------------------------------------------------------
is_space_exceeded()->
    PackSpace = get_my_pack_space(),
    CurCount = get_my_pack_item_amount(),
    PackSpace =< CurCount.

%% 还有几格
remain_space_count() ->
    PackSpace = get_my_pack_space(),
    CurCount = get_my_pack_item_amount(),
    PackSpace - CurCount.

%%check_space_enough([{100,1},{200,100}])

check_space_enough(Items)->
    Left = remain_space_count(),
    PackItems = get_my_pack(),
    %%io:format("~p~n",[Items]),
    NewItems = get_item_remain(compound_same_item(Items), PackItems, []),
    get_need_space(NewItems) =< Left.


get_need_space(Items) ->
    %%io:format("~p~n",[Items]),
    lists:foldl(fun({TempID, Amount}, Space) -> 
			Space + proc_ceil(Amount / item:get_overlay_count(TempID))
		end, 0, Items).



compound_same_item(Items)->
    lists:reverse(lists:foldl(fun({TempID, Amount}, In) -> 
			case lists:keyfind(TempID, 1, In) of
			    false ->
				[{TempID, Amount}|In];
			    {_, Org} ->
				lists:keyreplace(TempID, 1, In, {TempID, Org + Amount})
			end
		end, [], Items)).



%%--------------------------------------------------------------------
%% @doc
%% @获取物品的数量
%% @end
%%--------------------------------------------------------------------
get_item_remain([], _PackItems, ItemsCount) ->
    lists:reverse(lists:filter(fun({_, X}) -> 
				       X > 0
			       end, ItemsCount));
get_item_remain([{TempID, Amount}|TempIDs], PackItems, ItemsCount) ->
    %%io:format("~p~n",[TempID]),
    TotalCount = 
	lists:foldl(fun(PackItem, Count) ->
			    case TempID == PackItem:item_id() of
				true ->
				    Count + item:get_overlay_count(TempID) - PackItem:amount();
				false ->
				    Count
			    end
		    end, 0, PackItems),
    get_item_remain(TempIDs, PackItems, [{TempID, Amount - TotalCount}|ItemsCount]).


proc_ceil(A)->
    round(A+0.499999).

