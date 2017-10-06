%%sys_msg_def


%%login
-define(sg_login_passward_error, 1).     %%密码错误
-define(sg_login_no_register, 2).     %%未注册
-define(sg_login_version_error, 3).     %%版本错误
-define(sg_login_repeat_login, 4).     %%其他地方登录
-define(sg_login_status_err, 5).     %%账号被封


%%select_role
-define(sg_select_role_roleid_err, 6).     %%发上来的ID错误
-define(sg_select_role_already_del, 7).     %%已被删除


%%del_role
-define(sg_del_role_roleid_err, 8).     %%发上来的ID错误
-define(sg_del_role_already_del, 9).     %%已被删除


%%recover_role
-define(sg_recover_role_roleid_err, 10).     %%发上来的ID错误
-define(sg_recover_role_status_normal, 11).     %%不是已删除状态
-define(sg_recover_role_status_remove, 12).     %%已被永久删除
-define(sg_recover_role_emoney_not_enough, 13).     %%代币不足
-define(sg_recover_role_amount_exceeded, 14).     %%数量超出


%%create_role
-define(sg_create_role_name_exist, 15).     %%创建角色名字已存在
-define(sg_create_role_not_login, 16).     %%未登录
-define(sg_create_role_amount_exceeded, 17).     %%超出数量
-define(sg_create_role_type_error, 18).     %%类型错误


%%register
-define(sg_register_account_exist, 19).     %%已注册


%%assistance
-define(sg_assistance_no_req_list, 20).     %%未请求援助列表
-define(sg_assistance_select_id_not_in_list, 21).     %%选择的援助不在列表中


%%reborn
-define(sg_reborn_emoney_not_enough, 22).     %%代币不足


%%push_tower
-define(sg_push_tower_enter_level_nomatch, 23).     %%等级不匹配
-define(sg_push_tower_times_exceeded, 24).     %%次数不足
-define(sg_push_tower_settle_gameinfo_not_exist, 25).     %%结算时信息不存在
-define(sg_push_tower_settle_items_not_right, 26).     %%客户端发上来的物品不对
-define(sg_push_tower_settle_round_not_enouth, 27).     %%回合数不对
-define(sg_push_tower_settle_cost_round_illegel, 28).     %%消耗的回合数非法
-define(sg_push_tower_settle_gameid_not_match, 29).     %%游戏ID不匹配


%%game
-define(sg_game_settle_error, 30).     %%结算错误
-define(sg_game_settle_item_exceeded, 31).     %%捡到的物品超过产出
-define(sg_game_settle_gold_exceeded, 32).     %%捡到的金币超过产出
-define(sg_game_not_enough_power, 33).     %%体力不足
-define(sg_game_not_enough_summon_stone, 34).     %%召唤石不足
-define(sg_game_copy_lock, 35).     %%未解锁
-define(sg_game_emoney_not_enough, 36).     %%代币不足


%%challenge
-define(sg_challenge_enemy_noexist, 37).     %%挑战者不存在
-define(sg_challenge_noreq_list, 38).     %%未请求挑战列表
-define(sg_challenge_times_use_up, 39).     %%挑战次数用完
-define(sg_challenge_self, 40).     %%不能挑战自己
-define(sg_challenge_level_err, 41).     %%等级错误
-define(sg_challenge_settle_not_info, 42).     %%结算时战斗信息不存在
-define(sg_challenge_settle_info_err, 43).     %%战斗信息有错
-define(sg_challenge_rank_award_in_cd, 44).     %%冷却中
-define(sg_challenge_rank_award_not_in_rank, 45).     %%不在可领取排名内


%%equipment_takeoff
-define(sg_equipment_takeoff_pack_full, 46).     %%背包已满
-define(sg_equipment_takeoff_type_error, 47).     %%发上来的位置有错


%%equipment_puton
-define(sg_equipment_puton_noexist, 48).     %%装备不存在
-define(sg_equipment_puton_levelerr, 49).     %%等级不匹配
-define(sg_equipment_puton_roletypeerr, 50).     %%角色类型不匹配
-define(sg_equipment_puton_notowner, 51).     %%不是拥有者
-define(sg_equipment_puton_itemtypeerr, 52).     %%物品类型错误


%%equipment_streng
-define(sg_equipment_streng_cannot_streng, 53).     %%无法强化，没有可强化
-define(sg_equipment_streng_gold_not_enough, 54).     %%金币不足
-define(sg_equipment_streng_item_not_enough, 55).     %%物品不足
-define(sg_equipment_streng_streng_failed, 56).     %%强化失败


%%equipment_advance
-define(sg_equipment_advance_can_not_advance, 57).     %%没有可进阶ID
-define(sg_equipment_advance_gold_not_enough, 58).     %%金币不足
-define(sg_equipment_advance_item_not_enough, 59).     %%材料不足不足
-define(sg_equipment_advance_level_not_enough, 60).     %%装备等级不足


%%equipment_recast
-define(sg_equipment_recast_can_not_recast, 61).     %%没有可进阶ID
-define(sg_equipment_recast_gold_not_enough, 62).     %%金币不足
-define(sg_equipment_recast_item_not_enough, 63).     %%材料不足不足


%%equipment_resolve
-define(sg_equipment_resolve_disable, 64).     %%无法分解
-define(sg_equipment_resolve_on_body, 65).     %%无法分解身上的装备
-define(sg_equipment_resolve_not_exist, 66).     %%不存在该装备


%%gem_mount
-define(sg_gem_mount_typeexist, 67).     %%绑定的宝石类型已存在
-define(sg_gem_mount_not_trough, 68).     %%没有插槽


%%equipment_save_recast
-define(sg_equipment_save_recast_iderr, 69).     %%ID没有未保存的重铸信息


%%gem_compound
-define(sg_gem_compound_not_related, 70).     %%无可合成的目标宝石
-define(sg_gem_compound_not_enough_gold, 71).     %%金币不足
-define(sg_gem_compound_not_protect, 72).     %%没有保护费
-define(sg_gem_compound_gem_not_enough, 73).     %%宝石不足
-define(sg_gem_compound_pack_full, 74).     %%背包已满


%%gem_unmounted
-define(sg_gem_unmounted_equip_notexist, 75).     %%装备不存在
-define(sg_gem_unmounted_pack_full, 76).     %%背包已满
-define(sg_gem_unmounted_emoney_not_enough, 77).     %%代币不足
-define(sg_gem_unmounted_notexist, 78).     %%装备上不存在该宝石


%%friend_add
-define(sg_friend_add_limit_exceeded, 79).     %%好友已达上限
-define(sg_friend_add_aim_limit_exceeded, 80).     %%对方好友已达上限
-define(sg_friend_add_self, 81).     %%不能添加自己
-define(sg_friend_add_exist, 82).     %%已存在
-define(sg_friend_add_offline, 83).     %%不能添加离线


%%mall_buy
-define(sg_mall_buy_times_exceeded, 84).     %%限购物品超出购买次数
-define(sg_mall_buy_money_not_enough, 85).     %%钱不够
-define(sg_mall_buy_not_on_sale, 86).     %%未上架
-define(sg_mall_buy_pack_exceeded, 87).     %%背包已满


%%point_mall_buy
-define(sg_point_mall_buy_rank_not_enough, 88).     %%军衔不足
-define(sg_point_mall_buy_point_not_enough, 89).     %%积分不够
-define(sg_point_mall_buy_not_on_sale, 90).     %%未上架
-define(sg_point_mall_buy_pack_exceeded, 91).     %%背包已满


%%power_hp
-define(sg_power_hp_emoney_not_enough, 92).     %%代币不足
-define(sg_power_hp_limit_exceeded, 93).     %%购买次数已达上限


%%extend_pack
-define(sg_extend_pack_is_max, 94).     %%已达上限
-define(sg_extend_pack_emoney_not_enough, 95).     %%代币不足


%%pack_sale
-define(sg_pack_sale_not_exists, 96).     %%物品不存在
-define(sg_pack_sale_amount_error, 97).     %%数量不足


%%summon_stone
-define(sg_summon_stone_already_award, 98).     %%召唤石已领取
-define(sg_summon_stone_emoney_not_enough_to_buy, 99).     %%代币不足够,无法购买
-define(sg_summon_stone_buy_times_exceeded, 100).     %%购买次数达到上限


%%sculpture
-define(sg_sculpture_upgrade_money_not_enough, 101).     %%符文升级钱不够
-define(sg_sculpture_upgrade_is_max_lev, 102).     %%已是最高等级
-define(sg_sculpture_takeoff_empty, 103).     %%没装符文，不用卸下,这条主要是给客户端看的
-define(sg_sculpture_puton_noexist, 104).     %%背包找不到符文物品
-define(sg_sculpture_puton_role_type_not_match, 105).     %%符文职业不符合
-define(sg_sculpture_divine_money_not_enough, 106).     %%符文占卜时钱不够
-define(sg_sculpture_takeoff_pack_full, 107).     %%脱符文时发现背包已满
-define(sg_sculpture_puton_skill_repeat, 108).     %%符文技能重复
-define(sg_sculpture_frag_not_enough, 109).     %%符文碎片不足
-define(sg_sculpture_divine_pack_full, 110).     %%符文占卜时背包满了
-define(sg_sculpture_convert_pack_full, 111).     %%符文兑换时背包满了
-define(sg_sculpture_divine_level_up, 112).     %%符文占卜升级了
-define(sg_sculpture_divine_level_down, 113).     %%符文占卜降级了
-define(sg_sculpture_pos_has_puton, 114).     %%当前位置已装备符文
-define(sg_sculpture_sale_is_on_body, 115).     %%正装备着
-define(sg_sculpture_sale_noexist, 116).     %%背包找不到符文物品
-define(sg_sculpture_upgrade_is_expsculp, 117).     %%是经验符文不能充能
-define(sg_sculpture_puton_is_expsculpture, 118).     %%是经验符文无法装备


%%task
-define(sg_task_not_exist, 119).     %%任务不存在，无法完成任务
-define(sg_task_monster_amount_not_enough, 120).     %%怪物数量不足，无法完成任务
-define(sg_task_not_pass, 121).     %%普通通关没过，无法完成任务
-define(sg_task_not_full_star_pass, 122).     %%没3星通关，无法完成任务
-define(sg_task_not_kill_all_pass, 123).     %%没全部杀敌通关，无法完成任务
-define(sg_task_has_finished, 124).     %%任务已完成，无法完成任务
-define(sg_task_player_level_not_enough, 125).     %%等级不足，无法完成任务
-define(sg_task_item_amount_not_enough, 126).     %%收集物品不够，无法完成任务
-define(sg_task_sculpture_upgrade_amount_not_enough, 127).     %%符文充能次数不足
-define(sg_task_advance_equipment_amount_not_enough, 128).     %%升级装备次数不足
-define(sg_task_equipment_resolve_amount_not_enough, 129).     %%装备分解次数不足
-define(sg_task_sculpture_divine_amount_not_enough, 130).     %%占卜次数不足


%%daily_award
-define(sg_daily_award_get_already, 131).     %%已经领取
-define(sg_daily_award_cannot_get, 132).     %%未达到领取条件


%%broadcast
-define(sg_broadcast_divine_sculpture_lev5, 133).     %%占卜到五阶符文
-define(sg_broadcast_convert_sculpture_lev6, 134).     %%兑换六阶符文
-define(sg_broadcast_buy_sculpture_lev6, 135).     %%购买六阶符文


%%clean_up_copy
-define(sg_clean_up_copy_not_card, 136).     %%没有扫荡卡
-define(sg_clean_up_copy_not_max_score, 137).     %%非三星通过
-define(sg_clean_up_copy_not_base_copy, 138).     %%非主线副本
-define(sg_clean_up_copy_ph_not_enough, 139).     %%体力不足


%%train_match
-define(sg_train_match_buy_times_not_enough_emoney, 140).     %%购买时代币不足
-define(sg_train_match_refresh_not_enough_emoney, 141).     %%请求刷新时检测到代币不足
-define(sg_train_match_against_enemy_not_exist, 142).     %%训练赛挑战的对象不存在
-define(sg_train_match_against_leverr, 143).     %%等级出错，无法生成地图
-define(sg_train_match_times_exceeded, 144).     %%比赛次数已经用完
-define(sg_train_match_has_train, 145).     %%选择的对象已经打败了
-define(sg_train_match_award_times_not_enough, 146).     %%次数不够完成失败
-define(sg_train_match_award_has_get, 147).     %%已经领取过
-define(sg_train_match_settle_not_info, 148).     %%未找到比赛信息
-define(sg_train_match_settle_info_error, 149).     %%结算信息有错


%%use_props
-define(sg_use_props_not_props, 150).     %%选择的物品不是可使用道具
-define(sg_use_props_not_exists, 151).     %%发上来的ID不在背包中


%%benison
-define(sg_benison_refresh_not_enough_gold, 152).     %%刷新没有足够的金币
-define(sg_benison_bless_id_not_exist, 153).     %%发上来的祝福ID不存在
-define(sg_benison_bless_emoney_not_enough, 154).     %%代币不足不能祝福
-define(sg_benison_bless_has_active, 155).     %%已经激活过


%%activeness
-define(sg_activeness_reward_point_not_enough, 156).     %%活跃点数不足无法来领取
-define(sg_activeness_reward_has_gotten, 157).     %%已经领取


%%reconnect
-define(sg_reconnect_token_err, 158).     %%Token错误
