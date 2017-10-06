%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 19 Apr 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(sculpture_pack).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("tplt_def.hrl").

-define(add_sculpture, 1).
-define(del_sculpture, 2).
-define(modify_sculpture, 3).




%% API
-export([  
	  add_frags/2, %%add_frags(SourceType, AddItems)
	  reduce_frags/2, %%reduce_frags(SourceType, DelItems)
	  get_item_by_tempid/1, %%get_item_by_tempid(TempId)
get_item_by_tempid/2,
	  get_item_by_instid/1, %%get_item_by_instid(InstId)
	  get_items_by_instids/2, %%get_items_by_instids([RoleId, InstIds])
	  create_sculpture_and_save/6,%%create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Level, RoleId)
	  create_sculpture_and_save/4,%%create_sculpture_and_save(SourceType, ItemType, SculptureID, Level)
	  get_type/1,%%get_type(Id)
	  level/1, %%level(Inst)
	  temp_id/1, %%temp_id(Inst)
	  modify_level/3, %%modify_level(SourceType, TempId, NewLevel)
	  modify_temp_id/3, %%modify_temp_id(SourceType, TempId, NewTempId)
	  get_frags_amount/1, %%get_frags_amount(FragIds)
	  check_frag_amount/1, %%check_frag_amount(Frags) 
	  get_all_skill/0, %%
	  get_all_talent/0, %%
	  %%notify_sculpture_pack_change/0, %%
	  get_my_sculpture/0,
	  gen_sculpture_type/0,
	  notify_sculpture_infos/0 %%
	]).




%% %%add_frags(?battle_settle, [{1001,10},{1002,1}])  , add frags
%% -spec add_frags(SourceType::integer(), AddItems::list()) -> Result::list().
%% %%reduce_frags(?battle_settle, [{1001,10},{1002,1}]), delete frags
%% -spec reduce_frags(SourceType::integer(), DelItems::list()) -> Result::list()|{delete_frag_err, frag_not_enough}. 
%% %%get_item_by_tempid(1001),get pack_item by temp_id
%% -spec get_item_by_tempid(TempId::integer()) -> Inst::tuple() |undefined.
%% %%create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Value, RoleId)
%% -spec create_sculpture_and_save(integer(), integer(), integer(), integer(), integer(), integer()) -> Inst::tuple().
%% %%


%%%===================================================================
%%% API
%%%===================================================================
gen_sculpture_type() ->
    case ets:info(sculpture_type_tplt) of
	undefined ->
	    ok;
	_ ->
	    ets:delete(sculpture_type_tplt)
    end,
    Sculptures = tplt:get_all_data(skill_tplt),
    Talents = tplt:get_all_data(talent_tplt),
    Frags = tplt:get_all_data(skill_frag_tplt),
    ets:new(sculpture_type_tplt, [ordered_set, public, named_table]),
    lists:foreach(fun(#skill_tplt{id = Id}) -> 
			  save_tplt(Id, ?item_sculpture);
		     (#talent_tplt{id = Id}) ->
			  save_tplt(Id, ?item_talent);
		     (#skill_frag_tplt{id = Id}) ->
			  save_tplt(Id, ?item_frag)
		  end, lists:concat([Sculptures, Talents, Frags])).


get_type(Id) ->
    tplt:get_data(sculpture_type_tplt, Id).


save_tplt(Id, Type) ->
    case ets:lookup(sculpture_type_tplt, Id) of
	[] ->
	    ets:insert(sculpture_type_tplt, {Id, Type});
	[{_, OldType}] ->
	    erlang:error({key_reapeat, sculpture_type_tplt, {Id, Type}, {exist_type, OldType}})
    end.




notify_sculpture_infos() ->
    packet:send(#notify_sculpture_infos{type = ?init, sculpture_infos = get_all_sculpture_info()}).




%%--------------------------------------------------------------------
%% @doc
%% @spec 新增符文 eg: add_frags(1, [{1001, 1}, {1002, 1}])
%% @end
%%--------------------------------------------------------------------
add_frags(SourceType, AddItems)->
    lists:foreach(fun(X) -> 
			  proc_add_single_frag(SourceType, X) 
		  end, merge_same_sculpture(AddItems)),
    notify_sculpture_pack_change().



%%--------------------------------------------------------------------
%% @doc
%% @spec 批量删除符文 eg: del_sculptures(1, [{1001, 1}, {1002, 1}])
%% @end
%%--------------------------------------------------------------------
reduce_frags(SourceType, DelItems)->
    lists:foreach(fun(X) -> 
			  proc_del_single_frag(SourceType, X) 
		  end, merge_same_sculpture(DelItems)),
    notify_sculpture_pack_change().

level(Inst) ->
    Inst:value().
temp_id(Inst) ->
    Inst:temp_id().

modify_level(SourceType, TempId, NewLevel) ->
    case get_item_by_tempid(TempId) of
	undefined ->
	    throw({sculpture_modify_level, item_not_exist});
	Inst ->
	    NewInst = Inst:set([{value, NewLevel}]),
	    modify_sculpture(SourceType, NewInst),
	    notify_sculpture_pack_change()
    end.


modify_temp_id(SourceType, TempId, NewTempId) ->
    case get_item_by_tempid(TempId) of
	undefined ->
	    throw({sculpture_modify_temp_id, item_not_exist});
	Inst ->
	    NewInst = Inst:set([{temp_id, NewTempId}]),
	    modify_sculpture(SourceType, NewInst),
	    notify_sculpture_pack_change()
    end.



%%--------------------------------------------------------------------
%% @doc
%% @spec 传进来一个新的符文并替换原来的符文
%% @end
%%--------------------------------------------------------------------
modify_sculpture(SourceType, Sculpture)->
    do_modify_sculpture(SourceType, Sculpture).



%%--------------------------------------------------------------------
%% @doc
%% @spec 通过符文的实例ID获取符文信息
%% @end
%%--------------------------------------------------------------------
%% get_sculpture(InstId) ->
%%     Pack = get_my_sculpture(),
%%     io_helper:format("SculptureId: ~p~n",[InstId]),
%%     Item = case lists:filter(fun(X) -> X:sculpture_id()=:=InstId end, Pack) of
%% 	       [] -> undefined;
%% 	       [NItem] -> NItem
%% 	   end,
%%     Item.


%%--------------------------------------------------------------------
%% @doc
%% @spec 通过符文的实例ID获取符文信息
%% @end
%%--------------------------------------------------------------------
notify_sculpture_pack_change()->
    {DelIds, ModifyItems}=unique_modify_pack(),
    clear_sculpture_pack_modify_info(),
    do_notify_delete_items([#sculpture_info{temp_id=X} || X <- DelIds]),
    %%do_notify_append_items([trans_sculpture_info(get_item_by_instid(AddItem)) || AddItem <- AddItems]),
    do_notify_modify_items([trans_sculpture_info(ModifyItem) || ModifyItem <- ModifyItems]).





get_all_skill() ->
    [S:temp_id() || S <- lists:filter(fun(Item) -> Item:type() =:= ?item_sculpture end, get_my_sculpture())].


get_all_talent() ->
    [S:temp_id() || S <- lists:filter(fun(Item) -> Item:type() =:= ?item_talent end, get_my_sculpture())].




get_item_by_tempid(TempId) ->
    case lists:keyfind(TempId, db_sculpture:index(temp_id), get_my_sculpture()) of
	false ->
	    undefined;
	Inst ->
	    Inst
    end.
get_item_by_tempid(RoleID, TempId) ->
	case lists:keyfind(TempId, db_sculpture:index(temp_id), get_db_sculptures(RoleID)) of
		false ->
			undefined;
		Inst ->
			Inst
	end.

get_item_by_instid(InstId) ->
    case lists:keyfind(InstId, db_sculpture:index(sculpture_id), get_my_sculpture()) of
	false ->
	    undefined;
	Inst ->
	    Inst
    end.


get_items_by_instids(RoleId, InstIds) ->
    case player:get_role_id() of
	RoleId ->
	    [get_item_by_instid(InstId)  || InstId <- InstIds];
	_ ->
	    db:find(db_sculpture, [{sculpture_id, 'in', InstIds}])
    end.


%%[{1001,1},{1002,3}]
check_frag_amount(Frags) ->
    lists:foldl(fun(_, false) ->
			false;
		   ({FragId, Amount}, true) ->
			get_frag_amount(FragId) >= Amount 
		end, true, merge_same_sculpture(Frags)).


get_frags_amount(FragIds) ->
    [{FragId, get_frag_amount(FragId)}|| FragId <- FragIds].





%%%===================================================================
%%% Internal functions
%%%===================================================================
get_all_sculpture_info() ->
    [#sculpture_info{temp_id = Inst:temp_id(), value = Inst:value(), type = Inst:type()}||Inst <- get_my_sculpture()].

%% 获取单种符文碎片数量
get_frag_amount(FragId) ->
    case lists:keyfind(FragId, db_sculpture:index(temp_id), get_my_sculpture()) of
	false ->
	    0;
	Inst ->
	    case Inst:type() of
		?item_frag ->
		    Inst:value();
		_ ->
		    throw({get_frag_amount, item_type_err})
	    end
    end.


%% 添加单种符文碎片
proc_add_single_frag(SourceType, {FragId, Value}) when Value > 0 ->
    case get_item_by_tempid(FragId) of
	undefined ->
	    do_create_sculpture_and_save(SourceType, ?item_frag, FragId, Value);
	Inst ->
	    NewInfo = Inst:set([{value, Inst:value() + Value}]),
	    NewInfo:save(),
	    sculpture_modify_msg_append(NewInfo),
	    player_log:create(NewInfo:role_id(), ?sculpture_frag, SourceType, 
		      ?add_sculpture, NewInfo:sculpture_id(), NewInfo:temp_id(), Value, "")
    end.

%% 删除单种符文碎片
proc_del_single_frag(SourceType, {FragId, Amount})->
    case get_item_by_tempid(FragId) of
	undefined ->
	    throw({delete_frag_err, frag_not_enough});%%(SourceType, ?item_frag, FragId, Value);
	Inst ->
	    case Inst:value() > Amount of
		true ->
		    NewInfo = Inst:set([{value, Inst:value() - Amount}]),
		    NewInfo:save(),
		    sculpture_modify_msg_append(NewInfo),
		    player_log:create(NewInfo:role_id(), ?sculpture_frag, SourceType, 
				      ?del_sculpture, NewInfo:sculpture_id(), NewInfo:temp_id(), Amount, "");
		false ->
		    do_del_sculpture(Inst, SourceType)
	    end
    end.



do_del_sculpture(Sculpture, SourceType) ->
    Sculpture:delete(),
    sculpture_del_msg_append(Sculpture:temp_id()),
    player_log:create(Sculpture:role_id(), ?sculptures, SourceType, 
		      ?del_sculpture, Sculpture:sculpture_id(), Sculpture:temp_id(), Sculpture:value(), "").


do_modify_sculpture(SourceType, Sculpture) ->
    Sculpture:save(),
    sculpture_modify_msg_append(Sculpture),
    player_log:create(Sculpture:role_id(), ?sculptures, SourceType, 
		      ?modify_sculpture, Sculpture:sculpture_id(), Sculpture:temp_id(), 1, "").



%% 批量保存符文物品
do_create_sculpture_and_save(_, _ItemType, _, 0)->
    [];



do_create_sculpture_and_save(SourceType, ItemType, SculptureID, Amount)->
    InstId = uuid:gen(),
    do_create_sculpture_and_save(SourceType, ItemType, SculptureID, InstId, Amount).
    %%[create_sculpture_and_save(SourceType, SculptureID, InstId)|create_sculptures_and_save(SourceType, SculptureID, Amount - 1)].




%% 保存符文物品
do_create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Amount)->
    %% 产生符文物品
    RoleId = player:get_role_id(),
    do_create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Amount, RoleId).

%% 保存单个符文
do_create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Value, RoleId)->
    %% 产生符文物品
    %%try SculptureInfo = tplt:get_data(sculpture_tplt, SculptureTpltId),
    SculptureObj = db_sculpture:new(id, InstanceId, RoleId, SculptureTpltId, Value, ItemType, datetime:local_time()),
    {ok, Result} = SculptureObj:save(),
    case player:get_role_id() of
	RoleId ->
	    sculpture_add_msg_append(Result);
	_ ->
	    ok
    end,
    player_log:create(Result:role_id(), ?sculptures, SourceType, ?add_sculpture, Result:sculpture_id(), Result:temp_id(), Value, ""),
    Result.
    


%% 批量保存符文物品
%% create_sculpture_and_save(_, _ItemType, _, 0)->
%%     [];



create_sculpture_and_save(SourceType, ItemType, SculptureID, Amount)->
    %% InstId = uuid:gen(),
    %% create_sculpture_and_save(SourceType, ItemType, SculptureID, InstId, Amount).
    %% %%[create_sculpture_and_save(SourceType, SculptureID, InstId)|create_sculptures_and_save(SourceType, SculptureID, Amount - 1)].
    Inst = do_create_sculpture_and_save(SourceType, ItemType, SculptureID, Amount),
    notify_sculpture_pack_change(),
    Inst.




%% %% 保存符文物品
%% create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Amount)->
%%     %% 产生符文物品
%%     RoleId = player:get_role_id(),
%%     create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Amount, RoleId).

%% 保存单个符文
create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Value, RoleId)->
    %% SculptureObj = db_sculpture:new(id, InstanceId, RoleId, SculptureTpltId, Value, ItemType, datetime:local_time()),
    %% {ok, Result} = SculptureObj:save(),
    %% case player:get_role_id() of
    %% 	RoleId ->
    %% 	    sculpture_add_msg_append(Result);
    %% 	_ ->
    %% 	    ok
    %% end,
    %% player_log:create(Result:role_id(), ?sculptures, SourceType, ?add_sculpture, Result:sculpture_id(), Result:temp_id(), Value, ""),
    %% Result.
    Inst = do_create_sculpture_and_save(SourceType, ItemType, SculptureTpltId, InstanceId, Value, RoleId),
    notify_sculpture_pack_change(),
    Inst.







%%通知删除
do_notify_delete_items(DelItems)->
    case length(DelItems) of
	0 ->
	    ok;
	_ ->
	    packet:send(#notify_sculpture_infos{type=?delete,sculpture_infos=DelItems})
    end.

%% %%通知追加
%% do_notify_append_items(AdditionList)->
%%     case length(AdditionList) of
%% 	0 ->
%% 	    ok;
%% 	_ ->
%% 	    packet:send(#notify_sculpture_infos{type=?append,sculpture_infos=AdditionList})
%%     end.

%%通知修改
do_notify_modify_items(ModifyItems)->
    case length(ModifyItems) of
	0 ->
	    ok;
	_ ->
	    packet:send(#notify_sculpture_infos{type=?modify,sculpture_infos=ModifyItems})

    end.



%%清空改变列表
clear_sculpture_pack_modify_info()->
    %% put(sculpture_del,[]),
    %% put(sculpture_add,[]),
    put(sculpture_change,[]).


get_sculpture_change() ->
    case get(sculpture_change) of
	undefined ->
	    [];
	List ->
	    List
    end.

%% get_sculpture_del() ->
%%     case get(sculpture_del) of
%% 	undefined ->
%% 	    [];
%% 	List ->
%% 	    List
%%     end.

%% get_sculpture_modify() ->
%%     case get(sculpture_modify) of
%% 	undefined ->
%% 	    [];
%% 	List ->
%% 	    List
%%     end.

%%获得整个改变列表
unique_modify_pack()->
    ChangeIds = get_sculpture_change(),
    %%[{Id, get_item_by_tempid(Id)}|| Id <- ChangeIds],
    {DelIds, ModifyItems} = lists:foldl(fun(X, {D, M}) -> 
						case get_item_by_tempid(X) of
						    undefined ->
							{[X|D], M};
						    Item ->
							{D, [Item|M]}
						end
					end, {[],[]}, ChangeIds),
    {DelIds, ModifyItems}.
    %% Del=get_sculpture_del(),
    %% AddItems=get_sculpture_add(),
    %% ModifyItems=get_sculpture_modify(),
    %% NewAdd=unique_items(AddItems,Del),
    %% NewModify=unique_items(unique_items(ModifyItems,Del),AddItems),
    %% {Del,NewAdd,NewModify}.


%% unique_items(ItemList1,ItemList2)->
%%     NewList=ItemList1--ItemList2,
%%     case length(NewList) =:= length(ItemList1) of
%% 	true -> NewList;
%% 	false -> unique_items(NewList,ItemList2)
%%     end.


%%获取我的符文列表
get_my_sculpture()->
    case get(sculpture_pack) of
	undefined -> 
	    MySculpture = get_db_sculptures(),
	    put(sculpture_pack,get_db_sculptures()),
	    put(sculpture_change,[]),
	    %% put(sculpture_add,[]),
	    %% put(sculpture_modify,[]),
	    MySculpture;
	Pack ->
	    Pack
    end.


%%把数据库里的数据转化成#sculpture_info{}
trans_sculpture_info(DBObj)->
    #sculpture_info{ temp_id=DBObj:temp_id(), 
		    value = DBObj:value(),
		    type = DBObj:type()}.


%%获取数据库里的符文信息
get_db_sculptures()->
    RoleId=player:get_role_id(),
    get_db_sculptures(RoleId).

get_db_sculptures(RoleId)->
    DBObjs = db:find(db_sculpture,[{role_id,'equals',RoleId}]),
    DBObjs.



%%合并相同ID的物品
merge_same_sculpture(Sculptures)->
    lists:reverse(lists:foldl(fun({TempID, Amount}, In) -> 
			case lists:keyfind(TempID, 1, In) of
			    false ->
				[{TempID, Amount}|In];
			    {_, Org} ->
				lists:keyreplace(TempID, 1, In, {TempID, Org + Amount})
			end
		end, [], Sculptures)).







sculpture_add_msg_append(NPackItem)->
    io_helper:format("NPackItem: ~p~n", [NPackItem]),
    CurPack=get_sculpture_change(),
    MyPack=lists:filter(fun(X)-> 
				X:sculpture_id() =/= NPackItem:sculpture_id()
			end,
			get_my_sculpture()),
    update_my_sculpture(lists:reverse([NPackItem|lists:reverse(MyPack)])),
    put(sculpture_change,[NPackItem:temp_id()|(CurPack--[NPackItem:temp_id()])]).



sculpture_del_msg_append(TempId)->
    CurPack=get_sculpture_change(),
    %%Inst = get_item_by_instid(InstId),
    update_my_sculpture(lists:keydelete(TempId, 
					db_sculpture:index(temp_id), 
					get_my_sculpture())),
    put(sculpture_change,[TempId|(CurPack--[TempId])]).



sculpture_modify_msg_append(NPackItem)-> 
    CurPack=get_sculpture_change(),
    OldItem = get_item_by_instid(NPackItem:sculpture_id()),
    CuChange = case OldItem:temp_id() =:= NPackItem:temp_id() of
		   true->
		       CurPack;
		   _ ->
		       [OldItem:temp_id()|(CurPack--[OldItem:temp_id()])]
	       end,
    update_my_sculpture(lists:keyreplace(NPackItem:sculpture_id(), 
					 db_sculpture:index(sculpture_id), 
					 get_my_sculpture(), 
					 NPackItem)),
    put(sculpture_change,[NPackItem:temp_id()|(CuChange--[NPackItem:temp_id()])]).



    


update_my_sculpture(Pack)->
    put(sculpture_pack,Pack).











    
    



