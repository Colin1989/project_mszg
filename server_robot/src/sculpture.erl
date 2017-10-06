%%% @author hongjx <>
%%% @copyright (C) 2014, hongjx
%%% @doc
%%%  符文相关操作
%%% @end
%%% Created :  5 Mar 2014 by hongjx <>

-module(sculpture).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").
-include("event_def.hrl").

-compile(export_all). %% 测试用

-export([start/0, 
	 %%get_temp_id/1, %% 根据实例id取模板id, 没有就返回0
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
    %% 请求符文列表
    packet:register(?msg_req_sculpture_infos, {?MODULE, proc_req_sculpture_infos}),
    %% 符文占卜
    packet:register(?msg_req_sculpture_divine,{?MODULE, proc_req_sculpture_divine}),   
    %% 符文升级
    packet:register(?msg_req_sculpture_upgrade,{?MODULE, proc_req_sculpture_upgrade}),
    %% 符文碎片兑换符
    packet:register(?msg_req_sculpture_convert,{?MODULE, proc_req_sculpture_convert}),
    %% 符文装上
    packet:register(?msg_req_sculpture_puton,{?MODULE, proc_req_sculpture_puton}),
    %% 符文脱下
    packet:register(?msg_req_sculpture_takeoff,{?MODULE, proc_req_sculpture_takeoff}),
    %% 符文出售
    packet:register(?msg_req_sale_sculpture, {?MODULE, proc_req_sale_sculpture}),
    ok.


%% 符文出售
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
%% 请求符文列表
%% [req_sculpture_infos
%% ],
%%%===================================================================
proc_req_sculpture_infos(#req_sculpture_infos{})->
    packet:send(#notify_sculpture_infos{type=?init,sculpture_infos=get_sculpture_infos()}).

%% create_sculpture_and_save(SculptureTpltId, InstanceId, RoleId)->
%%     %% 产生符文物品
%%     Exp = 0,
%%     SculptureObj = db_sculpture:new(id,InstanceId,RoleId,SculptureTpltId,Exp,datetime:local_time()),
%%     SculptureObj:save(),
%%     SculptureObj.

%% %% player_pack自动创建对象时，会回调这个函数
%% create_sculpture_and_save(SculptureTpltId, InstanceId)->
%%     %% 产生符文物品
%%     RoleId = player:get_role_id(),
%%     Exp = 0,
%%     SculptureObj = db_sculpture:new(id,InstanceId,RoleId,SculptureTpltId,Exp,datetime:local_time()),
%%     SculptureObj:save(),
%%     SculptureObj.

%%%===================================================================
%% 升级
%% [req_sculpture_upgrade,  % 符文升级
%%  {int, main_id},         % 主符文id
%%  {array, eat_ids}     % 被吃符文id列表(符文id，不是物品id)    
%% ],
%%%===================================================================
proc_req_sculpture_upgrade(#req_sculpture_upgrade{eat_ids=[]})->
    % 没被吃符文, 不理
    ok;
proc_req_sculpture_upgrade(#req_sculpture_upgrade{main_id=MainId, eat_ids=EatList})->
    RoleId = player:get_role_id(),
 
    MainObj = get_my_sculpture(MainId, RoleId),

    %% 取主符文的xml id
    SculptureTpltID = MainObj:temp_id(),%%item:get_sub_id(MainObj:temp_id()),
    #sculpture_tplt{type=Type} = tplt:get_data(sculpture_tplt, SculptureTpltID),
    case Type of
	?item_expsculp ->
	    notify_upgrade_fail(?sg_sculpture_upgrade_is_expsculp,[]);
	_ ->
	    %% 取被吃符文的xml id
	    EatInstList = [%%begin
			   sculpture_pack:get_sculpture_by_inst(EatID)
			   %% SubObj = get_my_sculpture(EatID, RoleId),
			   %% %% 必须有这个物品
			   %% case sculpture_pack:get_sculpture_by_inst(EatID) == undefined of
			   %%     false ->
			   %% 	 ok
			   %% end,

			   %% item:get_sub_id(SubObj:temp_id())
			   %%end 
			   || EatID <- EatList],

	    {CostGold, AddExp} = calc_eat_gold_and_exp(EatInstList),
	    case player_role:check_gold_enough(CostGold) of
		false -> %% 判断钱够不够
		    notify_upgrade_fail(?sg_sculpture_upgrade_money_not_enough,[]);
		_ ->
		    #sculpture_tplt{max_lev = MaxLev, grade = Grade} = tplt:get_data(sculpture_tplt, SculptureTpltID),
		    case MaxLev > MainObj:level() of
			true ->
			    event_router:send_event_msg(#event_sculpture_upgrade{amount = length(EatList)}),
			    OldExp = MainObj:exp(),
			    %% 扣钱
			    player_role:reduce_gold(?st_sculpture_upgrade, CostGold),
			    %% 加经验
			    {NewLevel, NewExp} = sculpture_add_exp(MainObj:level(), Grade, OldExp, AddExp, MaxLev),
			    %% 主符文加经验, 并改变等级
			    NewMainObj = MainObj:set([{exp, NewExp}, {level, NewLevel}]),
			    sculpture_pack:modify_sculpture(?st_sculpture_upgrade, NewMainObj),
			    %% packet:send(#notify_sculpture_infos{type=?modify,
			    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(NewMainObj)]}),
			    %% packet:send(#notify_sculpture_infos{type=?delete,
			    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(get_my_sculpture(EatID, RoleId)) 
			    %% 							 ||EatID  <- EatList]}),

			    %% 删物品, 删符文
			    sculpture_pack:del_sculptures_by_inst(?st_sculpture_upgrade, EatList),

			    %% 保存主符文
			    %%NewMainObj:save(),
			    %% 通知客户端升级了客户端可能要做动画效果，要在通知背包数据前发给客户端,实例才有效
			    sculpture_pack:notify_sculpture_pack_change(),
			    packet:send(#notify_sculpture_upgrade{is_success=?common_success}),
			    %% 通知其他系统
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

    %% %% 取被吃符文的xml id
    %% EatInstList = [%%begin
    %% 			 sculpture_pack:get_sculpture_by_inst(EatID)
    %% 			 %% SubObj = get_my_sculpture(EatID, RoleId),
    %% 			 %% %% 必须有这个物品
    %% 			 %% case sculpture_pack:get_sculpture_by_inst(EatID) == undefined of
    %% 			 %%     false ->
    %% 			 %% 	 ok
    %% 			 %% end,

    %% 			 %% item:get_sub_id(SubObj:temp_id())
    %% 		     %%end 
    %% 		     || EatID <- EatList],

    %% {CostGold, AddExp} = calc_eat_gold_and_exp(EatInstList),
    %% case player_role:check_gold_enough(CostGold) of
    %% 	false -> %% 判断钱够不够
    %% 	    notify_upgrade_fail(?sg_sculpture_upgrade_money_not_enough,[]);
    %% 	_ ->
    %% 	    #sculpture_tplt{max_lev = MaxLev, grade = Grade} = tplt:get_data(sculpture_tplt, SculptureTpltID),
    %% 	    case MaxLev > MainObj:level() of
    %% 		true ->
    %% 		    event_router:send_event_msg(#event_sculpture_upgrade{amount = length(EatList)}),
    %% 		    OldExp = MainObj:exp(),
    %% 		    %% 扣钱
    %% 		    player_role:reduce_gold(?st_sculpture_upgrade, CostGold),
    %% 		    %% 加经验
    %% 		    {NewLevel, NewExp} = sculpture_add_exp(MainObj:level(), Grade, OldExp, AddExp, MaxLev),
    %% 		    %% 主符文加经验, 并改变等级
    %% 		    NewMainObj = MainObj:set([{exp, NewExp}, {level, NewLevel}]),
    %% 		    sculpture_pack:modify_sculpture(?st_sculpture_upgrade, NewMainObj),
    %% 		    %% packet:send(#notify_sculpture_infos{type=?modify,
    %% 		    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(NewMainObj)]}),
    %% 		    %% packet:send(#notify_sculpture_infos{type=?delete,
    %% 		    %% 					sculpture_infos=[sculpture_pack:trans_sculpture_info(get_my_sculpture(EatID, RoleId)) 
    %% 		    %% 							 ||EatID  <- EatList]}),

    %% 		    %% 删物品, 删符文
    %% 		    sculpture_pack:del_sculptures_by_inst(?st_sculpture_upgrade, EatList),

    %% 		    %% 保存主符文
    %% 		    %%NewMainObj:save(),
    %% 		    %% 通知客户端升级了客户端可能要做动画效果，要在通知背包数据前发给客户端,实例才有效
    %% 		    sculpture_pack:notify_sculpture_pack_change(),
    %% 		    packet:send(#notify_sculpture_upgrade{is_success=?common_success}),
    %% 		    %% 通知其他系统
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
%% 符文卸下
%% [req_sculpture_takeoff,  % 符文脱下
%%  {int, pos}                % 符文位置 
%% ],
%%%===================================================================
proc_req_sculpture_takeoff(#req_sculpture_takeoff{position=Pos}) 
  when (1 =< Pos) and (Pos =< 4) -> %% 只允许4个位置
    RoleId = player:get_role_id(),
    %%[Role|_] = db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    SField = "sculpture" ++ integer_to_list(Pos),
    AtomField = list_to_atom(SField),
    %% 旧符文id
    SculptureInstID = Role:AtomField(),

    case SculptureInstID of
	0 -> % 本来就没装符文，客户端搞错了
	    notify_taskoff_fail(?sg_sculpture_takeoff_empty,[]);
	_ -> % 有装符文要放回背包
	    case sculpture_pack:check_pack_enough(1) of
		false -> %% 背包满了要提示
		    notify_taskoff_fail(?sg_sculpture_takeoff_pack_full,[]);
		_ ->
		    %% 通知卸下成功，客户端可能要做动画效果，要在通知背包数据前发给客户端,实例才有效
		    packet:send(#notify_sculpture_takeoff{is_success=?common_success, position=Pos}),
		    %% 清空符文位置
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

		    %% 背包加物品
		    %% 这里会自动保存背包数据, 并发消息给客户端
		    %%player_pack:add_item(whole,NewItem,?st_sculpture_takeoff),
		    %% 保存数据
		    player_role:save_my_db_role(NewRole),
		    %% 通知其他系统
		    friend:set_sculpture_update([{Pos, #sculpture_data{temp_id = 0}}]),
		    
		    sculpture_pack:take_off(Pos)
	    end
    end,

    ok.

notify_taskoff_fail(MsgID, Args) ->
    packet:send(#notify_sculpture_takeoff{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).
%%%===================================================================
%% 符文装上
%% [req_sculpture_puton,  % 符文装上
%%  {int, pos},              % 符文位置 
%%  {int, id}                % 符文id 
%% ],
%%%===================================================================
proc_req_sculpture_puton(#req_sculpture_puton{position=ReqPos, inst_id=InstId})
  when (0 =< ReqPos) and (ReqPos =< 4) -> %% 只允许4个位置, 为0时，服务端算位置

    RoleId = player:get_role_id(),

    case sculpture_pack:get_sculpture_by_inst(InstId) of
	undefined -> %% 背包物品没这个符文, 说明客户端与服务端数据不一致
	    notify_puton_fail(?sg_sculpture_puton_noexist,[]);
	Item -> 
	    #sculpture_tplt{type=Type} = tplt:get_data(sculpture_tplt, Item:temp_id()),
	    case Type of
		?item_expsculp ->
		    notify_puton_fail(?sg_sculpture_puton_is_expsculpture,[]);
		_ ->
		    %%case Item:item_type() of
		    %%?sculpture -> %% 必须是符文
		    case Item:role_id() of
			RoleId-> %% 角色id必须一样
			    SculptureTplt = tplt:get_data(sculpture_tplt,Item:temp_id()),
			    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
			    Role = player_role:get_db_role(RoleId),
			    RoleType=Role:role_type(),

			    case RoleType =/= SculptureTplt#sculpture_tplt.role_type of
				true -> %% 判断职业是否可装该技能
				    notify_puton_fail(?sg_sculpture_puton_role_type_not_match,[]);
				_ ->
				    SkillGroupID = SculptureTplt#sculpture_tplt.skill_group,
				    GroupList = get_role_sculpture_groups(Role),
				    case lists:member(SkillGroupID, GroupList) of
					true -> %% 同系技能只可存在1个
					    notify_puton_fail(?sg_sculpture_puton_skill_repeat,[]);
					_ ->
					    Pos = calc_put_on_pos(ReqPos, Role),
					    %% 所有判断通过，保存数据
					    SField = "sculpture" ++ integer_to_list(Pos),
					    AtomField = list_to_atom(SField),
					    case Role:AtomField() =/= 0 of
						true -> %%该位置已有符文
						    notify_puton_fail(?sg_sculpture_pos_has_puton,[]);
						_ ->
						    %% 设置符文到位置上
						    NewRole = Role:set([{AtomField, InstId}]),
						    %% 通知装上成功，客户端可能要做动画效果，要在通知背包数据前发给客户端,实例才有效
						    packet:send(#notify_sculpture_puton{is_success=?common_success, position=Pos,
											inst_id=InstId}),

						    %% 背包删物品, 并通知
						    %%player_pack:delete_item_notify(InstId, ?st_sculpture_puton),
						    %% 保存数据
						    player_role:save_my_db_role(NewRole),
						    %% 通知其他系统
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
%% 符文兑换
%% [req_sculpture_convert,  % 碎片兑换符文
%%  {int, target_item_id}        % 目标物品xml id
%% ],
%%%===================================================================
proc_req_sculpture_convert(#req_sculpture_convert{target_item_id=ItemTpltId})->
    RoleId = player:get_role_id(),

    %%[Role|_] = db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    FragCount = get_frag_count(),

    %% 根据物品id 取符文id
    SculptureTpltId = ItemTpltId,
    %% 必须存在这种符文
    #sculpture_tplt{role_type=NeedRoleType} = tplt:get_data(sculpture_tplt, SculptureTpltId),

    %% 必须存在这种兑换
    #sculpture_convert_tplt{frag_count=NeedCount} = tplt:get_data(sculpture_convert_tplt, ItemTpltId),

    %% 判断职业
    case NeedRoleType =/= Role:role_type() of 
	true ->
	    notify_convert_fail(?sg_sculpture_puton_role_type_not_match, []);
	_ ->
	    %% 判断碎片是否足够
	    case FragCount < NeedCount of
		true -> %% 碎片不足
		    notify_convert_fail(?sg_sculpture_frag_not_enough, []);
		_ ->
		    %% 背包是否满了
		    case sculpture_pack:check_pack_enough(1) of
			false -> %% 背包满了要提示
			    notify_convert_fail(?sg_sculpture_convert_pack_full,[]);		    
			_ ->
			    %% 背包减符文碎片
			    %% 这里会自动保存背包数据, 并发消息给客户端
			    broadcast_convert_item(ItemTpltId),
			    dec_frag_count(NeedCount),
			    %% 背包加符文物品
			    %% 这里会自动保存背包数据, 并发消息给客户端
			    sculpture_pack:add_sculptures(?st_sculpture_convert, [{ItemTpltId, 1}]),
			    %% 通知兑换成功，客户端可能要做动画效果, 要在通知背包数据前发给客户端,实例才有效
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
%% 占卜
%% [req_sculpture_divine,  % 符文占卜
%%  {int, money_type},     % 货币类型
%%  {int, times}           % 占卜次数
%% ]
%%%===================================================================
proc_req_sculpture_divine(#req_sculpture_divine{money_type=MoneyType, times=RawTimes})->
    RoleId = player:get_role_id(),

    #sculpture_divine_tplt{money_amounts=MoneyAmounts,  %% 对应占卜等级要花多少钱 
			   upgrade_rates=UpgradeRates,  %% 占卜等级的升级几率
			   divine_award_file=AwardFile} = 
	tplt:get_data(sculpture_divine_tplt, MoneyType),

    %% 占卜等级, 不同货币，不一样
    DivineLevel = db_get_divine_level(RoleId, MoneyType),
 
    AllData = tplt:get_all_data(list_to_atom(binary_to_list(AwardFile))),

    %% 根据金钱类型，取当前还有多少钱
    MyMoney = get_money_by_type(MoneyType),
    PackRemainCount = sculpture_pack:get_remain_space(),
    %% 先都搞成一
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
    %% 钱不够要提示
    case RemainMoney =:= MyMoney of
	true -> %% 钱都没扣
	    notify_divine_fail(?sg_sculpture_divine_money_not_enough,[]);
	_ ->

	    %% 判断背包是否够用
	    case PackRemainCount =< 0 of
		true -> %% 背包满了要提示
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
		    %% 背包加符文物品
		    sculpture_pack:add_sculptures(?st_sculpture_divine, ProductList),
		    broadcast_divine_item(ProductList),
		    %% 扣钱
		    DecMoney = MyMoney - RemainMoney,
		    reduce_money_by_type(MoneyType, DecMoney),

		    %% 保存占卜等级
		    db_set_divine_level(RoleId, MoneyType, NewDivineLevel),

        %%任务记录
        event_router:send_event_msg(#event_task_finish_times_update{amount = length(ProductList), sub_type = 7}),

		    %% 通知占卜等级变了,获得哪些奖品
		    Awards = [#award_item{temp_id=TempId,amount=Amount} || {TempId, Amount} <- ProductList],
		    packet:send(#notify_sculpture_divine{is_success=?common_success,divine_level=NewDivineLevel,
							 awards=Awards}),
		    case NewDivineLevel > DivineLevel of
			true -> %% 通知占卜升级
			    ok;%%sys_msg:send_to_self(?sg_sculpture_divine_level_up,[]);
			_ ->
			    case NewDivineLevel < DivineLevel of
				true -> %% 通知占卜降级
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
%%% 内部实现函数
%%%===================================================================

%% 算穿上位置
calc_put_on_pos(Pos, _Role) 
  when (1 =< Pos) and (Pos =< 4) -> %% 有指定位置
    Pos;
calc_put_on_pos(Pos, Role) when (Pos == 0) -> 
    L = [Role:sculpture1(), Role:sculpture2(), Role:sculpture3(), Role:sculpture4()],
    case lists_index_of(0, L) of
	0 -> %% 找不到就用第一个位置
	    1;
	Ret ->
	    Ret
    end.


%% 根据金钱类型，取当前还有多少钱
get_money_by_type(MoneyType) ->
    case MoneyType of 
	1 -> %% gold金币
	    player_role:get_gold();
	2 -> %% emoney代币
	    player_role:get_emoney();
	_ -> %% 其他情况都没实现
	    0
    end.

%% 扣钱
reduce_money_by_type(MoneyType, DecMoney) ->
    case MoneyType of 
	1 -> %% gold金币
	    player_role:reduce_gold(?st_sculpture_divine, DecMoney);
	2 -> %% emoney代币
	    player_role:reduce_emoney(?st_sculpture_divine, DecMoney)
    end.



%% 取技能组列表 
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

%% 根据实例id取模板id, 没有就返回0
%% SculptureInstId 符文的实例id
get_temp_id(SculptureInstId) ->
    case sculpture_pack:get_sculpture_by_inst(SculptureInstId) of
	undefined -> %% 没有就返回0
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


%% 尽量占卜，没钱没次数为止
%%        剩余次数        最后占卜等级     剩多少钱       产生哪些符文 
%% 返回  {_RemainTimes, NewDivineLevel, RemainMoney, ProductList}
try_divine(AllData, MoneyAmounts, UpgradeRates, 
	   {Times, DivineLevel, MyMoney, ProductList}=Acc) ->
    case Times of
	0 -> %% 如果次数为0要返回
	    Acc;
	_ ->
	    %% 根据占卜等级, 取可掉落列表
	    IDRateList = get_id_rate_list(DivineLevel, AllData),
	    %% 根据占卜等级, 取要消耗多少钱
	    CostMoney = lists:nth(DivineLevel, MoneyAmounts),
	    %% 根据占卜等级, 取升级几率百分比
	    UpgradeRate = lists:nth(DivineLevel, UpgradeRates),

	    %% 如果钱不够要返回
	    case CostMoney > MyMoney of
		true ->
		    Acc;
		_ ->
		    %% 随机产生一个
		    SculptureTpltID = rand_one(IDRateList),
		    NewDivineLevel =
			case rand:uniform(100) > UpgradeRate of
			    true -> %% 没命中，降为1级
				1;
			    _ -> %% 命中，升级
				DivineLevel + 1
			end,
		    ItemAmount = 1,
		    try_divine(AllData, MoneyAmounts, UpgradeRates,
			       {Times - 1, NewDivineLevel, MyMoney - CostMoney, 
				[{SculptureTpltID, ItemAmount} | ProductList]})
	    end
    end.


%% 符文加经验
%% 返回新的符文和经验{NewSculptureTpltID, NewExp}
sculpture_add_exp(Lev, Grade, OldExp, AddExp, MaxLev) ->
    Need = get_upgrade_need_exp(Lev, Grade),
    NewExp = OldExp + AddExp,
    case NewExp < Need of
	true -> %% 没升级
	    {Lev, NewExp};
	_ -> %% 升级了
	    %% 判断能否升级
	    case MaxLev > Lev  of
		false -> %% 不能再升了
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

%% 返回某个值的下标，没找到返回0
lists_index_of(Val, L) ->
    HeadL = lists:takewhile(fun(X) -> X =/= Val end, L),
    HeadCount = length(HeadL),
    case HeadCount =:= length(L) of
	true -> %% 没找到返回0
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
    %% 	RoleId-> %% 角色id必须一样
    %% 	    DBObj
    %% end
    sculpture_pack:get_sculpture_by_inst(SculptureInstId).



%% 取碎片数量
get_frag_count() ->
    sculpture_pack:get_frag_count().

%% 删碎片数量(兑换)
dec_frag_count(DecCount) ->
    sculpture_pack:del_sculptures(?st_sculpture_convert, 
			     [{config:get(sculpture_frag_item_id), DecCount}]).

%% 取可掉落列表(Value是个加总值，便于运算)
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
    %% 百分比(Rate)大的放后面
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
%%  从掉落列表中取一个
%% @end
%%--------------------------------------------------------------------
%% 功能: 随机产生1个物品id
%% 参数: IDRateList结构为[{ItemID, Rate}, ...], 注意Rate是加总值
rand_one(IDRateList) ->
    %% 取总概率
    TotalRate = get_total_rate(IDRateList),
    %% 生成一个随机数
    Hit = rand:uniform(TotalRate),
    %% 看这个随机数掉在哪里
    pick_hit(Hit, IDRateList).

pick_hit(Hit, IDRateList) ->
    %% 必须有1个以上符合条件
    [{Id, _} | _] = lists:dropwhile(fun({_Id, Rate}) -> Rate < Hit end, IDRateList),
    %%io:format("~p~n", [{Hit, IDRateList, Id}]),
    Id.

%% 取总概率
get_total_rate(IDRateList) ->
    {_K, Value} = lists:last(IDRateList),
    Value.

get_id_rate(R, Level) ->  
    %% 转成列表
    L = tuple_to_list(R),
    %% 第2个是Id
    Id = lists:nth(2, L),
    %% Id后是等级几率
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
%%  存取占卜等级
%% @end
%%--------------------------------------------------------------------
%% 取占卜等级
%% MoneyType 货币类型 1 gold, 2 emoney, 3 待定
db_get_divine_level(RoleId, MoneyType) ->
    Key = db_divine_level_key(MoneyType),
    case cache:get(Key, RoleId) of
	[{_Key,Value}]->
	    Value;
	_ -> %% 默认1级
	    1
    end.

db_divine_level_key(MoneyType) ->
    list_to_atom("divine_level" ++ integer_to_list(MoneyType)).

%% 存占卜等级
%% MoneyType 货币类型 1 gold, 2 emoney, 3 待定
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

