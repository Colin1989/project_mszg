%%sys_msg_def


%%login
-define(sg_login_passward_error, 1).     %%�������
-define(sg_login_no_register, 2).     %%δע��
-define(sg_login_version_error, 3).     %%�汾����
-define(sg_login_repeat_login, 4).     %%�����ط���¼
-define(sg_login_status_err, 5).     %%�˺ű���


%%select_role
-define(sg_select_role_roleid_err, 6).     %%��������ID����
-define(sg_select_role_already_del, 7).     %%�ѱ�ɾ��


%%del_role
-define(sg_del_role_roleid_err, 8).     %%��������ID����
-define(sg_del_role_already_del, 9).     %%�ѱ�ɾ��


%%recover_role
-define(sg_recover_role_roleid_err, 10).     %%��������ID����
-define(sg_recover_role_status_normal, 11).     %%������ɾ��״̬
-define(sg_recover_role_status_remove, 12).     %%�ѱ�����ɾ��
-define(sg_recover_role_emoney_not_enough, 13).     %%���Ҳ���
-define(sg_recover_role_amount_exceeded, 14).     %%��������


%%create_role
-define(sg_create_role_name_exist, 15).     %%������ɫ�����Ѵ���
-define(sg_create_role_not_login, 16).     %%δ��¼
-define(sg_create_role_amount_exceeded, 17).     %%��������
-define(sg_create_role_type_error, 18).     %%���ʹ���


%%register
-define(sg_register_account_exist, 19).     %%��ע��


%%assistance
-define(sg_assistance_no_req_list, 20).     %%δ����Ԯ���б�
-define(sg_assistance_select_id_not_in_list, 21).     %%ѡ���Ԯ�������б���


%%reborn
-define(sg_reborn_emoney_not_enough, 22).     %%���Ҳ���


%%push_tower
-define(sg_push_tower_enter_level_nomatch, 23).     %%�ȼ���ƥ��
-define(sg_push_tower_times_exceeded, 24).     %%��������
-define(sg_push_tower_settle_gameinfo_not_exist, 25).     %%����ʱ��Ϣ������
-define(sg_push_tower_settle_items_not_right, 26).     %%�ͻ��˷���������Ʒ����
-define(sg_push_tower_settle_round_not_enouth, 27).     %%�غ�������
-define(sg_push_tower_settle_cost_round_illegel, 28).     %%���ĵĻغ����Ƿ�
-define(sg_push_tower_settle_gameid_not_match, 29).     %%��ϷID��ƥ��


%%game
-define(sg_game_settle_error, 30).     %%�������
-define(sg_game_settle_item_exceeded, 31).     %%�񵽵���Ʒ��������
-define(sg_game_settle_gold_exceeded, 32).     %%�񵽵Ľ�ҳ�������
-define(sg_game_not_enough_power, 33).     %%��������
-define(sg_game_not_enough_summon_stone, 34).     %%�ٻ�ʯ����
-define(sg_game_copy_lock, 35).     %%δ����
-define(sg_game_emoney_not_enough, 36).     %%���Ҳ���


%%challenge
-define(sg_challenge_enemy_noexist, 37).     %%��ս�߲�����
-define(sg_challenge_noreq_list, 38).     %%δ������ս�б�
-define(sg_challenge_times_use_up, 39).     %%��ս��������
-define(sg_challenge_self, 40).     %%������ս�Լ�
-define(sg_challenge_level_err, 41).     %%�ȼ�����
-define(sg_challenge_settle_not_info, 42).     %%����ʱս����Ϣ������
-define(sg_challenge_settle_info_err, 43).     %%ս����Ϣ�д�
-define(sg_challenge_rank_award_in_cd, 44).     %%��ȴ��
-define(sg_challenge_rank_award_not_in_rank, 45).     %%���ڿ���ȡ������


%%equipment_takeoff
-define(sg_equipment_takeoff_pack_full, 46).     %%��������
-define(sg_equipment_takeoff_type_error, 47).     %%��������λ���д�


%%equipment_puton
-define(sg_equipment_puton_noexist, 48).     %%װ��������
-define(sg_equipment_puton_levelerr, 49).     %%�ȼ���ƥ��
-define(sg_equipment_puton_roletypeerr, 50).     %%��ɫ���Ͳ�ƥ��
-define(sg_equipment_puton_notowner, 51).     %%����ӵ����
-define(sg_equipment_puton_itemtypeerr, 52).     %%��Ʒ���ʹ���


%%equipment_streng
-define(sg_equipment_streng_cannot_streng, 53).     %%�޷�ǿ����û�п�ǿ��
-define(sg_equipment_streng_gold_not_enough, 54).     %%��Ҳ���
-define(sg_equipment_streng_item_not_enough, 55).     %%��Ʒ����
-define(sg_equipment_streng_streng_failed, 56).     %%ǿ��ʧ��


%%equipment_advance
-define(sg_equipment_advance_can_not_advance, 57).     %%û�пɽ���ID
-define(sg_equipment_advance_gold_not_enough, 58).     %%��Ҳ���
-define(sg_equipment_advance_item_not_enough, 59).     %%���ϲ��㲻��
-define(sg_equipment_advance_level_not_enough, 60).     %%װ���ȼ�����


%%equipment_recast
-define(sg_equipment_recast_can_not_recast, 61).     %%û�пɽ���ID
-define(sg_equipment_recast_gold_not_enough, 62).     %%��Ҳ���
-define(sg_equipment_recast_item_not_enough, 63).     %%���ϲ��㲻��


%%equipment_resolve
-define(sg_equipment_resolve_disable, 64).     %%�޷��ֽ�
-define(sg_equipment_resolve_on_body, 65).     %%�޷��ֽ����ϵ�װ��
-define(sg_equipment_resolve_not_exist, 66).     %%�����ڸ�װ��


%%gem_mount
-define(sg_gem_mount_typeexist, 67).     %%�󶨵ı�ʯ�����Ѵ���
-define(sg_gem_mount_not_trough, 68).     %%û�в��


%%equipment_save_recast
-define(sg_equipment_save_recast_iderr, 69).     %%IDû��δ�����������Ϣ


%%gem_compound
-define(sg_gem_compound_not_related, 70).     %%�޿ɺϳɵ�Ŀ�걦ʯ
-define(sg_gem_compound_not_enough_gold, 71).     %%��Ҳ���
-define(sg_gem_compound_not_protect, 72).     %%û�б�����
-define(sg_gem_compound_gem_not_enough, 73).     %%��ʯ����
-define(sg_gem_compound_pack_full, 74).     %%��������


%%gem_unmounted
-define(sg_gem_unmounted_equip_notexist, 75).     %%װ��������
-define(sg_gem_unmounted_pack_full, 76).     %%��������
-define(sg_gem_unmounted_emoney_not_enough, 77).     %%���Ҳ���
-define(sg_gem_unmounted_notexist, 78).     %%װ���ϲ����ڸñ�ʯ


%%friend_add
-define(sg_friend_add_limit_exceeded, 79).     %%�����Ѵ�����
-define(sg_friend_add_aim_limit_exceeded, 80).     %%�Է������Ѵ�����
-define(sg_friend_add_self, 81).     %%��������Լ�
-define(sg_friend_add_exist, 82).     %%�Ѵ���
-define(sg_friend_add_offline, 83).     %%�����������


%%mall_buy
-define(sg_mall_buy_times_exceeded, 84).     %%�޹���Ʒ�����������
-define(sg_mall_buy_money_not_enough, 85).     %%Ǯ����
-define(sg_mall_buy_not_on_sale, 86).     %%δ�ϼ�
-define(sg_mall_buy_pack_exceeded, 87).     %%��������


%%point_mall_buy
-define(sg_point_mall_buy_rank_not_enough, 88).     %%���β���
-define(sg_point_mall_buy_point_not_enough, 89).     %%���ֲ���
-define(sg_point_mall_buy_not_on_sale, 90).     %%δ�ϼ�
-define(sg_point_mall_buy_pack_exceeded, 91).     %%��������


%%power_hp
-define(sg_power_hp_emoney_not_enough, 92).     %%���Ҳ���
-define(sg_power_hp_limit_exceeded, 93).     %%��������Ѵ�����


%%extend_pack
-define(sg_extend_pack_is_max, 94).     %%�Ѵ�����
-define(sg_extend_pack_emoney_not_enough, 95).     %%���Ҳ���


%%pack_sale
-define(sg_pack_sale_not_exists, 96).     %%��Ʒ������
-define(sg_pack_sale_amount_error, 97).     %%��������


%%summon_stone
-define(sg_summon_stone_already_award, 98).     %%�ٻ�ʯ����ȡ
-define(sg_summon_stone_emoney_not_enough_to_buy, 99).     %%���Ҳ��㹻,�޷�����
-define(sg_summon_stone_buy_times_exceeded, 100).     %%��������ﵽ����


%%sculpture
-define(sg_sculpture_upgrade_money_not_enough, 101).     %%��������Ǯ����
-define(sg_sculpture_upgrade_is_max_lev, 102).     %%������ߵȼ�
-define(sg_sculpture_takeoff_empty, 103).     %%ûװ���ģ�����ж��,������Ҫ�Ǹ��ͻ��˿���
-define(sg_sculpture_puton_noexist, 104).     %%�����Ҳ���������Ʒ
-define(sg_sculpture_puton_role_type_not_match, 105).     %%����ְҵ������
-define(sg_sculpture_divine_money_not_enough, 106).     %%����ռ��ʱǮ����
-define(sg_sculpture_takeoff_pack_full, 107).     %%�ѷ���ʱ���ֱ�������
-define(sg_sculpture_puton_skill_repeat, 108).     %%���ļ����ظ�
-define(sg_sculpture_frag_not_enough, 109).     %%������Ƭ����
-define(sg_sculpture_divine_pack_full, 110).     %%����ռ��ʱ��������
-define(sg_sculpture_convert_pack_full, 111).     %%���Ķһ�ʱ��������
-define(sg_sculpture_divine_level_up, 112).     %%����ռ��������
-define(sg_sculpture_divine_level_down, 113).     %%����ռ��������
-define(sg_sculpture_pos_has_puton, 114).     %%��ǰλ����װ������
-define(sg_sculpture_sale_is_on_body, 115).     %%��װ����
-define(sg_sculpture_sale_noexist, 116).     %%�����Ҳ���������Ʒ
-define(sg_sculpture_upgrade_is_expsculp, 117).     %%�Ǿ�����Ĳ��ܳ���
-define(sg_sculpture_puton_is_expsculpture, 118).     %%�Ǿ�������޷�װ��


%%task
-define(sg_task_not_exist, 119).     %%���񲻴��ڣ��޷��������
-define(sg_task_monster_amount_not_enough, 120).     %%�����������㣬�޷��������
-define(sg_task_not_pass, 121).     %%��ͨͨ��û�����޷��������
-define(sg_task_not_full_star_pass, 122).     %%û3��ͨ�أ��޷��������
-define(sg_task_not_kill_all_pass, 123).     %%ûȫ��ɱ��ͨ�أ��޷��������
-define(sg_task_has_finished, 124).     %%��������ɣ��޷��������
-define(sg_task_player_level_not_enough, 125).     %%�ȼ����㣬�޷��������
-define(sg_task_item_amount_not_enough, 126).     %%�ռ���Ʒ�������޷��������
-define(sg_task_sculpture_upgrade_amount_not_enough, 127).     %%���ĳ��ܴ�������
-define(sg_task_advance_equipment_amount_not_enough, 128).     %%����װ����������
-define(sg_task_equipment_resolve_amount_not_enough, 129).     %%װ���ֽ��������
-define(sg_task_sculpture_divine_amount_not_enough, 130).     %%ռ����������


%%daily_award
-define(sg_daily_award_get_already, 131).     %%�Ѿ���ȡ
-define(sg_daily_award_cannot_get, 132).     %%δ�ﵽ��ȡ����


%%broadcast
-define(sg_broadcast_divine_sculpture_lev5, 133).     %%ռ������׷���
-define(sg_broadcast_convert_sculpture_lev6, 134).     %%�һ����׷���
-define(sg_broadcast_buy_sculpture_lev6, 135).     %%�������׷���


%%clean_up_copy
-define(sg_clean_up_copy_not_card, 136).     %%û��ɨ����
-define(sg_clean_up_copy_not_max_score, 137).     %%������ͨ��
-define(sg_clean_up_copy_not_base_copy, 138).     %%�����߸���
-define(sg_clean_up_copy_ph_not_enough, 139).     %%��������


%%train_match
-define(sg_train_match_buy_times_not_enough_emoney, 140).     %%����ʱ���Ҳ���
-define(sg_train_match_refresh_not_enough_emoney, 141).     %%����ˢ��ʱ��⵽���Ҳ���
-define(sg_train_match_against_enemy_not_exist, 142).     %%ѵ������ս�Ķ��󲻴���
-define(sg_train_match_against_leverr, 143).     %%�ȼ������޷����ɵ�ͼ
-define(sg_train_match_times_exceeded, 144).     %%���������Ѿ�����
-define(sg_train_match_has_train, 145).     %%ѡ��Ķ����Ѿ������
-define(sg_train_match_award_times_not_enough, 146).     %%�����������ʧ��
-define(sg_train_match_award_has_get, 147).     %%�Ѿ���ȡ��
-define(sg_train_match_settle_not_info, 148).     %%δ�ҵ�������Ϣ
-define(sg_train_match_settle_info_error, 149).     %%������Ϣ�д�


%%use_props
-define(sg_use_props_not_props, 150).     %%ѡ�����Ʒ���ǿ�ʹ�õ���
-define(sg_use_props_not_exists, 151).     %%��������ID���ڱ�����


%%benison
-define(sg_benison_refresh_not_enough_gold, 152).     %%ˢ��û���㹻�Ľ��
-define(sg_benison_bless_id_not_exist, 153).     %%��������ף��ID������
-define(sg_benison_bless_emoney_not_enough, 154).     %%���Ҳ��㲻��ף��
-define(sg_benison_bless_has_active, 155).     %%�Ѿ������


%%activeness
-define(sg_activeness_reward_point_not_enough, 156).     %%��Ծ���������޷�����ȡ
-define(sg_activeness_reward_has_gotten, 157).     %%�Ѿ���ȡ


%%reconnect
-define(sg_reconnect_token_err, 158).     %%Token����
