%%% @author  linyijie
%%% @copyright (C) 2010, 
%%% @doc
%%%  excel映射文件的结构体定义, 定义完结构体后, 程序会生成相应的资源映射文件供excel使用
%%% @end

%%% Created : 22 Mar 2010 by  <>

%% 类型的定义包括了: int, float, string, list_int, list_float, list_string
%% 新增类型 vector3, color, quaternion
%% 其中以list_ 打头的都是列表的形式, 模板表里填写的格式如下 1, 2, 3 要以逗号为分隔符
%% 其中以range 表示区间,  模板表里填写的格式如下 1~2,  最终生成的数据为元组{1, 2}。 也可直接填2, 表示{2, 2} 

-define(sys_msg_list,(
	  [
	   {service,
	    [
	     {broadcast, "广播"},
	     {is_busy_now, "服务器繁忙"},
	     {be_kick, "角色被封"},
	     {error, "服务器报错"}
	    ]
           },
	   {login,
	    [
	     {passward_error, "密码错误"}, 
	     {no_register, "未注册"}, 
	     {version_error, "版本错误"}, 
	     {repeat_login, "其他地方登录"},
	     {status_err, "账号被封"}
	    ]
	   },
	   {select_role,
	    [
	     {roleid_err, "发上来的ID错误"},
	     {already_del, "已被删除"},
	     {locked, "账号被封停"}
	    ]
	   },
	   {del_role,
	    [
	     {roleid_err, "发上来的ID错误"},
	     {already_del, "已被删除"}
	    ]
	   },
	   {recover_role,
	    [
	     {roleid_err, "发上来的ID错误"},
	     {status_normal, "不是已删除状态"},
	     {status_remove, "已被永久删除"},
	     {emoney_not_enough, "代币不足"},
	     {amount_exceeded, "数量超出"}
	    ]
	   },
	   {create_role,
	    [
	     {name_exist, "创建角色名字已存在"},
	     {not_login, "未登录"},
	     {amount_exceeded, "超出数量"},
	     {type_error, "类型错误"}
	    ]
	   },
	   {register,
	    [
	     {account_exist, "已注册"}
	    ]
	   },
	   {assistance,
	    [
	     {no_req_list,"未请求援助列表"},
	     {select_id_not_in_list,"选择的援助不在列表中"},
	     {get_lottery_item_err,"获取摇奖物品错误"}
	    ]
	   },
	   {reborn,
	    [
	     {emoney_not_enough, "代币不足"}
	    ]
	   },
	   {push_tower,
	    [
	     {buy_emoney_not_enough, "购买推塔次数的钱不够"},
	     {buy_times_exceeded, "已达购买上限"},
	     {enter_level_nomatch, "等级不匹配"},
	     {times_exceeded, "次数不足"},
	     {settle_gameinfo_not_exist, "结算时信息不存在"},
	     {settle_items_not_right, "客户端发上来的物品不对"},
	     {settle_round_not_enouth, "回合数不对"},
	     {settle_cost_round_illegel, "消耗的回合数非法"},
	     {settle_gameid_not_match, "游戏ID不匹配"}
	    ]
	   },
	   {game,
	    [
	     {settle_error, "结算错误"},
	     {settle_item_exceeded, "捡到的物品超过产出"},
	     {settle_gold_exceeded, "捡到的金币超过产出"},
	     {not_enough_power, "体力不足"},
	     {not_enough_summon_stone, "召唤石不足"},
	     {copy_lock, "未解锁"},
		 {emoney_not_enough, "代币不足"},
		 {level_not_enough, "进副本等级不足"},
		 {copy_not_pass, "副本未通过"}
	    ]
	   },
	   {challenge,
	    [
	     {buy_times_not_enough_emoney, "购买挑战的钱不够"},
	     {buy_times_exceeded, "购买次数已达上限"},
	     {enemy_noexist, "挑战者不存在"},
	     {noreq_list, "未请求挑战列表"},
	     {times_use_up, "挑战次数用完"},
	     {self, "不能挑战自己"},
	     {level_err, "等级错误"},
	     {settle_not_info, "结算时战斗信息不存在"},
	     {settle_info_err, "战斗信息有错"},
	     {rank_award_in_cd, "冷却中"},
	     {rank_award_not_in_rank, "不在可领取排名内"}
	    ]
	   },
	   {equipment_takeoff,
	    [
	     {pack_full, "背包已满"},
	     {type_error, "发上来的位置有错"}
	    ]
	   },
	   {equipment_puton,
	    [
	     {noexist, "装备不存在"},
	     {levelerr, "等级不匹配"},
	     {roletypeerr, "角色类型不匹配"},
	     {notowner, "不是拥有者"},
	     {itemtypeerr, "物品类型错误"}
	    ]
	   },
	   {equipment_streng,
	    [
	     {cannot_streng, "无法强化，没有可强化"},
	     {gold_not_enough, "金币不足"},
	     {item_not_enough, "物品不足"},
	     {streng_failed, "强化失败"},
	     {strenged_top, "已经强化到满级"}
	    ]
	   },
	   {equipment_advance,
	    [
	     {can_not_advance, "没有可进阶ID"},
	     {gold_not_enough, "金币不足"},
	     {item_not_enough, "材料不足不足"},
	     {level_not_enough, "装备等级不足"}
	    ]
	   },
	   {equipment_recast,
	    [
	     {can_not_recast, "没有可进阶ID"},
	     {gold_not_enough, "金币不足"},
	     {item_not_enough, "材料不足不足"}
	    ]
	   },
	   {equipment_resolve,
	    [{disable, "无法分解"},
	     {on_body, "无法分解身上的装备"},
	     {not_exist, "不存在该装备"}]
	   },
	   {gem_mount,
	    [
	     {typeexist, "绑定的宝石类型已存在"},
	     {not_trough, "没有插槽"}
	    ]
	   },
	   {equipment_save_recast,
	    [{iderr, "ID没有未保存的重铸信息"}]
	   },
	   {gem_compound,
	    [
	     {not_related, "无可合成的目标宝石"},
	     {not_enough_gold, "金币不足"},
	     {not_protect, "没有保护费"},
	     {gem_not_enough, "宝石不足"},
	     {pack_full, "背包已满"}
	    ]
	   },
	   {gem_unmounted,
	    [
	     {equip_notexist, "装备不存在"},
	     {pack_full, "背包已满"},
	     {emoney_not_enough, "代币不足"},
	     {notexist, "装备上不存在该宝石"}
	    ]
	   },
	   {friend_add,
	    [
	     {limit_exceeded, "好友已达上限"},
	     {aim_limit_exceeded, "对方好友已达上限"},
	     {self, "不能添加自己"},
	     {exist, "已存在"},
	     {offline, "不能添加离线"}
	    ]
	   },
	   {mall_buy,
	    [
	     {times_exceeded, "限购物品超出购买次数"},
	     {money_not_enough, "钱不够"},
	     {not_on_sale, "未上架"},
	     {pack_exceeded, "背包已满"}
	    ]
	   },
	   {point_mall_buy,
	    [
	     {rank_not_enough, "军衔不足"},
	     {point_not_enough, "积分不够"},
	     {not_on_sale, "未上架"},
	     {pack_exceeded, "背包已满"}
	    ]
	   },
	   {power_hp,
	    [
	     {emoney_not_enough, "代币不足"},
	     {limit_exceeded, "购买次数已达上限"}
	    ]
	   },
	   {extend_pack,
	    [
	     {is_max, "已达上限"},
	     {emoney_not_enough, "代币不足"}
	    ]
	   },
	   {pack_sale,
	    [
	     {not_exists, "物品不存在"},
	     {amount_error, "数量不足"}
	    ]
	   },
	   {summon_stone,
	    [
	     {already_award, "召唤石已领取"},
	     {emoney_not_enough_to_buy, "代币不足够,无法购买"},
	     {buy_times_exceeded, "购买次数达到上限"}		 
	    ]
	   },
	   {sculpture,
	    [
	     {upgrade_money_not_enough, "符文升级钱不够"},
	     {upgrade_is_max_lev, "已是最高等级"},
	     {takeoff_empty, "没装符文，不用卸下,这条主要是给客户端看的"},
	     {puton_noexist, "背包找不到符文物品"},
	     {puton_role_type_not_match, "符文职业不符合"},
	     {divine_money_not_enough, "符文占卜时钱不够"},
	     {takeoff_pack_full, "脱符文时发现背包已满"},
	     {puton_skill_repeat, "符文技能重复"},
	     {frag_not_enough, "符文碎片不足"},
	     {divine_pack_full, "符文占卜时背包满了"},
	     {convert_pack_full, "符文兑换时背包满了"},
	     {divine_level_up, "符文占卜升级了"},
	     {divine_level_down, "符文占卜降级了"},
	     {pos_has_puton, "当前位置已装备符文"},
	     {sale_is_on_body, "正装备着"},
	     {sale_noexist, "背包找不到符文物品"},
	     {upgrade_is_expsculp, "是经验符文不能充能"},
	     {puton_is_expsculpture, "是经验符文无法装备"}
	    ]
	   },
	   {task,
	    [
	     {not_exist, "任务不存在，无法完成任务"},
	     {monster_amount_not_enough, "怪物数量不足，无法完成任务"},
	     {not_pass, "普通通关没过，无法完成任务"},
	     {not_full_star_pass, "没3星通关，无法完成任务"},
	     {not_kill_all_pass, "没全部杀敌通关，无法完成任务"},
	     {has_finished, "任务已完成，无法完成任务"},
	     {player_level_not_enough, "等级不足，无法完成任务"},
	     {item_amount_not_enough, "收集物品不够，无法完成任务"},
	     {sculpture_upgrade_amount_not_enough, "符文充能次数不足"},
		 {advance_equipment_amount_not_enough, "升级装备次数不足"},
		 {equipment_resolve_amount_not_enough, "装备分解次数不足"},
		 {sculpture_divine_amount_not_enough, "占卜次数不足"}
	    ]
	   },
	   {daily_award,
	    [
	     {get_already, "已经领取"},
	     {cannot_get, "未达到领取条件"}
	    ]
	   },
	   {broadcast,
	    [
	     {divine_sculpture_lev5, "占卜到五阶符文"},
	     {convert_sculpture_lev6, "兑换六阶符文"},
	     {buy_sculpture_lev6, "购买六阶符文"},
	     {advance_orange_equipment, "进阶为橙色装备"},
	     {become_generalissimo, "成为大元帅"},
	     {become_vip, "成为VIP"},
	     {buy_advanced_item, "购买高级物品"},
	     {advance_equipment_success, "恭喜XX进阶装备成功"},
				{advance_role_success, "恭喜XX升阶成功"},
				{advance_skill_success, "恭喜XX将技能升阶成功"}
			]
	   },
	   {clean_up_copy,
	    [
	     {not_card, "没有扫荡卡"},
	     {not_max_score, "非三星通过"},
	     {not_base_copy, "非主线副本"},
	     {ph_not_enough, "体力不足"},
	     {clean_up_card_not_enough, "扫荡卡不足"},
	     {pass_copy_not_enough, "xx副本未通过"}
	    ]
	   },
	   {train_match,
	   [
	    {buy_times_not_enough_emoney, "购买时代币不足"},
	    {buy_times_exceeded, "购买次数超过限制"},
	    {refresh_not_enough_emoney, "请求刷新时检测到代币不足"},
	    {against_enemy_not_exist, "训练赛挑战的对象不存在"},
	    {against_leverr, "等级出错，无法生成地图"},
	    {times_exceeded, "比赛次数已经用完"},
	    {has_train, "选择的对象已经打败了"},
	    {award_times_not_enough, "次数不够完成失败"},
	    {award_has_get, "已经领取过"},
	    {settle_not_info, "未找到比赛信息"},
	    {settle_info_error, "结算信息有错"}
	   ]},
	   {use_props,
	    [
	     {not_props, "选择的物品不是可使用道具"},
	     {not_exists, "发上来的ID不在背包中"}
	    ]
	   },
	   {benison,
	    [
	     {refresh_not_enough_gold, "刷新没有足够的金币"},
	     {bless_id_not_exist, "发上来的祝福ID不存在"},
	     {bless_emoney_not_enough, "代币不足不能祝福"},
	     {bless_has_active, "已经激活过"}
	    ]
	   },
	   {activeness,
	    [
	     {reward_point_not_enough, "活跃点数不足无法来领取"},
	     {reward_has_gotten, "已经领取"}
	    ]
	   },
	   {reconnect, 
	    [
	     {token_err, "Token错误"},
	     {server_not_running, "服务器未开启"}
	    ]
	   },
	   {ladder_match,
	    [
	     {buy_times_exceeded, "购买次数已达上限"},
	     {award_gotten, "奖励已领取"},
	     {award_disable, "无奖励领取"},
	     {times_exceeded, "次数已用完"},
	     {emoney_not_enough, "代币不足"},
	     {settle_error, "结算时系统出错"}
	    ]
	   },
	   {equipment_exchange,
	    [
	     {disable, "无法转化"},
	     {gold_err, "金币不足"},
	     {meterial, "材料不足"}
	    ]
	   },
	   {online_award,
	    [
	     {lev_err, "ID对应的等级有错"},
	     {time_err, "时间不够"},
	     {has_gotten, "已经领取"}
	    ]
	   },
	   {exchange,
	    [
	     {item_not_enough, "材料不足"}
	    ]
	   },
	   {military_rank,
	    [
	     {level_err, "等级不足"}
	    ]
	   },
	   {mooncard,
	    [
	     {daily_award_gotten, "月卡的每日奖励已经领取"},
	     {daily_award_disable, "没有月卡，无法领取"}
	    ]
	   },
	   {invitation_code,
	    [
	     {code_err, "您输入的邀请码不存在"},
	     {verify_code_succeed, "成功绑定好友；绑定好友开放"},
	     {disengage_err, "您的好友在十天内登录过游戏，无法断绝关系"},
	     {invite_num_is_full, "邀请人数已满"},
		 {can_not_use_at_same_account, "无法邀请同个账号的角色"}
	    ]
	   },
	   {world_chat,
	    [
	     {too_quick, "发送太过频繁"},
	     {mute, "玩家被禁言"},
	     {emoney_not_enough, "魔石不足"}
	    ]
	   },
	   {activity_copy,
	    [
	     {times_use_up, "活动副本次数用完"},
	     {ph_not_enough, "体力不足"},
	     {level_not_enough, "等级不足"},
	     {not_open, "未开放"}
	    ]
	   },
	   {friend_help,
	    [
	     {hp_has_send, "体力已送出"}
	    ]
	   },
           {talent,
             [
              {layer_unlock,"天赋未解锁"},
              {server_error,"服务器异常"},
              {actived,"天赋已激活"},
              {actived_two,"每层仅允许激活一个"},
              {not_enough_frag,"技能碎片不足"},
              {max_level,"达到最高等级"},
              {emoney_not_enough,"魔石不足"},
              {unactived,"天赋未激活"},
              {actived_reseted,"已经为重置状态，请勿重复重置"}
             ]
           }
	  ])
       ).
