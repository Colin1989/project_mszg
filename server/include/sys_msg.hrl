%%sys_msg_def


%%service
-define(sg_service_broadcast, 1).     %%�㲥
-define(sg_service_is_busy_now, 2).     %%��������æ
-define(sg_service_be_kick, 3).     %%��ɫ����
-define(sg_service_error, 4).     %%����������


%%login
-define(sg_login_passward_error, 5).     %%�������
-define(sg_login_no_register, 6).     %%δע��
-define(sg_login_version_error, 7).     %%�汾����
-define(sg_login_repeat_login, 8).     %%�����ط���¼
-define(sg_login_status_err, 9).     %%�˺ű���


%%select_role
-define(sg_select_role_roleid_err, 10).     %%��������ID����
-define(sg_select_role_already_del, 11).     %%�ѱ�ɾ��
-define(sg_select_role_locked, 12).     %%�˺ű���ͣ


%%del_role
-define(sg_del_role_roleid_err, 13).     %%��������ID����
-define(sg_del_role_already_del, 14).     %%�ѱ�ɾ��


%%recover_role
-define(sg_recover_role_roleid_err, 15).     %%��������ID����
-define(sg_recover_role_status_normal, 16).     %%������ɾ��״̬
-define(sg_recover_role_status_remove, 17).     %%�ѱ�����ɾ��
-define(sg_recover_role_emoney_not_enough, 18).     %%���Ҳ���
-define(sg_recover_role_amount_exceeded, 19).     %%��������


%%create_role
-define(sg_create_role_name_exist, 20).     %%������ɫ�����Ѵ���
-define(sg_create_role_not_login, 21).     %%δ��¼
-define(sg_create_role_amount_exceeded, 22).     %%��������
-define(sg_create_role_type_error, 23).     %%���ʹ���


%%register
-define(sg_register_account_exist, 24).     %%��ע��


%%assistance
-define(sg_assistance_no_req_list, 25).     %%δ����Ԯ���б�
-define(sg_assistance_select_id_not_in_list, 26).     %%ѡ���Ԯ�������б���
-define(sg_assistance_get_lottery_item_err, 27).     %%��ȡҡ����Ʒ����


%%reborn
-define(sg_reborn_emoney_not_enough, 28).     %%���Ҳ���


%%push_tower
-define(sg_push_tower_buy_emoney_not_enough, 29).     %%��������������Ǯ����
-define(sg_push_tower_buy_times_exceeded, 30).     %%�Ѵﹺ������
-define(sg_push_tower_enter_level_nomatch, 31).     %%�ȼ���ƥ��
-define(sg_push_tower_times_exceeded, 32).     %%��������
-define(sg_push_tower_settle_gameinfo_not_exist, 33).     %%����ʱ��Ϣ������
-define(sg_push_tower_settle_items_not_right, 34).     %%�ͻ��˷���������Ʒ����
-define(sg_push_tower_settle_round_not_enouth, 35).     %%�غ�������
-define(sg_push_tower_settle_cost_round_illegel, 36).     %%���ĵĻغ����Ƿ�
-define(sg_push_tower_settle_gameid_not_match, 37).     %%��ϷID��ƥ��


%%game
-define(sg_game_settle_error, 38).     %%�������
-define(sg_game_settle_item_exceeded, 39).     %%�񵽵���Ʒ��������
-define(sg_game_settle_gold_exceeded, 40).     %%�񵽵Ľ�ҳ�������
-define(sg_game_not_enough_power, 41).     %%��������
-define(sg_game_not_enough_summon_stone, 42).     %%�ٻ�ʯ����
-define(sg_game_copy_lock, 43).     %%δ����
-define(sg_game_emoney_not_enough, 44).     %%���Ҳ���
-define(sg_game_level_not_enough, 45).     %%�������ȼ�����
-define(sg_game_copy_not_pass, 46).     %%����δͨ��


%%challenge
-define(sg_challenge_buy_times_not_enough_emoney, 47).     %%������ս��Ǯ����
-define(sg_challenge_buy_times_exceeded, 48).     %%��������Ѵ�����
-define(sg_challenge_enemy_noexist, 49).     %%��ս�߲�����
-define(sg_challenge_noreq_list, 50).     %%δ������ս�б�
-define(sg_challenge_times_use_up, 51).     %%��ս��������
-define(sg_challenge_self, 52).     %%������ս�Լ�
-define(sg_challenge_level_err, 53).     %%�ȼ�����
-define(sg_challenge_settle_not_info, 54).     %%����ʱս����Ϣ������
-define(sg_challenge_settle_info_err, 55).     %%ս����Ϣ�д�
-define(sg_challenge_rank_award_in_cd, 56).     %%��ȴ��
-define(sg_challenge_rank_award_not_in_rank, 57).     %%���ڿ���ȡ������


%%equipment_takeoff
-define(sg_equipment_takeoff_pack_full, 58).     %%��������
-define(sg_equipment_takeoff_type_error, 59).     %%��������λ���д�


%%equipment_puton
-define(sg_equipment_puton_noexist, 60).     %%װ��������
-define(sg_equipment_puton_levelerr, 61).     %%�ȼ���ƥ��
-define(sg_equipment_puton_roletypeerr, 62).     %%��ɫ���Ͳ�ƥ��
-define(sg_equipment_puton_notowner, 63).     %%����ӵ����
-define(sg_equipment_puton_itemtypeerr, 64).     %%��Ʒ���ʹ���


%%equipment_streng
-define(sg_equipment_streng_cannot_streng, 65).     %%�޷�ǿ����û�п�ǿ��
-define(sg_equipment_streng_gold_not_enough, 66).     %%��Ҳ���
-define(sg_equipment_streng_item_not_enough, 67).     %%��Ʒ����
-define(sg_equipment_streng_streng_failed, 68).     %%ǿ��ʧ��
-define(sg_equipment_streng_strenged_top, 69).     %%�Ѿ�ǿ��������


%%equipment_advance
-define(sg_equipment_advance_can_not_advance, 70).     %%û�пɽ���ID
-define(sg_equipment_advance_gold_not_enough, 71).     %%��Ҳ���
-define(sg_equipment_advance_item_not_enough, 72).     %%���ϲ��㲻��
-define(sg_equipment_advance_level_not_enough, 73).     %%װ���ȼ�����


%%equipment_recast
-define(sg_equipment_recast_can_not_recast, 74).     %%û�пɽ���ID
-define(sg_equipment_recast_gold_not_enough, 75).     %%��Ҳ���
-define(sg_equipment_recast_item_not_enough, 76).     %%���ϲ��㲻��


%%equipment_resolve
-define(sg_equipment_resolve_disable, 77).     %%�޷��ֽ�
-define(sg_equipment_resolve_on_body, 78).     %%�޷��ֽ����ϵ�װ��
-define(sg_equipment_resolve_not_exist, 79).     %%�����ڸ�װ��


%%gem_mount
-define(sg_gem_mount_typeexist, 80).     %%�󶨵ı�ʯ�����Ѵ���
-define(sg_gem_mount_not_trough, 81).     %%û�в��


%%equipment_save_recast
-define(sg_equipment_save_recast_iderr, 82).     %%IDû��δ�����������Ϣ


%%gem_compound
-define(sg_gem_compound_not_related, 83).     %%�޿ɺϳɵ�Ŀ�걦ʯ
-define(sg_gem_compound_not_enough_gold, 84).     %%��Ҳ���
-define(sg_gem_compound_not_protect, 85).     %%û�б�����
-define(sg_gem_compound_gem_not_enough, 86).     %%��ʯ����
-define(sg_gem_compound_pack_full, 87).     %%��������


%%gem_unmounted
-define(sg_gem_unmounted_equip_notexist, 88).     %%װ��������
-define(sg_gem_unmounted_pack_full, 89).     %%��������
-define(sg_gem_unmounted_emoney_not_enough, 90).     %%���Ҳ���
-define(sg_gem_unmounted_notexist, 91).     %%װ���ϲ����ڸñ�ʯ


%%friend_add
-define(sg_friend_add_limit_exceeded, 92).     %%�����Ѵ�����
-define(sg_friend_add_aim_limit_exceeded, 93).     %%�Է������Ѵ�����
-define(sg_friend_add_self, 94).     %%��������Լ�
-define(sg_friend_add_exist, 95).     %%�Ѵ���
-define(sg_friend_add_offline, 96).     %%�����������


%%mall_buy
-define(sg_mall_buy_times_exceeded, 97).     %%�޹���Ʒ�����������
-define(sg_mall_buy_money_not_enough, 98).     %%Ǯ����
-define(sg_mall_buy_not_on_sale, 99).     %%δ�ϼ�
-define(sg_mall_buy_pack_exceeded, 100).     %%��������


%%point_mall_buy
-define(sg_point_mall_buy_rank_not_enough, 101).     %%���β���
-define(sg_point_mall_buy_point_not_enough, 102).     %%���ֲ���
-define(sg_point_mall_buy_not_on_sale, 103).     %%δ�ϼ�
-define(sg_point_mall_buy_pack_exceeded, 104).     %%��������


%%power_hp
-define(sg_power_hp_emoney_not_enough, 105).     %%���Ҳ���
-define(sg_power_hp_limit_exceeded, 106).     %%��������Ѵ�����


%%extend_pack
-define(sg_extend_pack_is_max, 107).     %%�Ѵ�����
-define(sg_extend_pack_emoney_not_enough, 108).     %%���Ҳ���


%%pack_sale
-define(sg_pack_sale_not_exists, 109).     %%��Ʒ������
-define(sg_pack_sale_amount_error, 110).     %%��������


%%summon_stone
-define(sg_summon_stone_already_award, 111).     %%�ٻ�ʯ����ȡ
-define(sg_summon_stone_emoney_not_enough_to_buy, 112).     %%���Ҳ��㹻,�޷�����
-define(sg_summon_stone_buy_times_exceeded, 113).     %%��������ﵽ����


%%sculpture
-define(sg_sculpture_upgrade_money_not_enough, 114).     %%��������Ǯ����
-define(sg_sculpture_upgrade_is_max_lev, 115).     %%������ߵȼ�
-define(sg_sculpture_takeoff_empty, 116).     %%ûװ���ģ�����ж��,������Ҫ�Ǹ��ͻ��˿���
-define(sg_sculpture_puton_noexist, 117).     %%�����Ҳ���������Ʒ
-define(sg_sculpture_puton_role_type_not_match, 118).     %%����ְҵ������
-define(sg_sculpture_divine_money_not_enough, 119).     %%����ռ��ʱǮ����
-define(sg_sculpture_takeoff_pack_full, 120).     %%�ѷ���ʱ���ֱ�������
-define(sg_sculpture_puton_skill_repeat, 121).     %%���ļ����ظ�
-define(sg_sculpture_frag_not_enough, 122).     %%������Ƭ����
-define(sg_sculpture_divine_pack_full, 123).     %%����ռ��ʱ��������
-define(sg_sculpture_convert_pack_full, 124).     %%���Ķһ�ʱ��������
-define(sg_sculpture_divine_level_up, 125).     %%����ռ��������
-define(sg_sculpture_divine_level_down, 126).     %%����ռ��������
-define(sg_sculpture_pos_has_puton, 127).     %%��ǰλ����װ������
-define(sg_sculpture_sale_is_on_body, 128).     %%��װ����
-define(sg_sculpture_sale_noexist, 129).     %%�����Ҳ���������Ʒ
-define(sg_sculpture_upgrade_is_expsculp, 130).     %%�Ǿ�����Ĳ��ܳ���
-define(sg_sculpture_puton_is_expsculpture, 131).     %%�Ǿ�������޷�װ��


%%task
-define(sg_task_not_exist, 132).     %%���񲻴��ڣ��޷��������
-define(sg_task_monster_amount_not_enough, 133).     %%�����������㣬�޷��������
-define(sg_task_not_pass, 134).     %%��ͨͨ��û�����޷��������
-define(sg_task_not_full_star_pass, 135).     %%û3��ͨ�أ��޷��������
-define(sg_task_not_kill_all_pass, 136).     %%ûȫ��ɱ��ͨ�أ��޷��������
-define(sg_task_has_finished, 137).     %%��������ɣ��޷��������
-define(sg_task_player_level_not_enough, 138).     %%�ȼ����㣬�޷��������
-define(sg_task_item_amount_not_enough, 139).     %%�ռ���Ʒ�������޷��������
-define(sg_task_sculpture_upgrade_amount_not_enough, 140).     %%���ĳ��ܴ�������
-define(sg_task_advance_equipment_amount_not_enough, 141).     %%����װ����������
-define(sg_task_equipment_resolve_amount_not_enough, 142).     %%װ���ֽ��������
-define(sg_task_sculpture_divine_amount_not_enough, 143).     %%ռ����������


%%daily_award
-define(sg_daily_award_get_already, 144).     %%�Ѿ���ȡ
-define(sg_daily_award_cannot_get, 145).     %%δ�ﵽ��ȡ����


%%broadcast
-define(sg_broadcast_divine_sculpture_lev5, 146).     %%ռ������׷���
-define(sg_broadcast_convert_sculpture_lev6, 147).     %%�һ����׷���
-define(sg_broadcast_buy_sculpture_lev6, 148).     %%�������׷���
-define(sg_broadcast_advance_orange_equipment, 149).     %%����Ϊ��ɫװ��
-define(sg_broadcast_become_generalissimo, 150).     %%��Ϊ��Ԫ˧
-define(sg_broadcast_become_vip, 151).     %%��ΪVIP
-define(sg_broadcast_buy_advanced_item, 152).     %%����߼���Ʒ
-define(sg_broadcast_advance_equipment_success, 153).     %%��ϲXX����װ���ɹ�
-define(sg_broadcast_advance_role_success, 154).     %%��ϲXX���׳ɹ�
-define(sg_broadcast_advance_skill_success, 155).     %%��ϲXX���������׳ɹ�


%%clean_up_copy
-define(sg_clean_up_copy_not_card, 156).     %%û��ɨ����
-define(sg_clean_up_copy_not_max_score, 157).     %%������ͨ��
-define(sg_clean_up_copy_not_base_copy, 158).     %%�����߸���
-define(sg_clean_up_copy_ph_not_enough, 159).     %%��������
-define(sg_clean_up_copy_clean_up_card_not_enough, 160).     %%ɨ��������
-define(sg_clean_up_copy_pass_copy_not_enough, 161).     %%xx����δͨ��


%%train_match
-define(sg_train_match_buy_times_not_enough_emoney, 162).     %%����ʱ���Ҳ���
-define(sg_train_match_buy_times_exceeded, 163).     %%���������������
-define(sg_train_match_refresh_not_enough_emoney, 164).     %%����ˢ��ʱ��⵽���Ҳ���
-define(sg_train_match_against_enemy_not_exist, 165).     %%ѵ������ս�Ķ��󲻴���
-define(sg_train_match_against_leverr, 166).     %%�ȼ������޷����ɵ�ͼ
-define(sg_train_match_times_exceeded, 167).     %%���������Ѿ�����
-define(sg_train_match_has_train, 168).     %%ѡ��Ķ����Ѿ������
-define(sg_train_match_award_times_not_enough, 169).     %%�����������ʧ��
-define(sg_train_match_award_has_get, 170).     %%�Ѿ���ȡ��
-define(sg_train_match_settle_not_info, 171).     %%δ�ҵ�������Ϣ
-define(sg_train_match_settle_info_error, 172).     %%������Ϣ�д�


%%use_props
-define(sg_use_props_not_props, 173).     %%ѡ�����Ʒ���ǿ�ʹ�õ���
-define(sg_use_props_not_exists, 174).     %%��������ID���ڱ�����


%%benison
-define(sg_benison_refresh_not_enough_gold, 175).     %%ˢ��û���㹻�Ľ��
-define(sg_benison_bless_id_not_exist, 176).     %%��������ף��ID������
-define(sg_benison_bless_emoney_not_enough, 177).     %%���Ҳ��㲻��ף��
-define(sg_benison_bless_has_active, 178).     %%�Ѿ������


%%activeness
-define(sg_activeness_reward_point_not_enough, 179).     %%��Ծ���������޷�����ȡ
-define(sg_activeness_reward_has_gotten, 180).     %%�Ѿ���ȡ


%%reconnect
-define(sg_reconnect_token_err, 181).     %%Token����
-define(sg_reconnect_server_not_running, 182).     %%������δ����


%%ladder_match
-define(sg_ladder_match_buy_times_exceeded, 183).     %%��������Ѵ�����
-define(sg_ladder_match_award_gotten, 184).     %%��������ȡ
-define(sg_ladder_match_award_disable, 185).     %%�޽�����ȡ
-define(sg_ladder_match_times_exceeded, 186).     %%����������
-define(sg_ladder_match_emoney_not_enough, 187).     %%���Ҳ���
-define(sg_ladder_match_settle_error, 188).     %%����ʱϵͳ����


%%equipment_exchange
-define(sg_equipment_exchange_disable, 189).     %%�޷�ת��
-define(sg_equipment_exchange_gold_err, 190).     %%��Ҳ���
-define(sg_equipment_exchange_meterial, 191).     %%���ϲ���


%%online_award
-define(sg_online_award_lev_err, 192).     %%ID��Ӧ�ĵȼ��д�
-define(sg_online_award_time_err, 193).     %%ʱ�䲻��
-define(sg_online_award_has_gotten, 194).     %%�Ѿ���ȡ


%%exchange
-define(sg_exchange_item_not_enough, 195).     %%���ϲ���


%%military_rank
-define(sg_military_rank_level_err, 196).     %%�ȼ�����


%%mooncard
-define(sg_mooncard_daily_award_gotten, 197).     %%�¿���ÿ�ս����Ѿ���ȡ
-define(sg_mooncard_daily_award_disable, 198).     %%û���¿����޷���ȡ


%%invitation_code
-define(sg_invitation_code_code_err, 199).     %%������������벻����
-define(sg_invitation_code_verify_code_succeed, 200).     %%�ɹ��󶨺��ѣ��󶨺��ѿ���
-define(sg_invitation_code_disengage_err, 201).     %%���ĺ�����ʮ���ڵ�¼����Ϸ���޷��Ͼ���ϵ
-define(sg_invitation_code_invite_num_is_full, 202).     %%������������
-define(sg_invitation_code_can_not_use_at_same_account, 203).     %%�޷�����ͬ���˺ŵĽ�ɫ


%%world_chat
-define(sg_world_chat_too_quick, 204).     %%����̫��Ƶ��
-define(sg_world_chat_mute, 205).     %%��ұ�����
-define(sg_world_chat_emoney_not_enough, 206).     %%ħʯ����


%%activity_copy
-define(sg_activity_copy_times_use_up, 207).     %%�������������
-define(sg_activity_copy_ph_not_enough, 208).     %%��������
-define(sg_activity_copy_level_not_enough, 209).     %%�ȼ�����
-define(sg_activity_copy_not_open, 210).     %%δ����


%%friend_help
-define(sg_friend_help_hp_has_send, 211).     %%�������ͳ�


%%talent
-define(sg_talent_layer_unlock, 212).     %%�츳δ����
-define(sg_talent_server_error, 213).     %%�������쳣
-define(sg_talent_actived, 214).     %%�츳�Ѽ���
-define(sg_talent_actived_two, 215).     %%ÿ���������һ��
-define(sg_talent_not_enough_frag, 216).     %%������Ƭ����
-define(sg_talent_max_level, 217).     %%�ﵽ��ߵȼ�
-define(sg_talent_emoney_not_enough, 218).     %%ħʯ����
-define(sg_talent_unactived, 219).     %%�츳δ����
-define(sg_talent_actived_reseted, 220).     %%�Ѿ�Ϊ����״̬�������ظ�����
