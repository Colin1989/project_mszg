%%% @author linyibin
%%% @copyright (C) 2010, 
%%% @doc
%%% 程序中通用的类型定义
%%% @end
%%% Created : 19 Mar 2010 by  <>

%%----业务类型定义----
-define(item, 1).
-define(coin, 2).
-define(emoney, 3).
-define(friend_point, 4).
-define(point, 5).
-define(honour, 6).
-define(sculptures, 7).
-define(sculpture_frag, 8).
-define(summon_stone, 9).
-define(equipment_info, 10).
-define(power_hp, 11).
-define(exp, 12).

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

-define(st_reborn_base,100).
-define(st_reborn_common_game,101).
-define(st_reborn_push_tower,102).
-define(st_reborn_challenge,103).

-define(st_gm_cmd, 1000).
