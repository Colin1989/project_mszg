-module(protocal).
-include("packet_def.hrl").
-include("net_type.hrl").
-export([encode/1, decode/2]).


encode(#req_check_version{version=VERSION}) ->
	{?msg_req_check_version, <<VERSION:?INT>>};
encode(#notify_check_version_result{result=RESULT}) ->
	{?msg_notify_check_version_result, <<RESULT:?INT>>};
encode(#req_login{account=ACCOUNT, password=PASSWORD}) ->
	{?msg_req_login, <<(net_helper:encode_string(ACCOUNT))/binary, (net_helper:encode_string(PASSWORD))/binary>>};
encode(#req_login_check{uid=UID, token=TOKEN}) ->
	{?msg_req_login_check, <<(net_helper:encode_string(UID))/binary, (net_helper:encode_string(TOKEN))/binary>>};
encode(#role_data{role_id=ROLE_ID, role_status=ROLE_STATUS, type=TYPE, lev=LEV, name=NAME, is_del=IS_DEL, time_left=TIME_LEFT}) ->
	{?msg_role_data, <<ROLE_ID:?UINT64, ROLE_STATUS:?INT, TYPE:?INT, LEV:?INT, (net_helper:encode_string(NAME))/binary, IS_DEL:?INT, TIME_LEFT:?INT>>};
encode(#notifu_login_check_result{result=RESULT, error_code=ERROR_CODE, emoney=EMONEY, role_infos=ROLE_INFOS}) ->
	{?msg_notifu_login_check_result, <<RESULT:?INT, ERROR_CODE:?INT, EMONEY:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, ROLE_INFOS))/binary>>};
encode(#notify_login_result{id=ID, result=RESULT, emoney=EMONEY, role_infos=ROLE_INFOS}) ->
	{?msg_notify_login_result, <<ID:?UINT64, RESULT:?INT, EMONEY:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, ROLE_INFOS))/binary>>};
encode(#notify_sys_msg{code=CODE, params=PARAMS}) ->
	{?msg_notify_sys_msg, <<CODE:?INT, (net_helper:encode_list(fun(E)-> net_helper:encode_string(E) end, PARAMS))/binary>>};
encode(#req_select_role{role_id=ROLE_ID}) ->
	{?msg_req_select_role, <<ROLE_ID:?UINT64>>};
encode(#notify_select_role_result{result=RESULT}) ->
	{?msg_notify_select_role_result, <<RESULT:?INT>>};
encode(#req_delete_role{role_id=ROLE_ID}) ->
	{?msg_req_delete_role, <<ROLE_ID:?UINT64>>};
encode(#notify_delete_role_result{result=RESULT}) ->
	{?msg_notify_delete_role_result, <<RESULT:?INT>>};
encode(#req_recover_del_role{role_id=ROLE_ID}) ->
	{?msg_req_recover_del_role, <<ROLE_ID:?UINT64>>};
encode(#notify_recover_del_role_result{result=RESULT}) ->
	{?msg_notify_recover_del_role_result, <<RESULT:?INT>>};
encode(#req_reselect_role{}) ->
	{?msg_req_reselect_role, null};
encode(#notify_roles_infos{emoney=EMONEY, role_infos=ROLE_INFOS}) ->
	{?msg_notify_roles_infos, <<EMONEY:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, ROLE_INFOS))/binary>>};
encode(#req_gm_optition{opt_type=OPT_TYPE, value=VALUE}) ->
	{?msg_req_gm_optition, <<OPT_TYPE:?INT, VALUE:?INT>>};
encode(#player_data{account=ACCOUNT, username=USERNAME, sex=SEX}) ->
	{?msg_player_data, <<(net_helper:encode_string(ACCOUNT))/binary, (net_helper:encode_string(USERNAME))/binary, SEX:?INT>>};
encode(#sculpture_data{temp_id=TEMP_ID, level=LEVEL}) ->
	{?msg_sculpture_data, <<TEMP_ID:?INT, LEVEL:?INT>>};
encode(#stime{year=YEAR, month=MONTH, day=DAY, hour=HOUR, minute=MINUTE, second=SECOND}) ->
	{?msg_stime, <<YEAR:?INT, MONTH:?INT, DAY:?INT, HOUR:?INT, MINUTE:?INT, SECOND:?INT>>};
encode(#mons_item{id=ID, amount=AMOUNT}) ->
	{?msg_mons_item, <<ID:?INT, AMOUNT:?INT>>};
encode(#reward_item{id=ID, amount=AMOUNT}) ->
	{?msg_reward_item, <<ID:?INT, AMOUNT:?INT>>};
encode(#smonster{pos=POS, monsterid=MONSTERID, dropout=DROPOUT}) ->
	{?msg_smonster, <<POS:?INT, MONSTERID:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, DROPOUT))/binary>>};
encode(#strap{pos=POS, trapid=TRAPID}) ->
	{?msg_strap, <<POS:?INT, TRAPID:?INT>>};
encode(#saward{pos=POS, awardid=AWARDID}) ->
	{?msg_saward, <<POS:?INT, AWARDID:?INT>>};
encode(#sfriend{pos=POS, friend_role_id=FRIEND_ROLE_ID}) ->
	{?msg_sfriend, <<POS:?INT, FRIEND_ROLE_ID:?INT>>};
encode(#battle_info{sculpture=SCULPTURE, life=LIFE, speed=SPEED, atk=ATK, hit_ratio=HIT_RATIO, miss_ratio=MISS_RATIO, critical_ratio=CRITICAL_RATIO, tenacity=TENACITY, power=POWER}) ->
	{?msg_battle_info, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, SCULPTURE))/binary, LIFE:?INT, SPEED:?INT, ATK:?INT, HIT_RATIO:?INT, MISS_RATIO:?INT, CRITICAL_RATIO:?INT, TENACITY:?INT, POWER:?INT>>};
encode(#talent{talent_id=TALENT_ID, level=LEVEL}) ->
	{?msg_talent, <<TALENT_ID:?INT, LEVEL:?INT>>};
encode(#senemy{role_id=ROLE_ID, name=NAME, pos=POS, level=LEVEL, type=TYPE, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, battle_prop=BATTLE_PROP, talent_list=TALENT_LIST, team_tag=TEAM_TAG, id_leader=ID_LEADER, cur_life=CUR_LIFE, mitigation=MITIGATION}) ->
	{?msg_senemy, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, POS:?INT, LEVEL:?INT, TYPE:?INT, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, (net_helper:get_encode_binary_data(encode(BATTLE_PROP)))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TALENT_LIST))/binary, TEAM_TAG:?INT, ID_LEADER:?INT, CUR_LIFE:?INT, MITIGATION:?INT>>};
encode(#game_map{monster=MONSTER, key=KEY, start=START, award=AWARD, trap=TRAP, barrier=BARRIER, friend=FRIEND, scene=SCENE, enemy=ENEMY, boss=BOSS, boss_rule=BOSS_RULE}) ->
	{?msg_game_map, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MONSTER))/binary, KEY:?INT, START:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, AWARD))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TRAP))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, BARRIER))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, FRIEND))/binary, SCENE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, ENEMY))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, BOSS))/binary, BOSS_RULE:?INT>>};
encode(#item{inst_id=INST_ID, temp_id=TEMP_ID}) ->
	{?msg_item, <<INST_ID:?UINT64, TEMP_ID:?INT>>};
encode(#pack_item{id=ID, itemid=ITEMID, itemtype=ITEMTYPE, amount=AMOUNT}) ->
	{?msg_pack_item, <<ID:?UINT64, ITEMID:?INT, ITEMTYPE:?INT, AMOUNT:?INT>>};
encode(#copy_info{copy_id=COPY_ID, max_score=MAX_SCORE, pass_times=PASS_TIMES}) ->
	{?msg_copy_info, <<COPY_ID:?INT, MAX_SCORE:?INT, PASS_TIMES:?INT>>};
encode(#equipmentinfo{equipment_id=EQUIPMENT_ID, temp_id=TEMP_ID, strengthen_level=STRENGTHEN_LEVEL, gems=GEMS, attr_ids=ATTR_IDS, gem_extra=GEM_EXTRA, bindtype=BINDTYPE, bindstatus=BINDSTATUS}) ->
	{?msg_equipmentinfo, <<EQUIPMENT_ID:?UINT64, TEMP_ID:?INT, STRENGTHEN_LEVEL:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, GEMS))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, ATTR_IDS))/binary, GEM_EXTRA:?INT, BINDTYPE:?INT, BINDSTATUS:?INT>>};
encode(#extra_item{item_id=ITEM_ID, count=COUNT}) ->
	{?msg_extra_item, <<ITEM_ID:?INT, COUNT:?INT>>};
encode(#friend_data{nickname=NICKNAME, status=STATUS, head=HEAD, level=LEVEL, public=PUBLIC, battle_prop=BATTLE_PROP, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL}) ->
	{?msg_friend_data, <<(net_helper:encode_string(NICKNAME))/binary, STATUS:?INT, HEAD:?INT, LEVEL:?INT, (net_helper:encode_string(PUBLIC))/binary, (net_helper:get_encode_binary_data(encode(BATTLE_PROP)))/binary, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT>>};
encode(#friend_info{friend_id=FRIEND_ID, nickname=NICKNAME, status=STATUS, head=HEAD, level=LEVEL, public=PUBLIC, battle_prop=BATTLE_PROP, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, my_send_status=MY_SEND_STATUS, friend_send_status=FRIEND_SEND_STATUS, is_comrade=IS_COMRADE}) ->
	{?msg_friend_info, <<FRIEND_ID:?UINT64, (net_helper:encode_string(NICKNAME))/binary, STATUS:?INT, HEAD:?INT, LEVEL:?INT, (net_helper:encode_string(PUBLIC))/binary, (net_helper:get_encode_binary_data(encode(BATTLE_PROP)))/binary, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, MY_SEND_STATUS:?INT, FRIEND_SEND_STATUS:?INT, IS_COMRADE:?INT>>};
encode(#award_item{temp_id=TEMP_ID, amount=AMOUNT}) ->
	{?msg_award_item, <<TEMP_ID:?INT, AMOUNT:?INT>>};
encode(#challenge_info{name=NAME, result=RESULT, new_rank=NEW_RANK}) ->
	{?msg_challenge_info, <<(net_helper:encode_string(NAME))/binary, RESULT:?INT, NEW_RANK:?INT>>};
encode(#rank_info{role_id=ROLE_ID, name=NAME, type=TYPE, rank=RANK, level=LEVEL, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, power=POWER}) ->
	{?msg_rank_info, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, RANK:?INT, LEVEL:?INT, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, POWER:?INT>>};
encode(#train_info{role_id=ROLE_ID, name=NAME, type=TYPE, status=STATUS, level=LEVEL, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, power=POWER}) ->
	{?msg_train_info, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, STATUS:?INT, LEVEL:?INT, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, POWER:?INT>>};
encode(#rank_data{role_id=ROLE_ID, name=NAME, type=TYPE, rank=RANK, value=VALUE, public=PUBLIC}) ->
	{?msg_rank_data, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, RANK:?INT, VALUE:?INT, (net_helper:encode_string(PUBLIC))/binary>>};
encode(#donor{role_id=ROLE_ID, rel=REL, level=LEVEL, role_type=ROLE_TYPE, nick_name=NICK_NAME, friend_point=FRIEND_POINT, power=POWER, sculpture=SCULPTURE, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, is_used=IS_USED, is_robot=IS_ROBOT}) ->
	{?msg_donor, <<ROLE_ID:?UINT64, REL:?INT, LEVEL:?INT, ROLE_TYPE:?INT, (net_helper:encode_string(NICK_NAME))/binary, FRIEND_POINT:?INT, POWER:?INT, (net_helper:get_encode_binary_data(encode(SCULPTURE)))/binary, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, IS_USED:?INT, IS_ROBOT:?INT>>};
encode(#mall_buy_info{mallitem_id=MALLITEM_ID, times=TIMES}) ->
	{?msg_mall_buy_info, <<MALLITEM_ID:?INT, TIMES:?INT>>};
encode(#lottery_item{reward_id=REWARD_ID, amount=AMOUNT}) ->
	{?msg_lottery_item, <<REWARD_ID:?INT, AMOUNT:?INT>>};
encode(#friend_point_lottery_item{id=ID, amount=AMOUNT}) ->
	{?msg_friend_point_lottery_item, <<ID:?INT, AMOUNT:?INT>>};
encode(#activeness_task_item{id=ID, count=COUNT}) ->
	{?msg_activeness_task_item, <<ID:?INT, COUNT:?INT>>};
encode(#material_info{material_id=MATERIAL_ID, amount=AMOUNT}) ->
	{?msg_material_info, <<MATERIAL_ID:?INT, AMOUNT:?INT>>};
encode(#clean_up_trophy{item=ITEM, gold=GOLD, exp=EXP}) ->
	{?msg_clean_up_trophy, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, ITEM))/binary, GOLD:?INT, EXP:?INT>>};
encode(#semail{id=ID, type=TYPE, title=TITLE, content=CONTENT, attachments=ATTACHMENTS, recv_time=RECV_TIME, end_time=END_TIME}) ->
	{?msg_semail, <<ID:?INT, TYPE:?UCHAR, (net_helper:encode_string(TITLE))/binary, (net_helper:encode_string(CONTENT))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, ATTACHMENTS))/binary, (net_helper:get_encode_binary_data(encode(RECV_TIME)))/binary, (net_helper:get_encode_binary_data(encode(END_TIME)))/binary>>};
encode(#leave_msg{role_id=ROLE_ID, msg=MSG}) ->
	{?msg_leave_msg, <<ROLE_ID:?UINT64, (net_helper:encode_string(MSG))/binary>>};
encode(#master_info{role_id=ROLE_ID, name=NAME, type=TYPE, advanced_level=ADVANCED_LEVEL, battle_power=BATTLE_POWER, level=LEVEL, status=STATUS}) ->
	{?msg_master_info, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, ADVANCED_LEVEL:?INT, BATTLE_POWER:?INT, LEVEL:?INT, STATUS:?INT>>};
encode(#prentice_info{role_id=ROLE_ID, name=NAME, type=TYPE, advanced_level=ADVANCED_LEVEL, level=LEVEL, rewarded_list=REWARDED_LIST, status=STATUS}) ->
	{?msg_prentice_info, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, ADVANCED_LEVEL:?INT, LEVEL:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, REWARDED_LIST))/binary, STATUS:?INT>>};
encode(#skill_group_item{id1=ID1, id2=ID2, id3=ID3, id4=ID4, index=INDEX}) ->
	{?msg_skill_group_item, <<ID1:?INT, ID2:?INT, ID3:?INT, ID4:?INT, INDEX:?INT>>};
encode(#notice_list_item{id=ID, title=TITLE, sub_title=SUB_TITLE, icon=ICON, mark_id=MARK_ID, create_time=CREATE_TIME, priority=PRIORITY, top_pic=TOP_PIC, start_time=START_TIME, end_time=END_TIME}) ->
	{?msg_notice_list_item, <<ID:?INT, (net_helper:encode_string(TITLE))/binary, (net_helper:encode_string(SUB_TITLE))/binary, ICON:?INT, MARK_ID:?INT, (net_helper:get_encode_binary_data(encode(CREATE_TIME)))/binary, PRIORITY:?INT, TOP_PIC:?INT, (net_helper:get_encode_binary_data(encode(START_TIME)))/binary, (net_helper:get_encode_binary_data(encode(END_TIME)))/binary>>};
encode(#notice_item_detail{id=ID, title=TITLE, sub_title=SUB_TITLE, icon=ICON, content=CONTENT, toward_id=TOWARD_ID, mark_id=MARK_ID}) ->
	{?msg_notice_item_detail, <<ID:?INT, (net_helper:encode_string(TITLE))/binary, (net_helper:encode_string(SUB_TITLE))/binary, ICON:?INT, (net_helper:encode_string(CONTENT))/binary, TOWARD_ID:?INT, MARK_ID:?INT>>};
encode(#time_limit_rewarded_item{id=ID, count=COUNT, rewarded_time=REWARDED_TIME}) ->
	{?msg_time_limit_rewarded_item, <<ID:?INT, COUNT:?INT, (net_helper:get_encode_binary_data(encode(REWARDED_TIME)))/binary>>};
encode(#role_life_info{role_id=ROLE_ID, cur_life=CUR_LIFE}) ->
	{?msg_role_life_info, <<ROLE_ID:?UINT64, CUR_LIFE:?INT>>};
encode(#lottery_progress_item{id=ID, cur_count=CUR_COUNT}) ->
	{?msg_lottery_progress_item, <<ID:?INT, CUR_COUNT:?INT>>};
encode(#activity_item{id=ID, remain_seconds=REMAIN_SECONDS}) ->
	{?msg_activity_item, <<ID:?INT, REMAIN_SECONDS:?INT>>};
encode(#notify_heartbeat{version=VERSION}) ->
	{?msg_notify_heartbeat, <<VERSION:?INT>>};
encode(#notify_socket_close{}) ->
	{?msg_notify_socket_close, null};
encode(#notify_repeat_login{account=ACCOUNT}) ->
	{?msg_notify_repeat_login, <<(net_helper:encode_string(ACCOUNT))/binary>>};
encode(#req_register{account=ACCOUNT, channelid=CHANNELID, platformid=PLATFORMID, password=PASSWORD}) ->
	{?msg_req_register, <<(net_helper:encode_string(ACCOUNT))/binary, CHANNELID:?INT, PLATFORMID:?INT, (net_helper:encode_string(PASSWORD))/binary>>};
encode(#notify_register_result{result=RESULT}) ->
	{?msg_notify_register_result, <<RESULT:?INT>>};
encode(#req_create_role{roletype=ROLETYPE, nickname=NICKNAME}) ->
	{?msg_req_create_role, <<ROLETYPE:?INT, (net_helper:encode_string(NICKNAME))/binary>>};
encode(#notify_create_role_result{result=RESULT}) ->
	{?msg_notify_create_role_result, <<RESULT:?INT>>};
encode(#notify_roleinfo_msg{id=ID, nickname=NICKNAME, role_status=ROLE_STATUS, roletype=ROLETYPE, armor=ARMOR, weapon=WEAPON, ring=RING, necklace=NECKLACE, medal=MEDAL, jewelry=JEWELRY, skill1=SKILL1, skill2=SKILL2, skill_group_index=SKILL_GROUP_INDEX, level=LEVEL, exp=EXP, gold=GOLD, emoney=EMONEY, summon_stone=SUMMON_STONE, power_hp=POWER_HP, recover_time_left=RECOVER_TIME_LEFT, power_hp_buy_times=POWER_HP_BUY_TIMES, pack_space=PACK_SPACE, friend_point=FRIEND_POINT, point=POINT, honour=HONOUR, battle_power=BATTLE_POWER, alchemy_exp=ALCHEMY_EXP, battle_soul=BATTLE_SOUL, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, vip_level=VIP_LEVEL, vip_exp=VIP_EXP}) ->
	{?msg_notify_roleinfo_msg, <<ID:?UINT64, (net_helper:encode_string(NICKNAME))/binary, ROLE_STATUS:?INT, ROLETYPE:?INT, ARMOR:?UINT64, WEAPON:?UINT64, RING:?UINT64, NECKLACE:?UINT64, MEDAL:?UINT64, JEWELRY:?UINT64, SKILL1:?INT, SKILL2:?INT, SKILL_GROUP_INDEX:?INT, LEVEL:?INT, EXP:?INT, GOLD:?INT, EMONEY:?INT, SUMMON_STONE:?INT, POWER_HP:?INT, RECOVER_TIME_LEFT:?INT, POWER_HP_BUY_TIMES:?INT, PACK_SPACE:?INT, FRIEND_POINT:?INT, POINT:?INT, HONOUR:?INT, BATTLE_POWER:?INT, ALCHEMY_EXP:?INT, BATTLE_SOUL:?INT, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, VIP_LEVEL:?INT, VIP_EXP:?INT>>};
encode(#req_clean_up_copy{copy_id=COPY_ID, count=COUNT}) ->
	{?msg_req_clean_up_copy, <<COPY_ID:?INT, COUNT:?INT>>};
encode(#notify_clean_up_copy_result{result=RESULT, trophy_list=TROPHY_LIST}) ->
	{?msg_notify_clean_up_copy_result, <<RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TROPHY_LIST))/binary>>};
encode(#req_enter_game{id=ID, gametype=GAMETYPE, copy_id=COPY_ID}) ->
	{?msg_req_enter_game, <<ID:?UINT64, GAMETYPE:?INT, COPY_ID:?INT>>};
encode(#notify_enter_game{result=RESULT, game_id=GAME_ID, gamemaps=GAMEMAPS}) ->
	{?msg_notify_enter_game, <<RESULT:?INT, GAME_ID:?UINT64, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, GAMEMAPS))/binary>>};
encode(#notify_last_copy{last_copy_id=LAST_COPY_ID, copyinfos=COPYINFOS}) ->
	{?msg_notify_last_copy, <<LAST_COPY_ID:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, COPYINFOS))/binary>>};
encode(#req_last_copy{roleid=ROLEID}) ->
	{?msg_req_last_copy, <<ROLEID:?UINT64>>};
encode(#req_buy_power_hp{}) ->
	{?msg_req_buy_power_hp, null};
encode(#notify_buy_power_hp_result{result=RESULT}) ->
	{?msg_notify_buy_power_hp_result, <<RESULT:?INT>>};
encode(#notify_power_hp_msg{result=RESULT, power_hp=POWER_HP}) ->
	{?msg_notify_power_hp_msg, <<RESULT:?INT, POWER_HP:?INT>>};
encode(#notify_player_pack{type=TYPE, pack_items=PACK_ITEMS}) ->
	{?msg_notify_player_pack, <<TYPE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, PACK_ITEMS))/binary>>};
encode(#req_game_settle{game_id=GAME_ID, result=RESULT, life=LIFE, maxlife=MAXLIFE, cost_round=COST_ROUND, pickup_items=PICKUP_ITEMS, user_operations=USER_OPERATIONS, gold=GOLD, killmonsters=KILLMONSTERS}) ->
	{?msg_req_game_settle, <<GAME_ID:?UINT64, RESULT:?INT, LIFE:?INT, MAXLIFE:?INT, COST_ROUND:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, PICKUP_ITEMS))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, USER_OPERATIONS))/binary, GOLD:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, KILLMONSTERS))/binary>>};
encode(#notify_game_settle{game_id=GAME_ID, result=RESULT, score=SCORE, final_item=FINAL_ITEM, ratio_items=RATIO_ITEMS}) ->
	{?msg_notify_game_settle, <<GAME_ID:?UINT64, RESULT:?INT, SCORE:?INT, (net_helper:get_encode_binary_data(encode(FINAL_ITEM)))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, RATIO_ITEMS))/binary>>};
encode(#req_game_lottery{}) ->
	{?msg_req_game_lottery, null};
encode(#notify_game_lottery{second_item=SECOND_ITEM, result=RESULT}) ->
	{?msg_notify_game_lottery, <<(net_helper:get_encode_binary_data(encode(SECOND_ITEM)))/binary, RESULT:?INT>>};
encode(#req_game_reconnect{uid=UID, token=TOKEN, role_id=ROLE_ID, last_recv_stepnum=LAST_RECV_STEPNUM}) ->
	{?msg_req_game_reconnect, <<(net_helper:encode_string(UID))/binary, (net_helper:encode_string(TOKEN))/binary, ROLE_ID:?UINT64, LAST_RECV_STEPNUM:?INT>>};
encode(#notify_reconnect_result{id=ID, result=RESULT, last_recv_stepnum=LAST_RECV_STEPNUM}) ->
	{?msg_notify_reconnect_result, <<ID:?UINT64, RESULT:?INT, LAST_RECV_STEPNUM:?INT>>};
encode(#req_equipment_strengthen{equipment_id=EQUIPMENT_ID}) ->
	{?msg_req_equipment_strengthen, <<EQUIPMENT_ID:?UINT64>>};
encode(#notify_equipment_strengthen_result{strengthen_result=STRENGTHEN_RESULT, gold=GOLD}) ->
	{?msg_notify_equipment_strengthen_result, <<STRENGTHEN_RESULT:?INT, GOLD:?INT>>};
encode(#req_one_touch_equipment_strengthen{equipment_id=EQUIPMENT_ID}) ->
	{?msg_req_one_touch_equipment_strengthen, <<EQUIPMENT_ID:?UINT64>>};
encode(#notify_one_touch_equipment_strengthen_result{result_list=RESULT_LIST}) ->
	{?msg_notify_one_touch_equipment_strengthen_result, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, RESULT_LIST))/binary>>};
encode(#req_equipment_mountgem{equipment_id=EQUIPMENT_ID, gem_id=GEM_ID}) ->
	{?msg_req_equipment_mountgem, <<EQUIPMENT_ID:?UINT64, GEM_ID:?UINT64>>};
encode(#notify_equipment_mountgem_result{mountgem_result=MOUNTGEM_RESULT}) ->
	{?msg_notify_equipment_mountgem_result, <<MOUNTGEM_RESULT:?INT>>};
encode(#req_equipment_puton{equipment_id=EQUIPMENT_ID}) ->
	{?msg_req_equipment_puton, <<EQUIPMENT_ID:?UINT64>>};
encode(#notify_equipment_puton_result{puton_result=PUTON_RESULT}) ->
	{?msg_notify_equipment_puton_result, <<PUTON_RESULT:?INT>>};
encode(#req_equipment_infos{}) ->
	{?msg_req_equipment_infos, null};
encode(#notify_equipment_infos{type=TYPE, equipment_infos=EQUIPMENT_INFOS}) ->
	{?msg_notify_equipment_infos, <<TYPE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, EQUIPMENT_INFOS))/binary>>};
encode(#req_equipment_takeoff{position=POSITION}) ->
	{?msg_req_equipment_takeoff, <<POSITION:?INT>>};
encode(#notify_equipment_takeoff_result{takeoff_result=TAKEOFF_RESULT}) ->
	{?msg_notify_equipment_takeoff_result, <<TAKEOFF_RESULT:?INT>>};
encode(#notify_gold_update{gold=GOLD}) ->
	{?msg_notify_gold_update, <<GOLD:?INT>>};
encode(#notify_emoney_update{emoney=EMONEY}) ->
	{?msg_notify_emoney_update, <<EMONEY:?INT>>};
encode(#notify_summon_stone_info{is_award=IS_AWARD, has_buy_times=HAS_BUY_TIMES}) ->
	{?msg_notify_summon_stone_info, <<IS_AWARD:?INT, HAS_BUY_TIMES:?INT>>};
encode(#req_daily_summon_stone{}) ->
	{?msg_req_daily_summon_stone, null};
encode(#notify_daily_summon_stone{result=RESULT}) ->
	{?msg_notify_daily_summon_stone, <<RESULT:?INT>>};
encode(#req_buy_summon_stone{}) ->
	{?msg_req_buy_summon_stone, null};
encode(#notify_buy_summon_stone{result=RESULT}) ->
	{?msg_notify_buy_summon_stone, <<RESULT:?INT>>};
encode(#notify_player_pack_exceeded{new_extra=NEW_EXTRA}) ->
	{?msg_notify_player_pack_exceeded, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, NEW_EXTRA))/binary>>};
encode(#req_extend_pack{}) ->
	{?msg_req_extend_pack, null};
encode(#notify_extend_pack_result{result=RESULT}) ->
	{?msg_notify_extend_pack_result, <<RESULT:?INT>>};
encode(#req_sale_item{inst_id=INST_ID, amount=AMOUNT}) ->
	{?msg_req_sale_item, <<INST_ID:?UINT64, AMOUNT:?INT>>};
encode(#notify_sale_item_result{result=RESULT, gold=GOLD}) ->
	{?msg_notify_sale_item_result, <<RESULT:?INT, GOLD:?INT>>};
encode(#req_sale_items{inst_id=INST_ID}) ->
	{?msg_req_sale_items, <<(net_helper:encode_list(fun(E)-> <<E:?UINT64>>end, INST_ID))/binary>>};
encode(#notify_sale_items_result{result=RESULT, err_id=ERR_ID, gold=GOLD}) ->
	{?msg_notify_sale_items_result, <<RESULT:?INT, ERR_ID:?UINT64, GOLD:?INT>>};
encode(#req_search_friend{nickname=NICKNAME}) ->
	{?msg_req_search_friend, <<(net_helper:encode_string(NICKNAME))/binary>>};
encode(#notify_search_friend_result{result=RESULT, role_info=ROLE_INFO}) ->
	{?msg_notify_search_friend_result, <<RESULT:?INT, (net_helper:get_encode_binary_data(encode(ROLE_INFO)))/binary>>};
encode(#req_add_friend{friend_id=FRIEND_ID}) ->
	{?msg_req_add_friend, <<FRIEND_ID:?UINT64>>};
encode(#notify_add_friend_result{result=RESULT}) ->
	{?msg_notify_add_friend_result, <<RESULT:?INT>>};
encode(#notify_req_for_add_friend{friend_id=FRIEND_ID, role_data=ROLE_DATA}) ->
	{?msg_notify_req_for_add_friend, <<FRIEND_ID:?UINT64, (net_helper:get_encode_binary_data(encode(ROLE_DATA)))/binary>>};
encode(#req_proc_reqfor_add_friend{answer=ANSWER, friend_id=FRIEND_ID}) ->
	{?msg_req_proc_reqfor_add_friend, <<ANSWER:?INT, FRIEND_ID:?UINT64>>};
encode(#req_del_friend{friend_id=FRIEND_ID}) ->
	{?msg_req_del_friend, <<FRIEND_ID:?UINT64>>};
encode(#notify_del_friend_result{result=RESULT}) ->
	{?msg_notify_del_friend_result, <<RESULT:?INT>>};
encode(#req_get_friends{}) ->
	{?msg_req_get_friends, null};
encode(#notify_friend_list{type=TYPE, friends=FRIENDS}) ->
	{?msg_notify_friend_list, <<TYPE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, FRIENDS))/binary>>};
encode(#req_get_makefriend_reqs{}) ->
	{?msg_req_get_makefriend_reqs, null};
encode(#notify_makefriend_reqs{reqs=REQS}) ->
	{?msg_notify_makefriend_reqs, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, REQS))/binary>>};
encode(#notify_makefriend_reqs_amount{amount=AMOUNT}) ->
	{?msg_notify_makefriend_reqs_amount, <<AMOUNT:?INT>>};
encode(#notify_leave_msg_count{count=COUNT}) ->
	{?msg_notify_leave_msg_count, <<COUNT:?INT>>};
encode(#req_msg_list{}) ->
	{?msg_req_msg_list, null};
encode(#notify_msg_list{msg_list=MSG_LIST}) ->
	{?msg_notify_msg_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MSG_LIST))/binary>>};
encode(#req_send_chat_msg{friend_id=FRIEND_ID, chat_msg=CHAT_MSG}) ->
	{?msg_req_send_chat_msg, <<FRIEND_ID:?UINT64, (net_helper:encode_string(CHAT_MSG))/binary>>};
encode(#notify_send_chat_msg_result{result=RESULT}) ->
	{?msg_notify_send_chat_msg_result, <<RESULT:?INT>>};
encode(#notify_receive_chat_msg{friend_id=FRIEND_ID, chat_msg=CHAT_MSG}) ->
	{?msg_notify_receive_chat_msg, <<FRIEND_ID:?UINT64, (net_helper:encode_string(CHAT_MSG))/binary>>};
encode(#req_push_tower_map_settle{game_id=GAME_ID, result=RESULT, cost_round=COST_ROUND, life=LIFE, pickup_items=PICKUP_ITEMS, drop_gold=DROP_GOLD}) ->
	{?msg_req_push_tower_map_settle, <<GAME_ID:?UINT64, RESULT:?INT, COST_ROUND:?INT, LIFE:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, PICKUP_ITEMS))/binary, DROP_GOLD:?INT>>};
encode(#notify_push_tower_map_settle{result=RESULT, gamemap=GAMEMAP, awards=AWARDS, gold=GOLD, exp=EXP}) ->
	{?msg_notify_push_tower_map_settle, <<RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, GAMEMAP))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, AWARDS))/binary, GOLD:?INT, EXP:?INT>>};
encode(#req_push_tower_buy_round{}) ->
	{?msg_req_push_tower_buy_round, null};
encode(#notify_push_tower_buy_round{result=RESULT}) ->
	{?msg_notify_push_tower_buy_round, <<RESULT:?INT>>};
encode(#req_push_tower_buy_playtimes{}) ->
	{?msg_req_push_tower_buy_playtimes, null};
encode(#notify_push_tower_buy_playtimes{result=RESULT}) ->
	{?msg_notify_push_tower_buy_playtimes, <<RESULT:?INT>>};
encode(#req_reborn{type=TYPE}) ->
	{?msg_req_reborn, <<TYPE:?INT>>};
encode(#notify_reborn_result{result=RESULT}) ->
	{?msg_notify_reborn_result, <<RESULT:?INT>>};
encode(#req_auto_fight{}) ->
	{?msg_req_auto_fight, null};
encode(#notify_auto_fight_result{result=RESULT}) ->
	{?msg_notify_auto_fight_result, <<RESULT:?INT>>};
encode(#req_gem_compound{temp_id=TEMP_ID, is_protect=IS_PROTECT}) ->
	{?msg_req_gem_compound, <<TEMP_ID:?INT, IS_PROTECT:?INT>>};
encode(#notify_gem_compound_result{result=RESULT, lost_gem_amount=LOST_GEM_AMOUNT}) ->
	{?msg_notify_gem_compound_result, <<RESULT:?INT, LOST_GEM_AMOUNT:?INT>>};
encode(#req_one_touch_gem_compound{temp_id=TEMP_ID, is_protect=IS_PROTECT}) ->
	{?msg_req_one_touch_gem_compound, <<TEMP_ID:?INT, IS_PROTECT:?INT>>};
encode(#notify_one_touch_gem_compound_result{result_list=RESULT_LIST}) ->
	{?msg_notify_one_touch_gem_compound_result, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, RESULT_LIST))/binary>>};
encode(#req_gem_unmounted{equipment_id=EQUIPMENT_ID, gem_temp_id=GEM_TEMP_ID}) ->
	{?msg_req_gem_unmounted, <<EQUIPMENT_ID:?UINT64, GEM_TEMP_ID:?INT>>};
encode(#notify_gem_unmounted_result{result=RESULT}) ->
	{?msg_notify_gem_unmounted_result, <<RESULT:?INT>>};
encode(#req_push_tower_info{}) ->
	{?msg_req_push_tower_info, null};
encode(#notify_push_tower_info{play_times=PLAY_TIMES, max_times=MAX_TIMES, max_floor=MAX_FLOOR}) ->
	{?msg_notify_push_tower_info, <<PLAY_TIMES:?INT, MAX_TIMES:?INT, MAX_FLOOR:?INT>>};
encode(#req_tutorial_progress{}) ->
	{?msg_req_tutorial_progress, null};
encode(#notify_tutorial_progress{progress=PROGRESS}) ->
	{?msg_notify_tutorial_progress, <<(net_helper:encode_list(fun(E)-> <<E:?INT>>end, PROGRESS))/binary>>};
encode(#req_set_tutorial_progress{progress=PROGRESS}) ->
	{?msg_req_set_tutorial_progress, <<PROGRESS:?INT>>};
encode(#notify_set_tutorial_progress_result{result=RESULT}) ->
	{?msg_notify_set_tutorial_progress_result, <<RESULT:?INT>>};
encode(#notify_today_activeness_task{task_list=TASK_LIST, is_reward_activeness_item_info=IS_REWARD_ACTIVENESS_ITEM_INFO, activeness=ACTIVENESS}) ->
	{?msg_notify_today_activeness_task, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TASK_LIST))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, IS_REWARD_ACTIVENESS_ITEM_INFO))/binary, ACTIVENESS:?INT>>};
encode(#req_today_activeness_task{}) ->
	{?msg_req_today_activeness_task, null};
encode(#req_activeness_reward{reward=REWARD}) ->
	{?msg_req_activeness_reward, <<REWARD:?INT>>};
encode(#notify_activeness_reward_result{reward=REWARD, result=RESULT}) ->
	{?msg_notify_activeness_reward_result, <<REWARD:?INT, RESULT:?INT>>};
encode(#req_military_rank_reward{}) ->
	{?msg_req_military_rank_reward, null};
encode(#notify_military_rank_reward_result{result=RESULT}) ->
	{?msg_notify_military_rank_reward_result, <<RESULT:?INT>>};
encode(#req_military_rank_info{}) ->
	{?msg_req_military_rank_info, null};
encode(#notify_military_rank_info{level=LEVEL, is_rewarded=IS_REWARDED}) ->
	{?msg_notify_military_rank_info, <<LEVEL:?INT, IS_REWARDED:?INT>>};
encode(#notify_first_charge_info{status=STATUS}) ->
	{?msg_notify_first_charge_info, <<STATUS:?INT>>};
encode(#req_first_charge_reward{}) ->
	{?msg_req_first_charge_reward, null};
encode(#notify_first_charge_reward_result{result=RESULT}) ->
	{?msg_notify_first_charge_reward_result, <<RESULT:?INT>>};
encode(#notify_vip_reward_info{level_rewarded_list=LEVEL_REWARDED_LIST, daily_rewarded=DAILY_REWARDED}) ->
	{?msg_notify_vip_reward_info, <<(net_helper:encode_list(fun(E)-> <<E:?INT>>end, LEVEL_REWARDED_LIST))/binary, DAILY_REWARDED:?INT>>};
encode(#req_vip_grade_reward{level=LEVEL}) ->
	{?msg_req_vip_grade_reward, <<LEVEL:?INT>>};
encode(#notify_vip_grade_reward_result{result=RESULT}) ->
	{?msg_notify_vip_grade_reward_result, <<RESULT:?INT>>};
encode(#req_vip_daily_reward{result=RESULT}) ->
	{?msg_req_vip_daily_reward, <<RESULT:?INT>>};
encode(#notify_vip_daily_reward_result{result=RESULT}) ->
	{?msg_notify_vip_daily_reward_result, <<RESULT:?INT>>};
encode(#req_recharge{user_id=USER_ID, emoney=EMONEY, org_emoney=ORG_EMONEY, vip_exp=VIP_EXP}) ->
	{?msg_req_recharge, <<USER_ID:?INT, EMONEY:?INT, ORG_EMONEY:?INT, VIP_EXP:?INT>>};
encode(#notify_recharge_result{result=RESULT}) ->
	{?msg_notify_recharge_result, <<RESULT:?INT>>};
encode(#task_info{task_id=TASK_ID, has_finished=HAS_FINISHED, args=ARGS}) ->
	{?msg_task_info, <<TASK_ID:?INT, HAS_FINISHED:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, ARGS))/binary>>};
encode(#req_task_infos{}) ->
	{?msg_req_task_infos, null};
encode(#notify_task_infos{type=TYPE, infos=INFOS}) ->
	{?msg_notify_task_infos, <<TYPE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, INFOS))/binary>>};
encode(#req_finish_task{task_id=TASK_ID}) ->
	{?msg_req_finish_task, <<TASK_ID:?INT>>};
encode(#notify_finish_task{is_success=IS_SUCCESS, task_id=TASK_ID}) ->
	{?msg_notify_finish_task, <<IS_SUCCESS:?INT, TASK_ID:?INT>>};
encode(#sculpture_info{temp_id=TEMP_ID, value=VALUE, type=TYPE}) ->
	{?msg_sculpture_info, <<TEMP_ID:?INT, VALUE:?INT, TYPE:?INT>>};
encode(#req_sculpture_infos{}) ->
	{?msg_req_sculpture_infos, null};
encode(#notify_sculpture_infos{type=TYPE, sculpture_infos=SCULPTURE_INFOS}) ->
	{?msg_notify_sculpture_infos, <<TYPE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, SCULPTURE_INFOS))/binary>>};
encode(#req_sculpture_puton{group_index=GROUP_INDEX, position=POSITION, temp_id=TEMP_ID}) ->
	{?msg_req_sculpture_puton, <<GROUP_INDEX:?INT, POSITION:?INT, TEMP_ID:?INT>>};
encode(#notify_sculpture_puton{is_success=IS_SUCCESS, group_index=GROUP_INDEX, position=POSITION, temp_id=TEMP_ID}) ->
	{?msg_notify_sculpture_puton, <<IS_SUCCESS:?INT, GROUP_INDEX:?INT, POSITION:?INT, TEMP_ID:?INT>>};
encode(#req_sculpture_takeoff{group_index=GROUP_INDEX, position=POSITION}) ->
	{?msg_req_sculpture_takeoff, <<GROUP_INDEX:?INT, POSITION:?INT>>};
encode(#notify_sculpture_takeoff{is_success=IS_SUCCESS, group_index=GROUP_INDEX, position=POSITION}) ->
	{?msg_notify_sculpture_takeoff, <<IS_SUCCESS:?INT, GROUP_INDEX:?INT, POSITION:?INT>>};
encode(#req_change_skill_group{group_index=GROUP_INDEX}) ->
	{?msg_req_change_skill_group, <<GROUP_INDEX:?INT>>};
encode(#notify_change_skill_group{result=RESULT, activate_group=ACTIVATE_GROUP}) ->
	{?msg_notify_change_skill_group, <<RESULT:?INT, ACTIVATE_GROUP:?INT>>};
encode(#req_sculpture_upgrade{temp_id=TEMP_ID}) ->
	{?msg_req_sculpture_upgrade, <<TEMP_ID:?INT>>};
encode(#notify_sculpture_upgrade{result=RESULT}) ->
	{?msg_notify_sculpture_upgrade, <<RESULT:?INT>>};
encode(#req_sculpture_advnace{temp_id=TEMP_ID}) ->
	{?msg_req_sculpture_advnace, <<TEMP_ID:?INT>>};
encode(#notify_sculpture_advnace{result=RESULT, new_temp_id=NEW_TEMP_ID}) ->
	{?msg_notify_sculpture_advnace, <<RESULT:?INT, NEW_TEMP_ID:?INT>>};
encode(#req_sculpture_unlock{temp_id=TEMP_ID}) ->
	{?msg_req_sculpture_unlock, <<TEMP_ID:?INT>>};
encode(#notify_sculpture_unlock{result=RESULT, temp_id=TEMP_ID}) ->
	{?msg_notify_sculpture_unlock, <<RESULT:?INT, TEMP_ID:?INT>>};
encode(#req_sculpture_divine{type=TYPE}) ->
	{?msg_req_sculpture_divine, <<TYPE:?INT>>};
encode(#notify_sculpture_divine{result=RESULT, reward_list=REWARD_LIST, type=TYPE}) ->
	{?msg_notify_sculpture_divine, <<RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, REWARD_LIST))/binary, TYPE:?INT>>};
encode(#notify_divine_info{count=COUNT, common_remain_time=COMMON_REMAIN_TIME, rare_remain_time=RARE_REMAIN_TIME}) ->
	{?msg_notify_divine_info, <<COUNT:?INT, COMMON_REMAIN_TIME:?INT, RARE_REMAIN_TIME:?INT>>};
encode(#notify_skill_groups_info{groups=GROUPS}) ->
	{?msg_notify_skill_groups_info, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, GROUPS))/binary>>};
encode(#req_challenge_other_player{role_id=ROLE_ID}) ->
	{?msg_req_challenge_other_player, <<ROLE_ID:?UINT64>>};
encode(#notify_challenge_other_player_result{game_id=GAME_ID, result=RESULT, map=MAP}) ->
	{?msg_notify_challenge_other_player_result, <<GAME_ID:?UINT64, RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MAP))/binary>>};
encode(#req_challenge_settle{game_id=GAME_ID, result=RESULT}) ->
	{?msg_req_challenge_settle, <<GAME_ID:?UINT64, RESULT:?INT>>};
encode(#notify_challenge_settle{result=RESULT, point=POINT, coins=COINS}) ->
	{?msg_notify_challenge_settle, <<RESULT:?INT, POINT:?INT, COINS:?INT>>};
encode(#notify_be_challenged_times{times=TIMES}) ->
	{?msg_notify_be_challenged_times, <<TIMES:?INT>>};
encode(#req_get_be_challenged_info{}) ->
	{?msg_req_get_be_challenged_info, null};
encode(#notify_challenge_info_list{infos=INFOS}) ->
	{?msg_notify_challenge_info_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, INFOS))/binary>>};
encode(#req_get_challenge_rank{}) ->
	{?msg_req_get_challenge_rank, null};
encode(#notify_challenge_rank_list{infos=INFOS}) ->
	{?msg_notify_challenge_rank_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, INFOS))/binary>>};
encode(#req_get_can_challenge_role{}) ->
	{?msg_req_get_can_challenge_role, null};
encode(#notify_can_challenge_lists{infos=INFOS}) ->
	{?msg_notify_can_challenge_lists, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, INFOS))/binary>>};
encode(#req_buy_challenge_times{}) ->
	{?msg_req_buy_challenge_times, null};
encode(#notify_buy_challenge_times_result{result=RESULT}) ->
	{?msg_notify_buy_challenge_times_result, <<RESULT:?INT>>};
encode(#req_get_challenge_times_info{}) ->
	{?msg_req_get_challenge_times_info, null};
encode(#notify_challenge_times_info{buy_times=BUY_TIMES, org_times=ORG_TIMES, play_times=PLAY_TIMES, award_timeleft=AWARD_TIMELEFT}) ->
	{?msg_notify_challenge_times_info, <<BUY_TIMES:?INT, ORG_TIMES:?INT, PLAY_TIMES:?INT, AWARD_TIMELEFT:?INT>>};
encode(#req_assistance_list{}) ->
	{?msg_req_assistance_list, null};
encode(#notify_assistance_list{donors=DONORS}) ->
	{?msg_notify_assistance_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, DONORS))/binary>>};
encode(#req_select_donor{donor_id=DONOR_ID}) ->
	{?msg_req_select_donor, <<DONOR_ID:?UINT64>>};
encode(#notify_select_donor_result{result=RESULT}) ->
	{?msg_notify_select_donor_result, <<RESULT:?INT>>};
encode(#req_refresh_assistance_list{}) ->
	{?msg_req_refresh_assistance_list, null};
encode(#notify_refresh_assistance_list_result{result=RESULT}) ->
	{?msg_notify_refresh_assistance_list_result, <<RESULT:?INT>>};
encode(#req_fresh_lottery_list{}) ->
	{?msg_req_fresh_lottery_list, null};
encode(#notify_fresh_lottery_list{lottery_items=LOTTERY_ITEMS}) ->
	{?msg_notify_fresh_lottery_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, LOTTERY_ITEMS))/binary>>};
encode(#req_friend_point_lottery{}) ->
	{?msg_req_friend_point_lottery, null};
encode(#notify_friend_point_lottery_result{result=RESULT, id=ID, amount=AMOUNT}) ->
	{?msg_notify_friend_point_lottery_result, <<RESULT:?INT, ID:?INT, AMOUNT:?INT>>};
encode(#notify_assistance_info{lottery_times=LOTTERY_TIMES, refresh_times=REFRESH_TIMES}) ->
	{?msg_notify_assistance_info, <<LOTTERY_TIMES:?INT, REFRESH_TIMES:?INT>>};
encode(#notify_role_info_change{type=TYPE, new_value=NEW_VALUE}) ->
	{?msg_notify_role_info_change, <<(net_helper:encode_string(TYPE))/binary, NEW_VALUE:?INT>>};
encode(#req_buy_mall_item{mallitem_id=MALLITEM_ID, buy_times=BUY_TIMES}) ->
	{?msg_req_buy_mall_item, <<MALLITEM_ID:?INT, BUY_TIMES:?INT>>};
encode(#notify_buy_mall_item_result{result=RESULT}) ->
	{?msg_notify_buy_mall_item_result, <<RESULT:?INT>>};
encode(#req_has_buy_times{}) ->
	{?msg_req_has_buy_times, null};
encode(#notify_has_buy_times{buy_info_list=BUY_INFO_LIST}) ->
	{?msg_notify_has_buy_times, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, BUY_INFO_LIST))/binary>>};
encode(#notify_add_friend_defuse_msg{role_id=ROLE_ID}) ->
	{?msg_notify_add_friend_defuse_msg, <<ROLE_ID:?UINT64>>};
encode(#req_get_challenge_rank_award{}) ->
	{?msg_req_get_challenge_rank_award, null};
encode(#notify_get_challenge_rank_award_result{result=RESULT}) ->
	{?msg_notify_get_challenge_rank_award_result, <<RESULT:?INT>>};
encode(#req_buy_point_mall_item{mallitem_id=MALLITEM_ID, buy_times=BUY_TIMES}) ->
	{?msg_req_buy_point_mall_item, <<MALLITEM_ID:?INT, BUY_TIMES:?INT>>};
encode(#notify_buy_point_mall_item_result{result=RESULT}) ->
	{?msg_notify_buy_point_mall_item_result, <<RESULT:?INT>>};
encode(#nofity_continue_login_award_info{continue_login_days=CONTINUE_LOGIN_DAYS, daily_award_status=DAILY_AWARD_STATUS, cumulative_award3_status=CUMULATIVE_AWARD3_STATUS, cumulative_award7_status=CUMULATIVE_AWARD7_STATUS, cumulative_award15_status=CUMULATIVE_AWARD15_STATUS}) ->
	{?msg_nofity_continue_login_award_info, <<CONTINUE_LOGIN_DAYS:?INT, DAILY_AWARD_STATUS:?INT, CUMULATIVE_AWARD3_STATUS:?INT, CUMULATIVE_AWARD7_STATUS:?INT, CUMULATIVE_AWARD15_STATUS:?INT>>};
encode(#req_get_daily_award{type=TYPE}) ->
	{?msg_req_get_daily_award, <<TYPE:?INT>>};
encode(#notify_get_daily_award_result{type=TYPE, result=RESULT}) ->
	{?msg_notify_get_daily_award_result, <<TYPE:?INT, RESULT:?INT>>};
encode(#notify_sys_time{sys_time=SYS_TIME}) ->
	{?msg_notify_sys_time, <<(net_helper:get_encode_binary_data(encode(SYS_TIME)))/binary>>};
encode(#req_get_rank_infos{type=TYPE}) ->
	{?msg_req_get_rank_infos, <<TYPE:?INT>>};
encode(#notify_rank_infos{type=TYPE, myrank=MYRANK, top_hundred=TOP_HUNDRED}) ->
	{?msg_notify_rank_infos, <<TYPE:?INT, MYRANK:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TOP_HUNDRED))/binary>>};
encode(#req_train_match_list{list_type=LIST_TYPE}) ->
	{?msg_req_train_match_list, <<LIST_TYPE:?INT>>};
encode(#notify_train_match_list{match_list=MATCH_LIST}) ->
	{?msg_notify_train_match_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MATCH_LIST))/binary>>};
encode(#req_start_train_match{role_id=ROLE_ID}) ->
	{?msg_req_start_train_match, <<ROLE_ID:?UINT64>>};
encode(#notify_start_train_match_result{game_id=GAME_ID, result=RESULT, map=MAP}) ->
	{?msg_notify_start_train_match_result, <<GAME_ID:?UINT64, RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MAP))/binary>>};
encode(#req_train_match_settle{game_id=GAME_ID, result=RESULT}) ->
	{?msg_req_train_match_settle, <<GAME_ID:?UINT64, RESULT:?INT>>};
encode(#notify_train_match_settle{result=RESULT, point=POINT, honour=HONOUR}) ->
	{?msg_notify_train_match_settle, <<RESULT:?INT, POINT:?INT, HONOUR:?INT>>};
encode(#req_get_train_match_times_info{}) ->
	{?msg_req_get_train_match_times_info, null};
encode(#notify_train_match_times_info{buy_times=BUY_TIMES, org_times=ORG_TIMES, play_times=PLAY_TIMES, success_times=SUCCESS_TIMES, award_status=AWARD_STATUS, refresh_times=REFRESH_TIMES}) ->
	{?msg_notify_train_match_times_info, <<BUY_TIMES:?INT, ORG_TIMES:?INT, PLAY_TIMES:?INT, SUCCESS_TIMES:?INT, AWARD_STATUS:?INT, REFRESH_TIMES:?INT>>};
encode(#req_buy_train_match_times{}) ->
	{?msg_req_buy_train_match_times, null};
encode(#notify_buy_train_match_times_result{result=RESULT}) ->
	{?msg_notify_buy_train_match_times_result, <<RESULT:?INT>>};
encode(#req_get_train_award{type=TYPE}) ->
	{?msg_req_get_train_award, <<TYPE:?INT>>};
encode(#notify_get_train_award_type{result=RESULT, new_status=NEW_STATUS, award_id=AWARD_ID, amount=AMOUNT}) ->
	{?msg_notify_get_train_award_type, <<RESULT:?INT, NEW_STATUS:?INT, AWARD_ID:?INT, AMOUNT:?INT>>};
encode(#req_use_props{inst_id=INST_ID}) ->
	{?msg_req_use_props, <<INST_ID:?UINT64>>};
encode(#notify_use_props_result{result=RESULT, reward_id=REWARD_ID}) ->
	{?msg_notify_use_props_result, <<RESULT:?INT, REWARD_ID:?INT>>};
encode(#req_benison_list{}) ->
	{?msg_req_benison_list, null};
encode(#notify_benison_list{benison_list=BENISON_LIST, benison_status=BENISON_STATUS}) ->
	{?msg_notify_benison_list, <<(net_helper:encode_list(fun(E)-> <<E:?INT>>end, BENISON_LIST))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, BENISON_STATUS))/binary>>};
encode(#req_bless{benison_id=BENISON_ID}) ->
	{?msg_req_bless, <<BENISON_ID:?INT>>};
encode(#notify_bless_result{result=RESULT}) ->
	{?msg_notify_bless_result, <<RESULT:?INT>>};
encode(#notify_role_bless_buff{benison_id=BENISON_ID, buffs=BUFFS, time_left=TIME_LEFT}) ->
	{?msg_notify_role_bless_buff, <<BENISON_ID:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, BUFFS))/binary, TIME_LEFT:?INT>>};
encode(#req_refresh_benison_list{}) ->
	{?msg_req_refresh_benison_list, null};
encode(#notify_refresh_benison_list_result{result=RESULT}) ->
	{?msg_notify_refresh_benison_list_result, <<RESULT:?INT>>};
encode(#req_equipment_advance{inst_id=INST_ID}) ->
	{?msg_req_equipment_advance, <<INST_ID:?UINT64>>};
encode(#notify_equipment_advance_result{result=RESULT}) ->
	{?msg_notify_equipment_advance_result, <<RESULT:?INT>>};
encode(#req_equipment_exchange{inst_id=INST_ID}) ->
	{?msg_req_equipment_exchange, <<INST_ID:?UINT64>>};
encode(#notify_equipment_exchange_result{result=RESULT}) ->
	{?msg_notify_equipment_exchange_result, <<RESULT:?INT>>};
encode(#req_equipment_resolve{inst_id=INST_ID}) ->
	{?msg_req_equipment_resolve, <<(net_helper:encode_list(fun(E)-> <<E:?UINT64>>end, INST_ID))/binary>>};
encode(#notify_equipment_resolve_result{result=RESULT, errid=ERRID, infos=INFOS}) ->
	{?msg_notify_equipment_resolve_result, <<RESULT:?INT, ERRID:?UINT64, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, INFOS))/binary>>};
encode(#req_equipment_recast{inst_id=INST_ID}) ->
	{?msg_req_equipment_recast, <<INST_ID:?UINT64>>};
encode(#notify_equipment_recast_result{result=RESULT, new_info=NEW_INFO}) ->
	{?msg_notify_equipment_recast_result, <<RESULT:?INT, (net_helper:get_encode_binary_data(encode(NEW_INFO)))/binary>>};
encode(#req_save_recast_info{equipment_id=EQUIPMENT_ID}) ->
	{?msg_req_save_recast_info, <<EQUIPMENT_ID:?UINT64>>};
encode(#notify_save_recast_info_result{result=RESULT}) ->
	{?msg_notify_save_recast_info_result, <<RESULT:?INT>>};
encode(#notify_upgrade_task_rewarded_list{reward_ids=REWARD_IDS}) ->
	{?msg_notify_upgrade_task_rewarded_list, <<(net_helper:encode_list(fun(E)-> <<E:?INT>>end, REWARD_IDS))/binary>>};
encode(#req_upgrade_task_reward{task_id=TASK_ID}) ->
	{?msg_req_upgrade_task_reward, <<TASK_ID:?INT>>};
encode(#notify_upgrade_task_reward_result{task_id=TASK_ID, result=RESULT}) ->
	{?msg_notify_upgrade_task_reward_result, <<TASK_ID:?INT, RESULT:?INT>>};
encode(#ladder_role_info{role_id=ROLE_ID, data_type=DATA_TYPE, curHp=CURHP, nickname=NICKNAME, battle_power=BATTLE_POWER, type=TYPE, level=LEVEL, battle_prop=BATTLE_PROP, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, talent_list=TALENT_LIST}) ->
	{?msg_ladder_role_info, <<ROLE_ID:?UINT64, DATA_TYPE:?INT, CURHP:?INT, (net_helper:encode_string(NICKNAME))/binary, BATTLE_POWER:?INT, TYPE:?INT, LEVEL:?INT, (net_helper:get_encode_binary_data(encode(BATTLE_PROP)))/binary, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TALENT_LIST))/binary>>};
encode(#req_ladder_role_list{}) ->
	{?msg_req_ladder_role_list, null};
encode(#notify_ladder_role_list{teammate=TEAMMATE, opponent=OPPONENT}) ->
	{?msg_notify_ladder_role_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TEAMMATE))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, OPPONENT))/binary>>};
encode(#req_ladder_teammate{}) ->
	{?msg_req_ladder_teammate, null};
encode(#notify_req_ladder_teammate_result{teammate_info=TEAMMATE_INFO, result=RESULT}) ->
	{?msg_notify_req_ladder_teammate_result, <<(net_helper:get_encode_binary_data(encode(TEAMMATE_INFO)))/binary, RESULT:?INT>>};
encode(#req_reselect_ladder_teammate{role_id=ROLE_ID}) ->
	{?msg_req_reselect_ladder_teammate, <<ROLE_ID:?UINT64>>};
encode(#notify_reselect_ladder_teammate_result{teammate_info=TEAMMATE_INFO}) ->
	{?msg_notify_reselect_ladder_teammate_result, <<(net_helper:get_encode_binary_data(encode(TEAMMATE_INFO)))/binary>>};
encode(#req_ladder_match_info{}) ->
	{?msg_req_ladder_match_info, null};
encode(#notify_ladder_match_info{pass_level=PASS_LEVEL, cur_life=CUR_LIFE, is_failed=IS_FAILED, recover_count=RECOVER_COUNT, reset_count=RESET_COUNT}) ->
	{?msg_notify_ladder_match_info, <<PASS_LEVEL:?INT, CUR_LIFE:?INT, IS_FAILED:?INT, RECOVER_COUNT:?INT, RESET_COUNT:?INT>>};
encode(#req_ladder_match_battle{}) ->
	{?msg_req_ladder_match_battle, null};
encode(#notify_ladder_match_battle_result{result=RESULT, map=MAP, game_id=GAME_ID}) ->
	{?msg_notify_ladder_match_battle_result, <<RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MAP))/binary, GAME_ID:?UINT64>>};
encode(#req_settle_ladder_match{game_id=GAME_ID, life_info=LIFE_INFO, result=RESULT}) ->
	{?msg_req_settle_ladder_match, <<GAME_ID:?UINT64, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, LIFE_INFO))/binary, RESULT:?INT>>};
encode(#notify_settle_ladder_match{result=RESULT, reward_ids=REWARD_IDS, reward_amounts=REWARD_AMOUNTS}) ->
	{?msg_notify_settle_ladder_match, <<RESULT:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, REWARD_IDS))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, REWARD_AMOUNTS))/binary>>};
encode(#req_reset_ladder_match{}) ->
	{?msg_req_reset_ladder_match, null};
encode(#notify_reset_ladder_match_result{result=RESULT}) ->
	{?msg_notify_reset_ladder_match_result, <<RESULT:?INT>>};
encode(#req_recover_teammate_life{}) ->
	{?msg_req_recover_teammate_life, null};
encode(#notify_recover_teammate_life_result{result=RESULT}) ->
	{?msg_notify_recover_teammate_life_result, <<RESULT:?INT>>};
encode(#notify_online_award_info{total_online_time=TOTAL_ONLINE_TIME, has_get_awards=HAS_GET_AWARDS}) ->
	{?msg_notify_online_award_info, <<TOTAL_ONLINE_TIME:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, HAS_GET_AWARDS))/binary>>};
encode(#req_get_online_award{online_award_id=ONLINE_AWARD_ID}) ->
	{?msg_req_get_online_award, <<ONLINE_AWARD_ID:?INT>>};
encode(#notify_get_online_award_result{result=RESULT}) ->
	{?msg_notify_get_online_award_result, <<RESULT:?INT>>};
encode(#req_alchemy_info{}) ->
	{?msg_req_alchemy_info, null};
encode(#notify_alchemy_info{nomrmal_count=NOMRMAL_COUNT, remain_normal_second=REMAIN_NORMAL_SECOND, advanced_count=ADVANCED_COUNT, level=LEVEL, rewarded_list=REWARDED_LIST}) ->
	{?msg_notify_alchemy_info, <<NOMRMAL_COUNT:?INT, REMAIN_NORMAL_SECOND:?INT, ADVANCED_COUNT:?INT, LEVEL:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, REWARDED_LIST))/binary>>};
encode(#req_metallurgy{type=TYPE}) ->
	{?msg_req_metallurgy, <<TYPE:?INT>>};
encode(#notify_metallurgy_reuslt{result=RESULT}) ->
	{?msg_notify_metallurgy_reuslt, <<RESULT:?INT>>};
encode(#req_alchemy_reward{type=TYPE}) ->
	{?msg_req_alchemy_reward, <<TYPE:?INT>>};
encode(#notify_alchemy_reward_reuslt{result=RESULT}) ->
	{?msg_notify_alchemy_reward_reuslt, <<RESULT:?INT>>};
encode(#req_potence_advance{is_use_amulet=IS_USE_AMULET}) ->
	{?msg_req_potence_advance, <<IS_USE_AMULET:?INT>>};
encode(#notify_potence_advance_result{result=RESULT, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL}) ->
	{?msg_notify_potence_advance_result, <<RESULT:?INT, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT>>};
encode(#req_exchange_item{exchange_id=EXCHANGE_ID}) ->
	{?msg_req_exchange_item, <<EXCHANGE_ID:?INT>>};
encode(#notify_exchange_item_result{result=RESULT}) ->
	{?msg_notify_exchange_item_result, <<RESULT:?INT>>};
encode(#req_has_buy_discount_item_times{}) ->
	{?msg_req_has_buy_discount_item_times, null};
encode(#notify_has_buy_discount_item_times{buy_info_list=BUY_INFO_LIST}) ->
	{?msg_notify_has_buy_discount_item_times, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, BUY_INFO_LIST))/binary>>};
encode(#req_buy_discount_limit_item{id=ID}) ->
	{?msg_req_buy_discount_limit_item, <<ID:?INT>>};
encode(#notify_buy_discount_limit_item_result{result=RESULT, mall_item_id=MALL_ITEM_ID}) ->
	{?msg_notify_buy_discount_limit_item_result, <<RESULT:?INT, MALL_ITEM_ID:?INT>>};
encode(#req_convert_cdkey{award_id=AWARD_ID}) ->
	{?msg_req_convert_cdkey, <<AWARD_ID:?INT>>};
encode(#notify_redeem_cdoe_result{awards=AWARDS}) ->
	{?msg_notify_redeem_cdoe_result, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, AWARDS))/binary>>};
encode(#notify_email_list{emails=EMAILS}) ->
	{?msg_notify_email_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, EMAILS))/binary>>};
encode(#notify_email_add{new_email=NEW_EMAIL}) ->
	{?msg_notify_email_add, <<(net_helper:get_encode_binary_data(encode(NEW_EMAIL)))/binary>>};
encode(#req_get_email_attachments{email_id=EMAIL_ID}) ->
	{?msg_req_get_email_attachments, <<EMAIL_ID:?INT>>};
encode(#notify_get_email_attachments_result{result=RESULT}) ->
	{?msg_notify_get_email_attachments_result, <<RESULT:?INT>>};
encode(#req_buy_mooncard{type=TYPE, reward_emoney=REWARD_EMONEY}) ->
	{?msg_req_buy_mooncard, <<TYPE:?INT, REWARD_EMONEY:?INT>>};
encode(#notify_mooncard_info{award_status=AWARD_STATUS, days_remain=DAYS_REMAIN}) ->
	{?msg_notify_mooncard_info, <<AWARD_STATUS:?INT, DAYS_REMAIN:?INT>>};
encode(#req_get_mooncard_daily_award{}) ->
	{?msg_req_get_mooncard_daily_award, null};
encode(#notify_get_mooncard_daily_award_result{result=RESULT}) ->
	{?msg_notify_get_mooncard_daily_award_result, <<RESULT:?INT>>};
encode(#req_enter_activity_copy{copy_id=COPY_ID}) ->
	{?msg_req_enter_activity_copy, <<COPY_ID:?INT>>};
encode(#notify_enter_activity_result{result=RESULT, game_id=GAME_ID, gamemaps=GAMEMAPS}) ->
	{?msg_notify_enter_activity_result, <<RESULT:?INT, GAME_ID:?UINT64, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, GAMEMAPS))/binary>>};
encode(#req_settle_activity_copy{game_id=GAME_ID, result=RESULT, pickup_items=PICKUP_ITEMS, gold=GOLD}) ->
	{?msg_req_settle_activity_copy, <<GAME_ID:?UINT64, RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, PICKUP_ITEMS))/binary, GOLD:?INT>>};
encode(#notify_settle_activity_copy_result{result=RESULT}) ->
	{?msg_notify_settle_activity_copy_result, <<RESULT:?INT>>};
encode(#notify_activity_copy_info{play_times=PLAY_TIMES}) ->
	{?msg_notify_activity_copy_info, <<PLAY_TIMES:?INT>>};
encode(#req_verify_invite_code{code=CODE}) ->
	{?msg_req_verify_invite_code, <<(net_helper:encode_string(CODE))/binary>>};
encode(#notify_verify_invite_code_result{result=RESULT}) ->
	{?msg_notify_verify_invite_code_result, <<RESULT:?INT>>};
encode(#req_input_invite_code{code=CODE}) ->
	{?msg_req_input_invite_code, <<(net_helper:encode_string(CODE))/binary>>};
encode(#notify_input_invite_code_result{result=RESULT, master=MASTER}) ->
	{?msg_notify_input_invite_code_result, <<RESULT:?INT, (net_helper:get_encode_binary_data(encode(MASTER)))/binary>>};
encode(#req_disengage_check{type=TYPE, role_id=ROLE_ID}) ->
	{?msg_req_disengage_check, <<TYPE:?INT, ROLE_ID:?UINT64>>};
encode(#notify_disengage_check_result{result=RESULT, role_id=ROLE_ID, type=TYPE}) ->
	{?msg_notify_disengage_check_result, <<RESULT:?INT, ROLE_ID:?UINT64, TYPE:?INT>>};
encode(#req_disengage{type=TYPE, role_id=ROLE_ID}) ->
	{?msg_req_disengage, <<TYPE:?INT, ROLE_ID:?UINT64>>};
encode(#notify_disengage_result{result=RESULT, role_id=ROLE_ID, type=TYPE}) ->
	{?msg_notify_disengage_result, <<RESULT:?INT, ROLE_ID:?UINT64, TYPE:?INT>>};
encode(#notify_lost_prentice{role_id=ROLE_ID}) ->
	{?msg_notify_lost_prentice, <<ROLE_ID:?UINT64>>};
encode(#notify_lost_master{role_id=ROLE_ID}) ->
	{?msg_notify_lost_master, <<ROLE_ID:?UINT64>>};
encode(#req_master_level_reward{prentice_id=PRENTICE_ID, level=LEVEL}) ->
	{?msg_req_master_level_reward, <<PRENTICE_ID:?UINT64, LEVEL:?INT>>};
encode(#notify_master_level_reward_result{result=RESULT, prentice_id=PRENTICE_ID, level=LEVEL}) ->
	{?msg_notify_master_level_reward_result, <<RESULT:?INT, PRENTICE_ID:?UINT64, LEVEL:?INT>>};
encode(#req_prentice_level_reward{level=LEVEL}) ->
	{?msg_req_prentice_level_reward, <<LEVEL:?INT>>};
encode(#notify_prentice_level_reward_result{result=RESULT, level=LEVEL}) ->
	{?msg_notify_prentice_level_reward_result, <<RESULT:?INT, LEVEL:?INT>>};
encode(#req_master_help{level=LEVEL}) ->
	{?msg_req_master_help, <<LEVEL:?INT>>};
encode(#notify_master_help_result{result=RESULT}) ->
	{?msg_notify_master_help_result, <<RESULT:?INT>>};
encode(#req_give_help{prentice_id=PRENTICE_ID}) ->
	{?msg_req_give_help, <<PRENTICE_ID:?UINT64>>};
encode(#notify_give_help_result{result=RESULT}) ->
	{?msg_notify_give_help_result, <<RESULT:?INT>>};
encode(#req_get_help_reward{level=LEVEL}) ->
	{?msg_req_get_help_reward, <<LEVEL:?INT>>};
encode(#notify_get_help_reward_result{result=RESULT, level=LEVEL}) ->
	{?msg_notify_get_help_reward_result, <<RESULT:?INT, LEVEL:?INT>>};
encode(#notify_req_help_from_prentice{prentice_id=PRENTICE_ID}) ->
	{?msg_notify_req_help_from_prentice, <<PRENTICE_ID:?UINT64>>};
encode(#notify_give_help_from_master{master_id=MASTER_ID}) ->
	{?msg_notify_give_help_from_master, <<MASTER_ID:?UINT64>>};
encode(#notify_invite_code_info{master=MASTER, prentice_list=PRENTICE_LIST, code=CODE, is_new_prentice_got=IS_NEW_PRENTICE_GOT, rewarded_list=REWARDED_LIST}) ->
	{?msg_notify_invite_code_info, <<(net_helper:get_encode_binary_data(encode(MASTER)))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, PRENTICE_LIST))/binary, (net_helper:encode_string(CODE))/binary, IS_NEW_PRENTICE_GOT:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, REWARDED_LIST))/binary>>};
encode(#req_send_hp{friend_id=FRIEND_ID}) ->
	{?msg_req_send_hp, <<FRIEND_ID:?UINT64>>};
encode(#notify_send_hp_result{result=RESULT, friend_id=FRIEND_ID}) ->
	{?msg_notify_send_hp_result, <<RESULT:?INT, FRIEND_ID:?UINT64>>};
encode(#notify_get_hp_help_from_friend{friend_id=FRIEND_ID}) ->
	{?msg_notify_get_hp_help_from_friend, <<FRIEND_ID:?UINT64>>};
encode(#req_reward_hp_from_friend{friend_id=FRIEND_ID}) ->
	{?msg_req_reward_hp_from_friend, <<FRIEND_ID:?UINT64>>};
encode(#notify_reward_hp_from_friend_result{result=RESULT, friend_id=FRIEND_ID}) ->
	{?msg_notify_reward_hp_from_friend_result, <<RESULT:?INT, FRIEND_ID:?UINT64>>};
encode(#notify_boss_copy_fight_count{count=COUNT}) ->
	{?msg_notify_boss_copy_fight_count, <<COUNT:?INT>>};
encode(#req_chat_in_world_channel{msg=MSG}) ->
	{?msg_req_chat_in_world_channel, <<(net_helper:encode_string(MSG))/binary>>};
encode(#notify_chat_in_world_channel_result{result=RESULT}) ->
	{?msg_notify_chat_in_world_channel_result, <<RESULT:?INT>>};
encode(#notify_world_channel_msg{speaker_id=SPEAKER_ID, speaker=SPEAKER, msg=MSG}) ->
	{?msg_notify_world_channel_msg, <<SPEAKER_ID:?UINT64, (net_helper:encode_string(SPEAKER))/binary, (net_helper:encode_string(MSG))/binary>>};
encode(#notify_my_world_chat_info{speek_times=SPEEK_TIMES, extra_times=EXTRA_TIMES}) ->
	{?msg_notify_my_world_chat_info, <<SPEEK_TIMES:?INT, EXTRA_TIMES:?INT>>};
encode(#req_get_role_detail_info{role_id=ROLE_ID}) ->
	{?msg_req_get_role_detail_info, <<ROLE_ID:?UINT64>>};
encode(#notify_role_detail_info_result{role_id=ROLE_ID, nickname=NICKNAME, status=STATUS, level=LEVEL, type=TYPE, public=PUBLIC, potence_level=POTENCE_LEVEL, advanced_level=ADVANCED_LEVEL, sculptures=SCULPTURES, equipments=EQUIPMENTS, battle_power=BATTLE_POWER, military_lev=MILITARY_LEV, challenge_rank=CHALLENGE_RANK}) ->
	{?msg_notify_role_detail_info_result, <<ROLE_ID:?UINT64, (net_helper:encode_string(NICKNAME))/binary, STATUS:?INT, LEVEL:?INT, TYPE:?INT, (net_helper:encode_string(PUBLIC))/binary, POTENCE_LEVEL:?INT, ADVANCED_LEVEL:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, SCULPTURES))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, EQUIPMENTS))/binary, BATTLE_POWER:?INT, MILITARY_LEV:?INT, CHALLENGE_RANK:?INT>>};
encode(#notify_get_talent_active_info{active_talent_ids=ACTIVE_TALENT_IDS, reset_active_hours=RESET_ACTIVE_HOURS}) ->
	{?msg_notify_get_talent_active_info, <<(net_helper:encode_list(fun(E)-> <<E:?INT>>end, ACTIVE_TALENT_IDS))/binary, RESET_ACTIVE_HOURS:?INT>>};
encode(#req_actived_talent{talent_id=TALENT_ID}) ->
	{?msg_req_actived_talent, <<TALENT_ID:?INT>>};
encode(#notify_actived_talent{is_success=IS_SUCCESS, talent_id=TALENT_ID}) ->
	{?msg_notify_actived_talent, <<IS_SUCCESS:?INT, TALENT_ID:?INT>>};
encode(#req_reset_talent{}) ->
	{?msg_req_reset_talent, null};
encode(#notify_reset_talent{is_success=IS_SUCCESS}) ->
	{?msg_notify_reset_talent, <<IS_SUCCESS:?INT>>};
encode(#req_level_up_talent{talent_id=TALENT_ID}) ->
	{?msg_req_level_up_talent, <<TALENT_ID:?INT>>};
encode(#notify_level_up_talent{is_success=IS_SUCCESS}) ->
	{?msg_notify_level_up_talent, <<IS_SUCCESS:?INT>>};
encode(#req_notice_list{}) ->
	{?msg_req_notice_list, null};
encode(#notify_notice_list{list=LIST}) ->
	{?msg_notify_notice_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, LIST))/binary>>};
encode(#notify_notice_item_add{item_info=ITEM_INFO}) ->
	{?msg_notify_notice_item_add, <<(net_helper:get_encode_binary_data(encode(ITEM_INFO)))/binary>>};
encode(#notify_notice_item_del{del_id=DEL_ID}) ->
	{?msg_notify_notice_item_del, <<DEL_ID:?INT>>};
encode(#req_notice_item_detail{id=ID}) ->
	{?msg_req_notice_item_detail, <<ID:?INT>>};
encode(#notify_notice_item_detail{result=RESULT, item_info=ITEM_INFO}) ->
	{?msg_notify_notice_item_detail, <<RESULT:?INT, (net_helper:get_encode_binary_data(encode(ITEM_INFO)))/binary>>};
encode(#req_time_limit_reward{id=ID}) ->
	{?msg_req_time_limit_reward, <<ID:?INT>>};
encode(#notify_time_limit_reward{result=RESULT}) ->
	{?msg_notify_time_limit_reward, <<RESULT:?INT>>};
encode(#notify_time_limit_rewarded_list{list=LIST}) ->
	{?msg_notify_time_limit_rewarded_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, LIST))/binary>>};
encode(#notify_activity_list{list=LIST}) ->
	{?msg_notify_activity_list, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, LIST))/binary>>};
encode(#notify_act_lottery_info{remain_count=REMAIN_COUNT, progress_list=PROGRESS_LIST}) ->
	{?msg_notify_act_lottery_info, <<REMAIN_COUNT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, PROGRESS_LIST))/binary>>};
encode(#req_act_lottery{}) ->
	{?msg_req_act_lottery, null};
encode(#notify_act_lottery_result{result=RESULT, reward_id=REWARD_ID}) ->
	{?msg_notify_act_lottery_result, <<RESULT:?INT, REWARD_ID:?INT>>};
encode(#notify_act_recharge_info{cur_recharge_count=CUR_RECHARGE_COUNT, rewarded_list=REWARDED_LIST}) ->
	{?msg_notify_act_recharge_info, <<CUR_RECHARGE_COUNT:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, REWARDED_LIST))/binary>>};
encode(#req_act_recharge_reward{id=ID}) ->
	{?msg_req_act_recharge_reward, <<ID:?INT>>};
encode(#notify_act_recharge_reward_result{result=RESULT, id=ID}) ->
	{?msg_notify_act_recharge_reward_result, <<RESULT:?INT, ID:?INT>>};
encode(#req_emoney_2_gold{emoney=EMONEY}) ->
	{?msg_req_emoney_2_gold, <<EMONEY:?INT>>};
encode(#notify_emoney_2_gold_result{result=RESULT}) ->
	{?msg_notify_emoney_2_gold_result, <<RESULT:?INT>>}.


decode(?msg_req_check_version, Binary) ->
	net_helper:decode([int], Binary, [req_check_version]);
decode(?msg_notify_check_version_result, Binary) ->
	net_helper:decode([int], Binary, [notify_check_version_result]);
decode(?msg_req_login, Binary) ->
	net_helper:decode([string, string], Binary, [req_login]);
decode(?msg_req_login_check, Binary) ->
	net_helper:decode([string, string], Binary, [req_login_check]);
decode(?msg_role_data, Binary) ->
	net_helper:decode([uint64, int, int, int, string, int, int], Binary, [role_data]);
decode(?msg_notifu_login_check_result, Binary) ->
	net_helper:decode([int, int, int, {array, user_define, fun(Bin)->decode(?msg_role_data, Bin)end}], Binary, [notifu_login_check_result]);
decode(?msg_notify_login_result, Binary) ->
	net_helper:decode([uint64, int, int, {array, user_define, fun(Bin)->decode(?msg_role_data, Bin)end}], Binary, [notify_login_result]);
decode(?msg_notify_sys_msg, Binary) ->
	net_helper:decode([int, {array, string}], Binary, [notify_sys_msg]);
decode(?msg_req_select_role, Binary) ->
	net_helper:decode([uint64], Binary, [req_select_role]);
decode(?msg_notify_select_role_result, Binary) ->
	net_helper:decode([int], Binary, [notify_select_role_result]);
decode(?msg_req_delete_role, Binary) ->
	net_helper:decode([uint64], Binary, [req_delete_role]);
decode(?msg_notify_delete_role_result, Binary) ->
	net_helper:decode([int], Binary, [notify_delete_role_result]);
decode(?msg_req_recover_del_role, Binary) ->
	net_helper:decode([uint64], Binary, [req_recover_del_role]);
decode(?msg_notify_recover_del_role_result, Binary) ->
	net_helper:decode([int], Binary, [notify_recover_del_role_result]);
decode(?msg_req_reselect_role, Binary) ->
	net_helper:decode([], Binary, [req_reselect_role]);
decode(?msg_notify_roles_infos, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_role_data, Bin)end}], Binary, [notify_roles_infos]);
decode(?msg_req_gm_optition, Binary) ->
	net_helper:decode([int, int], Binary, [req_gm_optition]);
decode(?msg_player_data, Binary) ->
	net_helper:decode([string, string, int], Binary, [player_data]);
decode(?msg_sculpture_data, Binary) ->
	net_helper:decode([int, int], Binary, [sculpture_data]);
decode(?msg_stime, Binary) ->
	net_helper:decode([int, int, int, int, int, int], Binary, [stime]);
decode(?msg_mons_item, Binary) ->
	net_helper:decode([int, int], Binary, [mons_item]);
decode(?msg_reward_item, Binary) ->
	net_helper:decode([int, int], Binary, [reward_item]);
decode(?msg_smonster, Binary) ->
	net_helper:decode([int, int, {array, user_define, fun(Bin)->decode(?msg_mons_item, Bin)end}], Binary, [smonster]);
decode(?msg_strap, Binary) ->
	net_helper:decode([int, int], Binary, [strap]);
decode(?msg_saward, Binary) ->
	net_helper:decode([int, int], Binary, [saward]);
decode(?msg_sfriend, Binary) ->
	net_helper:decode([int, int], Binary, [sfriend]);
decode(?msg_battle_info, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_sculpture_data, Bin)end}, int, int, int, int, int, int, int, int], Binary, [battle_info]);
decode(?msg_talent, Binary) ->
	net_helper:decode([int, int], Binary, [talent]);
decode(?msg_senemy, Binary) ->
	net_helper:decode([uint64, string, int, int, int, int, int, {user_define, fun(Bin)->decode(?msg_battle_info, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_talent, Bin)end}, int, int, int, int], Binary, [senemy]);
decode(?msg_game_map, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_smonster, Bin)end}, int, int, {array, user_define, fun(Bin)->decode(?msg_saward, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_strap, Bin)end}, {array, int}, {array, user_define, fun(Bin)->decode(?msg_sfriend, Bin)end}, int, {array, user_define, fun(Bin)->decode(?msg_senemy, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_smonster, Bin)end}, int], Binary, [game_map]);
decode(?msg_item, Binary) ->
	net_helper:decode([uint64, int], Binary, [item]);
decode(?msg_pack_item, Binary) ->
	net_helper:decode([uint64, int, int, int], Binary, [pack_item]);
decode(?msg_copy_info, Binary) ->
	net_helper:decode([int, int, int], Binary, [copy_info]);
decode(?msg_equipmentinfo, Binary) ->
	net_helper:decode([uint64, int, int, {array, int}, {array, int}, int, int, int], Binary, [equipmentinfo]);
decode(?msg_extra_item, Binary) ->
	net_helper:decode([int, int], Binary, [extra_item]);
decode(?msg_friend_data, Binary) ->
	net_helper:decode([string, int, int, int, string, {user_define, fun(Bin)->decode(?msg_battle_info, Bin)end}, int, int], Binary, [friend_data]);
decode(?msg_friend_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, string, {user_define, fun(Bin)->decode(?msg_battle_info, Bin)end}, int, int, int, int, int], Binary, [friend_info]);
decode(?msg_award_item, Binary) ->
	net_helper:decode([int, int], Binary, [award_item]);
decode(?msg_challenge_info, Binary) ->
	net_helper:decode([string, int, int], Binary, [challenge_info]);
decode(?msg_rank_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, int, int, int], Binary, [rank_info]);
decode(?msg_train_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, int, int, int], Binary, [train_info]);
decode(?msg_rank_data, Binary) ->
	net_helper:decode([uint64, string, int, int, int, string], Binary, [rank_data]);
decode(?msg_donor, Binary) ->
	net_helper:decode([uint64, int, int, int, string, int, int, {user_define, fun(Bin)->decode(?msg_sculpture_data, Bin)end}, int, int, int, int], Binary, [donor]);
decode(?msg_mall_buy_info, Binary) ->
	net_helper:decode([int, int], Binary, [mall_buy_info]);
decode(?msg_lottery_item, Binary) ->
	net_helper:decode([int, int], Binary, [lottery_item]);
decode(?msg_friend_point_lottery_item, Binary) ->
	net_helper:decode([int, int], Binary, [friend_point_lottery_item]);
decode(?msg_activeness_task_item, Binary) ->
	net_helper:decode([int, int], Binary, [activeness_task_item]);
decode(?msg_material_info, Binary) ->
	net_helper:decode([int, int], Binary, [material_info]);
decode(?msg_clean_up_trophy, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_mons_item, Bin)end}, int, int], Binary, [clean_up_trophy]);
decode(?msg_semail, Binary) ->
	net_helper:decode([int, uchar, string, string, {array, user_define, fun(Bin)->decode(?msg_award_item, Bin)end}, {user_define, fun(Bin)->decode(?msg_stime, Bin)end}, {user_define, fun(Bin)->decode(?msg_stime, Bin)end}], Binary, [semail]);
decode(?msg_leave_msg, Binary) ->
	net_helper:decode([uint64, string], Binary, [leave_msg]);
decode(?msg_master_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, int, int], Binary, [master_info]);
decode(?msg_prentice_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, {array, int}, int], Binary, [prentice_info]);
decode(?msg_skill_group_item, Binary) ->
	net_helper:decode([int, int, int, int, int], Binary, [skill_group_item]);
decode(?msg_notice_list_item, Binary) ->
	net_helper:decode([int, string, string, int, int, {user_define, fun(Bin)->decode(?msg_stime, Bin)end}, int, int, {user_define, fun(Bin)->decode(?msg_stime, Bin)end}, {user_define, fun(Bin)->decode(?msg_stime, Bin)end}], Binary, [notice_list_item]);
decode(?msg_notice_item_detail, Binary) ->
	net_helper:decode([int, string, string, int, string, int, int], Binary, [notice_item_detail]);
decode(?msg_time_limit_rewarded_item, Binary) ->
	net_helper:decode([int, int, {user_define, fun(Bin)->decode(?msg_stime, Bin)end}], Binary, [time_limit_rewarded_item]);
decode(?msg_role_life_info, Binary) ->
	net_helper:decode([uint64, int], Binary, [role_life_info]);
decode(?msg_lottery_progress_item, Binary) ->
	net_helper:decode([int, int], Binary, [lottery_progress_item]);
decode(?msg_activity_item, Binary) ->
	net_helper:decode([int, int], Binary, [activity_item]);
decode(?msg_notify_heartbeat, Binary) ->
	net_helper:decode([int], Binary, [notify_heartbeat]);
decode(?msg_notify_socket_close, Binary) ->
	net_helper:decode([], Binary, [notify_socket_close]);
decode(?msg_notify_repeat_login, Binary) ->
	net_helper:decode([string], Binary, [notify_repeat_login]);
decode(?msg_req_register, Binary) ->
	net_helper:decode([string, int, int, string], Binary, [req_register]);
decode(?msg_notify_register_result, Binary) ->
	net_helper:decode([int], Binary, [notify_register_result]);
decode(?msg_req_create_role, Binary) ->
	net_helper:decode([int, string], Binary, [req_create_role]);
decode(?msg_notify_create_role_result, Binary) ->
	net_helper:decode([int], Binary, [notify_create_role_result]);
decode(?msg_notify_roleinfo_msg, Binary) ->
	net_helper:decode([uint64, string, int, int, uint64, uint64, uint64, uint64, uint64, uint64, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int], Binary, [notify_roleinfo_msg]);
decode(?msg_req_clean_up_copy, Binary) ->
	net_helper:decode([int, int], Binary, [req_clean_up_copy]);
decode(?msg_notify_clean_up_copy_result, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_clean_up_trophy, Bin)end}], Binary, [notify_clean_up_copy_result]);
decode(?msg_req_enter_game, Binary) ->
	net_helper:decode([uint64, int, int], Binary, [req_enter_game]);
decode(?msg_notify_enter_game, Binary) ->
	net_helper:decode([int, uint64, {array, user_define, fun(Bin)->decode(?msg_game_map, Bin)end}], Binary, [notify_enter_game]);
decode(?msg_notify_last_copy, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_copy_info, Bin)end}], Binary, [notify_last_copy]);
decode(?msg_req_last_copy, Binary) ->
	net_helper:decode([uint64], Binary, [req_last_copy]);
decode(?msg_req_buy_power_hp, Binary) ->
	net_helper:decode([], Binary, [req_buy_power_hp]);
decode(?msg_notify_buy_power_hp_result, Binary) ->
	net_helper:decode([int], Binary, [notify_buy_power_hp_result]);
decode(?msg_notify_power_hp_msg, Binary) ->
	net_helper:decode([int, int], Binary, [notify_power_hp_msg]);
decode(?msg_notify_player_pack, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_pack_item, Bin)end}], Binary, [notify_player_pack]);
decode(?msg_req_game_settle, Binary) ->
	net_helper:decode([uint64, int, int, int, int, {array, user_define, fun(Bin)->decode(?msg_mons_item, Bin)end}, {array, int}, int, {array, int}], Binary, [req_game_settle]);
decode(?msg_notify_game_settle, Binary) ->
	net_helper:decode([uint64, int, int, {user_define, fun(Bin)->decode(?msg_lottery_item, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_lottery_item, Bin)end}], Binary, [notify_game_settle]);
decode(?msg_req_game_lottery, Binary) ->
	net_helper:decode([], Binary, [req_game_lottery]);
decode(?msg_notify_game_lottery, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_lottery_item, Bin)end}, int], Binary, [notify_game_lottery]);
decode(?msg_req_game_reconnect, Binary) ->
	net_helper:decode([string, string, uint64, int], Binary, [req_game_reconnect]);
decode(?msg_notify_reconnect_result, Binary) ->
	net_helper:decode([uint64, int, int], Binary, [notify_reconnect_result]);
decode(?msg_req_equipment_strengthen, Binary) ->
	net_helper:decode([uint64], Binary, [req_equipment_strengthen]);
decode(?msg_notify_equipment_strengthen_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_equipment_strengthen_result]);
decode(?msg_req_one_touch_equipment_strengthen, Binary) ->
	net_helper:decode([uint64], Binary, [req_one_touch_equipment_strengthen]);
decode(?msg_notify_one_touch_equipment_strengthen_result, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_notify_equipment_strengthen_result, Bin)end}], Binary, [notify_one_touch_equipment_strengthen_result]);
decode(?msg_req_equipment_mountgem, Binary) ->
	net_helper:decode([uint64, uint64], Binary, [req_equipment_mountgem]);
decode(?msg_notify_equipment_mountgem_result, Binary) ->
	net_helper:decode([int], Binary, [notify_equipment_mountgem_result]);
decode(?msg_req_equipment_puton, Binary) ->
	net_helper:decode([uint64], Binary, [req_equipment_puton]);
decode(?msg_notify_equipment_puton_result, Binary) ->
	net_helper:decode([int], Binary, [notify_equipment_puton_result]);
decode(?msg_req_equipment_infos, Binary) ->
	net_helper:decode([], Binary, [req_equipment_infos]);
decode(?msg_notify_equipment_infos, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_equipmentinfo, Bin)end}], Binary, [notify_equipment_infos]);
decode(?msg_req_equipment_takeoff, Binary) ->
	net_helper:decode([int], Binary, [req_equipment_takeoff]);
decode(?msg_notify_equipment_takeoff_result, Binary) ->
	net_helper:decode([int], Binary, [notify_equipment_takeoff_result]);
decode(?msg_notify_gold_update, Binary) ->
	net_helper:decode([int], Binary, [notify_gold_update]);
decode(?msg_notify_emoney_update, Binary) ->
	net_helper:decode([int], Binary, [notify_emoney_update]);
decode(?msg_notify_summon_stone_info, Binary) ->
	net_helper:decode([int, int], Binary, [notify_summon_stone_info]);
decode(?msg_req_daily_summon_stone, Binary) ->
	net_helper:decode([], Binary, [req_daily_summon_stone]);
decode(?msg_notify_daily_summon_stone, Binary) ->
	net_helper:decode([int], Binary, [notify_daily_summon_stone]);
decode(?msg_req_buy_summon_stone, Binary) ->
	net_helper:decode([], Binary, [req_buy_summon_stone]);
decode(?msg_notify_buy_summon_stone, Binary) ->
	net_helper:decode([int], Binary, [notify_buy_summon_stone]);
decode(?msg_notify_player_pack_exceeded, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_extra_item, Bin)end}], Binary, [notify_player_pack_exceeded]);
decode(?msg_req_extend_pack, Binary) ->
	net_helper:decode([], Binary, [req_extend_pack]);
decode(?msg_notify_extend_pack_result, Binary) ->
	net_helper:decode([int], Binary, [notify_extend_pack_result]);
decode(?msg_req_sale_item, Binary) ->
	net_helper:decode([uint64, int], Binary, [req_sale_item]);
decode(?msg_notify_sale_item_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_sale_item_result]);
decode(?msg_req_sale_items, Binary) ->
	net_helper:decode([{array, uint64}], Binary, [req_sale_items]);
decode(?msg_notify_sale_items_result, Binary) ->
	net_helper:decode([int, uint64, int], Binary, [notify_sale_items_result]);
decode(?msg_req_search_friend, Binary) ->
	net_helper:decode([string], Binary, [req_search_friend]);
decode(?msg_notify_search_friend_result, Binary) ->
	net_helper:decode([int, {user_define, fun(Bin)->decode(?msg_friend_info, Bin)end}], Binary, [notify_search_friend_result]);
decode(?msg_req_add_friend, Binary) ->
	net_helper:decode([uint64], Binary, [req_add_friend]);
decode(?msg_notify_add_friend_result, Binary) ->
	net_helper:decode([int], Binary, [notify_add_friend_result]);
decode(?msg_notify_req_for_add_friend, Binary) ->
	net_helper:decode([uint64, {user_define, fun(Bin)->decode(?msg_friend_data, Bin)end}], Binary, [notify_req_for_add_friend]);
decode(?msg_req_proc_reqfor_add_friend, Binary) ->
	net_helper:decode([int, uint64], Binary, [req_proc_reqfor_add_friend]);
decode(?msg_req_del_friend, Binary) ->
	net_helper:decode([uint64], Binary, [req_del_friend]);
decode(?msg_notify_del_friend_result, Binary) ->
	net_helper:decode([int], Binary, [notify_del_friend_result]);
decode(?msg_req_get_friends, Binary) ->
	net_helper:decode([], Binary, [req_get_friends]);
decode(?msg_notify_friend_list, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_friend_info, Bin)end}], Binary, [notify_friend_list]);
decode(?msg_req_get_makefriend_reqs, Binary) ->
	net_helper:decode([], Binary, [req_get_makefriend_reqs]);
decode(?msg_notify_makefriend_reqs, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_friend_info, Bin)end}], Binary, [notify_makefriend_reqs]);
decode(?msg_notify_makefriend_reqs_amount, Binary) ->
	net_helper:decode([int], Binary, [notify_makefriend_reqs_amount]);
decode(?msg_notify_leave_msg_count, Binary) ->
	net_helper:decode([int], Binary, [notify_leave_msg_count]);
decode(?msg_req_msg_list, Binary) ->
	net_helper:decode([], Binary, [req_msg_list]);
decode(?msg_notify_msg_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_leave_msg, Bin)end}], Binary, [notify_msg_list]);
decode(?msg_req_send_chat_msg, Binary) ->
	net_helper:decode([uint64, string], Binary, [req_send_chat_msg]);
decode(?msg_notify_send_chat_msg_result, Binary) ->
	net_helper:decode([int], Binary, [notify_send_chat_msg_result]);
decode(?msg_notify_receive_chat_msg, Binary) ->
	net_helper:decode([uint64, string], Binary, [notify_receive_chat_msg]);
decode(?msg_req_push_tower_map_settle, Binary) ->
	net_helper:decode([uint64, int, int, int, {array, int}, int], Binary, [req_push_tower_map_settle]);
decode(?msg_notify_push_tower_map_settle, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_game_map, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_award_item, Bin)end}, int, int], Binary, [notify_push_tower_map_settle]);
decode(?msg_req_push_tower_buy_round, Binary) ->
	net_helper:decode([], Binary, [req_push_tower_buy_round]);
decode(?msg_notify_push_tower_buy_round, Binary) ->
	net_helper:decode([int], Binary, [notify_push_tower_buy_round]);
decode(?msg_req_push_tower_buy_playtimes, Binary) ->
	net_helper:decode([], Binary, [req_push_tower_buy_playtimes]);
decode(?msg_notify_push_tower_buy_playtimes, Binary) ->
	net_helper:decode([int], Binary, [notify_push_tower_buy_playtimes]);
decode(?msg_req_reborn, Binary) ->
	net_helper:decode([int], Binary, [req_reborn]);
decode(?msg_notify_reborn_result, Binary) ->
	net_helper:decode([int], Binary, [notify_reborn_result]);
decode(?msg_req_auto_fight, Binary) ->
	net_helper:decode([], Binary, [req_auto_fight]);
decode(?msg_notify_auto_fight_result, Binary) ->
	net_helper:decode([int], Binary, [notify_auto_fight_result]);
decode(?msg_req_gem_compound, Binary) ->
	net_helper:decode([int, int], Binary, [req_gem_compound]);
decode(?msg_notify_gem_compound_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_gem_compound_result]);
decode(?msg_req_one_touch_gem_compound, Binary) ->
	net_helper:decode([int, int], Binary, [req_one_touch_gem_compound]);
decode(?msg_notify_one_touch_gem_compound_result, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_notify_gem_compound_result, Bin)end}], Binary, [notify_one_touch_gem_compound_result]);
decode(?msg_req_gem_unmounted, Binary) ->
	net_helper:decode([uint64, int], Binary, [req_gem_unmounted]);
decode(?msg_notify_gem_unmounted_result, Binary) ->
	net_helper:decode([int], Binary, [notify_gem_unmounted_result]);
decode(?msg_req_push_tower_info, Binary) ->
	net_helper:decode([], Binary, [req_push_tower_info]);
decode(?msg_notify_push_tower_info, Binary) ->
	net_helper:decode([int, int, int], Binary, [notify_push_tower_info]);
decode(?msg_req_tutorial_progress, Binary) ->
	net_helper:decode([], Binary, [req_tutorial_progress]);
decode(?msg_notify_tutorial_progress, Binary) ->
	net_helper:decode([{array, int}], Binary, [notify_tutorial_progress]);
decode(?msg_req_set_tutorial_progress, Binary) ->
	net_helper:decode([int], Binary, [req_set_tutorial_progress]);
decode(?msg_notify_set_tutorial_progress_result, Binary) ->
	net_helper:decode([int], Binary, [notify_set_tutorial_progress_result]);
decode(?msg_notify_today_activeness_task, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_activeness_task_item, Bin)end}, {array, int}, int], Binary, [notify_today_activeness_task]);
decode(?msg_req_today_activeness_task, Binary) ->
	net_helper:decode([], Binary, [req_today_activeness_task]);
decode(?msg_req_activeness_reward, Binary) ->
	net_helper:decode([int], Binary, [req_activeness_reward]);
decode(?msg_notify_activeness_reward_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_activeness_reward_result]);
decode(?msg_req_military_rank_reward, Binary) ->
	net_helper:decode([], Binary, [req_military_rank_reward]);
decode(?msg_notify_military_rank_reward_result, Binary) ->
	net_helper:decode([int], Binary, [notify_military_rank_reward_result]);
decode(?msg_req_military_rank_info, Binary) ->
	net_helper:decode([], Binary, [req_military_rank_info]);
decode(?msg_notify_military_rank_info, Binary) ->
	net_helper:decode([int, int], Binary, [notify_military_rank_info]);
decode(?msg_notify_first_charge_info, Binary) ->
	net_helper:decode([int], Binary, [notify_first_charge_info]);
decode(?msg_req_first_charge_reward, Binary) ->
	net_helper:decode([], Binary, [req_first_charge_reward]);
decode(?msg_notify_first_charge_reward_result, Binary) ->
	net_helper:decode([int], Binary, [notify_first_charge_reward_result]);
decode(?msg_notify_vip_reward_info, Binary) ->
	net_helper:decode([{array, int}, int], Binary, [notify_vip_reward_info]);
decode(?msg_req_vip_grade_reward, Binary) ->
	net_helper:decode([int], Binary, [req_vip_grade_reward]);
decode(?msg_notify_vip_grade_reward_result, Binary) ->
	net_helper:decode([int], Binary, [notify_vip_grade_reward_result]);
decode(?msg_req_vip_daily_reward, Binary) ->
	net_helper:decode([int], Binary, [req_vip_daily_reward]);
decode(?msg_notify_vip_daily_reward_result, Binary) ->
	net_helper:decode([int], Binary, [notify_vip_daily_reward_result]);
decode(?msg_req_recharge, Binary) ->
	net_helper:decode([int, int, int, int], Binary, [req_recharge]);
decode(?msg_notify_recharge_result, Binary) ->
	net_helper:decode([int], Binary, [notify_recharge_result]);
decode(?msg_task_info, Binary) ->
	net_helper:decode([int, int, {array, int}], Binary, [task_info]);
decode(?msg_req_task_infos, Binary) ->
	net_helper:decode([], Binary, [req_task_infos]);
decode(?msg_notify_task_infos, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_task_info, Bin)end}], Binary, [notify_task_infos]);
decode(?msg_req_finish_task, Binary) ->
	net_helper:decode([int], Binary, [req_finish_task]);
decode(?msg_notify_finish_task, Binary) ->
	net_helper:decode([int, int], Binary, [notify_finish_task]);
decode(?msg_sculpture_info, Binary) ->
	net_helper:decode([int, int, int], Binary, [sculpture_info]);
decode(?msg_req_sculpture_infos, Binary) ->
	net_helper:decode([], Binary, [req_sculpture_infos]);
decode(?msg_notify_sculpture_infos, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_sculpture_info, Bin)end}], Binary, [notify_sculpture_infos]);
decode(?msg_req_sculpture_puton, Binary) ->
	net_helper:decode([int, int, int], Binary, [req_sculpture_puton]);
decode(?msg_notify_sculpture_puton, Binary) ->
	net_helper:decode([int, int, int, int], Binary, [notify_sculpture_puton]);
decode(?msg_req_sculpture_takeoff, Binary) ->
	net_helper:decode([int, int], Binary, [req_sculpture_takeoff]);
decode(?msg_notify_sculpture_takeoff, Binary) ->
	net_helper:decode([int, int, int], Binary, [notify_sculpture_takeoff]);
decode(?msg_req_change_skill_group, Binary) ->
	net_helper:decode([int], Binary, [req_change_skill_group]);
decode(?msg_notify_change_skill_group, Binary) ->
	net_helper:decode([int, int], Binary, [notify_change_skill_group]);
decode(?msg_req_sculpture_upgrade, Binary) ->
	net_helper:decode([int], Binary, [req_sculpture_upgrade]);
decode(?msg_notify_sculpture_upgrade, Binary) ->
	net_helper:decode([int], Binary, [notify_sculpture_upgrade]);
decode(?msg_req_sculpture_advnace, Binary) ->
	net_helper:decode([int], Binary, [req_sculpture_advnace]);
decode(?msg_notify_sculpture_advnace, Binary) ->
	net_helper:decode([int, int], Binary, [notify_sculpture_advnace]);
decode(?msg_req_sculpture_unlock, Binary) ->
	net_helper:decode([int], Binary, [req_sculpture_unlock]);
decode(?msg_notify_sculpture_unlock, Binary) ->
	net_helper:decode([int, int], Binary, [notify_sculpture_unlock]);
decode(?msg_req_sculpture_divine, Binary) ->
	net_helper:decode([int], Binary, [req_sculpture_divine]);
decode(?msg_notify_sculpture_divine, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_reward_item, Bin)end}, int], Binary, [notify_sculpture_divine]);
decode(?msg_notify_divine_info, Binary) ->
	net_helper:decode([int, int, int], Binary, [notify_divine_info]);
decode(?msg_notify_skill_groups_info, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_skill_group_item, Bin)end}], Binary, [notify_skill_groups_info]);
decode(?msg_req_challenge_other_player, Binary) ->
	net_helper:decode([uint64], Binary, [req_challenge_other_player]);
decode(?msg_notify_challenge_other_player_result, Binary) ->
	net_helper:decode([uint64, int, {array, user_define, fun(Bin)->decode(?msg_game_map, Bin)end}], Binary, [notify_challenge_other_player_result]);
decode(?msg_req_challenge_settle, Binary) ->
	net_helper:decode([uint64, int], Binary, [req_challenge_settle]);
decode(?msg_notify_challenge_settle, Binary) ->
	net_helper:decode([int, int, int], Binary, [notify_challenge_settle]);
decode(?msg_notify_be_challenged_times, Binary) ->
	net_helper:decode([int], Binary, [notify_be_challenged_times]);
decode(?msg_req_get_be_challenged_info, Binary) ->
	net_helper:decode([], Binary, [req_get_be_challenged_info]);
decode(?msg_notify_challenge_info_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_challenge_info, Bin)end}], Binary, [notify_challenge_info_list]);
decode(?msg_req_get_challenge_rank, Binary) ->
	net_helper:decode([], Binary, [req_get_challenge_rank]);
decode(?msg_notify_challenge_rank_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_rank_info, Bin)end}], Binary, [notify_challenge_rank_list]);
decode(?msg_req_get_can_challenge_role, Binary) ->
	net_helper:decode([], Binary, [req_get_can_challenge_role]);
decode(?msg_notify_can_challenge_lists, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_rank_info, Bin)end}], Binary, [notify_can_challenge_lists]);
decode(?msg_req_buy_challenge_times, Binary) ->
	net_helper:decode([], Binary, [req_buy_challenge_times]);
decode(?msg_notify_buy_challenge_times_result, Binary) ->
	net_helper:decode([int], Binary, [notify_buy_challenge_times_result]);
decode(?msg_req_get_challenge_times_info, Binary) ->
	net_helper:decode([], Binary, [req_get_challenge_times_info]);
decode(?msg_notify_challenge_times_info, Binary) ->
	net_helper:decode([int, int, int, int], Binary, [notify_challenge_times_info]);
decode(?msg_req_assistance_list, Binary) ->
	net_helper:decode([], Binary, [req_assistance_list]);
decode(?msg_notify_assistance_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_donor, Bin)end}], Binary, [notify_assistance_list]);
decode(?msg_req_select_donor, Binary) ->
	net_helper:decode([uint64], Binary, [req_select_donor]);
decode(?msg_notify_select_donor_result, Binary) ->
	net_helper:decode([int], Binary, [notify_select_donor_result]);
decode(?msg_req_refresh_assistance_list, Binary) ->
	net_helper:decode([], Binary, [req_refresh_assistance_list]);
decode(?msg_notify_refresh_assistance_list_result, Binary) ->
	net_helper:decode([int], Binary, [notify_refresh_assistance_list_result]);
decode(?msg_req_fresh_lottery_list, Binary) ->
	net_helper:decode([], Binary, [req_fresh_lottery_list]);
decode(?msg_notify_fresh_lottery_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_friend_point_lottery_item, Bin)end}], Binary, [notify_fresh_lottery_list]);
decode(?msg_req_friend_point_lottery, Binary) ->
	net_helper:decode([], Binary, [req_friend_point_lottery]);
decode(?msg_notify_friend_point_lottery_result, Binary) ->
	net_helper:decode([int, int, int], Binary, [notify_friend_point_lottery_result]);
decode(?msg_notify_assistance_info, Binary) ->
	net_helper:decode([int, int], Binary, [notify_assistance_info]);
decode(?msg_notify_role_info_change, Binary) ->
	net_helper:decode([string, int], Binary, [notify_role_info_change]);
decode(?msg_req_buy_mall_item, Binary) ->
	net_helper:decode([int, int], Binary, [req_buy_mall_item]);
decode(?msg_notify_buy_mall_item_result, Binary) ->
	net_helper:decode([int], Binary, [notify_buy_mall_item_result]);
decode(?msg_req_has_buy_times, Binary) ->
	net_helper:decode([], Binary, [req_has_buy_times]);
decode(?msg_notify_has_buy_times, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_mall_buy_info, Bin)end}], Binary, [notify_has_buy_times]);
decode(?msg_notify_add_friend_defuse_msg, Binary) ->
	net_helper:decode([uint64], Binary, [notify_add_friend_defuse_msg]);
decode(?msg_req_get_challenge_rank_award, Binary) ->
	net_helper:decode([], Binary, [req_get_challenge_rank_award]);
decode(?msg_notify_get_challenge_rank_award_result, Binary) ->
	net_helper:decode([int], Binary, [notify_get_challenge_rank_award_result]);
decode(?msg_req_buy_point_mall_item, Binary) ->
	net_helper:decode([int, int], Binary, [req_buy_point_mall_item]);
decode(?msg_notify_buy_point_mall_item_result, Binary) ->
	net_helper:decode([int], Binary, [notify_buy_point_mall_item_result]);
decode(?msg_nofity_continue_login_award_info, Binary) ->
	net_helper:decode([int, int, int, int, int], Binary, [nofity_continue_login_award_info]);
decode(?msg_req_get_daily_award, Binary) ->
	net_helper:decode([int], Binary, [req_get_daily_award]);
decode(?msg_notify_get_daily_award_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_get_daily_award_result]);
decode(?msg_notify_sys_time, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_stime, Bin)end}], Binary, [notify_sys_time]);
decode(?msg_req_get_rank_infos, Binary) ->
	net_helper:decode([int], Binary, [req_get_rank_infos]);
decode(?msg_notify_rank_infos, Binary) ->
	net_helper:decode([int, int, {array, user_define, fun(Bin)->decode(?msg_rank_data, Bin)end}], Binary, [notify_rank_infos]);
decode(?msg_req_train_match_list, Binary) ->
	net_helper:decode([int], Binary, [req_train_match_list]);
decode(?msg_notify_train_match_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_train_info, Bin)end}], Binary, [notify_train_match_list]);
decode(?msg_req_start_train_match, Binary) ->
	net_helper:decode([uint64], Binary, [req_start_train_match]);
decode(?msg_notify_start_train_match_result, Binary) ->
	net_helper:decode([uint64, int, {array, user_define, fun(Bin)->decode(?msg_game_map, Bin)end}], Binary, [notify_start_train_match_result]);
decode(?msg_req_train_match_settle, Binary) ->
	net_helper:decode([uint64, int], Binary, [req_train_match_settle]);
decode(?msg_notify_train_match_settle, Binary) ->
	net_helper:decode([int, int, int], Binary, [notify_train_match_settle]);
decode(?msg_req_get_train_match_times_info, Binary) ->
	net_helper:decode([], Binary, [req_get_train_match_times_info]);
decode(?msg_notify_train_match_times_info, Binary) ->
	net_helper:decode([int, int, int, int, int, int], Binary, [notify_train_match_times_info]);
decode(?msg_req_buy_train_match_times, Binary) ->
	net_helper:decode([], Binary, [req_buy_train_match_times]);
decode(?msg_notify_buy_train_match_times_result, Binary) ->
	net_helper:decode([int], Binary, [notify_buy_train_match_times_result]);
decode(?msg_req_get_train_award, Binary) ->
	net_helper:decode([int], Binary, [req_get_train_award]);
decode(?msg_notify_get_train_award_type, Binary) ->
	net_helper:decode([int, int, int, int], Binary, [notify_get_train_award_type]);
decode(?msg_req_use_props, Binary) ->
	net_helper:decode([uint64], Binary, [req_use_props]);
decode(?msg_notify_use_props_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_use_props_result]);
decode(?msg_req_benison_list, Binary) ->
	net_helper:decode([], Binary, [req_benison_list]);
decode(?msg_notify_benison_list, Binary) ->
	net_helper:decode([{array, int}, {array, int}], Binary, [notify_benison_list]);
decode(?msg_req_bless, Binary) ->
	net_helper:decode([int], Binary, [req_bless]);
decode(?msg_notify_bless_result, Binary) ->
	net_helper:decode([int], Binary, [notify_bless_result]);
decode(?msg_notify_role_bless_buff, Binary) ->
	net_helper:decode([int, {array, int}, int], Binary, [notify_role_bless_buff]);
decode(?msg_req_refresh_benison_list, Binary) ->
	net_helper:decode([], Binary, [req_refresh_benison_list]);
decode(?msg_notify_refresh_benison_list_result, Binary) ->
	net_helper:decode([int], Binary, [notify_refresh_benison_list_result]);
decode(?msg_req_equipment_advance, Binary) ->
	net_helper:decode([uint64], Binary, [req_equipment_advance]);
decode(?msg_notify_equipment_advance_result, Binary) ->
	net_helper:decode([int], Binary, [notify_equipment_advance_result]);
decode(?msg_req_equipment_exchange, Binary) ->
	net_helper:decode([uint64], Binary, [req_equipment_exchange]);
decode(?msg_notify_equipment_exchange_result, Binary) ->
	net_helper:decode([int], Binary, [notify_equipment_exchange_result]);
decode(?msg_req_equipment_resolve, Binary) ->
	net_helper:decode([{array, uint64}], Binary, [req_equipment_resolve]);
decode(?msg_notify_equipment_resolve_result, Binary) ->
	net_helper:decode([int, uint64, {array, user_define, fun(Bin)->decode(?msg_material_info, Bin)end}], Binary, [notify_equipment_resolve_result]);
decode(?msg_req_equipment_recast, Binary) ->
	net_helper:decode([uint64], Binary, [req_equipment_recast]);
decode(?msg_notify_equipment_recast_result, Binary) ->
	net_helper:decode([int, {user_define, fun(Bin)->decode(?msg_equipmentinfo, Bin)end}], Binary, [notify_equipment_recast_result]);
decode(?msg_req_save_recast_info, Binary) ->
	net_helper:decode([uint64], Binary, [req_save_recast_info]);
decode(?msg_notify_save_recast_info_result, Binary) ->
	net_helper:decode([int], Binary, [notify_save_recast_info_result]);
decode(?msg_notify_upgrade_task_rewarded_list, Binary) ->
	net_helper:decode([{array, int}], Binary, [notify_upgrade_task_rewarded_list]);
decode(?msg_req_upgrade_task_reward, Binary) ->
	net_helper:decode([int], Binary, [req_upgrade_task_reward]);
decode(?msg_notify_upgrade_task_reward_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_upgrade_task_reward_result]);
decode(?msg_ladder_role_info, Binary) ->
	net_helper:decode([uint64, int, int, string, int, int, int, {user_define, fun(Bin)->decode(?msg_battle_info, Bin)end}, int, int, {array, user_define, fun(Bin)->decode(?msg_talent, Bin)end}], Binary, [ladder_role_info]);
decode(?msg_req_ladder_role_list, Binary) ->
	net_helper:decode([], Binary, [req_ladder_role_list]);
decode(?msg_notify_ladder_role_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_ladder_role_info, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_ladder_role_info, Bin)end}], Binary, [notify_ladder_role_list]);
decode(?msg_req_ladder_teammate, Binary) ->
	net_helper:decode([], Binary, [req_ladder_teammate]);
decode(?msg_notify_req_ladder_teammate_result, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_ladder_role_info, Bin)end}, int], Binary, [notify_req_ladder_teammate_result]);
decode(?msg_req_reselect_ladder_teammate, Binary) ->
	net_helper:decode([uint64], Binary, [req_reselect_ladder_teammate]);
decode(?msg_notify_reselect_ladder_teammate_result, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_ladder_role_info, Bin)end}], Binary, [notify_reselect_ladder_teammate_result]);
decode(?msg_req_ladder_match_info, Binary) ->
	net_helper:decode([], Binary, [req_ladder_match_info]);
decode(?msg_notify_ladder_match_info, Binary) ->
	net_helper:decode([int, int, int, int, int], Binary, [notify_ladder_match_info]);
decode(?msg_req_ladder_match_battle, Binary) ->
	net_helper:decode([], Binary, [req_ladder_match_battle]);
decode(?msg_notify_ladder_match_battle_result, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_game_map, Bin)end}, uint64], Binary, [notify_ladder_match_battle_result]);
decode(?msg_req_settle_ladder_match, Binary) ->
	net_helper:decode([uint64, {array, user_define, fun(Bin)->decode(?msg_role_life_info, Bin)end}, int], Binary, [req_settle_ladder_match]);
decode(?msg_notify_settle_ladder_match, Binary) ->
	net_helper:decode([int, {array, int}, {array, int}], Binary, [notify_settle_ladder_match]);
decode(?msg_req_reset_ladder_match, Binary) ->
	net_helper:decode([], Binary, [req_reset_ladder_match]);
decode(?msg_notify_reset_ladder_match_result, Binary) ->
	net_helper:decode([int], Binary, [notify_reset_ladder_match_result]);
decode(?msg_req_recover_teammate_life, Binary) ->
	net_helper:decode([], Binary, [req_recover_teammate_life]);
decode(?msg_notify_recover_teammate_life_result, Binary) ->
	net_helper:decode([int], Binary, [notify_recover_teammate_life_result]);
decode(?msg_notify_online_award_info, Binary) ->
	net_helper:decode([int, {array, int}], Binary, [notify_online_award_info]);
decode(?msg_req_get_online_award, Binary) ->
	net_helper:decode([int], Binary, [req_get_online_award]);
decode(?msg_notify_get_online_award_result, Binary) ->
	net_helper:decode([int], Binary, [notify_get_online_award_result]);
decode(?msg_req_alchemy_info, Binary) ->
	net_helper:decode([], Binary, [req_alchemy_info]);
decode(?msg_notify_alchemy_info, Binary) ->
	net_helper:decode([int, int, int, int, {array, int}], Binary, [notify_alchemy_info]);
decode(?msg_req_metallurgy, Binary) ->
	net_helper:decode([int], Binary, [req_metallurgy]);
decode(?msg_notify_metallurgy_reuslt, Binary) ->
	net_helper:decode([int], Binary, [notify_metallurgy_reuslt]);
decode(?msg_req_alchemy_reward, Binary) ->
	net_helper:decode([int], Binary, [req_alchemy_reward]);
decode(?msg_notify_alchemy_reward_reuslt, Binary) ->
	net_helper:decode([int], Binary, [notify_alchemy_reward_reuslt]);
decode(?msg_req_potence_advance, Binary) ->
	net_helper:decode([int], Binary, [req_potence_advance]);
decode(?msg_notify_potence_advance_result, Binary) ->
	net_helper:decode([int, int, int], Binary, [notify_potence_advance_result]);
decode(?msg_req_exchange_item, Binary) ->
	net_helper:decode([int], Binary, [req_exchange_item]);
decode(?msg_notify_exchange_item_result, Binary) ->
	net_helper:decode([int], Binary, [notify_exchange_item_result]);
decode(?msg_req_has_buy_discount_item_times, Binary) ->
	net_helper:decode([], Binary, [req_has_buy_discount_item_times]);
decode(?msg_notify_has_buy_discount_item_times, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_mall_buy_info, Bin)end}], Binary, [notify_has_buy_discount_item_times]);
decode(?msg_req_buy_discount_limit_item, Binary) ->
	net_helper:decode([int], Binary, [req_buy_discount_limit_item]);
decode(?msg_notify_buy_discount_limit_item_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_buy_discount_limit_item_result]);
decode(?msg_req_convert_cdkey, Binary) ->
	net_helper:decode([int], Binary, [req_convert_cdkey]);
decode(?msg_notify_redeem_cdoe_result, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_award_item, Bin)end}], Binary, [notify_redeem_cdoe_result]);
decode(?msg_notify_email_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_semail, Bin)end}], Binary, [notify_email_list]);
decode(?msg_notify_email_add, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_semail, Bin)end}], Binary, [notify_email_add]);
decode(?msg_req_get_email_attachments, Binary) ->
	net_helper:decode([int], Binary, [req_get_email_attachments]);
decode(?msg_notify_get_email_attachments_result, Binary) ->
	net_helper:decode([int], Binary, [notify_get_email_attachments_result]);
decode(?msg_req_buy_mooncard, Binary) ->
	net_helper:decode([int, int], Binary, [req_buy_mooncard]);
decode(?msg_notify_mooncard_info, Binary) ->
	net_helper:decode([int, int], Binary, [notify_mooncard_info]);
decode(?msg_req_get_mooncard_daily_award, Binary) ->
	net_helper:decode([], Binary, [req_get_mooncard_daily_award]);
decode(?msg_notify_get_mooncard_daily_award_result, Binary) ->
	net_helper:decode([int], Binary, [notify_get_mooncard_daily_award_result]);
decode(?msg_req_enter_activity_copy, Binary) ->
	net_helper:decode([int], Binary, [req_enter_activity_copy]);
decode(?msg_notify_enter_activity_result, Binary) ->
	net_helper:decode([int, uint64, {array, user_define, fun(Bin)->decode(?msg_game_map, Bin)end}], Binary, [notify_enter_activity_result]);
decode(?msg_req_settle_activity_copy, Binary) ->
	net_helper:decode([uint64, int, {array, user_define, fun(Bin)->decode(?msg_mons_item, Bin)end}, int], Binary, [req_settle_activity_copy]);
decode(?msg_notify_settle_activity_copy_result, Binary) ->
	net_helper:decode([int], Binary, [notify_settle_activity_copy_result]);
decode(?msg_notify_activity_copy_info, Binary) ->
	net_helper:decode([int], Binary, [notify_activity_copy_info]);
decode(?msg_req_verify_invite_code, Binary) ->
	net_helper:decode([string], Binary, [req_verify_invite_code]);
decode(?msg_notify_verify_invite_code_result, Binary) ->
	net_helper:decode([int], Binary, [notify_verify_invite_code_result]);
decode(?msg_req_input_invite_code, Binary) ->
	net_helper:decode([string], Binary, [req_input_invite_code]);
decode(?msg_notify_input_invite_code_result, Binary) ->
	net_helper:decode([int, {user_define, fun(Bin)->decode(?msg_master_info, Bin)end}], Binary, [notify_input_invite_code_result]);
decode(?msg_req_disengage_check, Binary) ->
	net_helper:decode([int, uint64], Binary, [req_disengage_check]);
decode(?msg_notify_disengage_check_result, Binary) ->
	net_helper:decode([int, uint64, int], Binary, [notify_disengage_check_result]);
decode(?msg_req_disengage, Binary) ->
	net_helper:decode([int, uint64], Binary, [req_disengage]);
decode(?msg_notify_disengage_result, Binary) ->
	net_helper:decode([int, uint64, int], Binary, [notify_disengage_result]);
decode(?msg_notify_lost_prentice, Binary) ->
	net_helper:decode([uint64], Binary, [notify_lost_prentice]);
decode(?msg_notify_lost_master, Binary) ->
	net_helper:decode([uint64], Binary, [notify_lost_master]);
decode(?msg_req_master_level_reward, Binary) ->
	net_helper:decode([uint64, int], Binary, [req_master_level_reward]);
decode(?msg_notify_master_level_reward_result, Binary) ->
	net_helper:decode([int, uint64, int], Binary, [notify_master_level_reward_result]);
decode(?msg_req_prentice_level_reward, Binary) ->
	net_helper:decode([int], Binary, [req_prentice_level_reward]);
decode(?msg_notify_prentice_level_reward_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_prentice_level_reward_result]);
decode(?msg_req_master_help, Binary) ->
	net_helper:decode([int], Binary, [req_master_help]);
decode(?msg_notify_master_help_result, Binary) ->
	net_helper:decode([int], Binary, [notify_master_help_result]);
decode(?msg_req_give_help, Binary) ->
	net_helper:decode([uint64], Binary, [req_give_help]);
decode(?msg_notify_give_help_result, Binary) ->
	net_helper:decode([int], Binary, [notify_give_help_result]);
decode(?msg_req_get_help_reward, Binary) ->
	net_helper:decode([int], Binary, [req_get_help_reward]);
decode(?msg_notify_get_help_reward_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_get_help_reward_result]);
decode(?msg_notify_req_help_from_prentice, Binary) ->
	net_helper:decode([uint64], Binary, [notify_req_help_from_prentice]);
decode(?msg_notify_give_help_from_master, Binary) ->
	net_helper:decode([uint64], Binary, [notify_give_help_from_master]);
decode(?msg_notify_invite_code_info, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_master_info, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_prentice_info, Bin)end}, string, int, {array, int}], Binary, [notify_invite_code_info]);
decode(?msg_req_send_hp, Binary) ->
	net_helper:decode([uint64], Binary, [req_send_hp]);
decode(?msg_notify_send_hp_result, Binary) ->
	net_helper:decode([int, uint64], Binary, [notify_send_hp_result]);
decode(?msg_notify_get_hp_help_from_friend, Binary) ->
	net_helper:decode([uint64], Binary, [notify_get_hp_help_from_friend]);
decode(?msg_req_reward_hp_from_friend, Binary) ->
	net_helper:decode([uint64], Binary, [req_reward_hp_from_friend]);
decode(?msg_notify_reward_hp_from_friend_result, Binary) ->
	net_helper:decode([int, uint64], Binary, [notify_reward_hp_from_friend_result]);
decode(?msg_notify_boss_copy_fight_count, Binary) ->
	net_helper:decode([int], Binary, [notify_boss_copy_fight_count]);
decode(?msg_req_chat_in_world_channel, Binary) ->
	net_helper:decode([string], Binary, [req_chat_in_world_channel]);
decode(?msg_notify_chat_in_world_channel_result, Binary) ->
	net_helper:decode([int], Binary, [notify_chat_in_world_channel_result]);
decode(?msg_notify_world_channel_msg, Binary) ->
	net_helper:decode([uint64, string, string], Binary, [notify_world_channel_msg]);
decode(?msg_notify_my_world_chat_info, Binary) ->
	net_helper:decode([int, int], Binary, [notify_my_world_chat_info]);
decode(?msg_req_get_role_detail_info, Binary) ->
	net_helper:decode([uint64], Binary, [req_get_role_detail_info]);
decode(?msg_notify_role_detail_info_result, Binary) ->
	net_helper:decode([uint64, string, int, int, int, string, int, int, {array, user_define, fun(Bin)->decode(?msg_sculpture_data, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_equipmentinfo, Bin)end}, int, int, int], Binary, [notify_role_detail_info_result]);
decode(?msg_notify_get_talent_active_info, Binary) ->
	net_helper:decode([{array, int}, int], Binary, [notify_get_talent_active_info]);
decode(?msg_req_actived_talent, Binary) ->
	net_helper:decode([int], Binary, [req_actived_talent]);
decode(?msg_notify_actived_talent, Binary) ->
	net_helper:decode([int, int], Binary, [notify_actived_talent]);
decode(?msg_req_reset_talent, Binary) ->
	net_helper:decode([], Binary, [req_reset_talent]);
decode(?msg_notify_reset_talent, Binary) ->
	net_helper:decode([int], Binary, [notify_reset_talent]);
decode(?msg_req_level_up_talent, Binary) ->
	net_helper:decode([int], Binary, [req_level_up_talent]);
decode(?msg_notify_level_up_talent, Binary) ->
	net_helper:decode([int], Binary, [notify_level_up_talent]);
decode(?msg_req_notice_list, Binary) ->
	net_helper:decode([], Binary, [req_notice_list]);
decode(?msg_notify_notice_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_notice_list_item, Bin)end}], Binary, [notify_notice_list]);
decode(?msg_notify_notice_item_add, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_notice_list_item, Bin)end}], Binary, [notify_notice_item_add]);
decode(?msg_notify_notice_item_del, Binary) ->
	net_helper:decode([int], Binary, [notify_notice_item_del]);
decode(?msg_req_notice_item_detail, Binary) ->
	net_helper:decode([int], Binary, [req_notice_item_detail]);
decode(?msg_notify_notice_item_detail, Binary) ->
	net_helper:decode([int, {user_define, fun(Bin)->decode(?msg_notice_item_detail, Bin)end}], Binary, [notify_notice_item_detail]);
decode(?msg_req_time_limit_reward, Binary) ->
	net_helper:decode([int], Binary, [req_time_limit_reward]);
decode(?msg_notify_time_limit_reward, Binary) ->
	net_helper:decode([int], Binary, [notify_time_limit_reward]);
decode(?msg_notify_time_limit_rewarded_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_time_limit_rewarded_item, Bin)end}], Binary, [notify_time_limit_rewarded_list]);
decode(?msg_notify_activity_list, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_activity_item, Bin)end}], Binary, [notify_activity_list]);
decode(?msg_notify_act_lottery_info, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_lottery_progress_item, Bin)end}], Binary, [notify_act_lottery_info]);
decode(?msg_req_act_lottery, Binary) ->
	net_helper:decode([], Binary, [req_act_lottery]);
decode(?msg_notify_act_lottery_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_act_lottery_result]);
decode(?msg_notify_act_recharge_info, Binary) ->
	net_helper:decode([int, {array, int}], Binary, [notify_act_recharge_info]);
decode(?msg_req_act_recharge_reward, Binary) ->
	net_helper:decode([int], Binary, [req_act_recharge_reward]);
decode(?msg_notify_act_recharge_reward_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_act_recharge_reward_result]);
decode(?msg_req_emoney_2_gold, Binary) ->
	net_helper:decode([int], Binary, [req_emoney_2_gold]);
decode(?msg_notify_emoney_2_gold_result, Binary) ->
	net_helper:decode([int], Binary, [notify_emoney_2_gold_result]).
