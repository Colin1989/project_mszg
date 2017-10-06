%%% @author hongjx <>
%%% @copyright (C) 2014, hongjx
%%% @doc
%%%  ������ز���
%%% @end
%%% Created :  5 Mar 2014 by hongjx <>

-module(sculpture).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").
-include("event_def.hrl").

-compile(export_all). %% ������

-export([start/0, 
	 %%get_temp_id/1, %% ����ʵ��idȡģ��id, û�оͷ���0
	 get_sculpture_tempid_and_lev/1,
	 append_sculpture_infos/1
	 %% create_sculpture_and_save/2,
	 %% create_sculpture_and_save/3,
	 %%get_sculpture_info/1
	]).

-export([proc_req_sculpture_divine/1, 
	 proc_req_sculpture_upgrade/1,
	 proc_req_sculpture_infos/1,
	 proc_req_sculpture_convert/1,
	 proc_req_sculpture_puton/1,
	 proc_req_sculpture_takeoff/1,
	 proc_req_sale_sculpture/1,
	 broadcast_buy_item/1
	]).

start() ->
    %% ��������б�
    packet:register(?msg_req_sculpture_infos, {?MODULE, proc_req_sculpture_infos}),
    %% ����ռ��
    packet:register(?msg_req_sculpture_divine,{?MODULE, proc_req_sculpture_divine}),   
    %% ��������
    packet:register(?msg_req_sculpture_upgrade,{?MODULE, proc_req_sculpture_upgrade}),
    %% ������Ƭ�һ���
    packet:register(?msg_req_sculpture_convert,{?MODULE, proc_req_sculpture_convert}),
    %% ����װ��
    packet:register(?msg_req_sculpture_puton,{?MODULE, proc_req_sculpture_puton}),
    %% ��������
    packet:register(?msg_req_sculpture_takeoff,{?MODULE, proc_req_sculpture_takeoff}),
    %% ���ĳ���
    packet:register(?msg_req_sale_sculpture, {?MODULE, proc_req_sale_sculpture}),
    ok.


%% ���ĳ���
proc_req_sale_sculpture(#req_sale_sculpture{inst_ids = InstIds})->
    {Gold, Errid} = process_sale_sculpture(InstIds),
    sculpture_pack:del_sculptures_by_inst(?st_sale_sculpture, lists:takewhile(fun(X) -> X =/=Errid end, InstIds)),
    player_role:add_gold(?st_sale_sculpture, Gold),
    case Errid of
	0 ->
	    packet:send(#notify_sale_sculpture_result{result = ?common_success, gold = Gold});
	_ ->
	    packet:send(#notify_sale_sculpture_result{result = ?common_failed, gold = Gold, err_id = Errid})
    end,
    sculpture_pack:notify_sculpture_pack_change().
    %% case sculpture_pack:get_sculpture_by_inst(InstId) of
    %% 	undefined ->
    %% 	    notexist;
    %% 	_ ->
    %% 	    case sculpture_pack:get_inst_pos(InstId) of
    %% 		0 ->
    %% 		    sculpture_pack:del_sculptures_by_inst(?st_sale_sculpture, [InstId]),
    %% 		    packet:send(#notify_sale_sculpture_result{result = ?common_success}),
    %% 		    ;
    %% 		_ ->
    %% 		    packet:send(#notify_sale_sculpture_result{result = ?common_success}),
    %% 		    sys_msg:send_to_self(?sg_sculpture_sale_is_on_body, [])
    %% 	    end
    %% end,
    %% ok.

process_sale_sculpture([])->
    {0, 0};
process_sale_sculpture([InstId|InstIds]) -> 
    case sculpture_pack:get_sculpture_by_inst(InstId) of
	undefined ->
	    sys_msg:send_to_self(?sg_sculpture_sale_noexist, []),
	    {0, InstId};
	Inst ->
	    case sculpture_pack:get_inst_pos(InstId) of
		0 ->
		    #sculpture_tplt{grade=Grade} = tplt:get_data(sculpture_tplt, Inst:temp_id()),
		    Price = get_sale_sculpture_price(Inst:level(), Grade),
		    {TotalPrice, ErrId} = process_sale_sculpture(InstIds),
		    {TotalPrice + Price, ErrId};
		    %%sculpture_pack:del_sculptures_by_inst(?st_sale_sculpture, [InstId]);
		_ ->
		    sys_msg:send_to_self(?sg_sculpture_sale_is_on_body, []),
		    {0 ,InstId}
	    end
    end.



%%%===================================================================
%% ��������б�
%% [req_sculpture_infos
%% ],
%%%===================================================================
proc_req_sculpture_infos(#req_sculpture_infos{})->
    packet:send(#notify_sculpture_infos{type=?init,sculpture_infos=get_sculpture_infos()}).

%% create_sculpture_and_save(SculptureTpltId, InstanceId, RoleId)->
%%     %% ����������Ʒ
%%     Exp = 0,
%%     SculptureObj = db_sculpture:new(id,InstanceId,RoleId,SculptureTpltId,Exp,datetime:local_time()),
%%     SculptureObj:save(),
%%     SculptureObj.

%% %% player_pack�Զ���������ʱ����ص��������
%% create_sculpture_and_save(SculptureTpltId, InstanceId)->
%%     %% ����������Ʒ
%%     RoleId = player:get_role_id(),
%%     Exp = 0,
%%     SculptureObj = db_sculpture:new(id,InstanceId,RoleId,SculptureTpltId,Exp,datetime:local_time()),
%%     SculptureObj:save(),
%%     SculptureObj.

%%%===================================================================
%% ����
%% [req_sculpture_upgrade,  % ��������
%%  {int, main_id},         % ������id
%%  {array, eat_ids}     % ���Է���id�б�(����id��������Ʒid)    
%% ],
%%%===================================================================
proc_req_sculpture_upgrade(#req_sculpture_upgrade{eat_ids=[]})->
    % û���Է���, ����
    ok;
proc_req_sculpture_upgrade(#req_sculpture_upgrade{main_id=MainId, eat_ids=EatList})->
    RoleId = player:get_role_id(),
 
    MainObj = get_my_sculpture(MainId, RoleId),

    %% ȡ�����ĵ�xml id
    SculptureTpltID = MainObj:temp_id(),%%item:get_sub_id(MainObj:temp_id()),
    #sculpture_tplt{type=Type} = tplt:get_data(sculpture_tplt, SculptureTpltID),
    case Type of
	?item_expsculp ->
	    notify_upgrade_fail(?sg_sculpture_upgrade_is_expsculp,[]);
	_ ->
	    %% ȡ���Է��ĵ�xml id
	    EatInstList = [%%begin
			   sculpture_pack:get_sculpture_by_inst(EatID)
			   %% SubObj = get_my_sculpture(EatID, RoleId),
			   %% %% �����������Ʒ
			   %% case sculpture_pack:get_sculpture_by_inst(EatID) == undefined of
			   %%     false ->
			   %% 	 ok
			   %% end,

			   %% item:get_sub_id(SubObj:temp_id())
			   %%end 
			   || EatID <- EatList],

	    {CostGold, AddExp} = calc_eat_gold_and_exp(EatInstList),
	    case player_role:check_gold_enough(CostGold) of
		false -> %% �ж�Ǯ������
		    notify_upgrade_fail(?sg_sculpture_upgrade_money_not_enough,[]);
		_ ->
		    #sculpture_tplt{max_lev = MaxLev, grade = Grade} = tplt:get_data(sculpture_tplt, SculptureTpltID),
		    case MaxLev > MainObj:level() of
			true ->
			    event_router:send_event_msg(#event_sculpture_upgrade{amount = length(EatList)}),
			    OldExp = MainObj:exp(),
			    %% ��Ǯ
			    player_role:reduce_gold(?st_sculpture_upgrade, CostGold),
			    %% �Ӿ���
			    {NewLevel, NewExp} = sculpture_add_exp(MainObj:level(), Grade, OldExp, AddExp, MaxLev),
			    %% �����ļӾ���, ���ı�ȼ�
			    NewMainObj = MainObj:set([{exp, NewExp}, {level, NewLevel}]),
			    sculpture_pack:modify_sculpture(?st_sculpture_upgrade, NewMainObj),
			    %% packet:send(#notify_sculpture_infos{type=?modify,
			    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(NewMainObj)]}),
			    %% packet:send(#notify_sculpture_infos{type=?delete,
			    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(get_my_sculpture(EatID, RoleId)) 
			    %% 							 ||EatID  <- EatList]}),

			    %% ɾ��Ʒ, ɾ����
			    sculpture_pack:del_sculptures_by_inst(?st_sculpture_upgrade, EatList),

			    %% ����������
			    %%NewMainObj:save(),
			    %% ֪ͨ�ͻ��������˿ͻ��˿���Ҫ������Ч����Ҫ��֪ͨ��������ǰ�����ͻ���,ʵ������Ч
			    sculpture_pack:notify_sculpture_pack_change(),
			    packet:send(#notify_sculpture_upgrade{is_success=?common_success}),
			    %% ֪ͨ����ϵͳ
			    case get_sculpture_pos(MainId) of
				0 ->
				    ok;
				Pos ->
				    friend:set_sculpture_update([{Pos, #sculpture_data{temp_id = MainObj:temp_id(), level = NewMainObj:level()}}])
			    end,

			    ok;
			false ->
			    notify_upgrade_fail(?sg_sculpture_upgrade_is_max_lev,[])
		    end
	    end
    end.

    %% %% ȡ���Է��ĵ�xml id
    %% EatInstList = [%%begin
    %% 			 sculpture_pack:get_sculpture_by_inst(EatID)
    %% 			 %% SubObj = get_my_sculpture(EatID, RoleId),
    %% 			 %% %% �����������Ʒ
    %% 			 %% case sculpture_pack:get_sculpture_by_inst(EatID) == undefined of
    %% 			 %%     false ->
    %% 			 %% 	 ok
    %% 			 %% end,

    %% 			 %% item:get_sub_id(SubObj:temp_id())
    %% 		     %%end 
    %% 		     || EatID <- EatList],

    %% {CostGold, AddExp} = calc_eat_gold_and_exp(EatInstList),
    %% case player_role:check_gold_enough(CostGold) of
    %% 	false -> %% �ж�Ǯ������
    %% 	    notify_upgrade_fail(?sg_sculpture_upgrade_money_not_enough,[]);
    %% 	_ ->
    %% 	    #sculpture_tplt{max_lev = MaxLev, grade = Grade} = tplt:get_data(sculpture_tplt, SculptureTpltID),
    %% 	    case MaxLev > MainObj:level() of
    %% 		true ->
    %% 		    event_router:send_event_msg(#event_sculpture_upgrade{amount = length(EatList)}),
    %% 		    OldExp = MainObj:exp(),
    %% 		    %% ��Ǯ
    %% 		    player_role:reduce_gold(?st_sculpture_upgrade, CostGold),
    %% 		    %% �Ӿ���
    %% 		    {NewLevel, NewExp} = sculpture_add_exp(MainObj:level(), Grade, OldExp, AddExp, MaxLev),
    %% 		    %% �����ļӾ���, ���ı�ȼ�
    %% 		    NewMainObj = MainObj:set([{exp, NewExp}, {level, NewLevel}]),
    %% 		    sculpture_pack:modify_sculpture(?st_sculpture_upgrade, NewMainObj),
    %% 		    %% packet:send(#notify_sculpture_infos{type=?modify,
    %% 		    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(NewMainObj)]}),
    %% 		    %% packet:send(#notify_sculpture_infos{type=?delete,
    %% 		    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(get_my_sculpture(EatID, RoleId)) 
    %% 		    %% 							 ||EatID  <- EatList]}),

    %% 		    %% ɾ��Ʒ, ɾ����
    %% 		    sculpture_pack:del_sculptures_by_inst(?st_sculpture_upgrade, EatList),

    %% 		    %% ����������
    %% 		    %%NewMainObj:save(),
    %% 		    %% ֪ͨ�ͻ��������˿ͻ��˿���Ҫ������Ч����Ҫ��֪ͨ��������ǰ�����ͻ���,ʵ������Ч
    %% 		    sculpture_pack:notify_sculpture_pack_change(),
    %% 		    packet:send(#notify_sculpture_upgrade{is_success=?common_success}),
    %% 		    %% ֪ͨ����ϵͳ
    %% 		    case get_sculpture_pos(MainId) of
    %% 			0 ->
    %% 			    ok;
    %% 			Pos ->
    %% 			    friend:set_sculpture_update([{Pos, #sculpture_data{temp_id = MainObj:temp_id(), level = NewMainObj:level()}}])
    %% 		    end,
		    
    %% 		    ok;
    %% 		false ->
    %% 		    notify_upgrade_fail(?sg_sculpture_upgrade_is_max_lev,[])
    %% 	    end
    %% end.

notify_upgrade_fail(MsgID, Args) ->
    packet:send(#notify_sculpture_upgrade{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).

%%%===================================================================
%% ����ж��
%% [req_sculpture_takeoff,  % ��������
%%  {int, pos}                % ����λ�� 
%% ],
%%%===================================================================
proc_req_sculpture_takeoff(#req_sculpture_takeoff{position=Pos}) 
  when (1 =< Pos) and (Pos =< 4) -> %% ֻ����4��λ��
    RoleId = player:get_role_id(),
    %%[Role|_] = db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    SField = "sculpture" ++ integer_to_list(Pos),
    AtomField = list_to_atom(SField),
    %% �ɷ���id
    SculptureInstID = Role:AtomField(),

    case SculptureInstID of
	0 -> % ������ûװ���ģ��ͻ��˸����
	    notify_taskoff_fail(?sg_sculpture_takeoff_empty,[]);
	_ -> % ��װ����Ҫ�Żر���
	    case sculpture_pack:check_pack_enough(1) of
		false -> %% ��������Ҫ��ʾ
		    notify_taskoff_fail(?sg_sculpture_takeoff_pack_full,[]);
		_ ->
		    %% ֪ͨж�³ɹ����ͻ��˿���Ҫ������Ч����Ҫ��֪ͨ��������ǰ�����ͻ���,ʵ������Ч
		    packet:send(#notify_sculpture_takeoff{is_success=?common_success, position=Pos}),
		    %% ��շ���λ��
		    NewRole = Role:set([{AtomField, 0}]),

		    %% [SculptureObj] = db:find(db_sculpture,
		    %% 			     [{sculpture_id,'equals',SculptureInstID}]),
		    %%Amount = 1,
		    %% NewItem = db_pack:new(id, 
		    %% 			  RoleId, 
		    %% 			  SculptureInstID, 
		    %% 			  SculptureObj:temp_id(), 
		    %% 			  ?sculpture, 
		    %% 			  Amount, 
		    %% 			  SculptureObj:create_time()),

		    %% ��������Ʒ
		    %% ������Զ����汳������, ������Ϣ���ͻ���
		    %%player_pack:add_item(whole,NewItem,?st_sculpture_takeoff),
		    %% ��������
		    player_role:save_my_db_role(NewRole),
		    %% ֪ͨ����ϵͳ
		    friend:set_sculpture_update([{Pos, #sculpture_data{temp_id = 0}}]),
		    
		    sculpture_pack:take_off(Pos)
	    end
    end,

    ok.

notify_taskoff_fail(MsgID, Args) ->
    packet:send(#notify_sculpture_takeoff{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).
%%%===================================================================
%% ����װ��
%% [req_sculpture_puton,  % ����װ��
%%  {int, pos},              % ����λ�� 
%%  {int, id}                % ����id 
%% ],
%%%===================================================================
proc_req_sculpture_puton(#req_sculpture_puton{position=ReqPos, inst_id=InstId})
  when (0 =< ReqPos) and (ReqPos =< 4) -> %% ֻ����4��λ��, Ϊ0ʱ���������λ��

    RoleId = player:get_role_id(),

    case sculpture_pack:get_sculpture_by_inst(InstId) of
	undefined -> %% ������Ʒû�������, ˵���ͻ������������ݲ�һ��
	    notify_puton_fail(?sg_sculpture_puton_noexist,[]);
	Item -> 
	    #sculpture_tplt{type=Type} = tplt:get_data(sculpture_tplt, Item:temp_id()),
	    case Type of
		?item_expsculp ->
		    notify_puton_fail(?sg_sculpture_puton_is_expsculpture,[]);
		_ ->
		    %%case Item:item_type() of
		    %%?sculpture -> %% �����Ƿ���
		    case Item:role_id() of
			RoleId-> %% ��ɫid����һ��
			    SculptureTplt = tplt:get_data(sculpture_tplt,Item:temp_id()),
			    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
			    Role = player_role:get_db_role(RoleId),
			    RoleType=Role:role_type(),

			    case RoleType =/= SculptureTplt#sculpture_tplt.role_type of
				true -> %% �ж�ְҵ�Ƿ��װ�ü���
				    notify_puton_fail(?sg_sculpture_puton_role_type_not_match,[]);
				_ ->
				    SkillGroupID = SculptureTplt#sculpture_tplt.skill_group,
				    GroupList = get_role_sculpture_groups(Role),
				    case lists:member(SkillGroupID, GroupList) of
					true -> %% ͬϵ����ֻ�ɴ���1��
					    notify_puton_fail(?sg_sculpture_puton_skill_repeat,[]);
					_ ->
					    Pos = calc_put_on_pos(ReqPos, Role),
					    %% �����ж�ͨ������������
					    SField = "sculpture" ++ integer_to_list(Pos),
					    AtomField = list_to_atom(SField),
					    case Role:AtomField() =/= 0 of
						true -> %%��λ�����з���
						    notify_puton_fail(?sg_sculpture_pos_has_puton,[]);
						_ ->
						    %% ���÷��ĵ�λ����
						    NewRole = Role:set([{AtomField, InstId}]),
						    %% ֪ͨװ�ϳɹ����ͻ��˿���Ҫ������Ч����Ҫ��֪ͨ��������ǰ�����ͻ���,ʵ������Ч
						    packet:send(#notify_sculpture_puton{is_success=?common_success, position=Pos,
											inst_id=InstId}),

						    %% ����ɾ��Ʒ, ��֪ͨ
						    %%player_pack:delete_item_notify(InstId, ?st_sculpture_puton),
						    %% ��������
						    player_role:save_my_db_role(NewRole),
						    %% ֪ͨ����ϵͳ
						    friend:set_sculpture_update([{Pos, #sculpture_data{temp_id = SculptureTplt#sculpture_tplt.id, 
												       level = Item:level()}}]),
						    sculpture_pack:put_on(Pos, InstId),
						    ok

					    end

				    end
			    end

		    end
	    end
	    %% end
    end.

notify_puton_fail(MsgID, Args) ->
    packet:send(#notify_sculpture_puton{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).

%%%===================================================================
%% ���Ķһ�
%% [req_sculpture_convert,  % ��Ƭ�һ�����
%%  {int, target_item_id}        % Ŀ����Ʒxml id
%% ],
%%%===================================================================
proc_req_sculpture_convert(#req_sculpture_convert{target_item_id=ItemTpltId})->
    RoleId = player:get_role_id(),

    %%[Role|_] = db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    FragCount = get_frag_count(),

    %% ������Ʒid ȡ����id
    SculptureTpltId = ItemTpltId,
    %% ����������ַ���
    #sculpture_tplt{role_type=NeedRoleType} = tplt:get_data(sculpture_tplt, SculptureTpltId),

    %% ����������ֶһ�
    #sculpture_convert_tplt{frag_count=NeedCount} = tplt:get_data(sculpture_convert_tplt, ItemTpltId),

    %% �ж�ְҵ
    case NeedRoleType =/= Role:role_type() of 
	true ->
	    notify_convert_fail(?sg_sculpture_puton_role_type_not_match, []);
	_ ->
	    %% �ж���Ƭ�Ƿ��㹻
	    case FragCount < NeedCount of
		true -> %% ��Ƭ����
		    notify_convert_fail(?sg_sculpture_frag_not_enough, []);
		_ ->
		    %% �����Ƿ�����
		    case sculpture_pack:check_pack_enough(1) of
			false -> %% ��������Ҫ��ʾ
			    notify_convert_fail(?sg_sculpture_convert_pack_full,[]);		    
			_ ->
			    %% ������������Ƭ
			    %% ������Զ����汳������, ������Ϣ���ͻ���
			    broadcast_convert_item(ItemTpltId),
			    dec_frag_count(NeedCount),
			    %% �����ӷ�����Ʒ
			    %% ������Զ����汳������, ������Ϣ���ͻ���
			    sculpture_pack:add_sculptures(?st_sculpture_convert, [{ItemTpltId, 1}]),
			    %% ֪ͨ�һ��ɹ����ͻ��˿���Ҫ������Ч��, Ҫ��֪ͨ��������ǰ�����ͻ���,ʵ������Ч
			    packet:send(#notify_sculpture_convert{is_success=?common_success,target_item_id=ItemTpltId}),
			    sculpture_pack:notify_sculpture_pack_change(),
			    

			    ok	
		    end
	    end
    end,

    ok.

notify_convert_fail(MsgID, Args) ->
    packet:send(#notify_sculpture_convert{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).

%%%===================================================================
%% ռ��
%% [req_sculpture_divine,  % ����ռ��
%%  {int, money_type},     % ��������
%%  {int, times}           % ռ������
%% ]
%%%===================================================================
proc_req_sculpture_divine(#req_sculpture_divine{money_type=MoneyType, times=RawTimes})->
    RoleId = player:get_role_id(),

    #sculpture_divine_tplt{money_amounts=MoneyAmounts,  %% ��Ӧռ���ȼ�Ҫ������Ǯ 
			   upgrade_rates=UpgradeRates,  %% ռ���ȼ�����������
			   divine_award_file=AwardFile} = 
	tplt:get_data(sculpture_divine_tplt, MoneyType),

    %% ռ���ȼ�, ��ͬ���ң���һ��
    DivineLevel = db_get_divine_level(RoleId, MoneyType),
 
    AllData = tplt:get_all_data(list_to_atom(binary_to_list(AwardFile))),

    %% ���ݽ�Ǯ���ͣ�ȡ��ǰ���ж���Ǯ
    MyMoney = get_money_by_type(MoneyType),
    PackRemainCount = sculpture_pack:get_remain_space(),
    %% �ȶ����һ
    Times = 
	case RawTimes =:=1 of
	    true -> 
		1;
	    _ ->
		1
	end,
    %%io:format("~p~n", [{RawTimes, PackRemainCount, Times}]),
    {_RemainTimes, NewDivineLevel, RemainMoney, ProductList1} = try_divine(AllData, 
									  MoneyAmounts, UpgradeRates, 
									  {Times, DivineLevel, MyMoney, []}),
    %% Ǯ����Ҫ��ʾ
    case RemainMoney =:= MyMoney of
	true -> %% Ǯ��û��
	    notify_divine_fail(?sg_sculpture_divine_money_not_enough,[]);
	_ ->

	    %% �жϱ����Ƿ���
	    case PackRemainCount =< 0 of
		true -> %% ��������Ҫ��ʾ
		    notify_divine_fail(?sg_sculpture_divine_pack_full,[]);
		_ ->
		    activeness_task:update_activeness_task_status({divine, Times}),
		    ProductList = case redis:hincrby(divine_times, RoleId, Times) of
				      Times ->
					  [_|ProductListLeft] = ProductList1,
					  RoleTplt = tplt:get_data(role_tplt,player_role:get_role_type()),
					  [{RoleTplt#role_tplt.first_divine, 1}|ProductListLeft];
				      _ ->
					  ProductList1
				  end,
		    %% �����ӷ�����Ʒ
		    sculpture_pack:add_sculptures(?st_sculpture_divine, ProductList),
		    broadcast_divine_item(ProductList),
		    %% ��Ǯ
		    DecMoney = MyMoney - RemainMoney,
		    reduce_money_by_type(MoneyType, DecMoney),

		    %% ����ռ���ȼ�
		    db_set_divine_level(RoleId, MoneyType, NewDivineLevel),

        %%�����¼
        event_router:send_event_msg(#event_task_finish_times_update{amount = length(ProductList), sub_type = 7}),

		    %% ֪ͨռ���ȼ�����,�����Щ��Ʒ
		    Awards = [#award_item{temp_id=TempId,amount=Amount} || {TempId, Amount} <- ProductList],
		    packet:send(#notify_sculpture_divine{is_success=?common_success,divine_level=NewDivineLevel,
							 awards=Awards}),
		    case NewDivineLevel > DivineLevel of
			true -> %% ֪ͨռ������
			    ok;%%sys_msg:send_to_self(?sg_sculpture_divine_level_up,[]);
			_ ->
			    case NewDivineLevel < DivineLevel of
				true -> %% ֪ͨռ������
				    ok;%%sys_msg:send_to_self(?sg_sculpture_divine_level_down,[]);
				_ ->
				    ok
			    end
		    end,
		    sculpture_pack:notify_sculpture_pack_change()
	    end
    end.


    

notify_divine_fail(MsgID, Args) ->
    packet:send(#notify_sculpture_divine{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).
%%%===================================================================
%%% �ڲ�ʵ�ֺ���
%%%===================================================================

%% �㴩��λ��
calc_put_on_pos(Pos, _Role) 
  when (1 =< Pos) and (Pos =< 4) -> %% ��ָ��λ��
    Pos;
calc_put_on_pos(Pos, Role) when (Pos == 0) -> 
    L = [Role:sculpture1(), Role:sculpture2(), Role:sculpture3(), Role:sculpture4()],
    case lists_index_of(0, L) of
	0 -> %% �Ҳ������õ�һ��λ��
	    1;
	Ret ->
	    Ret
    end.


%% ���ݽ�Ǯ���ͣ�ȡ��ǰ���ж���Ǯ
get_money_by_type(MoneyType) ->
    case MoneyType of 
	1 -> %% gold���
	    player_role:get_gold();
	2 -> %% emoney����
	    player_role:get_emoney();
	_ -> %% ���������ûʵ��
	    0
    end.

%% ��Ǯ
reduce_money_by_type(MoneyType, DecMoney) ->
    case MoneyType of 
	1 -> %% gold���
	    player_role:reduce_gold(?st_sculpture_divine, DecMoney);
	2 -> %% emoney����
	    player_role:reduce_emoney(?st_sculpture_divine, DecMoney)
    end.



%% ȡ�������б� 
get_role_sculpture_groups(Role) ->
    [get_group_id(Role:sculpture1()),
     get_group_id(Role:sculpture2()),
     get_group_id(Role:sculpture3()),
     get_group_id(Role:sculpture4())].

get_group_id(0) ->
    0;
get_group_id(SculptureInstId) ->
    SculptureTplt = tplt:get_data(sculpture_tplt, get_temp_id(SculptureInstId)),
    SculptureTplt#sculpture_tplt.skill_group.

%% ����ʵ��idȡģ��id, û�оͷ���0
%% SculptureInstId ���ĵ�ʵ��id
get_temp_id(SculptureInstId) ->
    case sculpture_pack:get_sculpture_by_inst(SculptureInstId) of
	undefined -> %% û�оͷ���0
	    0;
	Obj ->
	    Obj:temp_id()
    end.

get_sculpture_tempid_and_lev(SculptureInstId) ->
    io_helper:format("~p~n", [SculptureInstId]),
    case db:find(db_sculpture, [{sculpture_id, 'equals', SculptureInstId}]) of
	[] ->
	    {0, 0};
	[Obj] ->
	    #sculpture_data{temp_id = Obj:temp_id(), level = Obj:level()}
    end.


%% ����ռ����ûǮû����Ϊֹ
%%        ʣ�����        ���ռ���ȼ�     ʣ����Ǯ       ������Щ���� 
%% ����  {_RemainTimes, NewDivineLevel, RemainMoney, ProductList}
try_divine(AllData, MoneyAmounts, UpgradeRates, 
	   {Times, DivineLevel, MyMoney, ProductList}=Acc) ->
    case Times of
	0 -> %% �������Ϊ0Ҫ����
	    Acc;
	_ ->
	    %% ����ռ���ȼ�, ȡ�ɵ����б�
	    IDRateList = get_id_rate_list(DivineLevel, AllData),
	    %% ����ռ���ȼ�, ȡҪ���Ķ���Ǯ
	    CostMoney = lists:nth(DivineLevel, MoneyAmounts),
	    %% ����ռ���ȼ�, ȡ�������ʰٷֱ�
	    UpgradeRate = lists:nth(DivineLevel, UpgradeRates),

	    %% ���Ǯ����Ҫ����
	    case CostMoney > MyMoney of
		true ->
		    Acc;
		_ ->
		    %% �������һ��
		    SculptureTpltID = rand_one(IDRateList),
		    NewDivineLevel =
			case rand:uniform(100) > UpgradeRate of
			    true -> %% û���У���Ϊ1��
				1;
			    _ -> %% ���У�����
				DivineLevel + 1
			end,
		    ItemAmount = 1,
		    try_divine(AllData, MoneyAmounts, UpgradeRates,
			       {Times - 1, NewDivineLevel, MyMoney - CostMoney, 
				[{SculptureTpltID, ItemAmount} | ProductList]})
	    end
    end.


%% ���ļӾ���
%% �����µķ��ĺ;���{NewSculptureTpltID, NewExp}
sculpture_add_exp(Lev, Grade, OldExp, AddExp, MaxLev) ->
    Need = get_upgrade_need_exp(Lev, Grade),
    NewExp = OldExp + AddExp,
    case NewExp < Need of
	true -> %% û����
	    {Lev, NewExp};
	_ -> %% ������
	    %% �ж��ܷ�����
	    case MaxLev > Lev  of
		false -> %% ����������
		    {Lev, 0};
		_ -> 
		    sculpture_add_exp(Lev + 1, Grade, 0, NewExp - Need, MaxLev)
	    end
    end.

get_sculpture_pos(InstId)  when InstId =/= 0 ->
    sculpture_pack:get_inst_pos(InstId).

%% get_sculpture_pos(InstId) when InstId =/= 0 ->
%%     RoleId = player:get_role_id(),
%%     [Role|_] = db:find(db_role,[{role_id,'equals',RoleId}]),
%%     L = [Role:sculpture1(), Role:sculpture2(), Role:sculpture3(), Role:sculpture4()],
%%     lists_index_of(InstId, L).

%% ����ĳ��ֵ���±꣬û�ҵ�����0
lists_index_of(Val, L) ->
    HeadL = lists:takewhile(fun(X) -> X =/= Val end, L),
    HeadCount = length(HeadL),
    case HeadCount =:= length(L) of
	true -> %% û�ҵ�����0
	    0;
	_ -> %% 
	    HeadCount + 1
    end.

calc_eat_gold_and_exp(SculptureInstList) ->
    lists:foldl(fun(Inst, {TotalGold, TotalExp})->
			
			#sculpture_tplt{grade=Grade} = tplt:get_data(sculpture_tplt, Inst:temp_id()),
			
			{TotalGold + get_eat_gold_need(Inst:level(), Grade, Inst:temp_id()), 
			 TotalExp + get_exp_provide(Inst:level(), Grade, Inst:exp(), Inst:temp_id())}
		end, 
		{0, 0}, SculptureInstList).

get_my_sculpture(SculptureInstId, _RoleId) ->
    %%io:format("~p~n", [{SculptureInstId, RoleId}]),
    %% [DBObj|_] = db:find(db_sculpture,[{sculpture_id,'equals',SculptureInstId}]),

    %% case DBObj:role_id() of
    %% 	RoleId-> %% ��ɫid����һ��
    %% 	    DBObj
    %% end
    sculpture_pack:get_sculpture_by_inst(SculptureInstId).



%% ȡ��Ƭ����
get_frag_count() ->
    sculpture_pack:get_frag_count().

%% ɾ��Ƭ����(�һ�)
dec_frag_count(DecCount) ->
    sculpture_pack:del_sculptures(?st_sculpture_convert, 
			     [{config:get(sculpture_frag_item_id), DecCount}]).

%% ȡ�ɵ����б�(Value�Ǹ�����ֵ����������)
get_id_rate_list(Level, AllData) ->
    {L, _Total} = lists:foldl(fun(R, {Acc, N}=Ret) ->
				      {Id, Rate} = get_id_rate(R, Level),
				      case Rate > 0 of
					  true ->
					      case config:get(sculpture_frag_item_id) of
						  Id ->
						      Value = N + Rate,
						      {[{Id, Value} | Acc], Value};
						  _ ->
						      #sculpture_tplt{role_type = RoleType} = tplt:get_data(sculpture_tplt,Id),
						      case player_role:get_role_type() of
							  RoleType ->
							      Value = N + Rate,
							      {[{Id, Value} | Acc], Value};
							  _ ->
							      Ret
						      end
					      end;
					  _ ->
					      Ret
				      end
			      end,{[], 0}, AllData),
    %% �ٷֱ�(Rate)��ķź���
    lists:reverse(L).

append_sculpture_infos(AdditionList)->
    case AdditionList of
	[] ->
	    ok;
	_ ->
	    packet:send(#notify_sculpture_infos{type=?append,sculpture_infos=AdditionList})
    end.

%% get_sculpture_info(DBObj)->
%%     #sculpture_info{sculpture_id=DBObj:sculpture_id(),
%% 		     temp_id=DBObj:temp_id(),
%% 		    lev = DBObj:level(),
%% 		     exp=DBObj:exp()}.

%% get_sculpture_infos()->
%%     RoleId=player:get_role_id(),
%%     get_sculpture_infos(RoleId).
get_sculpture_infos()->
    DBObjs=sculpture_pack:get_my_sculpture(),
    [sculpture_pack:trans_sculpture_info(DBObj) || DBObj <- DBObjs].


%%--------------------------------------------------------------------
%% @doc
%%  �ӵ����б���ȡһ��
%% @end
%%--------------------------------------------------------------------
%% ����: �������1����Ʒid
%% ����: IDRateList�ṹΪ[{ItemID, Rate}, ...], ע��Rate�Ǽ���ֵ
rand_one(IDRateList) ->
    %% ȡ�ܸ���
    TotalRate = get_total_rate(IDRateList),
    %% ����һ�������
    Hit = rand:uniform(TotalRate),
    %% ������������������
    pick_hit(Hit, IDRateList).

pick_hit(Hit, IDRateList) ->
    %% ������1�����Ϸ�������
    [{Id, _} | _] = lists:dropwhile(fun({_Id, Rate}) -> Rate < Hit end, IDRateList),
    %%io:format("~p~n", [{Hit, IDRateList, Id}]),
    Id.

%% ȡ�ܸ���
get_total_rate(IDRateList) ->
    {_K, Value} = lists:last(IDRateList),
    Value.

get_id_rate(R, Level) ->  
    %% ת���б�
    L = tuple_to_list(R),
    %% ��2����Id
    Id = lists:nth(2, L),
    %% Id���ǵȼ�����
    Rate = lists:nth(Level + 2, L),
    {Id, Rate}.


broadcast_divine_item(ProductList)->
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    lists:foreach(fun({ItemId, _})-> 
			  #sculpture_tplt{grade=Grade, name = Name} = tplt:get_data(sculpture_tplt, ItemId),
			  case Grade of
			      5 ->
				  broadcast:broadcast(?sg_broadcast_divine_sculpture_lev5, [Role:nickname(), Name]);
			      _ ->
				  ok
			  end
		  end, ProductList).


broadcast_convert_item(ItemTpltId)->
    io_helper:format("ItemTpltId:~p~n", [ItemTpltId]),
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    #sculpture_tplt{grade=Grade, name = Name} = tplt:get_data(sculpture_tplt, ItemTpltId),
    case Grade of
	6 ->
	    broadcast:broadcast(?sg_broadcast_convert_sculpture_lev6, [Role:nickname(), Name]);
	_ ->
	    ok
    end.

broadcast_buy_item(ItemTpltId)->
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    #sculpture_tplt{grade=Grade, name = Name} = tplt:get_data(sculpture_tplt, ItemTpltId),
    case Grade of
	6 ->
	    broadcast:broadcast(?sg_broadcast_buy_sculpture_lev6, [Role:nickname(), Name]);
	_ ->
	    ok
    end.

%%--------------------------------------------------------------------
%% @doc
%%  ��ȡռ���ȼ�
%% @end
%%--------------------------------------------------------------------
%% ȡռ���ȼ�
%% MoneyType �������� 1 gold, 2 emoney, 3 ����
db_get_divine_level(RoleId, MoneyType) ->
    Key = db_divine_level_key(MoneyType),
    case cache:get(Key, RoleId) of
	[{_Key,Value}]->
	    Value;
	_ -> %% Ĭ��1��
	    1
    end.

db_divine_level_key(MoneyType) ->
    list_to_atom("divine_level" ++ integer_to_list(MoneyType)).

%% ��ռ���ȼ�
%% MoneyType �������� 1 gold, 2 emoney, 3 ����
db_set_divine_level(RoleId, MoneyType, DivineLevel) ->
    Key = db_divine_level_key(MoneyType),
    cache:set(Key, RoleId, DivineLevel).




get_exp_provide(Lev, Quality, Exp, ItemId)->
    #sculpture_tplt{type=Type, skill_group = Value} = tplt:get_data(sculpture_tplt, ItemId),
    case Type of
	?item_expsculp ->
	    Value;
	_ ->
	    Fun = (tplt:get_data(expression_tplt, 1))#expression_tplt.expression,
	    Fun([{'Lev', Lev}, {'Quality', Quality}, {'Exp', Exp}])
    end.
    


get_upgrade_need_exp(Lev, Quality)->
    Fun = (tplt:get_data(expression_tplt, 2))#expression_tplt.expression,
    Fun([{'Lev', Lev}, {'Quality', Quality}]).


get_eat_gold_need(Lev, Quality, ItemId)->
    #sculpture_tplt{type=Type, skill_cd = Value} = tplt:get_data(sculpture_tplt, ItemId),
    case Type of
	?item_expsculp ->
	    Value;
	_ ->
	    Fun = (tplt:get_data(expression_tplt, 3))#expression_tplt.expression,
	    Fun([{'Lev', Lev}, {'Quality', Quality}])
    end.
    


get_sale_sculpture_price(Lev, Quality)->
    Fun = (tplt:get_data(expression_tplt, 4))#expression_tplt.expression,
    Fun([{'Lev', Lev}, {'Quality', Quality}]).

