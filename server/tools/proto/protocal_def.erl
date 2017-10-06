%% Author: NoteBook
%% Created: 2009-9-9
%% Description: 网络协议模块的定义
-module(protocal_def).


-export([get_struct_def/0, get_enum_def/0, get_version/0]).

%% 获得消息结构体的定义
get_struct_def() -> 
    [

     %%------------------------这两条置顶---------------------------
     [req_check_version,
      {int,version}
     ],
     [notify_check_version_result,
      {common_result,result}
     ],
     [req_login,                                          % 请求登录
      {string, account},                                  % 用户帐号
      {string, password}                                  % 用户密码
     ],
     [req_login_check,
      {string, uid},
      {string, token}
     ],
     [role_data,
      {uint64, role_id},
      {int, role_status},
      {int, type},
      {int, lev},
      {string, name},
      {int, is_del},
      {int, time_left}
     ],

     [notifu_login_check_result,
      {login_result, result},
      {int, error_code},
      {int, emoney},
      {array, role_data, role_infos}
     ],
     [notify_login_result,                                % 返回登录结果
      {uint64, id},
      {login_result, result},                                    % 登录结果
      {int, emoney},
      {array, role_data, role_infos}
     ],

     [notify_sys_msg,                                     % 发送系统消息给客户端
      {int, code},                                        % 系统消息代码, 参见sys_msg.hrl
      {array, string, params}                             % 参数
     ],


     [req_select_role,
      {uint64, role_id}
     ],
     [notify_select_role_result,
      {common_result, result}
     ],
     [req_delete_role,
      {uint64, role_id}
     ],
     [notify_delete_role_result,
      {common_result,result}
     ],
     [req_recover_del_role,
      {uint64, role_id}
     ],
     [notify_recover_del_role_result,
      {common_result, result}
     ],
     [req_reselect_role
     ],
     [notify_roles_infos,
      {int, emoney},
      {array, role_data, role_infos}
     ],
     [req_gm_optition,
      {gm_opt_type, opt_type},
      {int, value}
     ],
     %%------------------------公共数据---------------------------

     [player_data,                                        % 玩家基础数据
      {string, account},                                  % 用户帐号
      {string, username},                                 % 用户名称
      {int, sex}                                          % 性别
     ],

     [sculpture_data,
      {int, temp_id},
      {int, level}
     ],
     [stime,                                              % 时间
      {int, year},                                        % 年
      {int, month},                                       % 月
      {int, day},                                         % 日
      {int, hour},                                        % 时
      {int, minute},                                      % 分
      {int, second}                                       % 秒
     ],
     [mons_item, %%怪物掉落物品
      {int, id},    
      {int, amount}
     ],
     [reward_item, %%奖励物品
      {int, id},
      {int, amount}
     ],
     [smonster,
      {int ,pos},
      {int ,monsterid},
      {array,mons_item,dropout}
     ],
     [strap,
      {int,pos},
      {int,trapid}
     ],
     [saward,
      {int,pos},
      {int,awardid}
     ],
     [sfriend,
      {int,pos},
      {int,friend_role_id}
     ],
     [battle_info,
      {array, sculpture_data, sculpture},
      {int,life},
      {int,speed},
      {int,atk},
      {int,hit_ratio},
      {int,miss_ratio},
      {int,critical_ratio},
      {int,tenacity},
      {int,power}
     ],
     [talent,                           %% 天赋信息 {天赋ID,天赋等级}
      {int,talent_id},
      {int,level}
     ],
     [senemy,
      {uint64, role_id},
      {string,name},
      {int,pos},
      {int, level},
      {int,type},
      {int,potence_level},
      {int,advanced_level},
      {battle_info,battle_prop},        
      {array,talent,talent_list},        %% 根据角色ID  获得的天赋信息列表
      {int,team_tag},
      {int,id_leader},
      {int,cur_life},
      {int,mitigation}
     ],
     [game_map,
      {array, smonster, monster},
      {int, key},					           % 通知进入游戏
      {int, start},
      {array, saward, award},
      {array, strap, trap},
      {array, int, barrier},
      {array, sfriend,friend},
      {int, scene},
      {array, senemy, enemy},
      {array, smonster, boss},
      {int, boss_rule}
     ],

     [item,
      {uint64, inst_id},
      {int, temp_id}
     ],
     [pack_item,
      {uint64,id},           %%实例ID
      {int,itemid},          %%物品TempID
      {int,itemtype},        %%物品类型
      {int,amount}           %%物品数量
     ],

     [copy_info,
      {int,copy_id},         %%副本ID
      {int,max_score},       %%通关的星级
      {int,pass_times}       %%今天通关次数
     ],

     [equipmentinfo,
      {uint64,equipment_id},
      {int,temp_id},
      {int,strengthen_level},
      {array,int,gems},
      {array,int,attr_ids},
      {int,gem_extra},
      {bind_type, bindtype},
      {bind_status, bindstatus}
     ],
     [extra_item,
      {int,item_id},
      {int,count}
     ],



     [friend_data,
      {string,nickname},
      {role_status,status},
      {int,head},
      {int,level},
      {string,public},
      {battle_info,battle_prop},
      {int,potence_level},
      {int,advanced_level}
     ],

     [friend_info,
      {uint64, friend_id},
      {string, nickname},
      {int, status},
      {int, head},
      {int, level},
      {string, public},
      {battle_info, battle_prop},
      {int, potence_level},
      {int, advanced_level},
      {send_hp_status, my_send_status},
      {send_hp_status, friend_send_status},
      {int, is_comrade}
     ],

     [award_item,
      {int, temp_id},
      {int, amount}
     ],
     [challenge_info,
      {string, name},
      {game_result, result},
      {int, new_rank}
     ],

     [rank_info,
      {uint64,role_id},
      {string,name},
      {int,type},
      {int,rank},
      {int,level},
      {int,potence_level},
      {int,advanced_level},
      {int,power}
     ],
     [train_info,
      {uint64,role_id},
      {string,name},
      {int,type},
      {int,status},
      {int,level},
      {int,potence_level},
      {int,advanced_level},
      {int,power}
     ],
     [rank_data,
      {uint64, role_id},
      {string, name},
      {int, type},
      {int, rank},
      {int, value},
      {string, public}
     ],
     [donor,
      {uint64,role_id},
      {relation,rel},
      {int,level},
      {int,role_type},
      {string,nick_name},
      {int,friend_point},
      {int,power},
      {sculpture_data,sculpture},
      {int,potence_level},
      {int,advanced_level},
      {int,is_used},
      {int,is_robot}
     ]
    ,
     [mall_buy_info,
      {int,mallitem_id},
      {int,times}
     ],

     [lottery_item,
      {int, reward_id},
      {int, amount}
     ],
     [friend_point_lottery_item,
      {int,id},
      {int,amount}
     ],

     [activeness_task_item,
      {int, id},
      {int, count}
     ],
     [material_info,
      {int, material_id},
      {int, amount}
     ],
     [clean_up_trophy,
      {array, mons_item, item},    %%最终获得的物品
      {int, gold},
      {int, exp}
     ],
     [semail,
      {int, id},
      {uchar, type},
      {string, title},
      {string, content},
      {array, award_item, attachments},
      {stime, recv_time},
      {stime, end_time}
     ],
     [leave_msg,
      {uint64,role_id},
      {string,msg}
     ],
     [master_info,
      {uint64,role_id},
      {string, name},
      {int,type},
      {int,advanced_level},
      {int, battle_power},
      {int, level},
      {help_status, status}
     ],
     [prentice_info,
      {uint64,role_id},
      {string, name},
      {int,type},
      {int,advanced_level},
      {int, level},
      {array,int,rewarded_list},
      {help_status, status}
     ],
     [skill_group_item,
      {int,id1},
      {int,id2},
      {int,id3},
      {int,id4},
      {int,index}
     ],
     [notice_list_item,
      {int, id},
      {string, title},
      {string, sub_title},
      {int, icon},
      {int, mark_id},
      {stime, create_time},
      {int, priority},
      {int, top_pic},
	  {stime, start_time},
      {stime, end_time}
     ],
     [notice_item_detail,
      {int, id},
      {string, title},
      {string, sub_title},
      {int, icon},
      {string, content},
      {int, toward_id},
      {int, mark_id}
     ],
     [time_limit_rewarded_item,
      {int, id},
      {int, count},
      {stime, rewarded_time}
     ],
     [role_life_info,
      {uint64,role_id},
      {int,cur_life}
     ],
     [lottery_progress_item,
      {int, id},
      {int, cur_count}
     ],
     [activity_item,
      {int, id},
      {int, remain_seconds}
     ],

						%-----------------------具体业务---------------------------
     [notify_heartbeat,
      {int, version}],

     [notify_socket_close],


     [notify_repeat_login,                                % 通知客户端重复登陆
      {string, account}                                   % 用户帐号
     ],

     [req_register,											%注册
      {string,account},										%账号
      {int,channelid},	
      {int,platformid},										
      {string,password}

     ],
     [notify_register_result,									%登陆结果
      {register_result,result}
     ],

     [req_create_role,                                    % 请求创建角色
						% {player_data, basic_data}                     % 玩家信息
      {int,roletype},
      {string,nickname}
     ],

     [notify_create_role_result,                         % 返回角色创建结果
      {create_role_result,result}
     ],

     [notify_roleinfo_msg,
      {uint64,id},
      {string,nickname},
      {int, role_status},
      {int, roletype},
      {uint64, armor},                                     %角色信息
      {uint64,weapon},
      {uint64,ring},
      {uint64,necklace},
      {uint64,medal},
      {uint64,jewelry},
      {int,skill1},
      {int,skill2},
      {int,skill_group_index},
      {int,level},
      {int,exp},
      {int,gold},
      {int,emoney},
      {int,summon_stone},
      {int,power_hp},                %体力
      {int,recover_time_left},
      {int,power_hp_buy_times},
      {int,pack_space},
      {int,friend_point},
      {int,point},
      {int,honour},
      {int,battle_power},
      {int,alchemy_exp},
      {int,battle_soul},
      {int, potence_level},
      {int, advanced_level},
      {int, vip_level},
      {int, vip_exp}
     ],
     [req_clean_up_copy,
      {int,copy_id},
      {int,count}
     ],
     [notify_clean_up_copy_result,
      {common_result,result},%%游戏结果game_win|game_lost
      {array, clean_up_trophy, trophy_list}
     ],
     [req_enter_game,                                      % 请求进入游戏
      {uint64,id},
      {game_type,gametype},
      {int,copy_id}
     ],

     [notify_enter_game,
      {enter_game_result,result},
      {uint64,game_id},
      {array,game_map,gamemaps}					           % 通知进入游戏
     ],
     [notify_last_copy,
      {int,last_copy_id},                                 %返回可进行的最后一个副本ID
      {array,copy_info,copyinfos}
     ],
     [req_last_copy,
      {uint64,roleid}
     ],

     [req_buy_power_hp         %请求购买体力
     ],
     [notify_buy_power_hp_result,         %购买体力结果
      {common_result,result}
     ],

     [notify_power_hp_msg,      %返回当前体力
      {int,result},
      {int,power_hp}
     ],
     [notify_player_pack,
      {data_type,type},
      {array,pack_item,pack_items}
     ],
     [req_game_settle,
      {uint64,game_id},
      {game_result,result},%%游戏结果game_win|game_lost
      {int,life},
      {int,maxlife},
      {int, cost_round},%%消耗的回合数
      {array,mons_item,pickup_items},
      {array,int,user_operations},
      {int,gold},
      {array, int, killmonsters}
     ],
     [notify_game_settle,
      {uint64,game_id},
      {game_result,result},%%游戏结果game_win|game_lost
      {int,score},
      {lottery_item,final_item},    %%最终获得的物品
      {array,lottery_item,ratio_items}%%随机的物品列表
     ],
     [req_game_lottery],
     [notify_game_lottery,
      {lottery_item, second_item},
      {common_result,result}
     ],
     [req_game_reconnect,                                  
      {string, uid},                                  % 用户帐号
      {string, token},                                  % 用户密码
      {uint64, role_id},                                  %%角色Id
      {int, last_recv_stepnum}
     ],
     [notify_reconnect_result,                                % 返回登录结果
      {uint64, id},
      {reconnect_result, result},                                    % 登录结果
      {int, last_recv_stepnum}
     ],
     [req_equipment_strengthen,
      {uint64,equipment_id}
     ],
     [notify_equipment_strengthen_result,
      {common_result,strengthen_result},
      {int, gold}
     ],
     [req_one_touch_equipment_strengthen,
      {uint64,equipment_id}
     ],
     [notify_one_touch_equipment_strengthen_result,
      {array, notify_equipment_strengthen_result,result_list}
     ],
     [req_equipment_mountgem,
      {uint64,equipment_id},
      {uint64,gem_id}
     ],
     [notify_equipment_mountgem_result,
      {common_result,mountgem_result}
     ],
     [req_equipment_puton,
      {uint64,equipment_id}
     ],
     [notify_equipment_puton_result,
      {common_result,puton_result}
     ],
     [req_equipment_infos],
     [notify_equipment_infos,
      {data_type,type},
      {array,equipmentinfo,equipment_infos}
     ],
     [req_equipment_takeoff,
      {int,position}
     ],
     [notify_equipment_takeoff_result,
      {common_result,takeoff_result}
     ],
     [notify_gold_update,
      {int,gold}
     ],
     [notify_emoney_update,
      {int,emoney}
     ],
     [notify_summon_stone_info,
      {int,is_award},
      {int,has_buy_times}
     ],
     [req_daily_summon_stone],
     [notify_daily_summon_stone,
      {common_result,result}
     ],
     [req_buy_summon_stone],
     [notify_buy_summon_stone,
      {common_result,result}
     ],
     [notify_player_pack_exceeded,
      {array,extra_item,new_extra}
     ],
     [req_extend_pack],
     [notify_extend_pack_result,
      {common_result,result}
     ],
     [req_sale_item,
      {uint64,inst_id},
      {int,amount}
     ],
     [notify_sale_item_result,
      {common_result,result},
      {int,gold}
     ],
     [req_sale_items,
      {array,uint64,inst_id}
     ],
     [notify_sale_items_result,
      {common_result, result},
      {uint64, err_id},
      {int,gold}
     ],
     %%好友
     [req_search_friend,
      {string,nickname}
     ],
     [notify_search_friend_result,
      {common_result,result},
      {friend_info,role_info}
     ],
     [req_add_friend,
      {uint64,friend_id}
     ],
     [notify_add_friend_result,
      {common_result,result}
     ],
     [notify_req_for_add_friend,
      {uint64, friend_id},
      {friend_data, role_data}
     ],
     [req_proc_reqfor_add_friend,
      {answer_type,answer},
      {uint64,friend_id}
     ],
     [req_del_friend,
      {uint64,friend_id}
     ],
     [notify_del_friend_result,
      {common_result,result}
     ],
     [req_get_friends
     ],
     [notify_friend_list,
      {data_type,type},
      {array,friend_info,friends}
     ],
     [req_get_makefriend_reqs],
     [notify_makefriend_reqs,
      {array, friend_info, reqs}
     ],
     [notify_makefriend_reqs_amount,
      {int, amount}
     ],
     [notify_leave_msg_count,
      {int,count}
     ],
     [req_msg_list
     ],
     [notify_msg_list,
      {array,leave_msg,msg_list}
     ],
     [req_send_chat_msg,
      {uint64,friend_id},
      {string,chat_msg}
     ],
     [notify_send_chat_msg_result,
      {common_result,result}
     ],
     [notify_receive_chat_msg,
      {uint64,friend_id},
      {string,chat_msg}
     ],
     [req_push_tower_map_settle,
      {uint64,game_id},
      {map_settle_result,result},
      {int,cost_round},
      {int,life},
      {array,int,pickup_items},
      {int,drop_gold}
     ],
     [notify_push_tower_map_settle,
      {map_settle_result,result},
      {array, game_map, gamemap},
      {array, award_item, awards},
      {int, gold},
      {int, exp}
     ],
     [req_push_tower_buy_round
     ],
     [notify_push_tower_buy_round,
      {common_result,result}
     ],
     [req_push_tower_buy_playtimes],
     [notify_push_tower_buy_playtimes,
      {common_result,result}
     ],
     [req_reborn,
      {game_type,type}
     ],
     [notify_reborn_result,
      {common_result,result}
     ],
     [req_auto_fight],
     [notify_auto_fight_result,
      {common_result,result}
     ],
     [req_gem_compound,
      {int,temp_id},
      {int,is_protect}
     ],
     [notify_gem_compound_result,
      {common_result,result},
      {int,lost_gem_amount}
     ],
     [req_one_touch_gem_compound,
      {int,temp_id},
      {int,is_protect}
     ],
     [notify_one_touch_gem_compound_result,
      {array, notify_gem_compound_result, result_list}
     ],
     [req_gem_unmounted,
      {uint64,equipment_id},
      {int,gem_temp_id}
     ],
     [notify_gem_unmounted_result,
      {common_result,result}
     ],
     [req_push_tower_info],
     [notify_push_tower_info,
      {int, play_times},
      {int, max_times},
      {int, max_floor}
     ],	 
     [req_tutorial_progress],
     [notify_tutorial_progress,
      {array, int, progress}
     ],
     [req_set_tutorial_progress,
      {int,progress}
     ],
     [notify_set_tutorial_progress_result,
      {common_result,result}
     ],
     [notify_today_activeness_task,
      {array,activeness_task_item,task_list},
      {array, int, is_reward_activeness_item_info},
      {int,activeness}
     ],
     [req_today_activeness_task],
     %% [notify_update_activeness,
     %%  {int,activeness}
     %% ],
     [req_activeness_reward,
      {int,reward}
     ],
     [notify_activeness_reward_result,
      {int,reward},
      {common_result,result}
     ],
     [req_military_rank_reward
     ],
     [notify_military_rank_reward_result,
      {common_result,result}
     ],
     [req_military_rank_info
     ],
     [notify_military_rank_info,
      {int,level},
      {int,is_rewarded}
     ],
     [notify_first_charge_info,
      {first_charge_status,status}
     ],
     [req_first_charge_reward
     ],
     [notify_first_charge_reward_result,
      {common_result,result}
     ],
     [notify_vip_reward_info,
      {array, int, level_rewarded_list},
      {int, daily_rewarded}
     ],
     [req_vip_grade_reward,
      {int, level}
     ],
     [notify_vip_grade_reward_result,
      {common_result,result}
     ],
     [req_vip_daily_reward,
      {common_result,result}
     ],
     [notify_vip_daily_reward_result,
      {common_result,result}
     ],
     [req_recharge,
      {int,user_id},
      {int,emoney},
      {int,org_emoney},
      {int,vip_exp}
     ],
     [notify_recharge_result,
      {common_result,result}
     ],
						%-----------------------任务---------------------------
     [task_info,         % 任务信息
      {int, task_id},    % 任务xml id, 根据这个id可以知道任务类型
      {int, has_finished},  % 是否已完成 0 未完成 1 完成 (目前客户端这个字段没用，都是0未完成)
      {array, int, args}  
      %% args 参数列表用于表示各种复杂任务条件的完成情况            
      %%   任务类型=1击杀怪物时,args表示: 击杀怪物数量
      %%   任务类型=2通关副本时,args表示: 通关次数
      %%   任务类型=3收集物品时,args目前没值: 因为收集物品背包可以找到 
     ],

     [req_task_infos %% 请求完成任务 
     ],

     [notify_task_infos, 
      {data_type, type},      % 参考data_type: ?init 表示首次 ?append 表示添加 ？delete... 
      {array, task_info, infos}
     ],

     [req_finish_task,%% 请求完成任务 
      {int, task_id}  % 任务xml id
     ],

     [notify_finish_task,%% 通知任务完成
      {common_result, is_success},      % 1表示common_success 成功, 其他值表示失败
      {int, task_id}  % 任务xml id
     ],

						%-----------------------符文相关---------------------------
     [sculpture_info,
      {int,temp_id},  % xml id, 需要等级级在xml中取
      {int,value},      % 当前等级
      {int,type}       % 当前经验
     ],
     [req_sculpture_infos   % 请求符文实例信息
     ],
     [notify_sculpture_infos, % 通知符文实例信息
      {data_type, type},      % 参考data_type: ?init 表示首次 ?append 表示添加 ... 
      {array, sculpture_info, sculpture_infos}
     ],
     [req_sculpture_puton,  % 符文装备 （成功后会发背包更新消息给客户端）
      {int,group_index},
      {int, position},      % 符文位置(1, 2, 3, 4) 
      {int, temp_id}        % 符文实例id
     ],
     [notify_sculpture_puton, % 成功后通知符文装上 客户端做动画表现或消息提示,并将该位置设为符文实例id
      {common_result, is_success},      % 1表示common_success 成功, 其他值表示失败
      {int,group_index},
      {int, position},      % 符文位置(1, 2, 3, 4)
      {int, temp_id}        % 符文实例id
     ],
     [req_sculpture_takeoff,  % 符文脱下 （成功后会发背包更新消息给客户端）
      {int,group_index},
      {int, position}         % 符文位置 (1, 2, 3, 4)
     ],
     [notify_sculpture_takeoff, % 成功后通知符文脱下 客户端做动画表现或消息提示,并将该位置设为0
      {common_result, is_success},      %  1表示common_success 成功, 其他值表示失败
      {int,group_index},
      {int, position}           % 符文位置 (1, 2, 3, 4)
     ],
     [req_change_skill_group,
      {int, group_index}
     ],
     [notify_change_skill_group,
      {common_result, result},
      {int, activate_group}
     ],
     [req_sculpture_upgrade,  % 符文升级
      {int, temp_id}         % 主符文id
     ],
     [notify_sculpture_upgrade,  % 成功后通知符文升级 客户端做动画表现或消息提示
      {common_result, result}      % 1表示common_success 成功, 其他值表示失败
     ],
     [req_sculpture_advnace,  % 符文升阶
      {int, temp_id}         % 主符文id
     ],
     [notify_sculpture_advnace,
      {common_result, result},
      {int, new_temp_id}
     ],
     [req_sculpture_unlock,  % 符文解锁
      {int, temp_id}         % 主符文id
     ],
     [notify_sculpture_unlock,
      {common_result, result},
      {int,temp_id}
     ],
     [req_sculpture_divine,  % 符文占卜
      {divine_type, type}    % 占卜类型
     ],
     [notify_sculpture_divine,  % 成功后通知符文占卜结果 客户端做动画表现或消息提示
      {common_result, result},      % 1表示common_success 成功, 其他值表示失败
      {array,reward_item,reward_list},
      {divine_type, type}
     ],
     [notify_divine_info,
      {int, count},
      {int, common_remain_time},
      {int, rare_remain_time}
     ],
     [notify_skill_groups_info,
      {array, skill_group_item, groups}
     ],
     %%进行挑战
     [req_challenge_other_player,
      {uint64,role_id}
     ],
     [notify_challenge_other_player_result,
      {uint64,game_id},
      {common_result,result},
      {array,game_map,map}
     ],
     [req_challenge_settle,
      {uint64,game_id},
      {game_result,result}
     ],
     [notify_challenge_settle,
      {game_result,result},
      {int,point},
      {int,coins}
     ],
     %%进行通知新被挑战次数
     [notify_be_challenged_times,
      {int,times}
     ],
     %%获取被挑战信息
     [req_get_be_challenged_info
     ],
     [notify_challenge_info_list,
      {array,challenge_info,infos}
     ],
     %%获取排行榜信息
     [req_get_challenge_rank
     ],
     [notify_challenge_rank_list,
      {array,rank_info,infos}
     ],
     %%获取挑战列表
     [req_get_can_challenge_role],
     [notify_can_challenge_lists,
      {array,rank_info,infos}
     ],
     [req_buy_challenge_times],
     [notify_buy_challenge_times_result,
      {common_result,result}
     ],
     [req_get_challenge_times_info],
     [notify_challenge_times_info,
      {int,buy_times},
      {int,org_times},
      {int,play_times},
      {int, award_timeleft}
     ],
     [req_assistance_list
     ],
     [notify_assistance_list,
      {array,donor,donors}
     ],
     [req_select_donor,
      {uint64,donor_id}
     ],
     [notify_select_donor_result,
      {common_result,result}
     ],
     [req_refresh_assistance_list
     ],
     [notify_refresh_assistance_list_result,
      {common_result,result}
     ],
     [req_fresh_lottery_list
     ],
     [notify_fresh_lottery_list,
      {array,friend_point_lottery_item, lottery_items}
     ],
     [req_friend_point_lottery
     ],
     [notify_friend_point_lottery_result,
      {common_result,result},
      {int,id},
      {int,amount}
     ],
     [notify_assistance_info,
      {int,lottery_times},
      {int,refresh_times}
     ],
     [notify_role_info_change,
      {string,type},
      {int,new_value}
     ],
     [req_buy_mall_item,
      {int, mallitem_id},
      {int, buy_times}
     ],
     [notify_buy_mall_item_result,
      {common_result,result}
     ],
     [req_has_buy_times],
     [notify_has_buy_times,
      {array, mall_buy_info, buy_info_list}
     ],
     [notify_add_friend_defuse_msg,
      {uint64, role_id}
     ],
     [req_get_challenge_rank_award
     ],
     [notify_get_challenge_rank_award_result,
      {common_result, result}
     ],
     [req_buy_point_mall_item,
      {int,mallitem_id},
      {int, buy_times}
     ],
     [notify_buy_point_mall_item_result,
      {common_result, result}
     ],
     [nofity_continue_login_award_info,
      {int, continue_login_days},
      {int, daily_award_status},
      {int, cumulative_award3_status},
      {int, cumulative_award7_status},
      {int, cumulative_award15_status}
     ],
     [req_get_daily_award,
      {award_type, type}
     ],
     [notify_get_daily_award_result,
      {award_type, type},
      {common_result, result}
     ],
     [notify_sys_time,
      {stime, sys_time}
     ],
     [req_get_rank_infos,
      {rank_type, type}
     ],
     [notify_rank_infos,
      {rank_type, type},
      {int, myrank},
      {array, rank_data, top_hundred}
     ],
     [req_train_match_list,
      {int, list_type}
     ],
     [notify_train_match_list,
      {array, train_info, match_list}
     ],
     [req_start_train_match,
      {uint64, role_id}
     ],
     [notify_start_train_match_result,
      {uint64,game_id},
      {common_result,result},
      {array,game_map,map}
     ],
     [req_train_match_settle,
      {uint64,game_id},
      {game_result,result}
     ],
     [notify_train_match_settle,
      {game_result,result},
      {int,point},
      {int,honour}
     ],
     [req_get_train_match_times_info],
     [notify_train_match_times_info,
      {int,buy_times},
      {int,org_times},
      {int,play_times},
      {int, success_times},
      {int, award_status},
      {int, refresh_times}
     ],
     [req_buy_train_match_times],
     [notify_buy_train_match_times_result,
      {common_result,result}
     ],
     [req_get_train_award,
      {train_award_type,type}
     ],
     [notify_get_train_award_type,
      {common_result, result},
      {int, new_status},
      {int, award_id},
      {int, amount}
     ],
     [req_use_props,
      {uint64, inst_id}
     ],
     [notify_use_props_result,
      {common_result, result},
      {int, reward_id}
     ],
     [req_benison_list
     ],
     [notify_benison_list,
      {array, int, benison_list},
      {array, int, benison_status}
     ],
     [req_bless,
      {int, benison_id}
     ],
     [notify_bless_result,
      {common_result, result}
     ],
     [notify_role_bless_buff,
      {int, benison_id},
      {array, int, buffs},
      {int, time_left}
     ],
     [req_refresh_benison_list],
     [notify_refresh_benison_list_result,
      {common_result, result}
     ],
     [req_equipment_advance,
      {uint64, inst_id}
     ],
     [notify_equipment_advance_result,
      {common_result, result}
     ],
     [req_equipment_exchange,
      {uint64, inst_id}
     ],
     [notify_equipment_exchange_result,
      {common_result, result}
     ],
     [req_equipment_resolve,
      {array, uint64, inst_id}
     ],
     [notify_equipment_resolve_result,
      {common_result, result},
      {uint64, errid},
      {array, material_info, infos}
     ],
     [req_equipment_recast,
      {uint64, inst_id}
     ],
     [notify_equipment_recast_result,
      {common_result, result},
      {equipmentinfo, new_info}
     ],
     [req_save_recast_info,
      {uint64, equipment_id}
     ],
     [notify_save_recast_info_result,
      {common_result, result}
     ],
     [notify_upgrade_task_rewarded_list,
      {array, int, reward_ids}
     ],
     [req_upgrade_task_reward,
      {int, task_id}
     ],
     [notify_upgrade_task_reward_result,
      {int, task_id},
      {common_result, result}
     ],
     [ladder_role_info,
      {uint64, role_id},
      {int, data_type},
      {int, curHp},
      {string, nickname},
      {int, battle_power},
      {int, type},
      {int, level},
      {battle_info,battle_prop},
      {int, potence_level},
      {int, advanced_level},
      {array,talent,talent_list}        %% 根据角色ID  获得的天赋信息列表
     ],
     [req_ladder_role_list
     ],
     [notify_ladder_role_list,
      {array,ladder_role_info, teammate},
      {array,ladder_role_info, opponent}
     ],
     [req_ladder_teammate
     ],
     [notify_req_ladder_teammate_result,
      {ladder_role_info, teammate_info},
      {common_result,result}
     ],
     [req_reselect_ladder_teammate,
      {uint64, role_id}
     ],
     [notify_reselect_ladder_teammate_result,
      {ladder_role_info, teammate_info}
     ],
     [req_ladder_match_info
     ],
     [notify_ladder_match_info,
      {int, pass_level},
      {int, cur_life},
      {int, is_failed},
      {int, recover_count},
      {int, reset_count}
     ],
     [req_ladder_match_battle
     ],
     [notify_ladder_match_battle_result,
      {common_result, result},
      {array, game_map, map},
      {uint64, game_id}
     ],
     [req_settle_ladder_match,
      {uint64, game_id},
      {array, role_life_info, life_info},
      {game_result, result}
     ],
     [notify_settle_ladder_match,
      {game_result, result},
      {array,int, reward_ids},
      {array,int, reward_amounts}
     ],
     [req_reset_ladder_match
     ],
     [notify_reset_ladder_match_result,
      {common_result, result}
     ],
     [req_recover_teammate_life
     ],
     [notify_recover_teammate_life_result,
      {common_result, result}
     ],
     [notify_online_award_info,
      {int, total_online_time},
      {array, int, has_get_awards}
     ],
     [req_get_online_award,
      {int, online_award_id}
     ],
     [notify_get_online_award_result,
      {common_result, result}
     ],
     [req_alchemy_info],
     [notify_alchemy_info,
      {int, nomrmal_count},
      {int, remain_normal_second},
      {int, advanced_count},
      {int, level},
      {array, int, rewarded_list}
     ],
     [req_metallurgy,
      {int, type}
     ],
     [notify_metallurgy_reuslt,
      {common_result, result}
     ],
     [req_alchemy_reward,
      {int, type}
     ],
     [notify_alchemy_reward_reuslt,
      {common_result, result}
     ],
     [req_potence_advance,
      {int, is_use_amulet}
     ],
     [notify_potence_advance_result,
      {common_result, result},
      {int, potence_level},
      {int, advanced_level}
     ],
     [req_exchange_item,
      {int, exchange_id}
     ],
     [notify_exchange_item_result,
      {common_result, result}
     ],
     [req_has_buy_discount_item_times],
     [notify_has_buy_discount_item_times,
      {array, mall_buy_info, buy_info_list}
     ],
     [req_buy_discount_limit_item,
      {int, id}
     ],
     [notify_buy_discount_limit_item_result,
      {common_result, result},
      {int, mall_item_id}
     ],
     [req_convert_cdkey,
      {int,award_id}
     ],
     [notify_redeem_cdoe_result,
      {array, award_item, awards}
     ],
     [notify_email_list,
      {array, semail, emails}
     ],
     [notify_email_add,
      {semail, new_email}
     ],
     [req_get_email_attachments,
      {int, email_id}
     ],
     [notify_get_email_attachments_result,
      {common_result, result}
     ],
     [req_buy_mooncard,
      {int, type},
      {int, reward_emoney}
     ],
     %% [notify_buy_mooncard_result,
     %%  {common_result,result}
     %% ],
     [notify_mooncard_info,
      {int, award_status},
      {int, days_remain}
     ],
     [req_get_mooncard_daily_award

     ],
     [notify_get_mooncard_daily_award_result,
      {common_result, result}
     ],
     [req_enter_activity_copy,
      {int, copy_id}
     ],
     [notify_enter_activity_result,
      {enter_game_result,result},
      {uint64,game_id},
      {array,game_map,gamemaps}					           % 通知进入游戏
     ],
     [req_settle_activity_copy,
      {uint64,game_id},
      {game_result,result},%%游戏结果game_win|game_lost
      {array,mons_item,pickup_items},
      {int,gold}
     ],
     [notify_settle_activity_copy_result,
      {game_result,result}%%游戏结果game_win|game_lost
     ],
     [notify_activity_copy_info,
      {int, play_times}
     ],
    [req_verify_invite_code,
      {string, code}
    ],
    [notify_verify_invite_code_result,
      {common_result, result}
    ],
     [req_input_invite_code,
      {string, code}
     ],
     [notify_input_invite_code_result,
      {common_result, result},
      {master_info,master}
     ],
     [req_disengage_check,
      {int, type},
      {uint64, role_id}
     ],
     [notify_disengage_check_result,
      {common_result, result},
      {uint64, role_id},
      {int, type}
     ],
     [req_disengage,
      {int, type},
      {uint64, role_id}
     ],
     [notify_disengage_result,
      {common_result, result},
      {uint64, role_id},
      {int, type}
     ],
     [notify_lost_prentice,
      {uint64, role_id}
     ],
     [notify_lost_master,
      {uint64, role_id}
     ],
     [req_master_level_reward,
      {uint64, prentice_id},
      {int, level}
     ],
     [notify_master_level_reward_result,
      {common_result, result},
	  {uint64, prentice_id},
	  {int, level}
     ],
     [req_prentice_level_reward,
      {int, level}
     ],
     [notify_prentice_level_reward_result,
      {common_result, result},
      {int, level}
     ],
     [req_master_help,
      {int, level}
     ],
     [notify_master_help_result,
      {common_result, result}
     ],
     [req_give_help,
      {uint64, prentice_id}
     ],
     [notify_give_help_result,
      {common_result, result}
     ],
     [req_get_help_reward,
      {int, level}
     ],
     [notify_get_help_reward_result,
      {common_result, result},
      {int, level}
     ],
     [notify_req_help_from_prentice,
      {uint64, prentice_id}
     ],
     [notify_give_help_from_master,
      {uint64, master_id}
     ],
     [notify_invite_code_info,
      {master_info, master},
      {array, prentice_info, prentice_list},
      {string, code},
      {int, is_new_prentice_got},
      {array,int,rewarded_list}
     ],
     [req_send_hp,
      {uint64, friend_id}
     ],
     [notify_send_hp_result,
      {common_result, result},
	  {uint64, friend_id}
     ],
     [notify_get_hp_help_from_friend,
      {uint64, friend_id}
     ],
     [req_reward_hp_from_friend,
      {uint64, friend_id}
     ],
     [notify_reward_hp_from_friend_result,
      {common_result, result},
      {uint64, friend_id}
     ],
     [notify_boss_copy_fight_count,
      {int, count}
     ],
     [req_chat_in_world_channel,
      {string, msg}
     ],
     [notify_chat_in_world_channel_result,
      {common_result, result}
     ],
     [notify_world_channel_msg,
      {uint64, speaker_id},
      {string, speaker},
      {string, msg}
     ],
     [notify_my_world_chat_info,
      {int, speek_times},
      {int, extra_times}
     ],
     [req_get_role_detail_info,
      {uint64, role_id}
     ],
     [notify_role_detail_info_result,
      {uint64, role_id}, 
      {string, nickname}, 
      {int, status}, 
      {int, level}, 
      {int, type}, 
      {string, public}, 
      {int, potence_level}, 
      {int, advanced_level},
      {array, sculpture_data, sculptures}, 
      {array, equipmentinfo, equipments}, 
      {int, battle_power},
      {int, military_lev},
      {int, challenge_rank}
     ],
%%-------------------------英雄天赋业务------------------------------%%
     [notify_get_talent_active_info,                 
      {array,int,active_talent_ids},      %%已激活天赋id列表
      {int,reset_active_hours}            %%重置激活剩余时间
     ],
     [req_actived_talent,                 %%激活天赋
      {int,talent_id}
     ],
     [notify_actived_talent,
      {common_result,is_success},
      {int,talent_id}
     ],
     [req_reset_talent],                  %%重置天赋
     [notify_reset_talent,
      {common_result,is_success}
     ],
     [req_level_up_talent,                %%升级天赋
      {int,talent_id}
     ],
     [notify_level_up_talent,
      {common_result,is_success}
     ],
     [req_notice_list
     ],
     [notify_notice_list,
      {array, notice_list_item, list}
     ],
     [notify_notice_item_add,
      {notice_list_item, item_info}
     ],
     [notify_notice_item_del,
      {int, del_id}
     ],
     [req_notice_item_detail,                %%请求公告内容详情
      {int, id}
     ],
     [notify_notice_item_detail,
      {common_result, result},
      {notice_item_detail, item_info}
     ],
     [req_time_limit_reward,                %% 请求获取显示奖励
      {int, id}
     ],
     [notify_time_limit_reward,
      {common_result, result}
     ],
     [notify_time_limit_rewarded_list,
      {array, time_limit_rewarded_item, list}
     ],
     [notify_activity_list,
      {array, activity_item, list}
     ],
     [notify_act_lottery_info,
      {int, remain_count},
      {array, lottery_progress_item, progress_list}
     ],
     [req_act_lottery],
     [notify_act_lottery_result,
      {common_result,result},
      {int, reward_id}
     ],
     [notify_act_recharge_info,
      {int, cur_recharge_count},
      {array,int, rewarded_list}
     ],
     [req_act_recharge_reward,                %% 请求获取显示奖励
      {int, id}
     ],
     [notify_act_recharge_reward_result,
      {common_result, result},
      {int,id}
     ],
     [req_emoney_2_gold,     %% 魔石转换成金币
      {int, emoney}
     ],
     [notify_emoney_2_gold_result,
      {common_result, result}
     ]
    ].

					% 获得枚举类型的定义
get_enum_def() ->
    [{sex_type, [boy, girl]},
     {game_type,[common,push_tower,game_challenge,copy_clean_up, activity_copy]},
     {user_operation,[opt_open,opt_atk_monster,opt_pickup_item,opt_use_skill,opt_use_item,opt_pass]},
     {game_result,[game_win,game_lost,game_error]},
     {register_result,[register_success,register_failed]},
     {login_result,[login_success,login_noregister,login_passworderror,login_norole,login_versionerror, login_status_err]},
     {reconnect_result,[reconnect_success,reconnect_noregister,reconnect_passworderror,reconnect_versionerror]},
     {create_role_result,[create_role_success,create_role_failed,create_role_nologin,create_role_typeerror,create_role_nameexisted]},
     {enter_game_result,[enter_game_success,enter_game_failed,enter_game_unlogin]},
     {common_result,[common_success,common_failed,common_error]},
     {equipment_type,[weapon,armor,necklace,ring,jewelry,medal]},
     {item_type,[equipment,sculpture,gem,varia,props, material, rand_props]},
     {quality_type,[white,green,blue,purple,orange,red]},
     {data_type,[init,append,delete,modify]},
     {role_status,[online,offline]},
     {answer_type,[agree,defuse]},
     {map_settle_result,[map_settle_next_map,map_settle_finish,map_settle_died,map_settle_error]},
     {relation,[friend,other]},
     {price_type,[price_type_gold,price_type_emoney]},
     {mall_item_state,[on_sale,not_on_sale]},
     {award_type,[daily_award,cumulative_award3,cumulative_award7,cumulative_award15]},
     {ladder_award_type, [ladder_daily_award, ladder_weekiy_award]},
     {bind_type, [bind_never, bind_default, bind_puton]},
     {bind_status, [bind, not_bind]},
     {lottery_type, [lottery_item, lottery_gold, lottery_exp]},
     {rank_type, [battle_power_rank, role_level_rank]},
     {train_award_type, [blue_award, purple_award, orange_award, red_award]},
     {sculpture_item_type, [item_sculpture, item_talent, item_frag, item_expsculp]},
     {gm_opt_type, [gm_opt_exp, gm_opt_gold, gm_opt_emoney, gm_opt_summon_stone, gm_opt_point, gm_opt_honour, gm_opt_item, gm_opt_sculpture, gm_opt_frag,
		    gm_opt_recharge,gm_opt_battle_soul,gm_opt_friend_point,gm_opt_pass_copy,gm_opt_ladder_match_point, gm_opt_vip_exp]},
     {first_charge_status, [not_charge, charget_not_rewarded, rewarded]},
     {help_status, [help_none, help_req, help_doing, help_got]},
     {send_hp_status, [send_hp_none, send_hp_done, send_hp_got]},
     {divine_type, [divine_common_once, divine_common_ten, divine_rare_once, divine_rare_ten]},
     {skill_group_status,[skill_group_activate, skill_group_unactivate]}
    ].

						% 设置版本信息
get_version() -> 
    90.

