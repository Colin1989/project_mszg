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
encode(#role_data{role_id=ROLE_ID, type=TYPE, lev=LEV, name=NAME, is_del=IS_DEL, time_left=TIME_LEFT}) ->
	{?msg_role_data, <<ROLE_ID:?UINT64, TYPE:?INT, LEV:?INT, (net_helper:encode_string(NAME))/binary, IS_DEL:?INT, TIME_LEFT:?INT>>};
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
encode(#smonster{pos=POS, monsterid=MONSTERID, dropout=DROPOUT}) ->
	{?msg_smonster, <<POS:?INT, MONSTERID:?INT, DROPOUT:?INT>>};
encode(#strap{pos=POS, trapid=TRAPID}) ->
	{?msg_strap, <<POS:?INT, TRAPID:?INT>>};
encode(#saward{pos=POS, awardid=AWARDID}) ->
	{?msg_saward, <<POS:?INT, AWARDID:?INT>>};
encode(#sfriend{pos=POS, friend_role_id=FRIEND_ROLE_ID}) ->
	{?msg_sfriend, <<POS:?INT, FRIEND_ROLE_ID:?INT>>};
encode(#battle_info{sculpture=SCULPTURE, life=LIFE, speed=SPEED, atk=ATK, hit_ratio=HIT_RATIO, miss_ratio=MISS_RATIO, critical_ratio=CRITICAL_RATIO, tenacity=TENACITY, power=POWER}) ->
	{?msg_battle_info, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, SCULPTURE))/binary, LIFE:?INT, SPEED:?INT, ATK:?INT, HIT_RATIO:?INT, MISS_RATIO:?INT, CRITICAL_RATIO:?INT, TENACITY:?INT, POWER:?INT>>};
encode(#senemy{pos=POS, type=TYPE, battle_prop=BATTLE_PROP}) ->
	{?msg_senemy, <<POS:?INT, TYPE:?INT, (net_helper:get_encode_binary_data(encode(BATTLE_PROP)))/binary>>};
encode(#game_map{monster=MONSTER, key=KEY, start=START, award=AWARD, trap=TRAP, barrier=BARRIER, friend=FRIEND, scene=SCENE, enemy=ENEMY}) ->
	{?msg_game_map, <<(net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MONSTER))/binary, KEY:?INT, START:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, AWARD))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, TRAP))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, BARRIER))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, FRIEND))/binary, SCENE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, ENEMY))/binary>>};
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
encode(#friend_data{nickname=NICKNAME, status=STATUS, head=HEAD, level=LEVEL, public=PUBLIC, battle_prop=BATTLE_PROP}) ->
	{?msg_friend_data, <<(net_helper:encode_string(NICKNAME))/binary, STATUS:?INT, HEAD:?INT, LEVEL:?INT, (net_helper:encode_string(PUBLIC))/binary, (net_helper:get_encode_binary_data(encode(BATTLE_PROP)))/binary>>};
encode(#friend_info{friend_id=FRIEND_ID, nickname=NICKNAME, status=STATUS, head=HEAD, level=LEVEL, public=PUBLIC, battle_prop=BATTLE_PROP}) ->
	{?msg_friend_info, <<FRIEND_ID:?UINT64, (net_helper:encode_string(NICKNAME))/binary, STATUS:?INT, HEAD:?INT, LEVEL:?INT, (net_helper:encode_string(PUBLIC))/binary, (net_helper:get_encode_binary_data(encode(BATTLE_PROP)))/binary>>};
encode(#award_item{temp_id=TEMP_ID, amount=AMOUNT}) ->
	{?msg_award_item, <<TEMP_ID:?INT, AMOUNT:?INT>>};
encode(#challenge_info{name=NAME, result=RESULT, new_rank=NEW_RANK}) ->
	{?msg_challenge_info, <<(net_helper:encode_string(NAME))/binary, RESULT:?INT, NEW_RANK:?INT>>};
encode(#rank_info{role_id=ROLE_ID, name=NAME, type=TYPE, rank=RANK, level=LEVEL, power=POWER}) ->
	{?msg_rank_info, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, RANK:?INT, LEVEL:?INT, POWER:?INT>>};
encode(#train_info{role_id=ROLE_ID, name=NAME, type=TYPE, status=STATUS, level=LEVEL, power=POWER}) ->
	{?msg_train_info, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, STATUS:?INT, LEVEL:?INT, POWER:?INT>>};
encode(#rank_data{role_id=ROLE_ID, name=NAME, type=TYPE, rank=RANK, value=VALUE, public=PUBLIC}) ->
	{?msg_rank_data, <<ROLE_ID:?UINT64, (net_helper:encode_string(NAME))/binary, TYPE:?INT, RANK:?INT, VALUE:?INT, (net_helper:encode_string(PUBLIC))/binary>>};
encode(#donor{role_id=ROLE_ID, rel=REL, level=LEVEL, role_type=ROLE_TYPE, nick_name=NICK_NAME, friend_point=FRIEND_POINT, power=POWER, sculpture=SCULPTURE}) ->
	{?msg_donor, <<ROLE_ID:?UINT64, REL:?INT, LEVEL:?INT, ROLE_TYPE:?INT, (net_helper:encode_string(NICK_NAME))/binary, FRIEND_POINT:?INT, POWER:?INT, (net_helper:get_encode_binary_data(encode(SCULPTURE)))/binary>>};
encode(#mall_buy_info{mallitem_id=MALLITEM_ID, times=TIMES}) ->
	{?msg_mall_buy_info, <<MALLITEM_ID:?INT, TIMES:?INT>>};
encode(#lottery_item{type=TYPE, item_info=ITEM_INFO}) ->
	{?msg_lottery_item, <<TYPE:?INT, ITEM_INFO:?INT>>};
encode(#activeness_task_item{id=ID, count=COUNT}) ->
	{?msg_activeness_task_item, <<ID:?INT, COUNT:?INT>>};
encode(#material_info{material_id=MATERIAL_ID, amount=AMOUNT}) ->
	{?msg_material_info, <<MATERIAL_ID:?INT, AMOUNT:?INT>>};
encode(#clean_up_trophy{item=ITEM, gold=GOLD, exp=EXP}) ->
	{?msg_clean_up_trophy, <<(net_helper:encode_list(fun(E)-> <<E:?INT>>end, ITEM))/binary, GOLD:?INT, EXP:?INT>>};
encode(#notify_heartbeat{}) ->
	{?msg_notify_heartbeat, null};
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
encode(#notify_roleinfo_msg{id=ID, nickname=NICKNAME, roletype=ROLETYPE, armor=ARMOR, weapon=WEAPON, ring=RING, necklace=NECKLACE, medal=MEDAL, jewelry=JEWELRY, skill1=SKILL1, skill2=SKILL2, sculpture1=SCULPTURE1, sculpture2=SCULPTURE2, sculpture3=SCULPTURE3, sculpture4=SCULPTURE4, divine_level1=DIVINE_LEVEL1, divine_level2=DIVINE_LEVEL2, divine_level3=DIVINE_LEVEL3, level=LEVEL, exp=EXP, gold=GOLD, emoney=EMONEY, summon_stone=SUMMON_STONE, power_hp=POWER_HP, recover_time_left=RECOVER_TIME_LEFT, power_hp_buy_times=POWER_HP_BUY_TIMES, pack_space=PACK_SPACE, friend_point=FRIEND_POINT, point=POINT, honour=HONOUR, sculpture_frag=SCULPTURE_FRAG, battle_power=BATTLE_POWER}) ->
	{?msg_notify_roleinfo_msg, <<ID:?UINT64, (net_helper:encode_string(NICKNAME))/binary, ROLETYPE:?INT, ARMOR:?UINT64, WEAPON:?UINT64, RING:?UINT64, NECKLACE:?UINT64, MEDAL:?UINT64, JEWELRY:?UINT64, SKILL1:?INT, SKILL2:?INT, SCULPTURE1:?UINT64, SCULPTURE2:?UINT64, SCULPTURE3:?UINT64, SCULPTURE4:?UINT64, DIVINE_LEVEL1:?INT, DIVINE_LEVEL2:?INT, DIVINE_LEVEL3:?INT, LEVEL:?INT, EXP:?INT, GOLD:?INT, EMONEY:?INT, SUMMON_STONE:?INT, POWER_HP:?INT, RECOVER_TIME_LEFT:?INT, POWER_HP_BUY_TIMES:?INT, PACK_SPACE:?INT, FRIEND_POINT:?INT, POINT:?INT, HONOUR:?INT, SCULPTURE_FRAG:?INT, BATTLE_POWER:?INT>>};
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
encode(#req_game_settle{game_id=GAME_ID, result=RESULT, life=LIFE, maxlife=MAXLIFE, monsterkill=MONSTERKILL, pickup_items=PICKUP_ITEMS, user_operations=USER_OPERATIONS, gold=GOLD, killmonsters=KILLMONSTERS}) ->
	{?msg_req_game_settle, <<GAME_ID:?UINT64, RESULT:?INT, LIFE:?INT, MAXLIFE:?INT, MONSTERKILL:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, PICKUP_ITEMS))/binary, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, USER_OPERATIONS))/binary, GOLD:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, KILLMONSTERS))/binary>>};
encode(#notify_game_settle{game_id=GAME_ID, result=RESULT, score=SCORE, final_item=FINAL_ITEM, ratio_items=RATIO_ITEMS}) ->
	{?msg_notify_game_settle, <<GAME_ID:?UINT64, RESULT:?INT, SCORE:?INT, (net_helper:get_encode_binary_data(encode(FINAL_ITEM)))/binary, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, RATIO_ITEMS))/binary>>};
encode(#req_game_lottery{}) ->
	{?msg_req_game_lottery, null};
encode(#notify_game_lottery{second_item=SECOND_ITEM, result=RESULT}) ->
	{?msg_notify_game_lottery, <<(net_helper:get_encode_binary_data(encode(SECOND_ITEM)))/binary, RESULT:?INT>>};
encode(#req_game_reconnect{uid=UID, token=TOKEN, role_id=ROLE_ID}) ->
	{?msg_req_game_reconnect, <<(net_helper:encode_string(UID))/binary, (net_helper:encode_string(TOKEN))/binary, ROLE_ID:?UINT64>>};
encode(#notify_reconnect_result{id=ID, result=RESULT}) ->
	{?msg_notify_reconnect_result, <<ID:?UINT64, RESULT:?INT>>};
encode(#req_equipment_strengthen{equipment_id=EQUIPMENT_ID}) ->
	{?msg_req_equipment_strengthen, <<EQUIPMENT_ID:?UINT64>>};
encode(#notify_equipment_strengthen_result{strengthen_result=STRENGTHEN_RESULT}) ->
	{?msg_notify_equipment_strengthen_result, <<STRENGTHEN_RESULT:?INT>>};
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
encode(#req_send_chat_msg{friend_id=FRIEND_ID, chat_msg=CHAT_MSG}) ->
	{?msg_req_send_chat_msg, <<FRIEND_ID:?UINT64, (net_helper:encode_string(CHAT_MSG))/binary>>};
encode(#notify_send_chat_msg_result{result=RESULT}) ->
	{?msg_notify_send_chat_msg_result, <<RESULT:?INT>>};
encode(#notify_receive_chat_msg{friend_id=FRIEND_ID, chat_msg=CHAT_MSG}) ->
	{?msg_notify_receive_chat_msg, <<FRIEND_ID:?UINT64, (net_helper:encode_string(CHAT_MSG))/binary>>};
encode(#req_push_tower_map_settle{game_id=GAME_ID, result=RESULT, cost_round=COST_ROUND, life=LIFE, pickup_items=PICKUP_ITEMS}) ->
	{?msg_req_push_tower_map_settle, <<GAME_ID:?UINT64, RESULT:?INT, COST_ROUND:?INT, LIFE:?INT, (net_helper:encode_list(fun(E)-> <<E:?INT>>end, PICKUP_ITEMS))/binary>>};
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
encode(#req_gem_compound{temp_id=TEMP_ID, is_protect=IS_PROTECT}) ->
	{?msg_req_gem_compound, <<TEMP_ID:?INT, IS_PROTECT:?INT>>};
encode(#notify_gem_compound_result{result=RESULT, lost_gem_amount=LOST_GEM_AMOUNT}) ->
	{?msg_notify_gem_compound_result, <<RESULT:?INT, LOST_GEM_AMOUNT:?INT>>};
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
encode(#sculpture_info{sculpture_id=SCULPTURE_ID, temp_id=TEMP_ID, lev=LEV, exp=EXP}) ->
	{?msg_sculpture_info, <<SCULPTURE_ID:?UINT64, TEMP_ID:?INT, LEV:?INT, EXP:?INT>>};
encode(#req_sculpture_infos{}) ->
	{?msg_req_sculpture_infos, null};
encode(#notify_sculpture_infos{type=TYPE, sculpture_infos=SCULPTURE_INFOS}) ->
	{?msg_notify_sculpture_infos, <<TYPE:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, SCULPTURE_INFOS))/binary>>};
encode(#req_sculpture_puton{position=POSITION, inst_id=INST_ID}) ->
	{?msg_req_sculpture_puton, <<POSITION:?INT, INST_ID:?UINT64>>};
encode(#notify_sculpture_puton{is_success=IS_SUCCESS, position=POSITION, inst_id=INST_ID}) ->
	{?msg_notify_sculpture_puton, <<IS_SUCCESS:?INT, POSITION:?INT, INST_ID:?UINT64>>};
encode(#req_sculpture_takeoff{position=POSITION}) ->
	{?msg_req_sculpture_takeoff, <<POSITION:?INT>>};
encode(#notify_sculpture_takeoff{is_success=IS_SUCCESS, position=POSITION}) ->
	{?msg_notify_sculpture_takeoff, <<IS_SUCCESS:?INT, POSITION:?INT>>};
encode(#req_sculpture_convert{target_item_id=TARGET_ITEM_ID}) ->
	{?msg_req_sculpture_convert, <<TARGET_ITEM_ID:?INT>>};
encode(#notify_sculpture_convert{is_success=IS_SUCCESS, target_item_id=TARGET_ITEM_ID}) ->
	{?msg_notify_sculpture_convert, <<IS_SUCCESS:?INT, TARGET_ITEM_ID:?INT>>};
encode(#req_sculpture_upgrade{main_id=MAIN_ID, eat_ids=EAT_IDS}) ->
	{?msg_req_sculpture_upgrade, <<MAIN_ID:?UINT64, (net_helper:encode_list(fun(E)-> <<E:?UINT64>>end, EAT_IDS))/binary>>};
encode(#notify_sculpture_upgrade{is_success=IS_SUCCESS}) ->
	{?msg_notify_sculpture_upgrade, <<IS_SUCCESS:?INT>>};
encode(#req_sculpture_divine{money_type=MONEY_TYPE, times=TIMES}) ->
	{?msg_req_sculpture_divine, <<MONEY_TYPE:?INT, TIMES:?INT>>};
encode(#notify_sculpture_divine{is_success=IS_SUCCESS, divine_level=DIVINE_LEVEL, awards=AWARDS}) ->
	{?msg_notify_sculpture_divine, <<IS_SUCCESS:?INT, DIVINE_LEVEL:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, AWARDS))/binary>>};
encode(#req_sale_sculpture{inst_ids=INST_IDS}) ->
	{?msg_req_sale_sculpture, <<(net_helper:encode_list(fun(E)-> <<E:?UINT64>>end, INST_IDS))/binary>>};
encode(#notify_sale_sculpture_result{result=RESULT, gold=GOLD, err_id=ERR_ID}) ->
	{?msg_notify_sale_sculpture_result, <<RESULT:?INT, GOLD:?INT, ERR_ID:?UINT64>>};
encode(#req_challenge_other_player{role_id=ROLE_ID}) ->
	{?msg_req_challenge_other_player, <<ROLE_ID:?UINT64>>};
encode(#notify_challenge_other_player_result{game_id=GAME_ID, result=RESULT, map=MAP}) ->
	{?msg_notify_challenge_other_player_result, <<GAME_ID:?UINT64, RESULT:?INT, (net_helper:encode_list(fun(E)-> net_helper:get_encode_binary_data(encode(E)) end, MAP))/binary>>};
encode(#req_challenge_settle{game_id=GAME_ID, result=RESULT}) ->
	{?msg_req_challenge_settle, <<GAME_ID:?UINT64, RESULT:?INT>>};
encode(#notify_challenge_settle{result=RESULT, point=POINT, honour=HONOUR}) ->
	{?msg_notify_challenge_settle, <<RESULT:?INT, POINT:?INT, HONOUR:?INT>>};
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
encode(#notify_get_challenge_rank_award_result{result=RESULT, point=POINT}) ->
	{?msg_notify_get_challenge_rank_award_result, <<RESULT:?INT, POINT:?INT>>};
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
	{?msg_notify_save_recast_info_result, <<RESULT:?INT>>}.


decode(?msg_req_check_version, Binary) ->
	net_helper:decode([int], Binary, [req_check_version]);
decode(?msg_notify_check_version_result, Binary) ->
	net_helper:decode([int], Binary, [notify_check_version_result]);
decode(?msg_req_login, Binary) ->
	net_helper:decode([string, string], Binary, [req_login]);
decode(?msg_req_login_check, Binary) ->
	net_helper:decode([string, string], Binary, [req_login_check]);
decode(?msg_role_data, Binary) ->
	net_helper:decode([uint64, int, int, string, int, int], Binary, [role_data]);
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
decode(?msg_smonster, Binary) ->
	net_helper:decode([int, int, int], Binary, [smonster]);
decode(?msg_strap, Binary) ->
	net_helper:decode([int, int], Binary, [strap]);
decode(?msg_saward, Binary) ->
	net_helper:decode([int, int], Binary, [saward]);
decode(?msg_sfriend, Binary) ->
	net_helper:decode([int, int], Binary, [sfriend]);
decode(?msg_battle_info, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_sculpture_data, Bin)end}, int, int, int, int, int, int, int, int], Binary, [battle_info]);
decode(?msg_senemy, Binary) ->
	net_helper:decode([int, int, {user_define, fun(Bin)->decode(?msg_battle_info, Bin)end}], Binary, [senemy]);
decode(?msg_game_map, Binary) ->
	net_helper:decode([{array, user_define, fun(Bin)->decode(?msg_smonster, Bin)end}, int, int, {array, user_define, fun(Bin)->decode(?msg_saward, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_strap, Bin)end}, {array, int}, {array, user_define, fun(Bin)->decode(?msg_sfriend, Bin)end}, int, {array, user_define, fun(Bin)->decode(?msg_senemy, Bin)end}], Binary, [game_map]);
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
	net_helper:decode([string, int, int, int, string, {user_define, fun(Bin)->decode(?msg_battle_info, Bin)end}], Binary, [friend_data]);
decode(?msg_friend_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, string, {user_define, fun(Bin)->decode(?msg_battle_info, Bin)end}], Binary, [friend_info]);
decode(?msg_award_item, Binary) ->
	net_helper:decode([int, int], Binary, [award_item]);
decode(?msg_challenge_info, Binary) ->
	net_helper:decode([string, int, int], Binary, [challenge_info]);
decode(?msg_rank_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, int], Binary, [rank_info]);
decode(?msg_train_info, Binary) ->
	net_helper:decode([uint64, string, int, int, int, int], Binary, [train_info]);
decode(?msg_rank_data, Binary) ->
	net_helper:decode([uint64, string, int, int, int, string], Binary, [rank_data]);
decode(?msg_donor, Binary) ->
	net_helper:decode([uint64, int, int, int, string, int, int, {user_define, fun(Bin)->decode(?msg_sculpture_data, Bin)end}], Binary, [donor]);
decode(?msg_mall_buy_info, Binary) ->
	net_helper:decode([int, int], Binary, [mall_buy_info]);
decode(?msg_lottery_item, Binary) ->
	net_helper:decode([int, int], Binary, [lottery_item]);
decode(?msg_activeness_task_item, Binary) ->
	net_helper:decode([int, int], Binary, [activeness_task_item]);
decode(?msg_material_info, Binary) ->
	net_helper:decode([int, int], Binary, [material_info]);
decode(?msg_clean_up_trophy, Binary) ->
	net_helper:decode([{array, int}, int, int], Binary, [clean_up_trophy]);
decode(?msg_notify_heartbeat, Binary) ->
	net_helper:decode([], Binary, [notify_heartbeat]);
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
	net_helper:decode([uint64, string, int, uint64, uint64, uint64, uint64, uint64, uint64, int, int, uint64, uint64, uint64, uint64, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int], Binary, [notify_roleinfo_msg]);
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
	net_helper:decode([uint64, int, int, int, int, {array, int}, {array, int}, int, {array, int}], Binary, [req_game_settle]);
decode(?msg_notify_game_settle, Binary) ->
	net_helper:decode([uint64, int, int, {user_define, fun(Bin)->decode(?msg_lottery_item, Bin)end}, {array, user_define, fun(Bin)->decode(?msg_lottery_item, Bin)end}], Binary, [notify_game_settle]);
decode(?msg_req_game_lottery, Binary) ->
	net_helper:decode([], Binary, [req_game_lottery]);
decode(?msg_notify_game_lottery, Binary) ->
	net_helper:decode([{user_define, fun(Bin)->decode(?msg_lottery_item, Bin)end}, int], Binary, [notify_game_lottery]);
decode(?msg_req_game_reconnect, Binary) ->
	net_helper:decode([string, string, uint64], Binary, [req_game_reconnect]);
decode(?msg_notify_reconnect_result, Binary) ->
	net_helper:decode([uint64, int], Binary, [notify_reconnect_result]);
decode(?msg_req_equipment_strengthen, Binary) ->
	net_helper:decode([uint64], Binary, [req_equipment_strengthen]);
decode(?msg_notify_equipment_strengthen_result, Binary) ->
	net_helper:decode([int], Binary, [notify_equipment_strengthen_result]);
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
decode(?msg_req_send_chat_msg, Binary) ->
	net_helper:decode([uint64, string], Binary, [req_send_chat_msg]);
decode(?msg_notify_send_chat_msg_result, Binary) ->
	net_helper:decode([int], Binary, [notify_send_chat_msg_result]);
decode(?msg_notify_receive_chat_msg, Binary) ->
	net_helper:decode([uint64, string], Binary, [notify_receive_chat_msg]);
decode(?msg_req_push_tower_map_settle, Binary) ->
	net_helper:decode([uint64, int, int, int, {array, int}], Binary, [req_push_tower_map_settle]);
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
decode(?msg_req_gem_compound, Binary) ->
	net_helper:decode([int, int], Binary, [req_gem_compound]);
decode(?msg_notify_gem_compound_result, Binary) ->
	net_helper:decode([int, int], Binary, [notify_gem_compound_result]);
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
	net_helper:decode([uint64, int, int, int], Binary, [sculpture_info]);
decode(?msg_req_sculpture_infos, Binary) ->
	net_helper:decode([], Binary, [req_sculpture_infos]);
decode(?msg_notify_sculpture_infos, Binary) ->
	net_helper:decode([int, {array, user_define, fun(Bin)->decode(?msg_sculpture_info, Bin)end}], Binary, [notify_sculpture_infos]);
decode(?msg_req_sculpture_puton, Binary) ->
	net_helper:decode([int, uint64], Binary, [req_sculpture_puton]);
decode(?msg_notify_sculpture_puton, Binary) ->
	net_helper:decode([int, int, uint64], Binary, [notify_sculpture_puton]);
decode(?msg_req_sculpture_takeoff, Binary) ->
	net_helper:decode([int], Binary, [req_sculpture_takeoff]);
decode(?msg_notify_sculpture_takeoff, Binary) ->
	net_helper:decode([int, int], Binary, [notify_sculpture_takeoff]);
decode(?msg_req_sculpture_convert, Binary) ->
	net_helper:decode([int], Binary, [req_sculpture_convert]);
decode(?msg_notify_sculpture_convert, Binary) ->
	net_helper:decode([int, int], Binary, [notify_sculpture_convert]);
decode(?msg_req_sculpture_upgrade, Binary) ->
	net_helper:decode([uint64, {array, uint64}], Binary, [req_sculpture_upgrade]);
decode(?msg_notify_sculpture_upgrade, Binary) ->
	net_helper:decode([int], Binary, [notify_sculpture_upgrade]);
decode(?msg_req_sculpture_divine, Binary) ->
	net_helper:decode([int, int], Binary, [req_sculpture_divine]);
decode(?msg_notify_sculpture_divine, Binary) ->
	net_helper:decode([int, int, {array, user_define, fun(Bin)->decode(?msg_award_item, Bin)end}], Binary, [notify_sculpture_divine]);
decode(?msg_req_sale_sculpture, Binary) ->
	net_helper:decode([{array, uint64}], Binary, [req_sale_sculpture]);
decode(?msg_notify_sale_sculpture_result, Binary) ->
	net_helper:decode([int, int, uint64], Binary, [notify_sale_sculpture_result]);
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
	net_helper:decode([int, int], Binary, [notify_get_challenge_rank_award_result]);
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
	net_helper:decode([int], Binary, [notify_save_recast_info_result]).
