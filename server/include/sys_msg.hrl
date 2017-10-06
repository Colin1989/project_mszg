%%sys_msg_def


%%service
-define(sg_service_broadcast, 1).     %%广播
-define(sg_service_is_busy_now, 2).     %%服务器繁忙
-define(sg_service_be_kick, 3).     %%角色被封
-define(sg_service_error, 4).     %%服务器报错


%%login
-define(sg_login_passward_error, 5).     %%密码错误
-define(sg_login_no_register, 6).     %%未注册
-define(sg_login_version_error, 7).     %%版本错误
-define(sg_login_repeat_login, 8).     %%其他地方登录
-define(sg_login_status_err, 9).     %%账号被封


%%select_role
-define(sg_select_role_roleid_err, 10).     %%发上来的ID错误
-define(sg_select_role_already_del, 11).     %%已被删除
-define(sg_select_role_locked, 12).     %%账号被封停


%%del_role
-define(sg_del_role_roleid_err, 13).     %%发上来的ID错误
-define(sg_del_role_already_del, 14).     %%已被删除


%%recover_role
-define(sg_recover_role_roleid_err, 15).     %%发上来的ID错误
-define(sg_recover_role_status_normal, 16).     %%不是已删除状态
-define(sg_recover_role_status_remove, 17).     %%已被永久删除
-define(sg_recover_role_emoney_not_enough, 18).     %%代币不足
-define(sg_recover_role_amount_exceeded, 19).     %%数量超出


%%create_role
-define(sg_create_role_name_exist, 20).     %%创建角色名字已存在
-define(sg_create_role_not_login, 21).     %%未登录
-define(sg_create_role_amount_exceeded, 22).     %%超出数量
-define(sg_create_role_type_error, 23).     %%类型错误


%%register
-define(sg_register_account_exist, 24).     %%已注册


%%assistance
-define(sg_assistance_no_req_list, 25).     %%未请求援助列表
-define(sg_assistance_select_id_not_in_list, 26).     %%选择的援助不在列表中
-define(sg_assistance_get_lottery_item_err, 27).     %%获取摇奖物品错误


%%reborn
-define(sg_reborn_emoney_not_enough, 28).     %%代币不足


%%push_tower
-define(sg_push_tower_buy_emoney_not_enough, 29).     %%购买推塔次数的钱不够
-define(sg_push_tower_buy_times_exceeded, 30).     %%已达购买上限
-define(sg_push_tower_enter_level_nomatch, 31).     %%等级不匹配
-define(sg_push_tower_times_exceeded, 32).     %%次数不足
-define(sg_push_tower_settle_gameinfo_not_exist, 33).     %%结算时信息不存在
-define(sg_push_tower_settle_items_not_right, 34).     %%客户端发上来的物品不对
-define(sg_push_tower_settle_round_not_enouth, 35).     %%回合数不对
-define(sg_push_tower_settle_cost_round_illegel, 36).     %%消耗的回合数非法
-define(sg_push_tower_settle_gameid_not_match, 37).     %%游戏ID不匹配


%%game
-define(sg_game_settle_error, 38).     %%结算错误
-define(sg_game_settle_item_exceeded, 39).     %%捡到的物品超过产出
-define(sg_game_settle_gold_exceeded, 40).     %%捡到的金币超过产出
-define(sg_game_not_enough_power, 41).     %%体力不足
-define(sg_game_not_enough_summon_stone, 42).     %%召唤石不足
-define(sg_game_copy_lock, 43).     %%未解锁
-define(sg_game_emoney_not_enough, 44).     %%代币不足
-define(sg_game_level_not_enough, 45).     %%进副本等级不足
-define(sg_game_copy_not_pass, 46).     %%副本未通过


%%challenge
-define(sg_challenge_buy_times_not_enough_emoney, 47).     %%购买挑战的钱不够
-define(sg_challenge_buy_times_exceeded, 48).     %%购买次数已达上限
-define(sg_challenge_enemy_noexist, 49).     %%挑战者不存在
-define(sg_challenge_noreq_list, 50).     %%未请求挑战列表
-define(sg_challenge_times_use_up, 51).     %%挑战次数用完
-define(sg_challenge_self, 52).     %%不能挑战自己
-define(sg_challenge_level_err, 53).     %%等级错误
-define(sg_challenge_settle_not_info, 54).     %%结算时战斗信息不存在
-define(sg_challenge_settle_info_err, 55).     %%战斗信息有错
-define(sg_challenge_rank_award_in_cd, 56).     %%冷却中
-define(sg_challenge_rank_award_not_in_rank, 57).     %%不在可领取排名内


%%equipment_takeoff
-define(sg_equipment_takeoff_pack_full, 58).     %%背包已满
-define(sg_equipment_takeoff_type_error, 59).     %%发上来的位置有错


%%equipment_puton
-define(sg_equipment_puton_noexist, 60).     %%装备不存在
-define(sg_equipment_puton_levelerr, 61).     %%等级不匹配
-define(sg_equipment_puton_roletypeerr, 62).     %%角色类型不匹配
-define(sg_equipment_puton_notowner, 63).     %%不是拥有者
-define(sg_equipment_puton_itemtypeerr, 64).     %%物品类型错误


%%equipment_streng
-define(sg_equipment_streng_cannot_streng, 65).     %%无法强化，没有可强化
-define(sg_equipment_streng_gold_not_enough, 66).     %%金币不足
-define(sg_equipment_streng_item_not_enough, 67).     %%物品不足
-define(sg_equipment_streng_streng_failed, 68).     %%强化失败
-define(sg_equipment_streng_strenged_top, 69).     %%已经强化到满级


%%equipment_advance
-define(sg_equipment_advance_can_not_advance, 70).     %%没有可进阶ID
-define(sg_equipment_advance_gold_not_enough, 71).     %%金币不足
-define(sg_equipment_advance_item_not_enough, 72).     %%材料不足不足
-define(sg_equipment_advance_level_not_enough, 73).     %%装备等级不足


%%equipment_recast
-define(sg_equipment_recast_can_not_recast, 74).     %%没有可进阶ID
-define(sg_equipment_recast_gold_not_enough, 75).     %%金币不足
-define(sg_equipment_recast_item_not_enough, 76).     %%材料不足不足


%%equipment_resolve
-define(sg_equipment_resolve_disable, 77).     %%无法分解
-define(sg_equipment_resolve_on_body, 78).     %%无法分解身上的装备
-define(sg_equipment_resolve_not_exist, 79).     %%不存在该装备


%%gem_mount
-define(sg_gem_mount_typeexist, 80).     %%绑定的宝石类型已存在
-define(sg_gem_mount_not_trough, 81).     %%没有插槽


%%equipment_save_recast
-define(sg_equipment_save_recast_iderr, 82).     %%ID没有未保存的重铸信息


%%gem_compound
-define(sg_gem_compound_not_related, 83).     %%无可合成的目标宝石
-define(sg_gem_compound_not_enough_gold, 84).     %%金币不足
-define(sg_gem_compound_not_protect, 85).     %%没有保护费
-define(sg_gem_compound_gem_not_enough, 86).     %%宝石不足
-define(sg_gem_compound_pack_full, 87).     %%背包已满


%%gem_unmounted
-define(sg_gem_unmounted_equip_notexist, 88).     %%装备不存在
-define(sg_gem_unmounted_pack_full, 89).     %%背包已满
-define(sg_gem_unmounted_emoney_not_enough, 90).     %%代币不足
-define(sg_gem_unmounted_notexist, 91).     %%装备上不存在该宝石


%%friend_add
-define(sg_friend_add_limit_exceeded, 92).     %%好友已达上限
-define(sg_friend_add_aim_limit_exceeded, 93).     %%对方好友已达上限
-define(sg_friend_add_self, 94).     %%不能添加自己
-define(sg_friend_add_exist, 95).     %%已存在
-define(sg_friend_add_offline, 96).     %%不能添加离线


%%mall_buy
-define(sg_mall_buy_times_exceeded, 97).     %%限购物品超出购买次数
-define(sg_mall_buy_money_not_enough, 98).     %%钱不够
-define(sg_mall_buy_not_on_sale, 99).     %%未上架
-define(sg_mall_buy_pack_exceeded, 100).     %%背包已满


%%point_mall_buy
-define(sg_point_mall_buy_rank_not_enough, 101).     %%军衔不足
-define(sg_point_mall_buy_point_not_enough, 102).     %%积分不够
-define(sg_point_mall_buy_not_on_sale, 103).     %%未上架
-define(sg_point_mall_buy_pack_exceeded, 104).     %%背包已满


%%power_hp
-define(sg_power_hp_emoney_not_enough, 105).     %%代币不足
-define(sg_power_hp_limit_exceeded, 106).     %%购买次数已达上限


%%extend_pack
-define(sg_extend_pack_is_max, 107).     %%已达上限
-define(sg_extend_pack_emoney_not_enough, 108).     %%代币不足


%%pack_sale
-define(sg_pack_sale_not_exists, 109).     %%物品不存在
-define(sg_pack_sale_amount_error, 110).     %%数量不足


%%summon_stone
-define(sg_summon_stone_already_award, 111).     %%召唤石已领取
-define(sg_summon_stone_emoney_not_enough_to_buy, 112).     %%代币不足够,无法购买
-define(sg_summon_stone_buy_times_exceeded, 113).     %%购买次数达到上限


%%sculpture
-define(sg_sculpture_upgrade_money_not_enough, 114).     %%符文升级钱不够
-define(sg_sculpture_upgrade_is_max_lev, 115).     %%已是最高等级
-define(sg_sculpture_takeoff_empty, 116).     %%没装符文，不用卸下,这条主要是给客户端看的
-define(sg_sculpture_puton_noexist, 117).     %%背包找不到符文物品
-define(sg_sculpture_puton_role_type_not_match, 118).     %%符文职业不符合
-define(sg_sculpture_divine_money_not_enough, 119).     %%符文占卜时钱不够
-define(sg_sculpture_takeoff_pack_full, 120).     %%脱符文时发现背包已满
-define(sg_sculpture_puton_skill_repeat, 121).     %%符文技能重复
-define(sg_sculpture_frag_not_enough, 122).     %%符文碎片不足
-define(sg_sculpture_divine_pack_full, 123).     %%符文占卜时背包满了
-define(sg_sculpture_convert_pack_full, 124).     %%符文兑换时背包满了
-define(sg_sculpture_divine_level_up, 125).     %%符文占卜升级了
-define(sg_sculpture_divine_level_down, 126).     %%符文占卜降级了
-define(sg_sculpture_pos_has_puton, 127).     %%当前位置已装备符文
-define(sg_sculpture_sale_is_on_body, 128).     %%正装备着
-define(sg_sculpture_sale_noexist, 129).     %%背包找不到符文物品
-define(sg_sculpture_upgrade_is_expsculp, 130).     %%是经验符文不能充能
-define(sg_sculpture_puton_is_expsculpture, 131).     %%是经验符文无法装备


%%task
-define(sg_task_not_exist, 132).     %%任务不存在，无法完成任务
-define(sg_task_monster_amount_not_enough, 133).     %%怪物数量不足，无法完成任务
-define(sg_task_not_pass, 134).     %%普通通关没过，无法完成任务
-define(sg_task_not_full_star_pass, 135).     %%没3星通关，无法完成任务
-define(sg_task_not_kill_all_pass, 136).     %%没全部杀敌通关，无法完成任务
-define(sg_task_has_finished, 137).     %%任务已完成，无法完成任务
-define(sg_task_player_level_not_enough, 138).     %%等级不足，无法完成任务
-define(sg_task_item_amount_not_enough, 139).     %%收集物品不够，无法完成任务
-define(sg_task_sculpture_upgrade_amount_not_enough, 140).     %%符文充能次数不足
-define(sg_task_advance_equipment_amount_not_enough, 141).     %%升级装备次数不足
-define(sg_task_equipment_resolve_amount_not_enough, 142).     %%装备分解次数不足
-define(sg_task_sculpture_divine_amount_not_enough, 143).     %%占卜次数不足


%%daily_award
-define(sg_daily_award_get_already, 144).     %%已经领取
-define(sg_daily_award_cannot_get, 145).     %%未达到领取条件


%%broadcast
-define(sg_broadcast_divine_sculpture_lev5, 146).     %%占卜到五阶符文
-define(sg_broadcast_convert_sculpture_lev6, 147).     %%兑换六阶符文
-define(sg_broadcast_buy_sculpture_lev6, 148).     %%购买六阶符文
-define(sg_broadcast_advance_orange_equipment, 149).     %%进阶为橙色装备
-define(sg_broadcast_become_generalissimo, 150).     %%成为大元帅
-define(sg_broadcast_become_vip, 151).     %%成为VIP
-define(sg_broadcast_buy_advanced_item, 152).     %%购买高级物品
-define(sg_broadcast_advance_equipment_success, 153).     %%恭喜XX进阶装备成功
-define(sg_broadcast_advance_role_success, 154).     %%恭喜XX升阶成功
-define(sg_broadcast_advance_skill_success, 155).     %%恭喜XX将技能升阶成功


%%clean_up_copy
-define(sg_clean_up_copy_not_card, 156).     %%没有扫荡卡
-define(sg_clean_up_copy_not_max_score, 157).     %%非三星通过
-define(sg_clean_up_copy_not_base_copy, 158).     %%非主线副本
-define(sg_clean_up_copy_ph_not_enough, 159).     %%体力不足
-define(sg_clean_up_copy_clean_up_card_not_enough, 160).     %%扫荡卡不足
-define(sg_clean_up_copy_pass_copy_not_enough, 161).     %%xx副本未通过


%%train_match
-define(sg_train_match_buy_times_not_enough_emoney, 162).     %%购买时代币不足
-define(sg_train_match_buy_times_exceeded, 163).     %%购买次数超过限制
-define(sg_train_match_refresh_not_enough_emoney, 164).     %%请求刷新时检测到代币不足
-define(sg_train_match_against_enemy_not_exist, 165).     %%训练赛挑战的对象不存在
-define(sg_train_match_against_leverr, 166).     %%等级出错，无法生成地图
-define(sg_train_match_times_exceeded, 167).     %%比赛次数已经用完
-define(sg_train_match_has_train, 168).     %%选择的对象已经打败了
-define(sg_train_match_award_times_not_enough, 169).     %%次数不够完成失败
-define(sg_train_match_award_has_get, 170).     %%已经领取过
-define(sg_train_match_settle_not_info, 171).     %%未找到比赛信息
-define(sg_train_match_settle_info_error, 172).     %%结算信息有错


%%use_props
-define(sg_use_props_not_props, 173).     %%选择的物品不是可使用道具
-define(sg_use_props_not_exists, 174).     %%发上来的ID不在背包中


%%benison
-define(sg_benison_refresh_not_enough_gold, 175).     %%刷新没有足够的金币
-define(sg_benison_bless_id_not_exist, 176).     %%发上来的祝福ID不存在
-define(sg_benison_bless_emoney_not_enough, 177).     %%代币不足不能祝福
-define(sg_benison_bless_has_active, 178).     %%已经激活过


%%activeness
-define(sg_activeness_reward_point_not_enough, 179).     %%活跃点数不足无法来领取
-define(sg_activeness_reward_has_gotten, 180).     %%已经领取


%%reconnect
-define(sg_reconnect_token_err, 181).     %%Token错误
-define(sg_reconnect_server_not_running, 182).     %%服务器未开启


%%ladder_match
-define(sg_ladder_match_buy_times_exceeded, 183).     %%购买次数已达上限
-define(sg_ladder_match_award_gotten, 184).     %%奖励已领取
-define(sg_ladder_match_award_disable, 185).     %%无奖励领取
-define(sg_ladder_match_times_exceeded, 186).     %%次数已用完
-define(sg_ladder_match_emoney_not_enough, 187).     %%代币不足
-define(sg_ladder_match_settle_error, 188).     %%结算时系统出错


%%equipment_exchange
-define(sg_equipment_exchange_disable, 189).     %%无法转化
-define(sg_equipment_exchange_gold_err, 190).     %%金币不足
-define(sg_equipment_exchange_meterial, 191).     %%材料不足


%%online_award
-define(sg_online_award_lev_err, 192).     %%ID对应的等级有错
-define(sg_online_award_time_err, 193).     %%时间不够
-define(sg_online_award_has_gotten, 194).     %%已经领取


%%exchange
-define(sg_exchange_item_not_enough, 195).     %%材料不足


%%military_rank
-define(sg_military_rank_level_err, 196).     %%等级不足


%%mooncard
-define(sg_mooncard_daily_award_gotten, 197).     %%月卡的每日奖励已经领取
-define(sg_mooncard_daily_award_disable, 198).     %%没有月卡，无法领取


%%invitation_code
-define(sg_invitation_code_code_err, 199).     %%您输入的邀请码不存在
-define(sg_invitation_code_verify_code_succeed, 200).     %%成功绑定好友；绑定好友开放
-define(sg_invitation_code_disengage_err, 201).     %%您的好友在十天内登录过游戏，无法断绝关系
-define(sg_invitation_code_invite_num_is_full, 202).     %%邀请人数已满
-define(sg_invitation_code_can_not_use_at_same_account, 203).     %%无法邀请同个账号的角色


%%world_chat
-define(sg_world_chat_too_quick, 204).     %%发送太过频繁
-define(sg_world_chat_mute, 205).     %%玩家被禁言
-define(sg_world_chat_emoney_not_enough, 206).     %%魔石不足


%%activity_copy
-define(sg_activity_copy_times_use_up, 207).     %%活动副本次数用完
-define(sg_activity_copy_ph_not_enough, 208).     %%体力不足
-define(sg_activity_copy_level_not_enough, 209).     %%等级不足
-define(sg_activity_copy_not_open, 210).     %%未开放


%%friend_help
-define(sg_friend_help_hp_has_send, 211).     %%体力已送出


%%talent
-define(sg_talent_layer_unlock, 212).     %%天赋未解锁
-define(sg_talent_server_error, 213).     %%服务器异常
-define(sg_talent_actived, 214).     %%天赋已激活
-define(sg_talent_actived_two, 215).     %%每层仅允许激活一个
-define(sg_talent_not_enough_frag, 216).     %%技能碎片不足
-define(sg_talent_max_level, 217).     %%达到最高等级
-define(sg_talent_emoney_not_enough, 218).     %%魔石不足
-define(sg_talent_unactived, 219).     %%天赋未激活
-define(sg_talent_actived_reseted, 220).     %%已经为重置状态，请勿重复重置
