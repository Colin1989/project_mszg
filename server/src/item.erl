%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2014, linyibin
%%% @doc 
%%% 物品
%%% @end
%%% Created :  3 Jan 2014 by linyibin <>
%%%-------------------------------------------------------------------
-module(item).

-include("packet_def.hrl").
-include("tplt_def.hrl").

%% API
-export([make/1, 
	 get_inst_id/1, 
	 get_temp_id/1,
	 get_type/1,
	 get_name/1,
	 is_overlay/1,
	 get_overlay_count/1,
	 get_sub_id/1,
	 get_sell_price/1,
	 get_bind_type/1,
	 get_role_type/1]).

%% 物品id根据角色类型转换API
-export([ init_item_role_type/0
	  %%reload_item_role_type/0
	]).
%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @生成物品
%% @end
%%--------------------------------------------------------------------
make(TempID) ->
    InstID = uuid:gen(),
    #item{inst_id = InstID, temp_id = TempID}.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品实例ID
%% @end
%%--------------------------------------------------------------------
get_inst_id(Item) when is_tuple(Item) ->
    Item#item.inst_id.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品模板ID
%% @end
%%--------------------------------------------------------------------
get_temp_id(Item) when is_tuple(Item) ->
    Item#item.temp_id.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品类型
%% @end
%%--------------------------------------------------------------------
get_type(TempID) when is_integer(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.type.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品职业类型
%% @end
%%--------------------------------------------------------------------
get_role_type(TempID) when is_integer(TempID) ->
    get_item_role_type(TempID).

%%--------------------------------------------------------------------
%% @doc
%% @获取物品名称
%% @end
%%--------------------------------------------------------------------
get_name(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.name.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品销售价格
%% @end
%%--------------------------------------------------------------------
get_sell_price(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.sell_price.

%%--------------------------------------------------------------------
%% @doc
%% @是否可叠加
%% @end
%%--------------------------------------------------------------------
is_overlay(TempID) ->
    OverlayCount = get_overlay_count(TempID),
    case OverlayCount > 0 of
	true ->
	    true;
	false ->
	    false
    end.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品堆叠数量
%% @end
%%--------------------------------------------------------------------
get_overlay_count(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.overlay_count.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品关联ID
%% @end
%%--------------------------------------------------------------------
get_sub_id(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.sub_id.


%%--------------------------------------------------------------------
%% @doc
%% @获取物品绑定类型
%% @end
%%--------------------------------------------------------------------
get_bind_type(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.bind_type.


%%--------------------------------------------------------------------
%% @doc
%% @获取物品所属角色类型
%% @end
%%--------------------------------------------------------------------
init_item_role_type() ->
    case ets:info(item_role_type) of
        undefined ->
            ok;
        _ ->
            ets:delete(item_role_type)

    end,
    Items = tplt:get_all_data(item_tplt),
    ets:new(item_role_type, [ordered_set, public, named_table]),
    save([{Key, RoleType} || #item_tplt{id = Key, role_type = RoleType} <- Items]),
    Frags = tplt:get_all_data(skill_frag_tplt),
    save([{Key, RoleType} || #skill_frag_tplt{id = Key, role_type = RoleType} <- Frags]),
    Skills = tplt:get_all_data(skill_tplt),
    save([{Key, RoleType} || #skill_tplt{id = Key, role_type = RoleType} <- Skills]),
    ok.
   
%%--------------------------------------------------------------------
%% @doc
%% @spe重载物品角色对应关系
%% @end
%%--------------------------------------------------------------------
%%reload_item_role_type()->
%%    ets:delete(item_role_type),
%%    FilePath = get_file_path(),
%%    Item_role = get_role_type(FilePath),
%%    ets:new(item_role_type, [ordered_set, public, named_table]),
%%    save(Item_role).

%%--------------------------------------------------------------------
%% @doc
%% @spec read file and get the roletype
%% @end
%%--------------------------------------------------------------------

%% get_role_type(FilePath)->
%%     {ok,Xml} = file:read_file(FilePath),
%%     {ok,{_Root,_,[{_,_,_}|_]=Records},_} = erlsom:simple_form(Xml),
%%     F = fun({_,_,[{_,_,[Id]},_2,_3,_4,_5,_6,_7,_8,_9,{_,_,[Role_type]},_]})-> {list_to_integer(Id),list_to_integer(Role_type)} end,
%%     lists:map(F,Records).
%%--------------------------------------------------------------------
%% @doc
%% @spec  get the item_tplt.xml filepath
%% @end
%%--------------------------------------------------------------------
%% get_file_path() ->
%%     FilePath = case os:getenv("template") of
%% 	       false -> "./template/"
%% 	   end,
%%     FilePath ++ "item_tplt.xml".
%%--------------------------------------------------------------------
%% @doc
%% @desc get the item role_type value by key
%% @end
%%--------------------------------------------------------------------
get_item_role_type(Key)when is_integer(Key) ->
    case  ets:lookup(item_role_type, Key) of 
	[{Key, Value}]  ->
	    Value;
	_ ->
	   %% io_helper:format("Error Key:~p~n",[Key]),
	    0
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec save the value the ets
%% @end
%%--------------------------------------------------------------------

save([]) ->
    ok;
save([{Key, Value}|ItemRoleType]) ->
    case Value of
	0 ->
	    save(ItemRoleType);
	_ ->
	    %%io_helper:format("~p~n", [{Key, Value}]),
	    ets:insert(item_role_type, {Key, Value}),
	    save(ItemRoleType)
    end.
%%%===================================================================
%%% Internal functions
%%%===================================================================
