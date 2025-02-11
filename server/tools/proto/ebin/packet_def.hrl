-record(req_check_version, {version=0}).
-record(notify_check_version_result, {result=0}).
-record(req_login, {account="", password=""}).
-record(req_login_check, {uid="", token=""}).
-record(role_data, {role_id=0, role_status=0, type=0, lev=0, name="", is_del=0, time_left=0}).
-record(notifu_login_check_result, {result=0, error_code=0, emoney=0, role_infos=[]}).
-record(notify_login_result, {id=0, result=0, emoney=0, role_infos=[]}).
-record(notify_sys_msg, {code=0, params=[]}).
-record(req_select_role, {role_id=0}).
-record(notify_select_role_result, {result=0}).
-record(req_delete_role, {role_id=0}).
-record(notify_delete_role_result, {result=0}).
-record(req_recover_del_role, {role_id=0}).
-record(notify_recover_del_role_result, {result=0}).
-record(req_reselect_role, {}).
-record(notify_roles_infos, {emoney=0, role_infos=[]}).
-record(req_gm_optition, {opt_type=0, value=0}).
-record(player_data, {account="", username="", sex=0}).
-record(sculpture_data, {temp_id=0, level=0}).
-record(stime, {year=0, month=0, day=0, hour=0, minute=0, second=0}).
-record(mons_item, {id=0, amount=0}).
-record(reward_item, {id=0, amount=0}).
-record(smonster, {pos=0, monsterid=0, dropout=[]}).
-record(strap, {pos=0, trapid=0}).
-record(saward, {pos=0, awardid=0}).
-record(sfriend, {pos=0, friend_role_id=0}).
-record(battle_info, {sculpture=[], life=0, speed=0, atk=0, hit_ratio=0, miss_ratio=0, critical_ratio=0, tenacity=0, power=0}).
-record(talent, {talent_id=0, level=0}).
-record(senemy, {role_id=0, name="", pos=0, level=0, type=0, potence_level=0, advanced_level=0, battle_prop=#battle_info{}, talent_list=[], team_tag=0, id_leader=0, cur_life=0, mitigation=0}).
-record(game_map, {monster=[], key=0, start=0, award=[], trap=[], barrier=[], friend=[], scene=0, enemy=[], boss=[], boss_rule=0}).
-record(item, {inst_id=0, temp_id=0}).
-record(pack_item, {id=0, itemid=0, itemtype=0, amount=0}).
-record(copy_info, {copy_id=0, max_score=0, pass_times=0}).
-record(equipmentinfo, {equipment_id=0, temp_id=0, strengthen_level=0, gems=[], attr_ids=[], gem_extra=0, bindtype=0, bindstatus=0}).
-record(extra_item, {item_id=0, count=0}).
-record(friend_data, {nickname="", status=0, head=0, level=0, public="", battle_prop=#battle_info{}, potence_level=0, advanced_level=0}).
-record(friend_info, {friend_id=0, nickname="", status=0, head=0, level=0, public="", battle_prop=#battle_info{}, potence_level=0, advanced_level=0, my_send_status=0, friend_send_status=0, is_comrade=0}).
-record(award_item, {temp_id=0, amount=0}).
-record(challenge_info, {name="", result=0, new_rank=0}).
-record(rank_info, {role_id=0, name="", type=0, rank=0, level=0, potence_level=0, advanced_level=0, power=0}).
-record(train_info, {role_id=0, name="", type=0, status=0, level=0, potence_level=0, advanced_level=0, power=0}).
-record(rank_data, {role_id=0, name="", type=0, rank=0, value=0, public=""}).
-record(donor, {role_id=0, rel=0, level=0, role_type=0, nick_name="", friend_point=0, power=0, sculpture=#sculpture_data{}, potence_level=0, advanced_level=0, is_used=0, is_robot=0}).
-record(mall_buy_info, {mallitem_id=0, times=0}).
-record(lottery_item, {reward_id=0, amount=0}).
-record(friend_point_lottery_item, {id=0, amount=0}).
-record(activeness_task_item, {id=0, count=0}).
-record(material_info, {material_id=0, amount=0}).
-record(clean_up_trophy, {item=[], gold=0, exp=0}).
-record(semail, {id=0, type="", title="", content="", attachments=[], recv_time=#stime{}, end_time=#stime{}}).
-record(leave_msg, {role_id=0, msg=""}).
-record(master_info, {role_id=0, name="", type=0, advanced_level=0, battle_power=0, level=0, status=0}).
-record(prentice_info, {role_id=0, name="", type=0, advanced_level=0, level=0, rewarded_list=[], status=0}).
-record(skill_group_item, {id1=0, id2=0, id3=0, id4=0, index=0}).
-record(notice_list_item, {id=0, title="", sub_title="", icon=0, mark_id=0, create_time=#stime{}, priority=0, top_pic=0, start_time=#stime{}, end_time=#stime{}}).
-record(notice_item_detail, {id=0, title="", sub_title="", icon=0, content="", toward_id=0, mark_id=0}).
-record(time_limit_rewarded_item, {id=0, count=0, rewarded_time=#stime{}}).
-record(role_life_info, {role_id=0, cur_life=0}).
-record(lottery_progress_item, {id=0, cur_count=0}).
-record(activity_item, {id=0, remain_seconds=0}).
-record(notify_heartbeat, {version=0}).
-record(notify_socket_close, {}).
-record(notify_repeat_login, {account=""}).
-record(req_register, {account="", channelid=0, platformid=0, password=""}).
-record(notify_register_result, {result=0}).
-record(req_create_role, {roletype=0, nickname=""}).
-record(notify_create_role_result, {result=0}).
-record(notify_roleinfo_msg, {id=0, nickname="", role_status=0, roletype=0, armor=0, weapon=0, ring=0, necklace=0, medal=0, jewelry=0, skill1=0, skill2=0, skill_group_index=0, level=0, exp=0, gold=0, emoney=0, summon_stone=0, power_hp=0, recover_time_left=0, power_hp_buy_times=0, pack_space=0, friend_point=0, point=0, honour=0, battle_power=0, alchemy_exp=0, battle_soul=0, potence_level=0, advanced_level=0, vip_level=0, vip_exp=0}).
-record(req_clean_up_copy, {copy_id=0, count=0}).
-record(notify_clean_up_copy_result, {result=0, trophy_list=[]}).
-record(req_enter_game, {id=0, gametype=0, copy_id=0}).
-record(notify_enter_game, {result=0, game_id=0, gamemaps=[]}).
-record(notify_last_copy, {last_copy_id=0, copyinfos=[]}).
-record(req_last_copy, {roleid=0}).
-record(req_buy_power_hp, {}).
-record(notify_buy_power_hp_result, {result=0}).
-record(notify_power_hp_msg, {result=0, power_hp=0}).
-record(notify_player_pack, {type=0, pack_items=[]}).
-record(req_game_settle, {game_id=0, result=0, life=0, maxlife=0, cost_round=0, pickup_items=[], user_operations=[], gold=0, killmonsters=[]}).
-record(notify_game_settle, {game_id=0, result=0, score=0, final_item=#lottery_item{}, ratio_items=[]}).
-record(req_game_lottery, {}).
-record(notify_game_lottery, {second_item=#lottery_item{}, result=0}).
-record(req_game_reconnect, {uid="", token="", role_id=0, last_recv_stepnum=0}).
-record(notify_reconnect_result, {id=0, result=0, last_recv_stepnum=0}).
-record(req_equipment_strengthen, {equipment_id=0}).
-record(notify_equipment_strengthen_result, {strengthen_result=0, gold=0}).
-record(req_one_touch_equipment_strengthen, {equipment_id=0}).
-record(notify_one_touch_equipment_strengthen_result, {result_list=[]}).
-record(req_equipment_mountgem, {equipment_id=0, gem_id=0}).
-record(notify_equipment_mountgem_result, {mountgem_result=0}).
-record(req_equipment_puton, {equipment_id=0}).
-record(notify_equipment_puton_result, {puton_result=0}).
-record(req_equipment_infos, {}).
-record(notify_equipment_infos, {type=0, equipment_infos=[]}).
-record(req_equipment_takeoff, {position=0}).
-record(notify_equipment_takeoff_result, {takeoff_result=0}).
-record(notify_gold_update, {gold=0}).
-record(notify_emoney_update, {emoney=0}).
-record(notify_summon_stone_info, {is_award=0, has_buy_times=0}).
-record(req_daily_summon_stone, {}).
-record(notify_daily_summon_stone, {result=0}).
-record(req_buy_summon_stone, {}).
-record(notify_buy_summon_stone, {result=0}).
-record(notify_player_pack_exceeded, {new_extra=[]}).
-record(req_extend_pack, {}).
-record(notify_extend_pack_result, {result=0}).
-record(req_sale_item, {inst_id=0, amount=0}).
-record(notify_sale_item_result, {result=0, gold=0}).
-record(req_sale_items, {inst_id=[]}).
-record(notify_sale_items_result, {result=0, err_id=0, gold=0}).
-record(req_search_friend, {nickname=""}).
-record(notify_search_friend_result, {result=0, role_info=#friend_info{}}).
-record(req_add_friend, {friend_id=0}).
-record(notify_add_friend_result, {result=0}).
-record(notify_req_for_add_friend, {friend_id=0, role_data=#friend_data{}}).
-record(req_proc_reqfor_add_friend, {answer=0, friend_id=0}).
-record(req_del_friend, {friend_id=0}).
-record(notify_del_friend_result, {result=0}).
-record(req_get_friends, {}).
-record(notify_friend_list, {type=0, friends=[]}).
-record(req_get_makefriend_reqs, {}).
-record(notify_makefriend_reqs, {reqs=[]}).
-record(notify_makefriend_reqs_amount, {amount=0}).
-record(notify_leave_msg_count, {count=0}).
-record(req_msg_list, {}).
-record(notify_msg_list, {msg_list=[]}).
-record(req_send_chat_msg, {friend_id=0, chat_msg=""}).
-record(notify_send_chat_msg_result, {result=0}).
-record(notify_receive_chat_msg, {friend_id=0, chat_msg=""}).
-record(req_push_tower_map_settle, {game_id=0, result=0, cost_round=0, life=0, pickup_items=[], drop_gold=0}).
-record(notify_push_tower_map_settle, {result=0, gamemap=[], awards=[], gold=0, exp=0}).
-record(req_push_tower_buy_round, {}).
-record(notify_push_tower_buy_round, {result=0}).
-record(req_push_tower_buy_playtimes, {}).
-record(notify_push_tower_buy_playtimes, {result=0}).
-record(req_reborn, {type=0}).
-record(notify_reborn_result, {result=0}).
-record(req_auto_fight, {}).
-record(notify_auto_fight_result, {result=0}).
-record(req_gem_compound, {temp_id=0, is_protect=0}).
-record(notify_gem_compound_result, {result=0, lost_gem_amount=0}).
-record(req_one_touch_gem_compound, {temp_id=0, is_protect=0}).
-record(notify_one_touch_gem_compound_result, {result_list=[]}).
-record(req_gem_unmounted, {equipment_id=0, gem_temp_id=0}).
-record(notify_gem_unmounted_result, {result=0}).
-record(req_push_tower_info, {}).
-record(notify_push_tower_info, {play_times=0, max_times=0, max_floor=0}).
-record(req_tutorial_progress, {}).
-record(notify_tutorial_progress, {progress=[]}).
-record(req_set_tutorial_progress, {progress=0}).
-record(notify_set_tutorial_progress_result, {result=0}).
-record(notify_today_activeness_task, {task_list=[], is_reward_activeness_item_info=[], activeness=0}).
-record(req_today_activeness_task, {}).
-record(req_activeness_reward, {reward=0}).
-record(notify_activeness_reward_result, {reward=0, result=0}).
-record(req_military_rank_reward, {}).
-record(notify_military_rank_reward_result, {result=0}).
-record(req_military_rank_info, {}).
-record(notify_military_rank_info, {level=0, is_rewarded=0}).
-record(notify_first_charge_info, {status=0}).
-record(req_first_charge_reward, {}).
-record(notify_first_charge_reward_result, {result=0}).
-record(notify_vip_reward_info, {level_rewarded_list=[], daily_rewarded=0}).
-record(req_vip_grade_reward, {level=0}).
-record(notify_vip_grade_reward_result, {result=0}).
-record(req_vip_daily_reward, {result=0}).
-record(notify_vip_daily_reward_result, {result=0}).
-record(req_recharge, {user_id=0, emoney=0, org_emoney=0, vip_exp=0}).
-record(notify_recharge_result, {result=0}).
-record(task_info, {task_id=0, has_finished=0, args=[]}).
-record(req_task_infos, {}).
-record(notify_task_infos, {type=0, infos=[]}).
-record(req_finish_task, {task_id=0}).
-record(notify_finish_task, {is_success=0, task_id=0}).
-record(sculpture_info, {temp_id=0, value=0, type=0}).
-record(req_sculpture_infos, {}).
-record(notify_sculpture_infos, {type=0, sculpture_infos=[]}).
-record(req_sculpture_puton, {group_index=0, position=0, temp_id=0}).
-record(notify_sculpture_puton, {is_success=0, group_index=0, position=0, temp_id=0}).
-record(req_sculpture_takeoff, {group_index=0, position=0}).
-record(notify_sculpture_takeoff, {is_success=0, group_index=0, position=0}).
-record(req_change_skill_group, {group_index=0}).
-record(notify_change_skill_group, {result=0, activate_group=0}).
-record(req_sculpture_upgrade, {temp_id=0}).
-record(notify_sculpture_upgrade, {result=0}).
-record(req_sculpture_advnace, {temp_id=0}).
-record(notify_sculpture_advnace, {result=0, new_temp_id=0}).
-record(req_sculpture_unlock, {temp_id=0}).
-record(notify_sculpture_unlock, {result=0, temp_id=0}).
-record(req_sculpture_divine, {type=0}).
-record(notify_sculpture_divine, {result=0, reward_list=[], type=0}).
-record(notify_divine_info, {count=0, common_remain_time=0, rare_remain_time=0}).
-record(notify_skill_groups_info, {groups=[]}).
-record(req_challenge_other_player, {role_id=0}).
-record(notify_challenge_other_player_result, {game_id=0, result=0, map=[]}).
-record(req_challenge_settle, {game_id=0, result=0}).
-record(notify_challenge_settle, {result=0, point=0, coins=0}).
-record(notify_be_challenged_times, {times=0}).
-record(req_get_be_challenged_info, {}).
-record(notify_challenge_info_list, {infos=[]}).
-record(req_get_challenge_rank, {}).
-record(notify_challenge_rank_list, {infos=[]}).
-record(req_get_can_challenge_role, {}).
-record(notify_can_challenge_lists, {infos=[]}).
-record(req_buy_challenge_times, {}).
-record(notify_buy_challenge_times_result, {result=0}).
-record(req_get_challenge_times_info, {}).
-record(notify_challenge_times_info, {buy_times=0, org_times=0, play_times=0, award_timeleft=0}).
-record(req_assistance_list, {}).
-record(notify_assistance_list, {donors=[]}).
-record(req_select_donor, {donor_id=0}).
-record(notify_select_donor_result, {result=0}).
-record(req_refresh_assistance_list, {}).
-record(notify_refresh_assistance_list_result, {result=0}).
-record(req_fresh_lottery_list, {}).
-record(notify_fresh_lottery_list, {lottery_items=[]}).
-record(req_friend_point_lottery, {}).
-record(notify_friend_point_lottery_result, {result=0, id=0, amount=0}).
-record(notify_assistance_info, {lottery_times=0, refresh_times=0}).
-record(notify_role_info_change, {type="", new_value=0}).
-record(req_buy_mall_item, {mallitem_id=0, buy_times=0}).
-record(notify_buy_mall_item_result, {result=0}).
-record(req_has_buy_times, {}).
-record(notify_has_buy_times, {buy_info_list=[]}).
-record(notify_add_friend_defuse_msg, {role_id=0}).
-record(req_get_challenge_rank_award, {}).
-record(notify_get_challenge_rank_award_result, {result=0}).
-record(req_buy_point_mall_item, {mallitem_id=0, buy_times=0}).
-record(notify_buy_point_mall_item_result, {result=0}).
-record(nofity_continue_login_award_info, {continue_login_days=0, daily_award_status=0, cumulative_award3_status=0, cumulative_award7_status=0, cumulative_award15_status=0}).
-record(req_get_daily_award, {type=0}).
-record(notify_get_daily_award_result, {type=0, result=0}).
-record(notify_sys_time, {sys_time=#stime{}}).
-record(req_get_rank_infos, {type=0}).
-record(notify_rank_infos, {type=0, myrank=0, top_hundred=[]}).
-record(req_train_match_list, {list_type=0}).
-record(notify_train_match_list, {match_list=[]}).
-record(req_start_train_match, {role_id=0}).
-record(notify_start_train_match_result, {game_id=0, result=0, map=[]}).
-record(req_train_match_settle, {game_id=0, result=0}).
-record(notify_train_match_settle, {result=0, point=0, honour=0}).
-record(req_get_train_match_times_info, {}).
-record(notify_train_match_times_info, {buy_times=0, org_times=0, play_times=0, success_times=0, award_status=0, refresh_times=0}).
-record(req_buy_train_match_times, {}).
-record(notify_buy_train_match_times_result, {result=0}).
-record(req_get_train_award, {type=0}).
-record(notify_get_train_award_type, {result=0, new_status=0, award_id=0, amount=0}).
-record(req_use_props, {inst_id=0}).
-record(notify_use_props_result, {result=0, reward_id=0}).
-record(req_benison_list, {}).
-record(notify_benison_list, {benison_list=[], benison_status=[]}).
-record(req_bless, {benison_id=0}).
-record(notify_bless_result, {result=0}).
-record(notify_role_bless_buff, {benison_id=0, buffs=[], time_left=0}).
-record(req_refresh_benison_list, {}).
-record(notify_refresh_benison_list_result, {result=0}).
-record(req_equipment_advance, {inst_id=0}).
-record(notify_equipment_advance_result, {result=0}).
-record(req_equipment_exchange, {inst_id=0}).
-record(notify_equipment_exchange_result, {result=0}).
-record(req_equipment_resolve, {inst_id=[]}).
-record(notify_equipment_resolve_result, {result=0, errid=0, infos=[]}).
-record(req_equipment_recast, {inst_id=0}).
-record(notify_equipment_recast_result, {result=0, new_info=#equipmentinfo{}}).
-record(req_save_recast_info, {equipment_id=0}).
-record(notify_save_recast_info_result, {result=0}).
-record(notify_upgrade_task_rewarded_list, {reward_ids=[]}).
-record(req_upgrade_task_reward, {task_id=0}).
-record(notify_upgrade_task_reward_result, {task_id=0, result=0}).
-record(ladder_role_info, {role_id=0, data_type=0, curHp=0, nickname="", battle_power=0, type=0, level=0, battle_prop=#battle_info{}, potence_level=0, advanced_level=0, talent_list=[]}).
-record(req_ladder_role_list, {}).
-record(notify_ladder_role_list, {teammate=[], opponent=[]}).
-record(req_ladder_teammate, {}).
-record(notify_req_ladder_teammate_result, {teammate_info=#ladder_role_info{}, result=0}).
-record(req_reselect_ladder_teammate, {role_id=0}).
-record(notify_reselect_ladder_teammate_result, {teammate_info=#ladder_role_info{}}).
-record(req_ladder_match_info, {}).
-record(notify_ladder_match_info, {pass_level=0, cur_life=0, is_failed=0, recover_count=0, reset_count=0}).
-record(req_ladder_match_battle, {}).
-record(notify_ladder_match_battle_result, {result=0, map=[], game_id=0}).
-record(req_settle_ladder_match, {game_id=0, life_info=[], result=0}).
-record(notify_settle_ladder_match, {result=0, reward_ids=[], reward_amounts=[]}).
-record(req_reset_ladder_match, {}).
-record(notify_reset_ladder_match_result, {result=0}).
-record(req_recover_teammate_life, {}).
-record(notify_recover_teammate_life_result, {result=0}).
-record(notify_online_award_info, {total_online_time=0, has_get_awards=[]}).
-record(req_get_online_award, {online_award_id=0}).
-record(notify_get_online_award_result, {result=0}).
-record(req_alchemy_info, {}).
-record(notify_alchemy_info, {nomrmal_count=0, remain_normal_second=0, advanced_count=0, level=0, rewarded_list=[]}).
-record(req_metallurgy, {type=0}).
-record(notify_metallurgy_reuslt, {result=0}).
-record(req_alchemy_reward, {type=0}).
-record(notify_alchemy_reward_reuslt, {result=0}).
-record(req_potence_advance, {is_use_amulet=0}).
-record(notify_potence_advance_result, {result=0, potence_level=0, advanced_level=0}).
-record(req_exchange_item, {exchange_id=0}).
-record(notify_exchange_item_result, {result=0}).
-record(req_has_buy_discount_item_times, {}).
-record(notify_has_buy_discount_item_times, {buy_info_list=[]}).
-record(req_buy_discount_limit_item, {id=0}).
-record(notify_buy_discount_limit_item_result, {result=0, mall_item_id=0}).
-record(req_convert_cdkey, {award_id=0}).
-record(notify_redeem_cdoe_result, {awards=[]}).
-record(notify_email_list, {emails=[]}).
-record(notify_email_add, {new_email=#semail{}}).
-record(req_get_email_attachments, {email_id=0}).
-record(notify_get_email_attachments_result, {result=0}).
-record(req_buy_mooncard, {type=0, reward_emoney=0}).
-record(notify_mooncard_info, {award_status=0, days_remain=0}).
-record(req_get_mooncard_daily_award, {}).
-record(notify_get_mooncard_daily_award_result, {result=0}).
-record(req_enter_activity_copy, {copy_id=0}).
-record(notify_enter_activity_result, {result=0, game_id=0, gamemaps=[]}).
-record(req_settle_activity_copy, {game_id=0, result=0, pickup_items=[], gold=0}).
-record(notify_settle_activity_copy_result, {result=0}).
-record(notify_activity_copy_info, {play_times=0}).
-record(req_verify_invite_code, {code=""}).
-record(notify_verify_invite_code_result, {result=0}).
-record(req_input_invite_code, {code=""}).
-record(notify_input_invite_code_result, {result=0, master=#master_info{}}).
-record(req_disengage_check, {type=0, role_id=0}).
-record(notify_disengage_check_result, {result=0, role_id=0, type=0}).
-record(req_disengage, {type=0, role_id=0}).
-record(notify_disengage_result, {result=0, role_id=0, type=0}).
-record(notify_lost_prentice, {role_id=0}).
-record(notify_lost_master, {role_id=0}).
-record(req_master_level_reward, {prentice_id=0, level=0}).
-record(notify_master_level_reward_result, {result=0, prentice_id=0, level=0}).
-record(req_prentice_level_reward, {level=0}).
-record(notify_prentice_level_reward_result, {result=0, level=0}).
-record(req_master_help, {level=0}).
-record(notify_master_help_result, {result=0}).
-record(req_give_help, {prentice_id=0}).
-record(notify_give_help_result, {result=0}).
-record(req_get_help_reward, {level=0}).
-record(notify_get_help_reward_result, {result=0, level=0}).
-record(notify_req_help_from_prentice, {prentice_id=0}).
-record(notify_give_help_from_master, {master_id=0}).
-record(notify_invite_code_info, {master=#master_info{}, prentice_list=[], code="", is_new_prentice_got=0, rewarded_list=[]}).
-record(req_send_hp, {friend_id=0}).
-record(notify_send_hp_result, {result=0, friend_id=0}).
-record(notify_get_hp_help_from_friend, {friend_id=0}).
-record(req_reward_hp_from_friend, {friend_id=0}).
-record(notify_reward_hp_from_friend_result, {result=0, friend_id=0}).
-record(notify_boss_copy_fight_count, {count=0}).
-record(req_chat_in_world_channel, {msg=""}).
-record(notify_chat_in_world_channel_result, {result=0}).
-record(notify_world_channel_msg, {speaker_id=0, speaker="", msg=""}).
-record(notify_my_world_chat_info, {speek_times=0, extra_times=0}).
-record(req_get_role_detail_info, {role_id=0}).
-record(notify_role_detail_info_result, {role_id=0, nickname="", status=0, level=0, type=0, public="", potence_level=0, advanced_level=0, sculptures=[], equipments=[], battle_power=0, military_lev=0, challenge_rank=0}).
-record(notify_get_talent_active_info, {active_talent_ids=[], reset_active_hours=0}).
-record(req_actived_talent, {talent_id=0}).
-record(notify_actived_talent, {is_success=0, talent_id=0}).
-record(req_reset_talent, {}).
-record(notify_reset_talent, {is_success=0}).
-record(req_level_up_talent, {talent_id=0}).
-record(notify_level_up_talent, {is_success=0}).
-record(req_notice_list, {}).
-record(notify_notice_list, {list=[]}).
-record(notify_notice_item_add, {item_info=#notice_list_item{}}).
-record(notify_notice_item_del, {del_id=0}).
-record(req_notice_item_detail, {id=0}).
-record(notify_notice_item_detail, {result=0, item_info=#notice_item_detail{}}).
-record(req_time_limit_reward, {id=0}).
-record(notify_time_limit_reward, {result=0}).
-record(notify_time_limit_rewarded_list, {list=[]}).
-record(notify_activity_list, {list=[]}).
-record(notify_act_lottery_info, {remain_count=0, progress_list=[]}).
-record(req_act_lottery, {}).
-record(notify_act_lottery_result, {result=0, reward_id=0}).
-record(notify_act_recharge_info, {cur_recharge_count=0, rewarded_list=[]}).
-record(req_act_recharge_reward, {id=0}).
-record(notify_act_recharge_reward_result, {result=0, id=0}).
-record(req_emoney_2_gold, {emoney=0}).
-record(notify_emoney_2_gold_result, {result=0}).

-define(msg_req_check_version, 1).
-define(msg_notify_check_version_result, 2).
-define(msg_req_login, 3).
-define(msg_req_login_check, 4).
-define(msg_role_data, 5).
-define(msg_notifu_login_check_result, 6).
-define(msg_notify_login_result, 7).
-define(msg_notify_sys_msg, 8).
-define(msg_req_select_role, 9).
-define(msg_notify_select_role_result, 10).
-define(msg_req_delete_role, 11).
-define(msg_notify_delete_role_result, 12).
-define(msg_req_recover_del_role, 13).
-define(msg_notify_recover_del_role_result, 14).
-define(msg_req_reselect_role, 15).
-define(msg_notify_roles_infos, 16).
-define(msg_req_gm_optition, 17).
-define(msg_player_data, 18).
-define(msg_sculpture_data, 19).
-define(msg_stime, 20).
-define(msg_mons_item, 21).
-define(msg_reward_item, 22).
-define(msg_smonster, 23).
-define(msg_strap, 24).
-define(msg_saward, 25).
-define(msg_sfriend, 26).
-define(msg_battle_info, 27).
-define(msg_talent, 28).
-define(msg_senemy, 29).
-define(msg_game_map, 30).
-define(msg_item, 31).
-define(msg_pack_item, 32).
-define(msg_copy_info, 33).
-define(msg_equipmentinfo, 34).
-define(msg_extra_item, 35).
-define(msg_friend_data, 36).
-define(msg_friend_info, 37).
-define(msg_award_item, 38).
-define(msg_challenge_info, 39).
-define(msg_rank_info, 40).
-define(msg_train_info, 41).
-define(msg_rank_data, 42).
-define(msg_donor, 43).
-define(msg_mall_buy_info, 44).
-define(msg_lottery_item, 45).
-define(msg_friend_point_lottery_item, 46).
-define(msg_activeness_task_item, 47).
-define(msg_material_info, 48).
-define(msg_clean_up_trophy, 49).
-define(msg_semail, 50).
-define(msg_leave_msg, 51).
-define(msg_master_info, 52).
-define(msg_prentice_info, 53).
-define(msg_skill_group_item, 54).
-define(msg_notice_list_item, 55).
-define(msg_notice_item_detail, 56).
-define(msg_time_limit_rewarded_item, 57).
-define(msg_role_life_info, 58).
-define(msg_lottery_progress_item, 59).
-define(msg_activity_item, 60).
-define(msg_notify_heartbeat, 61).
-define(msg_notify_socket_close, 62).
-define(msg_notify_repeat_login, 63).
-define(msg_req_register, 64).
-define(msg_notify_register_result, 65).
-define(msg_req_create_role, 66).
-define(msg_notify_create_role_result, 67).
-define(msg_notify_roleinfo_msg, 68).
-define(msg_req_clean_up_copy, 69).
-define(msg_notify_clean_up_copy_result, 70).
-define(msg_req_enter_game, 71).
-define(msg_notify_enter_game, 72).
-define(msg_notify_last_copy, 73).
-define(msg_req_last_copy, 74).
-define(msg_req_buy_power_hp, 75).
-define(msg_notify_buy_power_hp_result, 76).
-define(msg_notify_power_hp_msg, 77).
-define(msg_notify_player_pack, 78).
-define(msg_req_game_settle, 79).
-define(msg_notify_game_settle, 80).
-define(msg_req_game_lottery, 81).
-define(msg_notify_game_lottery, 82).
-define(msg_req_game_reconnect, 83).
-define(msg_notify_reconnect_result, 84).
-define(msg_req_equipment_strengthen, 85).
-define(msg_notify_equipment_strengthen_result, 86).
-define(msg_req_one_touch_equipment_strengthen, 87).
-define(msg_notify_one_touch_equipment_strengthen_result, 88).
-define(msg_req_equipment_mountgem, 89).
-define(msg_notify_equipment_mountgem_result, 90).
-define(msg_req_equipment_puton, 91).
-define(msg_notify_equipment_puton_result, 92).
-define(msg_req_equipment_infos, 93).
-define(msg_notify_equipment_infos, 94).
-define(msg_req_equipment_takeoff, 95).
-define(msg_notify_equipment_takeoff_result, 96).
-define(msg_notify_gold_update, 97).
-define(msg_notify_emoney_update, 98).
-define(msg_notify_summon_stone_info, 99).
-define(msg_req_daily_summon_stone, 100).
-define(msg_notify_daily_summon_stone, 101).
-define(msg_req_buy_summon_stone, 102).
-define(msg_notify_buy_summon_stone, 103).
-define(msg_notify_player_pack_exceeded, 104).
-define(msg_req_extend_pack, 105).
-define(msg_notify_extend_pack_result, 106).
-define(msg_req_sale_item, 107).
-define(msg_notify_sale_item_result, 108).
-define(msg_req_sale_items, 109).
-define(msg_notify_sale_items_result, 110).
-define(msg_req_search_friend, 111).
-define(msg_notify_search_friend_result, 112).
-define(msg_req_add_friend, 113).
-define(msg_notify_add_friend_result, 114).
-define(msg_notify_req_for_add_friend, 115).
-define(msg_req_proc_reqfor_add_friend, 116).
-define(msg_req_del_friend, 117).
-define(msg_notify_del_friend_result, 118).
-define(msg_req_get_friends, 119).
-define(msg_notify_friend_list, 120).
-define(msg_req_get_makefriend_reqs, 121).
-define(msg_notify_makefriend_reqs, 122).
-define(msg_notify_makefriend_reqs_amount, 123).
-define(msg_notify_leave_msg_count, 124).
-define(msg_req_msg_list, 125).
-define(msg_notify_msg_list, 126).
-define(msg_req_send_chat_msg, 127).
-define(msg_notify_send_chat_msg_result, 128).
-define(msg_notify_receive_chat_msg, 129).
-define(msg_req_push_tower_map_settle, 130).
-define(msg_notify_push_tower_map_settle, 131).
-define(msg_req_push_tower_buy_round, 132).
-define(msg_notify_push_tower_buy_round, 133).
-define(msg_req_push_tower_buy_playtimes, 134).
-define(msg_notify_push_tower_buy_playtimes, 135).
-define(msg_req_reborn, 136).
-define(msg_notify_reborn_result, 137).
-define(msg_req_auto_fight, 138).
-define(msg_notify_auto_fight_result, 139).
-define(msg_req_gem_compound, 140).
-define(msg_notify_gem_compound_result, 141).
-define(msg_req_one_touch_gem_compound, 142).
-define(msg_notify_one_touch_gem_compound_result, 143).
-define(msg_req_gem_unmounted, 144).
-define(msg_notify_gem_unmounted_result, 145).
-define(msg_req_push_tower_info, 146).
-define(msg_notify_push_tower_info, 147).
-define(msg_req_tutorial_progress, 148).
-define(msg_notify_tutorial_progress, 149).
-define(msg_req_set_tutorial_progress, 150).
-define(msg_notify_set_tutorial_progress_result, 151).
-define(msg_notify_today_activeness_task, 152).
-define(msg_req_today_activeness_task, 153).
-define(msg_req_activeness_reward, 154).
-define(msg_notify_activeness_reward_result, 155).
-define(msg_req_military_rank_reward, 156).
-define(msg_notify_military_rank_reward_result, 157).
-define(msg_req_military_rank_info, 158).
-define(msg_notify_military_rank_info, 159).
-define(msg_notify_first_charge_info, 160).
-define(msg_req_first_charge_reward, 161).
-define(msg_notify_first_charge_reward_result, 162).
-define(msg_notify_vip_reward_info, 163).
-define(msg_req_vip_grade_reward, 164).
-define(msg_notify_vip_grade_reward_result, 165).
-define(msg_req_vip_daily_reward, 166).
-define(msg_notify_vip_daily_reward_result, 167).
-define(msg_req_recharge, 168).
-define(msg_notify_recharge_result, 169).
-define(msg_task_info, 170).
-define(msg_req_task_infos, 171).
-define(msg_notify_task_infos, 172).
-define(msg_req_finish_task, 173).
-define(msg_notify_finish_task, 174).
-define(msg_sculpture_info, 175).
-define(msg_req_sculpture_infos, 176).
-define(msg_notify_sculpture_infos, 177).
-define(msg_req_sculpture_puton, 178).
-define(msg_notify_sculpture_puton, 179).
-define(msg_req_sculpture_takeoff, 180).
-define(msg_notify_sculpture_takeoff, 181).
-define(msg_req_change_skill_group, 182).
-define(msg_notify_change_skill_group, 183).
-define(msg_req_sculpture_upgrade, 184).
-define(msg_notify_sculpture_upgrade, 185).
-define(msg_req_sculpture_advnace, 186).
-define(msg_notify_sculpture_advnace, 187).
-define(msg_req_sculpture_unlock, 188).
-define(msg_notify_sculpture_unlock, 189).
-define(msg_req_sculpture_divine, 190).
-define(msg_notify_sculpture_divine, 191).
-define(msg_notify_divine_info, 192).
-define(msg_notify_skill_groups_info, 193).
-define(msg_req_challenge_other_player, 194).
-define(msg_notify_challenge_other_player_result, 195).
-define(msg_req_challenge_settle, 196).
-define(msg_notify_challenge_settle, 197).
-define(msg_notify_be_challenged_times, 198).
-define(msg_req_get_be_challenged_info, 199).
-define(msg_notify_challenge_info_list, 200).
-define(msg_req_get_challenge_rank, 201).
-define(msg_notify_challenge_rank_list, 202).
-define(msg_req_get_can_challenge_role, 203).
-define(msg_notify_can_challenge_lists, 204).
-define(msg_req_buy_challenge_times, 205).
-define(msg_notify_buy_challenge_times_result, 206).
-define(msg_req_get_challenge_times_info, 207).
-define(msg_notify_challenge_times_info, 208).
-define(msg_req_assistance_list, 209).
-define(msg_notify_assistance_list, 210).
-define(msg_req_select_donor, 211).
-define(msg_notify_select_donor_result, 212).
-define(msg_req_refresh_assistance_list, 213).
-define(msg_notify_refresh_assistance_list_result, 214).
-define(msg_req_fresh_lottery_list, 215).
-define(msg_notify_fresh_lottery_list, 216).
-define(msg_req_friend_point_lottery, 217).
-define(msg_notify_friend_point_lottery_result, 218).
-define(msg_notify_assistance_info, 219).
-define(msg_notify_role_info_change, 220).
-define(msg_req_buy_mall_item, 221).
-define(msg_notify_buy_mall_item_result, 222).
-define(msg_req_has_buy_times, 223).
-define(msg_notify_has_buy_times, 224).
-define(msg_notify_add_friend_defuse_msg, 225).
-define(msg_req_get_challenge_rank_award, 226).
-define(msg_notify_get_challenge_rank_award_result, 227).
-define(msg_req_buy_point_mall_item, 228).
-define(msg_notify_buy_point_mall_item_result, 229).
-define(msg_nofity_continue_login_award_info, 230).
-define(msg_req_get_daily_award, 231).
-define(msg_notify_get_daily_award_result, 232).
-define(msg_notify_sys_time, 233).
-define(msg_req_get_rank_infos, 234).
-define(msg_notify_rank_infos, 235).
-define(msg_req_train_match_list, 236).
-define(msg_notify_train_match_list, 237).
-define(msg_req_start_train_match, 238).
-define(msg_notify_start_train_match_result, 239).
-define(msg_req_train_match_settle, 240).
-define(msg_notify_train_match_settle, 241).
-define(msg_req_get_train_match_times_info, 242).
-define(msg_notify_train_match_times_info, 243).
-define(msg_req_buy_train_match_times, 244).
-define(msg_notify_buy_train_match_times_result, 245).
-define(msg_req_get_train_award, 246).
-define(msg_notify_get_train_award_type, 247).
-define(msg_req_use_props, 248).
-define(msg_notify_use_props_result, 249).
-define(msg_req_benison_list, 250).
-define(msg_notify_benison_list, 251).
-define(msg_req_bless, 252).
-define(msg_notify_bless_result, 253).
-define(msg_notify_role_bless_buff, 254).
-define(msg_req_refresh_benison_list, 255).
-define(msg_notify_refresh_benison_list_result, 256).
-define(msg_req_equipment_advance, 257).
-define(msg_notify_equipment_advance_result, 258).
-define(msg_req_equipment_exchange, 259).
-define(msg_notify_equipment_exchange_result, 260).
-define(msg_req_equipment_resolve, 261).
-define(msg_notify_equipment_resolve_result, 262).
-define(msg_req_equipment_recast, 263).
-define(msg_notify_equipment_recast_result, 264).
-define(msg_req_save_recast_info, 265).
-define(msg_notify_save_recast_info_result, 266).
-define(msg_notify_upgrade_task_rewarded_list, 267).
-define(msg_req_upgrade_task_reward, 268).
-define(msg_notify_upgrade_task_reward_result, 269).
-define(msg_ladder_role_info, 270).
-define(msg_req_ladder_role_list, 271).
-define(msg_notify_ladder_role_list, 272).
-define(msg_req_ladder_teammate, 273).
-define(msg_notify_req_ladder_teammate_result, 274).
-define(msg_req_reselect_ladder_teammate, 275).
-define(msg_notify_reselect_ladder_teammate_result, 276).
-define(msg_req_ladder_match_info, 277).
-define(msg_notify_ladder_match_info, 278).
-define(msg_req_ladder_match_battle, 279).
-define(msg_notify_ladder_match_battle_result, 280).
-define(msg_req_settle_ladder_match, 281).
-define(msg_notify_settle_ladder_match, 282).
-define(msg_req_reset_ladder_match, 283).
-define(msg_notify_reset_ladder_match_result, 284).
-define(msg_req_recover_teammate_life, 285).
-define(msg_notify_recover_teammate_life_result, 286).
-define(msg_notify_online_award_info, 287).
-define(msg_req_get_online_award, 288).
-define(msg_notify_get_online_award_result, 289).
-define(msg_req_alchemy_info, 290).
-define(msg_notify_alchemy_info, 291).
-define(msg_req_metallurgy, 292).
-define(msg_notify_metallurgy_reuslt, 293).
-define(msg_req_alchemy_reward, 294).
-define(msg_notify_alchemy_reward_reuslt, 295).
-define(msg_req_potence_advance, 296).
-define(msg_notify_potence_advance_result, 297).
-define(msg_req_exchange_item, 298).
-define(msg_notify_exchange_item_result, 299).
-define(msg_req_has_buy_discount_item_times, 300).
-define(msg_notify_has_buy_discount_item_times, 301).
-define(msg_req_buy_discount_limit_item, 302).
-define(msg_notify_buy_discount_limit_item_result, 303).
-define(msg_req_convert_cdkey, 304).
-define(msg_notify_redeem_cdoe_result, 305).
-define(msg_notify_email_list, 306).
-define(msg_notify_email_add, 307).
-define(msg_req_get_email_attachments, 308).
-define(msg_notify_get_email_attachments_result, 309).
-define(msg_req_buy_mooncard, 310).
-define(msg_notify_mooncard_info, 311).
-define(msg_req_get_mooncard_daily_award, 312).
-define(msg_notify_get_mooncard_daily_award_result, 313).
-define(msg_req_enter_activity_copy, 314).
-define(msg_notify_enter_activity_result, 315).
-define(msg_req_settle_activity_copy, 316).
-define(msg_notify_settle_activity_copy_result, 317).
-define(msg_notify_activity_copy_info, 318).
-define(msg_req_verify_invite_code, 319).
-define(msg_notify_verify_invite_code_result, 320).
-define(msg_req_input_invite_code, 321).
-define(msg_notify_input_invite_code_result, 322).
-define(msg_req_disengage_check, 323).
-define(msg_notify_disengage_check_result, 324).
-define(msg_req_disengage, 325).
-define(msg_notify_disengage_result, 326).
-define(msg_notify_lost_prentice, 327).
-define(msg_notify_lost_master, 328).
-define(msg_req_master_level_reward, 329).
-define(msg_notify_master_level_reward_result, 330).
-define(msg_req_prentice_level_reward, 331).
-define(msg_notify_prentice_level_reward_result, 332).
-define(msg_req_master_help, 333).
-define(msg_notify_master_help_result, 334).
-define(msg_req_give_help, 335).
-define(msg_notify_give_help_result, 336).
-define(msg_req_get_help_reward, 337).
-define(msg_notify_get_help_reward_result, 338).
-define(msg_notify_req_help_from_prentice, 339).
-define(msg_notify_give_help_from_master, 340).
-define(msg_notify_invite_code_info, 341).
-define(msg_req_send_hp, 342).
-define(msg_notify_send_hp_result, 343).
-define(msg_notify_get_hp_help_from_friend, 344).
-define(msg_req_reward_hp_from_friend, 345).
-define(msg_notify_reward_hp_from_friend_result, 346).
-define(msg_notify_boss_copy_fight_count, 347).
-define(msg_req_chat_in_world_channel, 348).
-define(msg_notify_chat_in_world_channel_result, 349).
-define(msg_notify_world_channel_msg, 350).
-define(msg_notify_my_world_chat_info, 351).
-define(msg_req_get_role_detail_info, 352).
-define(msg_notify_role_detail_info_result, 353).
-define(msg_notify_get_talent_active_info, 354).
-define(msg_req_actived_talent, 355).
-define(msg_notify_actived_talent, 356).
-define(msg_req_reset_talent, 357).
-define(msg_notify_reset_talent, 358).
-define(msg_req_level_up_talent, 359).
-define(msg_notify_level_up_talent, 360).
-define(msg_req_notice_list, 361).
-define(msg_notify_notice_list, 362).
-define(msg_notify_notice_item_add, 363).
-define(msg_notify_notice_item_del, 364).
-define(msg_req_notice_item_detail, 365).
-define(msg_notify_notice_item_detail, 366).
-define(msg_req_time_limit_reward, 367).
-define(msg_notify_time_limit_reward, 368).
-define(msg_notify_time_limit_rewarded_list, 369).
-define(msg_notify_activity_list, 370).
-define(msg_notify_act_lottery_info, 371).
-define(msg_req_act_lottery, 372).
-define(msg_notify_act_lottery_result, 373).
-define(msg_notify_act_recharge_info, 374).
-define(msg_req_act_recharge_reward, 375).
-define(msg_notify_act_recharge_reward_result, 376).
-define(msg_req_emoney_2_gold, 377).
-define(msg_notify_emoney_2_gold_result, 378).

-define(proto_ver, 90).
