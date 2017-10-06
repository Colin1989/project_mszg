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

-define(sys_msg_list,(
	  [
	   {service,
	    [
	     {broadcast, "�㲥"},
	     {is_busy_now, "��������æ"},
	     {be_kick, "��ɫ����"},
	     {error, "����������"}
	    ]
           },
	   {login,
	    [
	     {passward_error, "�������"}, 
	     {no_register, "δע��"}, 
	     {version_error, "�汾����"}, 
	     {repeat_login, "�����ط���¼"},
	     {status_err, "�˺ű���"}
	    ]
	   },
	   {select_role,
	    [
	     {roleid_err, "��������ID����"},
	     {already_del, "�ѱ�ɾ��"},
	     {locked, "�˺ű���ͣ"}
	    ]
	   },
	   {del_role,
	    [
	     {roleid_err, "��������ID����"},
	     {already_del, "�ѱ�ɾ��"}
	    ]
	   },
	   {recover_role,
	    [
	     {roleid_err, "��������ID����"},
	     {status_normal, "������ɾ��״̬"},
	     {status_remove, "�ѱ�����ɾ��"},
	     {emoney_not_enough, "���Ҳ���"},
	     {amount_exceeded, "��������"}
	    ]
	   },
	   {create_role,
	    [
	     {name_exist, "������ɫ�����Ѵ���"},
	     {not_login, "δ��¼"},
	     {amount_exceeded, "��������"},
	     {type_error, "���ʹ���"}
	    ]
	   },
	   {register,
	    [
	     {account_exist, "��ע��"}
	    ]
	   },
	   {assistance,
	    [
	     {no_req_list,"δ����Ԯ���б�"},
	     {select_id_not_in_list,"ѡ���Ԯ�������б���"},
	     {get_lottery_item_err,"��ȡҡ����Ʒ����"}
	    ]
	   },
	   {reborn,
	    [
	     {emoney_not_enough, "���Ҳ���"}
	    ]
	   },
	   {push_tower,
	    [
	     {buy_emoney_not_enough, "��������������Ǯ����"},
	     {buy_times_exceeded, "�Ѵﹺ������"},
	     {enter_level_nomatch, "�ȼ���ƥ��"},
	     {times_exceeded, "��������"},
	     {settle_gameinfo_not_exist, "����ʱ��Ϣ������"},
	     {settle_items_not_right, "�ͻ��˷���������Ʒ����"},
	     {settle_round_not_enouth, "�غ�������"},
	     {settle_cost_round_illegel, "���ĵĻغ����Ƿ�"},
	     {settle_gameid_not_match, "��ϷID��ƥ��"}
	    ]
	   },
	   {game,
	    [
	     {settle_error, "�������"},
	     {settle_item_exceeded, "�񵽵���Ʒ��������"},
	     {settle_gold_exceeded, "�񵽵Ľ�ҳ�������"},
	     {not_enough_power, "��������"},
	     {not_enough_summon_stone, "�ٻ�ʯ����"},
	     {copy_lock, "δ����"},
		 {emoney_not_enough, "���Ҳ���"},
		 {level_not_enough, "�������ȼ�����"},
		 {copy_not_pass, "����δͨ��"}
	    ]
	   },
	   {challenge,
	    [
	     {buy_times_not_enough_emoney, "������ս��Ǯ����"},
	     {buy_times_exceeded, "��������Ѵ�����"},
	     {enemy_noexist, "��ս�߲�����"},
	     {noreq_list, "δ������ս�б�"},
	     {times_use_up, "��ս��������"},
	     {self, "������ս�Լ�"},
	     {level_err, "�ȼ�����"},
	     {settle_not_info, "����ʱս����Ϣ������"},
	     {settle_info_err, "ս����Ϣ�д�"},
	     {rank_award_in_cd, "��ȴ��"},
	     {rank_award_not_in_rank, "���ڿ���ȡ������"}
	    ]
	   },
	   {equipment_takeoff,
	    [
	     {pack_full, "��������"},
	     {type_error, "��������λ���д�"}
	    ]
	   },
	   {equipment_puton,
	    [
	     {noexist, "װ��������"},
	     {levelerr, "�ȼ���ƥ��"},
	     {roletypeerr, "��ɫ���Ͳ�ƥ��"},
	     {notowner, "����ӵ����"},
	     {itemtypeerr, "��Ʒ���ʹ���"}
	    ]
	   },
	   {equipment_streng,
	    [
	     {cannot_streng, "�޷�ǿ����û�п�ǿ��"},
	     {gold_not_enough, "��Ҳ���"},
	     {item_not_enough, "��Ʒ����"},
	     {streng_failed, "ǿ��ʧ��"},
	     {strenged_top, "�Ѿ�ǿ��������"}
	    ]
	   },
	   {equipment_advance,
	    [
	     {can_not_advance, "û�пɽ���ID"},
	     {gold_not_enough, "��Ҳ���"},
	     {item_not_enough, "���ϲ��㲻��"},
	     {level_not_enough, "װ���ȼ�����"}
	    ]
	   },
	   {equipment_recast,
	    [
	     {can_not_recast, "û�пɽ���ID"},
	     {gold_not_enough, "��Ҳ���"},
	     {item_not_enough, "���ϲ��㲻��"}
	    ]
	   },
	   {equipment_resolve,
	    [{disable, "�޷��ֽ�"},
	     {on_body, "�޷��ֽ����ϵ�װ��"},
	     {not_exist, "�����ڸ�װ��"}]
	   },
	   {gem_mount,
	    [
	     {typeexist, "�󶨵ı�ʯ�����Ѵ���"},
	     {not_trough, "û�в��"}
	    ]
	   },
	   {equipment_save_recast,
	    [{iderr, "IDû��δ�����������Ϣ"}]
	   },
	   {gem_compound,
	    [
	     {not_related, "�޿ɺϳɵ�Ŀ�걦ʯ"},
	     {not_enough_gold, "��Ҳ���"},
	     {not_protect, "û�б�����"},
	     {gem_not_enough, "��ʯ����"},
	     {pack_full, "��������"}
	    ]
	   },
	   {gem_unmounted,
	    [
	     {equip_notexist, "װ��������"},
	     {pack_full, "��������"},
	     {emoney_not_enough, "���Ҳ���"},
	     {notexist, "װ���ϲ����ڸñ�ʯ"}
	    ]
	   },
	   {friend_add,
	    [
	     {limit_exceeded, "�����Ѵ�����"},
	     {aim_limit_exceeded, "�Է������Ѵ�����"},
	     {self, "��������Լ�"},
	     {exist, "�Ѵ���"},
	     {offline, "�����������"}
	    ]
	   },
	   {mall_buy,
	    [
	     {times_exceeded, "�޹���Ʒ�����������"},
	     {money_not_enough, "Ǯ����"},
	     {not_on_sale, "δ�ϼ�"},
	     {pack_exceeded, "��������"}
	    ]
	   },
	   {point_mall_buy,
	    [
	     {rank_not_enough, "���β���"},
	     {point_not_enough, "���ֲ���"},
	     {not_on_sale, "δ�ϼ�"},
	     {pack_exceeded, "��������"}
	    ]
	   },
	   {power_hp,
	    [
	     {emoney_not_enough, "���Ҳ���"},
	     {limit_exceeded, "��������Ѵ�����"}
	    ]
	   },
	   {extend_pack,
	    [
	     {is_max, "�Ѵ�����"},
	     {emoney_not_enough, "���Ҳ���"}
	    ]
	   },
	   {pack_sale,
	    [
	     {not_exists, "��Ʒ������"},
	     {amount_error, "��������"}
	    ]
	   },
	   {summon_stone,
	    [
	     {already_award, "�ٻ�ʯ����ȡ"},
	     {emoney_not_enough_to_buy, "���Ҳ��㹻,�޷�����"},
	     {buy_times_exceeded, "��������ﵽ����"}		 
	    ]
	   },
	   {sculpture,
	    [
	     {upgrade_money_not_enough, "��������Ǯ����"},
	     {upgrade_is_max_lev, "������ߵȼ�"},
	     {takeoff_empty, "ûװ���ģ�����ж��,������Ҫ�Ǹ��ͻ��˿���"},
	     {puton_noexist, "�����Ҳ���������Ʒ"},
	     {puton_role_type_not_match, "����ְҵ������"},
	     {divine_money_not_enough, "����ռ��ʱǮ����"},
	     {takeoff_pack_full, "�ѷ���ʱ���ֱ�������"},
	     {puton_skill_repeat, "���ļ����ظ�"},
	     {frag_not_enough, "������Ƭ����"},
	     {divine_pack_full, "����ռ��ʱ��������"},
	     {convert_pack_full, "���Ķһ�ʱ��������"},
	     {divine_level_up, "����ռ��������"},
	     {divine_level_down, "����ռ��������"},
	     {pos_has_puton, "��ǰλ����װ������"},
	     {sale_is_on_body, "��װ����"},
	     {sale_noexist, "�����Ҳ���������Ʒ"},
	     {upgrade_is_expsculp, "�Ǿ�����Ĳ��ܳ���"},
	     {puton_is_expsculpture, "�Ǿ�������޷�װ��"}
	    ]
	   },
	   {task,
	    [
	     {not_exist, "���񲻴��ڣ��޷��������"},
	     {monster_amount_not_enough, "�����������㣬�޷��������"},
	     {not_pass, "��ͨͨ��û�����޷��������"},
	     {not_full_star_pass, "û3��ͨ�أ��޷��������"},
	     {not_kill_all_pass, "ûȫ��ɱ��ͨ�أ��޷��������"},
	     {has_finished, "��������ɣ��޷��������"},
	     {player_level_not_enough, "�ȼ����㣬�޷��������"},
	     {item_amount_not_enough, "�ռ���Ʒ�������޷��������"},
	     {sculpture_upgrade_amount_not_enough, "���ĳ��ܴ�������"},
		 {advance_equipment_amount_not_enough, "����װ����������"},
		 {equipment_resolve_amount_not_enough, "װ���ֽ��������"},
		 {sculpture_divine_amount_not_enough, "ռ����������"}
	    ]
	   },
	   {daily_award,
	    [
	     {get_already, "�Ѿ���ȡ"},
	     {cannot_get, "δ�ﵽ��ȡ����"}
	    ]
	   },
	   {broadcast,
	    [
	     {divine_sculpture_lev5, "ռ������׷���"},
	     {convert_sculpture_lev6, "�һ����׷���"},
	     {buy_sculpture_lev6, "�������׷���"},
	     {advance_orange_equipment, "����Ϊ��ɫװ��"},
	     {become_generalissimo, "��Ϊ��Ԫ˧"},
	     {become_vip, "��ΪVIP"},
	     {buy_advanced_item, "����߼���Ʒ"},
	     {advance_equipment_success, "��ϲXX����װ���ɹ�"},
				{advance_role_success, "��ϲXX���׳ɹ�"},
				{advance_skill_success, "��ϲXX���������׳ɹ�"}
			]
	   },
	   {clean_up_copy,
	    [
	     {not_card, "û��ɨ����"},
	     {not_max_score, "������ͨ��"},
	     {not_base_copy, "�����߸���"},
	     {ph_not_enough, "��������"},
	     {clean_up_card_not_enough, "ɨ��������"},
	     {pass_copy_not_enough, "xx����δͨ��"}
	    ]
	   },
	   {train_match,
	   [
	    {buy_times_not_enough_emoney, "����ʱ���Ҳ���"},
	    {buy_times_exceeded, "���������������"},
	    {refresh_not_enough_emoney, "����ˢ��ʱ��⵽���Ҳ���"},
	    {against_enemy_not_exist, "ѵ������ս�Ķ��󲻴���"},
	    {against_leverr, "�ȼ������޷����ɵ�ͼ"},
	    {times_exceeded, "���������Ѿ�����"},
	    {has_train, "ѡ��Ķ����Ѿ������"},
	    {award_times_not_enough, "�����������ʧ��"},
	    {award_has_get, "�Ѿ���ȡ��"},
	    {settle_not_info, "δ�ҵ�������Ϣ"},
	    {settle_info_error, "������Ϣ�д�"}
	   ]},
	   {use_props,
	    [
	     {not_props, "ѡ�����Ʒ���ǿ�ʹ�õ���"},
	     {not_exists, "��������ID���ڱ�����"}
	    ]
	   },
	   {benison,
	    [
	     {refresh_not_enough_gold, "ˢ��û���㹻�Ľ��"},
	     {bless_id_not_exist, "��������ף��ID������"},
	     {bless_emoney_not_enough, "���Ҳ��㲻��ף��"},
	     {bless_has_active, "�Ѿ������"}
	    ]
	   },
	   {activeness,
	    [
	     {reward_point_not_enough, "��Ծ���������޷�����ȡ"},
	     {reward_has_gotten, "�Ѿ���ȡ"}
	    ]
	   },
	   {reconnect, 
	    [
	     {token_err, "Token����"},
	     {server_not_running, "������δ����"}
	    ]
	   },
	   {ladder_match,
	    [
	     {buy_times_exceeded, "��������Ѵ�����"},
	     {award_gotten, "��������ȡ"},
	     {award_disable, "�޽�����ȡ"},
	     {times_exceeded, "����������"},
	     {emoney_not_enough, "���Ҳ���"},
	     {settle_error, "����ʱϵͳ����"}
	    ]
	   },
	   {equipment_exchange,
	    [
	     {disable, "�޷�ת��"},
	     {gold_err, "��Ҳ���"},
	     {meterial, "���ϲ���"}
	    ]
	   },
	   {online_award,
	    [
	     {lev_err, "ID��Ӧ�ĵȼ��д�"},
	     {time_err, "ʱ�䲻��"},
	     {has_gotten, "�Ѿ���ȡ"}
	    ]
	   },
	   {exchange,
	    [
	     {item_not_enough, "���ϲ���"}
	    ]
	   },
	   {military_rank,
	    [
	     {level_err, "�ȼ�����"}
	    ]
	   },
	   {mooncard,
	    [
	     {daily_award_gotten, "�¿���ÿ�ս����Ѿ���ȡ"},
	     {daily_award_disable, "û���¿����޷���ȡ"}
	    ]
	   },
	   {invitation_code,
	    [
	     {code_err, "������������벻����"},
	     {verify_code_succeed, "�ɹ��󶨺��ѣ��󶨺��ѿ���"},
	     {disengage_err, "���ĺ�����ʮ���ڵ�¼����Ϸ���޷��Ͼ���ϵ"},
	     {invite_num_is_full, "������������"},
		 {can_not_use_at_same_account, "�޷�����ͬ���˺ŵĽ�ɫ"}
	    ]
	   },
	   {world_chat,
	    [
	     {too_quick, "����̫��Ƶ��"},
	     {mute, "��ұ�����"},
	     {emoney_not_enough, "ħʯ����"}
	    ]
	   },
	   {activity_copy,
	    [
	     {times_use_up, "�������������"},
	     {ph_not_enough, "��������"},
	     {level_not_enough, "�ȼ�����"},
	     {not_open, "δ����"}
	    ]
	   },
	   {friend_help,
	    [
	     {hp_has_send, "�������ͳ�"}
	    ]
	   },
           {talent,
             [
              {layer_unlock,"�츳δ����"},
              {server_error,"�������쳣"},
              {actived,"�츳�Ѽ���"},
              {actived_two,"ÿ���������һ��"},
              {not_enough_frag,"������Ƭ����"},
              {max_level,"�ﵽ��ߵȼ�"},
              {emoney_not_enough,"ħʯ����"},
              {unactived,"�츳δ����"},
              {actived_reseted,"�Ѿ�Ϊ����״̬�������ظ�����"}
             ]
           }
	  ])
       ).
