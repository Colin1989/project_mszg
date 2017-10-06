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

-define(add_sculpture, 1).
-define(del_sculpture, 2).
-define(modify_sculpture, 3).

%% API
-export([start/0, 
	 add_sculptures/2, 
	 del_sculptures/2,
	 del_sculptures_by_inst/2,
	 get_sculpture_by_inst/1,
	 modify_sculpture/2,
	 batch_proc/3,
	 create_sculpture_and_save/4,
	 put_on/2,
	 take_off/1,
	 get_inst_pos/1]).
%% -export([add_item/2,
%% 	 add_item/3,
%% 	 add_item/4,
%% 	 add_items/2,
%% 	 get_item/1,
%% 	 set_item/3,
%% 	 delete_items/2,
%% 	 delete_items_by_insts_and_amount/2,
%% 	 delete_item/2,
%% 	 delete_item/3,
%% 	 delete_item_and_other/2,
%% 	 delete_item_notify/2,
%% 	 get_items_count/1,
%% 	 is_exist/1,
%% 	 is_exist_by_temp_id/1,
%% 	 is_space_exceeded/0,
%% 	 remain_space_count/0, %% ʣ�༸��
%% 	 check_space_enough/1
%% 	]).

-export([get_my_sculpture/0, 
	 trans_sculpture_info/1, 
	 get_max_space/0, 
	 check_pack_enough/1, 
	 get_remain_space/0,
	 notify_sculpture_pack_change/0,
	 get_frag_count/0,
	 get_temp_id_index/0]).

%%-export([notify_append_items/1,notify_delete_items/1,notify_modify_items/1,do_notify_pack_change/0, notify_init_player_pack/0]).


%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
start() ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec �������� eg: add_sculpture(1, [{1001, 1}, {1002, 1}])
%% @end
%%--------------------------------------------------------------------
add_sculptures(SourceType, AddItems)->
    lists:foreach(fun(X) -> 
			  proc_add_single_sculpture(SourceType, X) 
		  end, merge_same_sculpture(AddItems)).



%%--------------------------------------------------------------------
%% @doc
%% @spec ����ɾ������ eg: del_sculptures(1, [{1001, 1}, {1002, 1}])
%% @end
%%--------------------------------------------------------------------
del_sculptures(SourceType, DelItems)->
    lists:foreach(fun(X) -> 
			  proc_del_single_sculpture(SourceType, X) 
		  end, merge_same_sculpture(DelItems)).



%%--------------------------------------------------------------------
%% @doc
%% @spec ͨ��ʵ��IDɾ������ eg: del_sculptures_by_inst(1, [1111111111111111111111,2222222222222222222222,3333333333333333333333])
%% @end
%%--------------------------------------------------------------------
del_sculptures_by_inst(SourceType, DelItems)->
    MySculpture = get_my_sculpture(),
    lists:map(fun(X) -> 
		      T = lists:keyfind(X, get_inst_id_index(), MySculpture),
		      do_del_sculpture(T, SourceType)
	      end, DelItems).


%%--------------------------------------------------------------------
%% @doc
%% @spec ͨ��ʵ��ID��ȡ���� eg: get_sculpture_by_inst(1111111111111111111111,2222222222222222222222,3333333333333333333333)
%% @end
%%--------------------------------------------------------------------
get_sculpture_by_inst(InstId)->
    case lists:keyfind(InstId, get_inst_id_index(), get_my_sculpture()) of
	false ->
	    undefined;
	Inst ->
	    Inst
    end.



%%--------------------------------------------------------------------
%% @doc
%% @spec ������һ���µķ��Ĳ��滻ԭ���ķ���
%% @end
%%--------------------------------------------------------------------
modify_sculpture(SourceType, Sculpture)->
    do_modify_sculpture(SourceType, Sculpture).

%%--------------------------------------------------------------------
%% @doc
%% @spec �жϷ��ı����Ƿ���������ΪAmount�ķ���
%% @end
%%--------------------------------------------------------------------
check_pack_enough(Amount) ->
    SculpturePack = get_my_sculpture(),
    length(SculpturePack) + Amount =< get_max_space().


get_remain_space()->
    SculpturePack = get_my_sculpture(),
    get_max_space() - length(SculpturePack).


get_frag_count()->
    player_role:get_sculpture_frag().


%%--------------------------------------------------------------------
%% @doc
%% @spec ͨ�����ĵ�ʵ��ID��ȡ������Ϣ
%% @end
%%--------------------------------------------------------------------
get_sculpture(InstId) ->
    Pack = get_my_sculpture(),
    io_helper:format("SculptureId: ~p~n",[InstId]),
    Item = case lists:filter(fun(X) -> X:sculpture_id()=:=InstId end, Pack) of
	       [] -> undefined;
	       [NItem] -> NItem
	   end,
    Item.


%%--------------------------------------------------------------------
%% @doc
%% @spec ͨ�����ĵ�ʵ��ID��ȡ������Ϣ
%% @end
%%--------------------------------------------------------------------
notify_sculpture_pack_change()->
    {DelItems,AddItems,ModifyItems}=unique_modify_pack(),
    clear_sculpture_pack_modify_info(),
    do_notify_delete_items([#pack_item{id=X} || X <- DelItems]),
    do_notify_append_items([trans_sculpture_info(get_sculpture(AddItem)) || AddItem <- AddItems]),
    do_notify_modify_items([trans_sculpture_info(get_sculpture(ModifyItem)) || ModifyItem <- ModifyItems]).



put_on(Pos, InstId)->
    put(role_puton, lists:keyreplace(Pos, 1, get(role_puton), {Pos, InstId})).


take_off(Pos)->
    put(role_puton, lists:keyreplace(Pos, 1, get(role_puton), {Pos, 0})).


get_inst_pos(InstId)->
    case lists:keyfind(InstId, 2, get(role_puton)) of
	false ->
	    0;
	{Pos, InstId} ->
	    Pos
    end.









%%%===================================================================
%%% Internal functions
%%%===================================================================


%% ��ӵ������
proc_add_single_sculpture(SourceType, {SculptureId, Amount})->
    case get_frag_id() of
	SculptureId ->
	    player_role:add_sculpture_frag(SourceType, Amount);
	_ ->
	    create_sculptures_and_save(SourceType, SculptureId, Amount)
    end.

%% ɾ���������
proc_del_single_sculpture(SourceType, {SculptureId, Amount})->
    case get_frag_id() of
	SculptureId ->
	    player_role:reduce_sculpture_frag(SourceType, Amount);
	_ ->
	    do_del_sculpture(SourceType, SculptureId, Amount)
    end.

do_del_sculpture(SourceType, SculptureID, Amount) ->
    MySculpture = get(sculpture_pack),
    0 = lists:foldl(fun(X, Left) ->
			case Left of
			    _ when Left =< 0 ->
				0;
			    _ ->
				case X:temp_id() =:= SculptureID of
				    true ->
					do_del_sculpture(X, SourceType),
					Left - 1;
				    false ->
					Left
				end
			end
		end, Amount, MySculpture).


do_del_sculpture(Sculpture, SourceType) ->
    Sculpture:delete(),
    sculpture_del_msg_append(Sculpture:sculpture_id()),
    player_log:create(Sculpture:role_id(), ?sculptures, SourceType, 
		      ?del_sculpture, Sculpture:sculpture_id(), Sculpture:temp_id(), 1, "").


do_modify_sculpture(SourceType, Sculpture) ->
    Sculpture:save(),
    sculpture_modify_msg_append(Sculpture),
    player_log:create(Sculpture:role_id(), ?sculptures, SourceType, 
		      ?modify_sculpture, Sculpture:sculpture_id(), Sculpture:temp_id(), 1, "").




%% �������������Ʒ
create_sculptures_and_save(_, _, 0)->
    [];



create_sculptures_and_save(SourceType, SculptureID, Amount)->
    InstId = uuid:gen(),
    [create_sculpture_and_save(SourceType, SculptureID, InstId)|create_sculptures_and_save(SourceType, SculptureID, Amount - 1)].



%% ���浥������
create_sculpture_and_save(SourceType, SculptureTpltId, InstanceId, RoleId)->
    %% ����������Ʒ
    Exp = 0,
    try SculptureInfo = tplt:get_data(sculpture_tplt, SculptureTpltId),
	 SculptureObj = db_sculpture:new(id,InstanceId,RoleId,SculptureTpltId,0,Exp,datetime:local_time()),
	 {ok, Result} = SculptureObj:save(),
	 case player:get_role_id() of
	     RoleId ->
		 sculpture_add_msg_append(Result);
	     _ ->
		 ok
	 end,
	 player_log:create(Result:role_id(), ?sculptures, SourceType, ?add_sculpture, Result:sculpture_id(), Result:temp_id(), 1, ""),
	 Result
    catch
	_:_ -> 
	    player_log:create(RoleId, ?sculptures, SourceType, ?add_sculpture, InstanceId, SculptureTpltId, 1, ""),
	    undefined
    end.

%% ���������Ʒ
create_sculpture_and_save(SourceType, SculptureTpltId, InstanceId)->
    %% ����������Ʒ
    RoleId = player:get_role_id(),
    create_sculpture_and_save(SourceType, SculptureTpltId, InstanceId, RoleId).



%%֪ͨɾ��
do_notify_delete_items(DelItems)->
    case length(DelItems) of
	0 ->
	    ok;
	_ ->
	    packet:send(#notify_sculpture_infos{type=?delete,sculpture_infos=DelItems})
    end.

%%֪ͨ׷��
do_notify_append_items(AdditionList)->
    case length(AdditionList) of
	0 ->
	    ok;
	_ ->
	    packet:send(#notify_sculpture_infos{type=?append,sculpture_infos=AdditionList})
    end.

%%֪ͨ�޸�
do_notify_modify_items(ModifyItems)->
    case length(ModifyItems) of
	0 ->
	    ok;
	_ ->
	    packet:send(#notify_sculpture_infos{type=?modify,sculpture_infos=ModifyItems})

    end.



%%��ոı��б�
clear_sculpture_pack_modify_info()->
    put(sculpture_del,[]),
    put(sculpture_add,[]),
    put(sculpture_modify,[]).

%%��������ı��б�
unique_modify_pack()->
    Del=get(sculpture_del),
    AddItems=get(sculpture_add),
    ModifyItems=get(sculpture_modify),
    NewAdd=unique_items(AddItems,Del),
    NewModify=unique_items(unique_items(ModifyItems,Del),AddItems),
    {Del,NewAdd,NewModify}.


unique_items(ItemList1,ItemList2)->
    NewList=ItemList1--ItemList2,
    case length(NewList) =:= length(ItemList1) of
	true -> NewList;
	false -> unique_items(NewList,ItemList2)
    end.


%%��ȡ�ҵķ����б�
get_my_sculpture()->
    case get(sculpture_pack) of
	undefined -> 
	    MySculpture = get_db_sculptures(),
	    put(sculpture_pack,get_db_sculptures()),
	    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
	    put(role_puton, [{1, Role:sculpture1()}, {2, Role:sculpture2()}, {3, Role:sculpture3()}, {4, Role:sculpture4()}]),
	    put(sculpture_del,[]),
	    put(sculpture_add,[]),
	    put(sculpture_modify,[]),
	    MySculpture;
	Pack ->
	    Pack
    end.


%%�����ݿ��������ת����#sculpture_info{}
trans_sculpture_info(DBObj)->
    #sculpture_info{sculpture_id=DBObj:sculpture_id(),
		    temp_id=DBObj:temp_id(), 
		    lev = DBObj:level(),
		    exp=DBObj:exp()}.


%%��ȡ���ݿ���ķ�����Ϣ
get_db_sculptures()->
    RoleId=player:get_role_id(),
    get_db_sculptures(RoleId).
get_db_sculptures(RoleId)->
    DBObjs=db:find(db_sculpture,[{role_id,'equals',RoleId}]),
    DBObjs.
    %%[trans_sculpture_info(DBObj) || DBObj <- DBObjs].


%%��ȡ���ı����ĸ�������
get_max_space()->
    config:get(max_sculpture_pack_space) + get_puton_amount().

%%�������ϵ�����
get_puton_amount()->
    length(lists:filter(fun({_, X}) -> X =/= 0 end, get(role_puton))).


%%��ȡ������Ƭ��ID
get_frag_id()->
    config:get(sculpture_frag_item_id).


%%�ϲ���ͬID����Ʒ
merge_same_sculpture(Sculptures)->
    lists:reverse(lists:foldl(fun({TempID, Amount}, In) -> 
			case lists:keyfind(TempID, 1, In) of
			    false ->
				[{TempID, Amount}|In];
			    {_, Org} ->
				lists:keyreplace(TempID, 1, In, {TempID, Org + Amount})
			end
		end, [], Sculptures)).









batch_proc(_, Arg, Times) when Times =< 0->
    Arg;

batch_proc(Fun, Arg, Times)->
    batch_proc(Fun, Fun(Arg, Times), Times - 1).



sculpture_add_msg_append(NPackItem)->
    io_helper:format("NPackItem: ~p~n", [NPackItem]),
    CurPack=get(sculpture_add),
    MyPack=lists:filter(fun(X)-> 
				X:sculpture_id() =/= NPackItem:sculpture_id()
			end,
			get_my_sculpture()),
    update_my_sculpture(lists:reverse([NPackItem|lists:reverse(MyPack)])),
    put(sculpture_add,[NPackItem:sculpture_id()|(CurPack--[NPackItem:sculpture_id()])]).

sculpture_del_msg_append(InstId)->
    CurPack=get(sculpture_del),
    %% MyPack=lists:filter(fun(X)-> 
    %% 				X:inst_id() =/= InstId
    %% 			end,
    %% 			get_my_sculpture()),
    update_my_sculpture(lists:keydelete(InstId, get_inst_id_index(), get_my_sculpture())),
    put(sculpture_del,[InstId|(CurPack--[InstId])]).

sculpture_modify_msg_append(NPackItem)->
    CurPack=get(sculpture_modify),
    %% MyPack=lists:foldr(fun(X, In) ->
    %% 			       case X:inst_id() =:= NPackItem:inst_id() of
    %% 				   true ->[NPackItem|In];
    %% 				   false ->[X|In]
    %% 			       end
    %% 		       end,[],get_my_sculpture()),
    update_my_sculpture(lists:keyreplace(NPackItem:sculpture_id(), get_inst_id_index(), get_my_sculpture(), NPackItem)),
    put(sculpture_modify,[NPackItem:sculpture_id()|(CurPack--[NPackItem:sculpture_id()])]).


update_my_sculpture(Pack)->
    put(sculpture_pack,Pack).


get_inst_id_index()->
    3.

get_temp_id_index()->
    5.









    
    



