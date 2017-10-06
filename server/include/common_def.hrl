%%% @author linyibin
%%% @copyright (C) 2010, 
%%% @doc
%%% 程序中通用的类型定义
%%% @end
%%% Created : 19 Mar 2010 by  <>

%%----业务类型定义----
-define(item, 1).           %% 物品
-define(coin, 2).           %% 金币
-define(emoney, 3).         %% 魔石
-define(friend_point, 4).   %% 友情点
-define(point, 5).          %% 积分
-define(honour, 6).         %% 荣誉值
-define(sculptures, 7).     %% 技能 天赋
-define(sculpture_frag, 8). %% 技能碎片
-define(summon_stone, 9).   %% 召唤石
-define(equipment_info, 10).%% 装备信息（强化，兑换，重铸）
-define(power_hp, 11).      %% 体力
-define(exp, 12).           %% 经验
-define(ladder_point, 13).  %% 分组赛积分
-define(battle_soul, 14).   %% 战魂值
-define(vip_exp, 15).           %% vip经验值

%%----子业务类型定义----
-define(st_register, 1).
-define(st_equip_strengthen,2).
-define(st_game_settle,3).
-define(st_power_hp,4).
-define(st_pack_extend,5).
-define(st_pack_sale,6).

-define(st_test,7).

-define(st_equip_puton,8).
-define(st_equip_takeoff,9).

-define(st_push_tower_settle,10).
-define(st_push_tower_buy_round,11).
-define(st_push_tower_buy_playtimes,12).

-define(st_equip_mounted,13).
-define(st_gem_compound,14).
-define(st_gem_compound_failed,15).
-define(st_gem_unmounted,16).
-define(st_sculpture_puton,17).
-define(st_sculpture_takeoff,18).
-define(st_sculpture_convert,19).
-define(st_sculpture_divine,20).
-define(st_sculpture_upgrade,21).
-define(st_buy_challenge_times,22).
-define(st_task_reward,23).
-define(st_mall_buy,24).
-define(st_get_rank_award,25).
-define(st_challenge_settle, 26).

-define(st_honour_deduct, 27).
-define(st_point_mall_buy,28).
-define(st_recover_del_role,29).
-define(st_daily_award,30).
-define(st_create_role, 31).
-define(st_sale_sculpture, 32).

-define(st_boss_copy, 33).

-define(st_activeness_task, 34).

-define(st_buy_train_times, 35).
-define(st_train_refresh_list, 36).
-define(st_train_match_award, 37).
-define(st_train_match_settle, 38).
-define(st_use_prop, 39).
-define(st_refresh_benison_list, 40).
-define(st_equipment_advance, 41).
-define(st_equipment_recast, 42).
-define(st_equipment_resolve, 43).
-define(st_bless, 44). %%激活祝福
-define(st_tutorial, 45). %%新手

-define(st_military_rank, 46). %%军衔奖励


-define(st_ladder_against_win, 47). %%天梯胜利
-define(st_ladder_against_lost, 48). %%天梯失败
-define(st_ladder_daiay_award, 49). %%天梯日常奖励
-define(st_ladder_weekiy_award, 50). %%天梯周奖励
-define(st_buy_ladder_against_times, 51). %% 购买天梯比赛次数



-define(st_assistance, 52). %% 援军相关

-define(st_equipment_exchange, 53). %% 装备转化

-define(st_alchemy, 54). %% 炼金术

-define(st_role_advance, 55). %% 角色进阶


-define(st_online_award, 56). %%在线奖励
-define(st_recharge, 57). %%充值
-define(st_exchange_item, 58). %%兑换物品
-define(st_discount_mall_buy, 59). %% 打折物品购买

-define(st_auto_fight, 60). %% 自动战斗

-define(st_first_charge, 61). %% 首充奖励

-define(st_vip, 62). %% vip奖励

-define(st_summon_stone_daily_award, 63). %% 每日召唤石领取

-define(st_redeem_code_award, 64). %% 兑换码奖励
-define(st_email_attachment, 65). %%邮件附件

-define(st_summon_stone_buy, 66). %% 召唤石购买

-define(st_mooncard_daily_card, 67). %%月卡日奖励


-define(st_invitation_help, 68). %%每日帮助奖励
-define(st_invitation_bind, 69). %%帮助绑定奖励
-define(st_invitation_level, 70). %%帮助等级奖励
-define(st_activity_copy_settle, 71). %%活动副本结算

-define(st_send_hp_from_friend, 72). %% 好友送体力
-define(st_world_chat, 73).  %%世界聊天
-define(st_mooncard_buy_reward, 74).  %%月卡购买返利

-define(st_sculpture_advance,75). %%技能进阶
-define(st_sculpture_unlock,76). %%技能解锁

-define(st_role_upgrade,77). %%角色升级

-define(st_time_limit_reward,78). %% 限时奖励

-define(st_ladder_role_reselect,79). %% 角色重选
-define(st_ladder_role_recover_life,80). %% 恢复分组赛成员生命
-define(st_ladder_match_reset,81). %% 重置分组赛


-define(st_act_lottery,82). %% 活动摇奖奖励
-define(st_act_recharge_reward,83). %% 充值奖励

-define(st_emoney_2_gold,84). %% 魔石兑换成金币

-define(st_medal_exchange,85). %% 勋章补偿

-define(st_reborn_base,100).
-define(st_reborn_common_game,101).
-define(st_reborn_push_tower,102).
-define(st_reborn_challenge,103).

-define(st_gm_cmd, 1000).
-define(st_unlock_talent,201).    %% 解锁天赋
-define(st_actived_talent,202).    %% 激活天赋
