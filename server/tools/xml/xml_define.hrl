%%% @author  linyijie
%%% @copyright (C) 2010, 
%%% @doc
%%%  excelӳ���ļ��Ľṹ�嶨��, ������ṹ���, �����������Ӧ����Դӳ���ļ���excelʹ��
%%% @end

%%% Created : 22 Mar 2010 by  <>

%% ���͵Ķ��������: int, float, string, list_int, list_float, list_string
%% �������� vector3, color, quaternion
%% ������list_ ��ͷ�Ķ����б����ʽ, ģ�������д�ĸ�ʽ���� 1, 2, 3 Ҫ�Զ���Ϊ�ָ���
%% ������range ��ʾ����,  ģ�������д�ĸ�ʽ���� 1~2,  �������ɵ�����ΪԪ��{1, 2}�� Ҳ��ֱ����2, ��ʾ{2, 2} 
-define(tplt_list,(
	  [
	   {role_tplt,
	    [{int,id},    %��ɫ����ID
	     {string,name},%��ɫ����
	     {int,armor},%��ʼ����
	     {int,weapon},%��ʼ����
	     {int,skill1},%����1
	     {int,skill2}, %����2
	     {string,describe},%��ɫ˵��
	     {int,default_sculpture},
	     {list_int,init_sculpture},
	     {list_int,divine_list}, %ռ���ķ��Ķ��У�������������
		 {int,icon}
	    ]},
	   {copy_group_tplt,
	    [
	     {int,id},    %����ȺID
	     {int,type},    %����Ⱥ����
	     {string,name},   %����Ⱥ����
	     {int,next_group_id},   %�¸�����ȺID
	     {string,icon},         %ͼƬ����
	     {int,first_copy_id},    %%��һ������ID
	     {int,last_copy_id}
	    ]
	   },
	   {copy_tplt,
	    [
	     {int,id},              %����ID
	     {int,type},				%�������� 	
	     {string,name},         %��������
	     {int,copy_group_id},   %��������Ⱥid
	     {int,need_power},      %������������
	     {int,win_need_power},  %ʤ����������
	     {int,gold},            %��ҽ���
	     {int,exp},             %���齱��
	     {int,award},           %������ƷID
	     {string,describe},     %��������
	     {int,first_map_id},    %������һ���ͼID
	     {list_int,pre_copy},        %ǰ�ø���
	     {int,need_stone},     	%���裨�ٻ���ʯ
	     {list_int,dropitems},   %�������Ʒ�б��ͻ��˱��� 
	     {string, small_icon},
	     {int, recommended_battle_power}, %�Ƽ�ս����
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
	     {int,id},              %����ID	
	     {string,name},         %��������
	     {int,copy_group_id},   %��������Ⱥid
	     {int,need_power},      %������������
	     {int,gold},            %��ҽ���
	     {int,exp},             %���齱��
	     {string,describe},     %��������
	     {int,first_map_id},    %������һ���ͼID
	     {list_int,dropitems},   %�������Ʒ�б��ͻ��˱��� 
	     {string, small_icon},
	     {int, recommended_battle_power}, %�Ƽ�ս����
	     {int, need_level}
	    ]
	   },
	   {activities_tplt,
	    [
	     {int, id}, %%ID
	     {string, icon}, %%ͼƬ
	     {int, time_type},
	     {string, describe},
	     {list_tuple, begin_time_array}, %%��ʼʱ��
	     {list_tuple, end_time_array}    %%����ʱ��
	    ]
	   },
	   {game_map_tplt,
	    [
	     {int,id},              %��ͼID
	     {string,name},         %��ͼ����
	     {int,copy_id},         %����ID
	     {int,room},            %��������ID
	     {list_int,monster},    %����ID
	     {list_int,trap},       %����ID
	     {list_int,buff},       %����ID
	     {list_int,friend_role},%�ѷ���Ӫ
	     {int,barries_amount},  %�ϰ�����
	     {int,map_rule_id},     %ָ������
	     {int,next_map},         %��һ���ͼ
	     {list_int,key_monster} %�Ž��б�
	    ]
	   },
	   {friend_role,
	    [{int,id},                  %%ID
	     {int,skill},               %%����ID
	     {string,icon}              %%ͼƬ
	    ]
	   },
	   {game_map_rule_tplt,
	    [
	     {int,id},              %����ID
	     {list_int,monster},    %����ID
	     {list_int,monster_pos},%����ID
	     {int,door},            %����ID,
	     {list_tuple, awards},  %����
	     {list_int,barries_pos}, %�ϰ�λ��
	     {int, boss_amount},
	     {list_tuple, boss},
	     {list_int,  boss_rule}     %ָ��boss�ֵĻغ϶�Ӧ����
	    ]
	   },
	   {monster_tplt,
	    [
	     {int, id},              %����ID
	     {string, name},         %��������
	     {string, icon},         %ͼƬID
	     {int, level},           %����ȼ�
	     {int, description_id}, % ��������ID
	     {int, type},            %��������
	     {int, attack_type},     %���﹥������
	     {list_int, relative_id},%����ID 
	     {int, life},	    %����
	     {int, atk},             %����
	     {int, speed},           %�ٶ�
	     {int, hit_ratio},       %����
	     {int, critical_ratio},  %����
	     {int, miss_ratio},      %����
	     {int, tenacity},        %����
	     {list_int, skills},         %����1
	     {int, special_skill},  %���⼼��
	     {list_int, drop_rate},  %�������
	     {list_int, item_id},     %��Ʒid
	     {list_int, drop_amount}, %��������
	     {int, fly_effect_id},
	     {int, front_effect_id},
	     {int, back_effect_id},
	     {int, ai_behavior}
	    ]
	   },
	   {monster_description_tplt,
	    [
	     {int,id},              % ����ID
	     {string, introduction}, % ���
	     {string, atk_mode},     % ������ʽ
	     {string, corresponding_strategy} % ��Ӧ����
	    ]
	   },
	   {item_tplt,
	    [{int, id},                 %% ��ƷID
	     {int, type},               %% ��Ʒ����
	     {string, name},            %% ��Ʒ����
	     {int, overlay_count},      %% �ѵ�����
	     {int, sell_price},         %% ���ۼ۸�
	     {int, sub_id},             %% ����ID
	     {string, icon},            %% ��Ʒͼ��
	     {string, describe},        %% ��Ʒ˵�� 
	     {int,bind_type},           %% ������
	     {int,role_type},           %% ְҵ����
	     {int,quality}              %% Ʒ��
	    ]},
	   {equipment_tplt,
	    [{int,id},                  %%װ��ID
	     {int,type},                %%װ������
	     {int,gem_trough},          %%��ʯ��
	     {int,life},                %%���ӵ�����ֵ
	     {int,atk},                 %%���ӵĹ���
	     {int,speed},               %%���ӵ��ٶ�
	     {int,hit_ratio},           %%����
	     {int,miss_ratio},          %%����
	     {int,critical_ratio},      %%����
	     {int,tenacity},            %%����
	     {int,mf_rule},             %%mf_rule
	     {int,mitigation},          %%����
	     {list_int,attr_ids},       %%���и�������
	     {int,strengthen_id},       %%ǿ������ID
	     {int,equip_level},         %%װ���ȼ�
	     {int,equip_use_level},     %%ʹ�õȼ�
	     {int,combat_effectiveness}, %%ս����
	     {int,max_combat_effectiveness}, %%���ս����
	     {int, advance_id},         %%����ID
	     {int, recast_id}           %%����ID
	    ]
	   },
	   {equipment_mf_rule_tplt,
	    [{int,id},                           %%mfID
	     {int,addtional_attr_max},           %%����������Ը������
	     {int,addtional_attr_min},           %%����������Ը�����С
	     {list_tuple,addtional_attr_ids},      %%��������ĸ�������id
	     {int,special_attr_max},             %%����������Ը������
	     {int,special_attr_min},             %%����������Ը�����С
	     {list_tuple,special_attr_ids},        %%�����������������id
	     {int,gem_trough}                    %%������ı�ʯ�������
	    ]
	   },
	   {equip_strengthen_tplt,
	    [{int,id},                  %%��ƷId
	     {int,need_type},           %%ǿ����������
	     {int,need_amount},           %%ǿ����������
	     {list_string,attr_types},  %%���ӵ���������
	     {list_int,attr_values},    %%���ӵ�����ֵ
	     {int,strengthen_rate},     %%ǿ������
	     {int,strengthen_battle_power},     %%ǿ��ս����
	     {int,strengthen_addition_gold}      %%ǿ��������
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
				{int,need_type},           %%ǿ����������
				{int,need_amount},           %%ǿ����������
	     {int, advance_id}
	    ]
	   },
	   {equipment_resolve_tplt,
	    [{int, id},
	     {list_tuple, material_resolved}
	    ]
	   },
	   {trap_tplt,
	    [{int,id},                  %%����ID
	     {int,skill},               %%����ID
	     {string,icon}              %%ͼƬ
	    ]
	   },
	   {award_tplt,
	    [
	     {int,id},                  %%����ID
	     {string,name},             %%��������
	     {int,award_type},          %%��������
	     {int,award_id}             %%����ID
	    ]
	   },
	   {role_upgrad_tplt,
	    [{int,id},                  %%id
	     {string,name},             %%����
	     {int,life},                %%����ֵ
	     {int,atk},                 %%����
	     {int,speed},               %%�ٶ�
	     {int,hit_ratio},           %%����
	     {int,critical_ratio},      %%����
	     {int,miss_ratio},          %%����
	     {int,tenacity},            %%����
	     {int,combat_effectiveness} %%ս����
	    ]
	   },
	   {role_exp_tplt,
	    [{int,id},                  %%id
	     {int,exp},                  %%���辭��
	     {int, group_id},
		 {list_int,ids}, 			%%����id�б�
		 {list_int,amounts} 		%%����������
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
	     {int,price}                  %%�������
	    ]
	   },
	   {extend_pack_price,
	    [{int,the_time},                  %%id
	     {int,price}                  %%�������
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
	     {list_int,key_monster} %�Ž��б�
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
	   {task_tplt,            %�����    
	    [{int,id},           % id    
	     {string,title},     % ����
	     {int,main_type},	  % 1 ���� 2 ֧��
	     {int,need_level},   % ��Ҫ�ȼ� 
	     {list_int,next_ids},% ��������id�����Ƕ��
	     {int,sub_type},     % ���������� 1=��ɱ���� 2=ͨ�ظ��� 3=�ռ���Ʒ
	     {int,monster_id},   % ����id
	     {int,clear_type},   % ͨ������ 1=����ͨ�� 2=����ͨ�� 3=��ɱ���е���ͨ��
	     {int,collect_id},   % �ռ���Ʒid
	     {int,location},     % �����ص�
	     {int,number},       % ����Ҫ�������
	     {string,text},      % �ı�����
	     {list_int, reward_ids}, 	  % ����ID
	     {list_int, reward_amounts}  % ��������
	    ]
	   },
           {skill_tplt,       %���ı�
            [{int, id},           % ����id
             {int, role_type},          % ְҵ
             {int, skill_group},  % �������鼼��(1.����ϵ��2.����ϵ��
             {int, max_lev}, %   ��ߵȼ�
             {list_int, desc_ids}, %%��������id
             {int, star}, %%�Ǽ�
             {int, upgrate_cost_id}, %%������������ID
             {int, advance_cost_id}, %%���׿۳�ID
             {int, unlock_need_id},   %%�������輼����ƬID
             {int, unlock_need_amount}, %%�������輼����Ƭ����
             {int, attribute_tag},      %%����������ǩҳ
             {int, equal_frags_amount}  %% ��������ͬ����Ƭ����
            ]
	   },
           {skill_frag_tplt,   %������Ƭ��
            [
                {int, id},           % ����id
                {string, name},      % ����
                {int, role_type},    % ְҵ
                {string, icon},      % ͼ��
                {int, star},          %%�Ǽ�
                {string, desc},       % ����
                {int, skill_id}
            ]
           },
           {skill_upgrade_tplt,   %����������
            [
                {int,id},       %������������ID
                {int,level},    %���ܵȼ�
                {int,cost}      %��ҷ���
            ]
           },
           {skill_advance_tplt,   %���Ľ��ױ�
            [
                {int,id},                   %ID
                {list_int,need_ids},        %�۳�ID
                {list_int,need_amount},     %�۳�����
                {int,advanced_id}           %���׺�ļ���ID
            ]
           },
	   {skill_divine_tplt,   %����ռ����
	    [ 
	      {int,id},       %���
              {int,type},     %�齱����
              {list_int, level_interval}, %�ȼ�����
              {list_tuple,reward_group_list} %�齱��ȡ�Ľ�����
	    ]
	   },
           {divine_reward_tplt,      % ռ�˽������
            [{int, id},              % ��ID
             {list_int, ids},     % ����ID
             {list_int, amounts},          % ����
             {list_int, rate_list}          % ռ������
            ]
           },
	   {sculpture_convert_tplt,       %���Ķһ���    
	    [{int,id},             % ����id ��Ӧsculpture_tplt.id   
	     {int,frag_count},    %��Ƭ��Ŀ
	     {int,can_show}      %�Ƿ����ʾ 1-��ʾ 0-����
	    ]
	   },
	   {gem_attributes,
	    [{int,id},
	     {string,name},
	     {int,type},
	     {int,life},	     %����
	     {int,atk},             %����
	     {int,speed},           %�ٶ�
	     {int,hit_ratio},       %����
	     {int,miss_ratio},      %����
	     {int,critical_ratio},  %����
	     {int,tenacity},        %����
	     {int,unmounted_price}, %%ж�¼۸�
	     {int,combat_effectiveness}, %%ս����
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
	     {int,combat_effectiveness} %%ս����
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
	   {military_rank_tplt, %����ģ���
	    [
	     {int, id},
	     {string, name},
	     {string,icon},%ͼƬ
	     {int, need_honour},
	     {list_int, need_rank},
	     {list_int, reward_ids}, 	  % ����ID
	     {list_int, reward_amounts}  % ��������
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
	   {upgrade_task_tplt,  %�弶ģ���
	    [
	     {int, id},
	     {int, level}, 				% ����ȼ�
	     {list_int, reward_ids}, 	% ����ID
	     {list_int, reward_amounts} % ��������
	    ]
	   },
	   {friend_point_lottery_tplt,  %�����齱��
	    [
	     {int, id},
	     {int, times}, 				% �ѳ����
	     {int, need_point}		% ���������  
	    ]
	   },
	   {friend_point_lottery_item_tplt,  %�����齱��Ʒ��
	    [
	     {int, id},
	     {int, itemd_id}, 		% ��ƷID
	     {int, amount}, 		% ��������
	     {int, rate}   	% �������� 
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
	     {int, need_money},  %% ���vip����
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
	   {challenge_reward_tplt, % ��λ������
	    [
	     {int, id},
	     {list_int, rank_range},
	     {list_int, ids},
	     {list_int, amounts}
	    ]
	   },
	   {invite_code_reward_tplt, % �����뽱��
	    [
	     {int, id},
	     {list_int, pretince_ids},
	     {list_int, prentince_amounts},
	     {list_int, master_ids},
	     {list_int, master_amounts}
	    ]
	   },
	   {invite_help_reward_tplt, % ����������뽱��
	    [
	     {int, id},
		 {list_int, ids},
		 {list_int, amounts},
		 {int, need_level}
	    ]
	   },
           {talent_tplt,     %%�츳���ݱ�
            [
             {int,id},
             {string,name},       %%�츳����
             {string,icon},       %%�츳ͼ��
             {int,max_level},     %%��ߵȼ�
             {int,job},           %%ְҵ
             {int,position},      %%�����е�λ��
             {int,layer},         %%�츳��������
             {int,level_up_id}    %%�츳����ID
            ]
           },
        %%   {talent_perform_tplt,          %%�츳���ֱ�
        %%   [
        %%   {int,id},
        %%    {list_int,trigger_type},      %%��������
        %%    {int,rate},                   %%��������
        %%    {list_int,affect_attri_id},   %%��ɫ��������
        %%    {list_int,affect_attri_value},%%Ӱ���ɫ������ֵ
        %%    {list_int,affect_skill_id},   %%Ӱ�켼��Ч��Id
        %%    {list_int,affect_skill_type}, %%Ӱ�켼��Ч������
        %%    {list_int,affect_skill_value},%%Ӱ�켼��Ч����ֵ
        %%    {int,auto_used_skill_id},     %%�Զ�ʩ�ż���ID
        %%    {int,auto_used_skill_target}  %%�Զ�ʩ�ż���Ŀ��
        %%   ]
        %%   },
           {talent_level_up_tplt,         %%�츳�����ֱ�
            [
             {int,level_up_id},           %%����Id=temp_id*100+next_level
             {int,skill_piece_id},        %%������ƬID(ԭ������Ƭ)
             {int,skill_piece_num},       %%���輼����Ƭ����
             {string,describe},           %%�츳����
             {list_int,talent_trigger_id},%%��������
             {int,talent_result_id}       %%�������
            ]
           },
           {time_limit_reward_tplt,         %%��ʱ����
            [
                {int, id},
                {list_tuple, start_time},   %%��ʼʱ��
                {list_tuple, end_time},     %%����ʱ��
                {int, count},               %%����
                {int, cd_time},             %%cdʱ��
                {list_int, ids},            %%����id
                {list_int, amounts}         %%��������
            ]
           },
	      {ladder_match_level_tplt,         %%�������ؿ���
		  [
		      {int, id},
		      {int, match_opponent_level}   %%ƥ����ٵȼ�
		  ]
	      },
	      {ladder_match_reward_tplt,         %%������������
		  [
		      {int, id},
		      {int, level_id},           %%ƥ����ٵȼ�
		      {list_int, role_level_range},   %%ƥ����ٵȼ�
		      {list_int, ids},            %%����id
		      {list_int, amounts}         %%��������
		  ]
	      },
	      {activity_tplt,
		  [
		      {int, id}, %%ID
		      {string, icon}, %%ͼƬ
		      {string, describe},
		      {list_tuple, begin_time_array}, %%��ʼʱ��
		      {list_tuple, end_time_array}    %%����ʱ��
		  ]
	      },
	      {act_lottery_tplt, %% ��齱ģ��
		  [
		      {int, id},
		      {string, name},
		      {int, need_times},
		      {int, repeat_type}
		  ]
	      },
	      {act_lottery_reward_tplt,%% ��齱����ģ��
		  [
		      {int, id},
		      {list_int, ids},
		      {list_int, amounts},
		      {int, rate}
		  ]
	      },
              {act_recharge_tplt, %% ���ֵ����ģ��
               [
                   {int, id},
                   {string, describe},
                   {int, need_emoney},
                   {list_int, reward_ids},
                   {list_int, reward_amounts}
               ]
              },
              {act_multi_reward_tplt, %% ��౶����ģ��
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
