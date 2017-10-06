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
-define(tplt_list,(
	  [
	   {role_tplt,
	    [{int,id},    %角色类型ID
	     {string,name},%角色名称
	     {int,armor},%初始护甲
	     {int,weapon},%初始武器
	     {int,skill1},%技能1
	     {int,skill2}, %技能2
	     {string,describe},%角色说明
	     {int,default_sculpture},
	     {list_int,init_sculpture},
	     {list_int,divine_list}, %占卜的符文队列，用于新手引导
		 {int,icon}
	    ]},
	   {copy_group_tplt,
	    [
	     {int,id},    %副本群ID
	     {int,type},    %副本群类型
	     {string,name},   %副本群名字
	     {int,next_group_id},   %下个副本群ID
	     {string,icon},         %图片名字
	     {int,first_copy_id},    %%第一个副本ID
	     {int,last_copy_id}
	    ]
	   },
	   {copy_tplt,
	    [
	     {int,id},              %副本ID
	     {int,type},				%副本类型 	
	     {string,name},         %副本名字
	     {int,copy_group_id},   %所属副本群id
	     {int,need_power},      %所需体力消耗
	     {int,win_need_power},  %胜利体力消耗
	     {int,gold},            %金币奖励
	     {int,exp},             %经验奖励
	     {int,award},           %奖励物品ID
	     {string,describe},     %副本描述
	     {int,first_map_id},    %副本第一层地图ID
	     {list_int,pre_copy},        %前置副本
	     {int,need_stone},     	%所需（召唤）石
	     {list_int,dropitems},   %掉落的物品列表供客户端表现 
	     {string, small_icon},
	     {int, recommended_battle_power}, %推荐战斗力
	     {list_int, new_monsters},
	     {int, need_level},
	     {list_int, dialog_groupid},
	     {int, min_life_percent},
	     {int, min_cost_round},
	     {list_int, clean_up_reward_ids},
	     {list_int, clean_up_reward_amounts}
	    ]
	   },
	   {activity_copy_tplt,
	    [
	     {int,id},              %副本ID	
	     {string,name},         %副本名字
	     {int,copy_group_id},   %所属副本群id
	     {int,need_power},      %所需体力消耗
	     {int,gold},            %金币奖励
	     {int,exp},             %经验奖励
	     {string,describe},     %副本描述
	     {int,first_map_id},    %副本第一层地图ID
	     {list_int,dropitems},   %掉落的物品列表供客户端表现 
	     {string, small_icon},
	     {int, recommended_battle_power}, %推荐战斗力
	     {int, need_level}
	    ]
	   },
	   {activities_tplt,
	    [
	     {int, id}, %%ID
	     {string, icon}, %%图片
	     {int, time_type},
	     {string, describe},
	     {list_tuple, begin_time_array}, %%开始时间
	     {list_tuple, end_time_array}    %%结束时间
	    ]
	   },
	   {game_map_tplt,
	    [
	     {int,id},              %地图ID
	     {string,name},         %地图名称
	     {int,copy_id},         %副本ID
	     {int,room},            %副本背景ID
	     {list_int,monster},    %怪物ID
	     {list_int,trap},       %陷阱ID
	     {list_int,buff},       %奖励ID
	     {list_int,friend_role},%友方阵营
	     {int,barries_amount},  %障碍数量
	     {int,map_rule_id},     %指定规则
	     {int,next_map},         %下一层地图
	     {list_int,key_monster} %门将列表
	    ]
	   },
	   {friend_role,
	    [{int,id},                  %%ID
	     {int,skill},               %%技能ID
	     {string,icon}              %%图片
	    ]
	   },
	   {game_map_rule_tplt,
	    [
	     {int,id},              %规则ID
	     {list_int,monster},    %怪物ID
	     {list_int,monster_pos},%怪物ID
	     {int,door},            %奖励ID,
	     {list_tuple, awards},  %奖励
	     {list_int,barries_pos}, %障碍位置
	     {int, boss_amount},
	     {list_tuple, boss},
	     {list_int,  boss_rule}     %指定boss怪的回合对应规则
	    ]
	   },
	   {monster_tplt,
	    [
	     {int, id},              %怪物ID
	     {string, name},         %怪物名称
	     {string, icon},         %图片ID
	     {int, level},           %怪物等级
	     {int, description_id}, % 怪物描述ID
	     {int, type},            %怪物类型
	     {int, attack_type},     %怪物攻击类型
	     {list_int, relative_id},%关联ID 
	     {int, life},	    %生命
	     {int, atk},             %攻击
	     {int, speed},           %速度
	     {int, hit_ratio},       %命中
	     {int, critical_ratio},  %暴击
	     {int, miss_ratio},      %闪避
	     {int, tenacity},        %韧性
	     {list_int, skills},         %技能1
	     {int, special_skill},  %特殊技能
	     {list_int, drop_rate},  %掉落概率
	     {list_int, item_id},     %物品id
	     {list_int, drop_amount}, %掉落数量
	     {int, fly_effect_id},
	     {int, front_effect_id},
	     {int, back_effect_id},
	     {int, ai_behavior}
	    ]
	   },
	   {monster_description_tplt,
	    [
	     {int,id},              % 怪物ID
	     {string, introduction}, % 简介
	     {string, atk_mode},     % 攻击方式
	     {string, corresponding_strategy} % 对应策略
	    ]
	   },
	   {item_tplt,
	    [{int, id},                 %% 物品ID
	     {int, type},               %% 物品类型
	     {string, name},            %% 物品名称
	     {int, overlay_count},      %% 堆叠个数
	     {int, sell_price},         %% 出售价格
	     {int, sub_id},             %% 关联ID
	     {string, icon},            %% 物品图标
	     {string, describe},        %% 物品说明 
	     {int,bind_type},           %% 绑定类型
	     {int,role_type},           %% 职业类型
	     {int,quality}              %% 品质
	    ]},
	   {equipment_tplt,
	    [{int,id},                  %%装备ID
	     {int,type},                %%装备类型
	     {int,gem_trough},          %%宝石槽
	     {int,life},                %%增加的生命值
	     {int,atk},                 %%增加的攻击
	     {int,speed},               %%增加的速度
	     {int,hit_ratio},           %%命中
	     {int,miss_ratio},          %%闪避
	     {int,critical_ratio},      %%暴击
	     {int,tenacity},            %%韧性
	     {int,mf_rule},             %%mf_rule
	     {int,mitigation},          %%减伤
	     {list_int,attr_ids},       %%固有附加属性
	     {int,strengthen_id},       %%强化规则ID
	     {int,equip_level},         %%装备等级
	     {int,equip_use_level},     %%使用等级
	     {int,combat_effectiveness}, %%战斗力
	     {int,max_combat_effectiveness}, %%最大战斗力
	     {int, advance_id},         %%升阶ID
	     {int, recast_id}           %%重铸ID
	    ]
	   },
	   {equipment_mf_rule_tplt,
	    [{int,id},                           %%mfID
	     {int,addtional_attr_max},           %%随机附加属性个数最大
	     {int,addtional_attr_min},           %%随机附加属性个数最小
	     {list_tuple,addtional_attr_ids},      %%参与随机的附加属性id
	     {int,special_attr_max},             %%随机特殊属性个数最大
	     {int,special_attr_min},             %%随机特殊属性个数最小
	     {list_tuple,special_attr_ids},        %%参与随机的特殊属性id
	     {int,gem_trough}                    %%随机出的宝石孔最大数
	    ]
	   },
	   {equip_strengthen_tplt,
	    [{int,id},                  %%物品Id
	     {int,need_type},           %%强化所需类型
	     {int,need_amount},           %%强化所需数量
	     {list_string,attr_types},  %%增加的属性类型
	     {list_int,attr_values},    %%增加的属性值
	     {int,strengthen_rate},     %%强化几率
	     {int,strengthen_battle_power},     %%强化战斗力
	     {int,strengthen_addition_gold}      %%强化额外金币
	    ]
	   },
	   {equipment_recast_tplt,
	    [{int, id},
	     {list_tuple, need_material},
	     {int, need_gold},
	     {int, mf_rule_id}
	    ]
	   },
	   {equipment_advance_tplt,
	    [{int, id},
	     {list_tuple, need_material},
				{int,need_type},           %%强化所需类型
				{int,need_amount},           %%强化所需数量
	     {int, advance_id}
	    ]
	   },
	   {equipment_resolve_tplt,
	    [{int, id},
	     {list_tuple, material_resolved}
	    ]
	   },
	   {trap_tplt,
	    [{int,id},                  %%陷阱ID
	     {int,skill},               %%技能ID
	     {string,icon}              %%图片
	    ]
	   },
	   {award_tplt,
	    [
	     {int,id},                  %%奖励ID
	     {string,name},             %%奖励名字
	     {int,award_type},          %%奖励类型
	     {int,award_id}             %%奖励ID
	    ]
	   },
	   {role_upgrad_tplt,
	    [{int,id},                  %%id
	     {string,name},             %%名字
	     {int,life},                %%生命值
	     {int,atk},                 %%攻击
	     {int,speed},               %%速度
	     {int,hit_ratio},           %%命中
	     {int,critical_ratio},      %%暴击
	     {int,miss_ratio},          %%闪避
	     {int,tenacity},            %%韧性
	     {int,combat_effectiveness} %%战斗力
	    ]
	   },
	   {role_exp_tplt,
	    [{int,id},                  %%id
	     {int,exp},                  %%所需经验
	     {int, group_id},
		 {list_int,ids}, 			%%奖励id列表
		 {list_int,amounts} 		%%奖励数量表
	    ]
	   },
	   {game_award,
	    [{int,id},
	     {list_int,id_list1},
	     {list_int,amount_list1},
	     {int,list1_ratio},
	     {list_int,id_list2},
	     {list_int,amount_list2},
	     {int,list2_ratio},
	     {list_int,id_list3},
	     {list_int,amount_list3},
	     {int,list3_ratio},
	     {int,need_emoney}
	    ]
	   },
	   {power_hp_price,
	    [{int,the_time},                  %%id
	     {int,price}                  %%所需代币
	    ]
	   },
	   {extend_pack_price,
	    [{int,the_time},                  %%id
	     {int,price}                  %%所需代币
	    ]
	   },
	   {push_tower_copy,
	    [{int,id},
	     {int,min_level},
	     {int,max_level},
	     {int,first_map_id}
	    ]
	   },
	   {push_tower_map,
	    [{int,id},
	     {int,repeat_times},
	     {int,next_map},
	     {list_int,monsters},
	     {int,monster_min},
	     {int,monster_max},
	     {list_int,scene},
	     {list_int,traps},
	     {int,trap_min},
	     {int,trap_max},
	     {list_int,friends},
	     {int,friend_min},
	     {int,friend_max},
	     {list_int,awards},
	     {int,award_min},
	     {int,award_max},
	     {int,barrier_amount},
	     %%{int,award},
	     {int, gold},
	     {list_int,key_monster} %门将列表
	    ]
	   },
	   {push_tower_award,
	    [{int,id},
	     {list_int,gem_lev1},
	     {int,lev1_radio},
	     {list_int,gem_lev2},
	     {int,lev2_radio},
	     {list_int,gem_lev3},
	     {int,lev3_radio},
	     {list_int,gem_lev4},
	     {int,lev4_radio}
	    ]
	   },
	   {task_tplt,            %任务表    
	    [{int,id},           % id    
	     {string,title},     % 标题
	     {int,main_type},	  % 1 主线 2 支线
	     {int,need_level},   % 需要等级 
	     {list_int,next_ids},% 后置任务id可能是多个
	     {int,sub_type},     % 任务子类型 1=击杀怪物 2=通关副本 3=收集物品
	     {int,monster_id},   % 怪物id
	     {int,clear_type},   % 通关类型 1=常规通关 2=三星通关 3=击杀所有敌人通关
	     {int,collect_id},   % 收集物品id
	     {int,location},     % 副本地点
	     {int,number},       % 任务要求的数量
	     {string,text},      % 文本描述
	     {list_int, reward_ids}, 	  % 奖励ID
	     {list_int, reward_amounts}  % 奖励数量
	    ]
	   },
           {skill_tplt,       %符文表
            [{int, id},           % 符文id
             {int, role_type},          % 职业
             {int, skill_group},  % 属于哪组技能(1.火球系，2.闪电系）
             {int, max_lev}, %   最高等级
             {list_int, desc_ids}, %%技能描述id
             {int, star}, %%星级
             {int, upgrate_cost_id}, %%技能升级费用ID
             {int, advance_cost_id}, %%进阶扣除ID
             {int, unlock_need_id},   %%解锁所需技能碎片ID
             {int, unlock_need_amount}, %%解锁所需技能碎片数量
             {int, attribute_tag},      %%性能所属标签页
             {int, equal_frags_amount}  %% 奖励所等同的碎片数量
            ]
	   },
           {skill_frag_tplt,   %符文碎片表
            [
                {int, id},           % 符文id
                {string, name},      % 名字
                {int, role_type},    % 职业
                {string, icon},      % 图标
                {int, star},          %%星级
                {string, desc},       % 描述
                {int, skill_id}
            ]
           },
           {skill_upgrade_tplt,   %符文升级表
            [
                {int,id},       %技能升级费用ID
                {int,level},    %技能等级
                {int,cost}      %金币费用
            ]
           },
           {skill_advance_tplt,   %符文进阶表
            [
                {int,id},                   %ID
                {list_int,need_ids},        %扣除ID
                {list_int,need_amount},     %扣除数量
                {int,advanced_id}           %进阶后的技能ID
            ]
           },
	   {skill_divine_tplt,   %符文占卜表
	    [ 
	      {int,id},       %编号
              {int,type},     %抽奖类型
              {list_int, level_interval}, %等级区间
              {list_tuple,reward_group_list} %抽奖读取的奖励组
	    ]
	   },
           {divine_reward_tplt,      % 占扑奖励组表
            [{int, id},              % 组ID
             {list_int, ids},     % 奖励ID
             {list_int, amounts},          % 数量
             {list_int, rate_list}          % 占卜几率
            ]
           },
	   {sculpture_convert_tplt,       %符文兑换表    
	    [{int,id},             % 符文id 对应sculpture_tplt.id   
	     {int,frag_count},    %碎片数目
	     {int,can_show}      %是否可显示 1-显示 0-隐藏
	    ]
	   },
	   {gem_attributes,
	    [{int,id},
	     {string,name},
	     {int,type},
	     {int,life},	     %生命
	     {int,atk},             %攻击
	     {int,speed},           %速度
	     {int,hit_ratio},       %命中
	     {int,miss_ratio},      %闪避
	     {int,critical_ratio},  %暴击
	     {int,tenacity},        %韧性
	     {int,unmounted_price}, %%卸下价格
	     {int,combat_effectiveness}, %%战斗力
	     {string,small_icon}
	    ]
	   },
	   {gem_compound,
	    [{int,id},
	     {int,gold},
	     {int,related_id},
	     {int,success_rate},
	     {list_int,miss_rate}
	    ]
	   },
	   {equipment_lev_price,
	    [{int,level},
	     {int,percent},
	     {int,combat_effectiveness} %%战斗力
	    ]
	   },
	   {challenge_award_tplt,
	    [{int,id},
	     {list_int,ranking_range},
	     {int,success_points},
	     {int,success_honours},
	     {int,failed_points},
	     {int,failed_honours}
	    ]
	   },
	   {ranking_award_tplt,
	    [{int,id},
	     {list_int,ranking_range},
	     {int,points},
	     {int,honours}
	    ]
	   },
	   {ranking_copy_tplt,
	    [{int,id},
	     {list_int,lev_range},
	     {list_int,scene},
	     {list_int,friends},
	     {int,friend_min},
	     {int,friend_max},
	     {list_int,traps},
	     {int,trap_min},
	     {int,trap_max},
	     {int,barrier_amount},
	     {list_int,awards},
	     {int,award_min},
	     {int,award_max},
	     {list_int,monsters},
	     {int,monster_min},
	     {int,monster_max}
	    ]
	   },
	   {mall_item,
	    [{int, id},
	     {int, mall_item_type},
	     {int, item_id},
	     {int, item_amount},
	     {int, price_type},
	     {int, price},
	     {int, vip_discount},
	     {int, mark},
	     {int, buy_limit},
	     {int, tag_id},
	     {int, profession},
	     {int, level},
	     {int, show},
	     {int, client_show},
	     {list_int, item_sources}
	    ] 
	   },
	   {event_tplt,
	    [{int,id},
	     {string,name},
	     {int,type},
	     {int,skill},
	     {int,number},
	     {string,icon},
	     {int, trigger_effect_id},
	     {string, params}
	    ]
	   },
	   {expression_tplt,
	    [{int,id},
	     {exp_str, expression}
	    ]
	   },
	   {military_rank_tplt, %军衔模版表
	    [
	     {int, id},
	     {string, name},
	     {string,icon},%图片
	     {int, need_honour},
	     {list_int, need_rank},
	     {list_int, reward_ids}, 	  % 奖励ID
	     {list_int, reward_amounts}  % 奖励数量
	    ]
	   },
	   {point_mall_tplt,
	    [{int,id},
	     {int,mall_item_type},
	     {int,item_id},
	     {int,item_amount},
	     {list_int, need_ids},
	     {list_int, need_amounts},
	     {int,tag_id},
	     {int,need_rank},
	     {int, profession},
	     {int, level},
	     {int,show}
	    ]
	   },
	   {gift_bag_tplt,
	    [{int, id},
	     {string, name},
	     {string, icon},
	     {list_int, item_id},
	     {list_int, item_amount},
	     {string, desc}
	    ]
	   },
	   {daily_award_tplt,
	    [{list_int, level_range},
	     {int, days1_award},
	     {int, days3_award},
	     {int, days7_award},
	     {int, days15_award}
	    ]
	   },
	   {activeness_task_tplt,
	    [{int, id},
	     {string, name},
	     {int, max_times},
	     {int, award_pertime}
	    ]
	   },
	   {activeness_reward_tplt,
	    [{int, id},
	     {list_int, ids},
	     {list_int, amounts},
	     {int,need_activess}
	    ]
	   },
	   {reward_item_tplt,
	    [{int, id},
	     {int, type},
	     {list_tuple, temp_id},
	     {string, description}
	    ]
	   },
	   {train_match_award_group,
	    [{int, id},
	     {int, min_lev},
	     {int, max_lev},
	     {int, blue_award},
	     {int, purple_award},
	     {int, orange_award},
	     {int, red_award}
	    ]
	   },
	   {train_match_award,
	    [{int, id},
	     {list_int, awards},
	     {list_int, amounts},
	     {list_int, radios}
	    ]
	   },
	   {nickname_tplt,
	    [{int, id},
	     {int, radio},
	     {list_string, content},
	     {list_string, secname}
	    ]
	   },
	   {benison_tplt,
	    [{int, id},
	     {string, name},
	     {string, icon},
	     {list_int, status_ids},
	     {int, duration},
	     {int, need_emoney}
	    ]
	   },
	   {benison_status_tplt,
	    [{int, id},
	     {int, attr_type},
	     {int, value_type},
	     {int, value}
	    ]
	   },
	   {randon_gift_bag_tplt,
	    [{int, id},
	     {list_int, gift_bag_ids},
	     {list_int, radios}]
	   },
	   {tutorial_item_tplt,
	    [
	     {int, group_id},
	     {int, gift_bag_id}
	    ]
	   },
	   {upgrade_task_tplt,  %冲级模版表
	    [
	     {int, id},
	     {int, level}, 				% 所需等级
	     {list_int, reward_ids}, 	% 奖励ID
	     {list_int, reward_amounts} % 奖励数量
	    ]
	   },
	   {friend_point_lottery_tplt,  %友情点抽奖表
	    [
	     {int, id},
	     {int, times}, 				% 已抽次数
	     {int, need_point}		% 所需友情点  
	    ]
	   },
	   {friend_point_lottery_item_tplt,  %友情点抽奖物品表
	    [
	     {int, id},
	     {int, itemd_id}, 		% 物品ID
	     {int, amount}, 		% 奖励数量
	     {int, rate}   	% 奖励概率 
	    ]
	   },
	   {stress_test_tplt,
	    [
	     {int, id},
	     {string, name},
	     {list_tuple, next_action}
	    ]
	   },
	   {alchemy_tplt,
	    [
	     {int, id},
	     {int, level},
	     {int, normal_reward_gold},
	     {int, advanced_reward_gold},
	     {list_int, reward_ids},
	     {list_int, reward_amounts}
	    ]
	   },
	   {equipment_exchange,
	    [
	     {int, id},
	     {list_int, exchange_ids},
	     {int, need_gold},
	     {list_int, need_meterials},
	     {list_int, amounts}
	    ]
	   },
	   {recharge_tplt,
	    [
	     {int, id},
	     {int, type},
	     {int, channel_id},
	     {int, money},
	     {int, recharge_emoney},
	     {int, reward_emoney},
	     {string, desc},
             {int, reward_vip_exp}
	    ]
	   },
	   {online_award_tplt,
	    [
	     {int, id},
	     {list_int, lev_range},
	     {int, minutes},
	     {list_int, ids},
	     {list_int, amounts}
	    ]
	   },
	   {exchange_item_tplt,
	    [
	     {int, id},
	     {int, aim_item_id},
	     {int, aim_item_amount},
	     {list_int, need_items},
	     {list_int, need_amounts}
	    ]
	   },
	   {discount_mall_item_tplt,
	    [{int, id},
	     {int, type},
	     {int, temp_id},
	     {int, amount},
	     {int, price},
	     {int, discount_price},
	     {int, limit_times},
	     {int, show}]
	   },
	   {role_advance_tplt,
	    [
	     {int, id},
	     {string, icon},
	     {string, big_icon},
	     {string, heroicon},
	     {string, herosmallicon},
	     {int, fly_effect_id},
	     {int, front_effect_id},
	     {int, back_effect_id},
	     {int, potence_level},
	     {int, progress_length}
	    ]
	   },
	   {potence_tplt,
	    [
	     {int, id},
	     {int, level_limit},
	     {int, life},
	     {int, attack},
	     {int, battle_soul},
	     {int, rate},
	     {int, power}
	    ]
	   },
	   {vip_tplt,
	    [
	     {int, id},
	     {int, need_money},  %% 变成vip经验
	     {list_int, grade_gift_bag_ids},
	     {list_int, grade_gift_bag_amounts},
	     {list_int, daily_gift_bag_ids},
	     {list_int, daily_gift_bag_amounts},
	     {list_int, privilege_ids},
	     {list_int, privilege_amounts}
	    ]
	   },
	   {redeem_code_reward_tplt,
	    [
	     {int, id},
	     {list_int, reward_ids},
	     {list_int, reward_amounts}
	    ]
	   },
	   {function_unlock_tplt,
	    [
	     {int, id},
	     {string, icon},
	     {string, name},
	     {int, copy_id},
	     {string, description}
	    ]
	   },
	   {robot_skill_tplt,
	    [
	     {int, id},
	     {list_tuple, skills}
	    ]
	   },
	   {mooncard_daily_award_tplt,
	    [
	     {int, id},
	     {int, day_amount},
	     {list_int, award_ids},
	     {list_int, amount}
	    ]
	   },
	   {challenge_reward_tplt, % 排位赛奖励
	    [
	     {int, id},
	     {list_int, rank_range},
	     {list_int, ids},
	     {list_int, amounts}
	    ]
	   },
	   {invite_code_reward_tplt, % 邀请码奖励
	    [
	     {int, id},
	     {list_int, pretince_ids},
	     {list_int, prentince_amounts},
	     {list_int, master_ids},
	     {list_int, master_amounts}
	    ]
	   },
	   {invite_help_reward_tplt, % 邀请帮助给与奖励
	    [
	     {int, id},
		 {list_int, ids},
		 {list_int, amounts},
		 {int, need_level}
	    ]
	   },
           {talent_tplt,     %%天赋数据表
            [
             {int,id},
             {string,name},       %%天赋名称
             {string,icon},       %%天赋图标
             {int,max_level},     %%最高等级
             {int,job},           %%职业
             {int,position},      %%层数中的位置
             {int,layer},         %%天赋所属层数
             {int,level_up_id}    %%天赋升级ID
            ]
           },
        %%   {talent_perform_tplt,          %%天赋表现表
        %%   [
        %%   {int,id},
        %%    {list_int,trigger_type},      %%触发条件
        %%    {int,rate},                   %%触发概率
        %%    {list_int,affect_attri_id},   %%角色属性类型
        %%    {list_int,affect_attri_value},%%影响角色属性数值
        %%    {list_int,affect_skill_id},   %%影响技能效果Id
        %%    {list_int,affect_skill_type}, %%影响技能效果类型
        %%    {list_int,affect_skill_value},%%影响技能效果数值
        %%    {int,auto_used_skill_id},     %%自动施放技能ID
        %%    {int,auto_used_skill_target}  %%自动施放技能目标
        %%   ]
        %%   },
           {talent_level_up_tplt,         %%天赋升级现表
            [
             {int,level_up_id},           %%升级Id=temp_id*100+next_level
             {int,skill_piece_id},        %%技能碎片ID(原符文碎片)
             {int,skill_piece_num},       %%所需技能碎片数量
             {string,describe},           %%天赋描述
             {list_int,talent_trigger_id},%%触发条件
             {int,talent_result_id}       %%触发结果
            ]
           },
           {time_limit_reward_tplt,         %%限时奖励
            [
                {int, id},
                {list_tuple, start_time},   %%开始时间
                {list_tuple, end_time},     %%结束时间
                {int, count},               %%次数
                {int, cd_time},             %%cd时间
                {list_int, ids},            %%奖励id
                {list_int, amounts}         %%奖励数量
            ]
           },
	      {ladder_match_level_tplt,         %%分组赛关卡表
		  [
		      {int, id},
		      {int, match_opponent_level}   %%匹配对少等级
		  ]
	      },
	      {ladder_match_reward_tplt,         %%分组赛奖励表
		  [
		      {int, id},
		      {int, level_id},           %%匹配对少等级
		      {list_int, role_level_range},   %%匹配对少等级
		      {list_int, ids},            %%奖励id
		      {list_int, amounts}         %%奖励数量
		  ]
	      },
	      {activity_tplt,
		  [
		      {int, id}, %%ID
		      {string, icon}, %%图片
		      {string, describe},
		      {list_tuple, begin_time_array}, %%开始时间
		      {list_tuple, end_time_array}    %%结束时间
		  ]
	      },
	      {act_lottery_tplt, %% 活动抽奖模板
		  [
		      {int, id},
		      {string, name},
		      {int, need_times},
		      {int, repeat_type}
		  ]
	      },
	      {act_lottery_reward_tplt,%% 活动抽奖奖励模板
		  [
		      {int, id},
		      {list_int, ids},
		      {list_int, amounts},
		      {int, rate}
		  ]
	      },
              {act_recharge_tplt, %% 活动充值奖励模板
               [
                   {int, id},
                   {string, describe},
                   {int, need_emoney},
                   {list_int, reward_ids},
                   {list_int, reward_amounts}
               ]
              },
              {act_multi_reward_tplt, %% 活动多倍产能模板
               [
                   {int, id},
                   {string, describe},
                   {int, multi_rate}
               ]
              },
			{medal_exchange_tplt,
				[
					{int, id},
					{int, temp_id},
					{int, level},
					{int, gold},
					{int, point}
				]
			}
	  ])
       ).
