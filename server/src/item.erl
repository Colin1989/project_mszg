%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2014, linyibin
%%% @doc 
%%% ��Ʒ
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

%% ��Ʒid���ݽ�ɫ����ת��API
-export([ init_item_role_type/0
	  %%reload_item_role_type/0
	]).
%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @������Ʒ
%% @end
%%--------------------------------------------------------------------
make(TempID) ->
    InstID = uuid:gen(),
    #item{inst_id = InstID, temp_id = TempID}.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒʵ��ID
%% @end
%%--------------------------------------------------------------------
get_inst_id(Item) when is_tuple(Item) ->
    Item#item.inst_id.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒģ��ID
%% @end
%%--------------------------------------------------------------------
get_temp_id(Item) when is_tuple(Item) ->
    Item#item.temp_id.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒ����
%% @end
%%--------------------------------------------------------------------
get_type(TempID) when is_integer(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.type.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒְҵ����
%% @end
%%--------------------------------------------------------------------
get_role_type(TempID) when is_integer(TempID) ->
    get_item_role_type(TempID).

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒ����
%% @end
%%--------------------------------------------------------------------
get_name(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.name.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒ���ۼ۸�
%% @end
%%--------------------------------------------------------------------
get_sell_price(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.sell_price.

%%--------------------------------------------------------------------
%% @doc
%% @�Ƿ�ɵ���
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
%% @��ȡ��Ʒ�ѵ�����
%% @end
%%--------------------------------------------------------------------
get_overlay_count(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.overlay_count.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒ����ID
%% @end
%%--------------------------------------------------------------------
get_sub_id(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.sub_id.


%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒ������
%% @end
%%--------------------------------------------------------------------
get_bind_type(TempID) ->
    ItemTplt = tplt:get_data(item_tplt, TempID),
    ItemTplt#item_tplt.bind_type.


%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��Ʒ������ɫ����
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
%% @spe������Ʒ��ɫ��Ӧ��ϵ
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
