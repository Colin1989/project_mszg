--sys_msg_def
sys_msg =
{

    --service
    [1] = "sg_service_broadcast",
    [2] = "sg_service_is_busy_now",
    [3] = "sg_service_be_kick",
    [4] = "sg_service_error",


    --login
    [5] = "sg_login_passward_error",
    [6] = "sg_login_no_register",
    [7] = "sg_login_version_error",
    [8] = "sg_login_repeat_login",
    [9] = "sg_login_status_err",


    --select_role
    [10] = "sg_select_role_roleid_err",
    [11] = "sg_select_role_already_del",
    [12] = "sg_select_role_locked",


    --del_role
    [13] = "sg_del_role_roleid_err",
    [14] = "sg_del_role_already_del",


    --recover_role
    [15] = "sg_recover_role_roleid_err",
    [16] = "sg_recover_role_status_normal",
    [17] = "sg_recover_role_status_remove",
    [18] = "sg_recover_role_emoney_not_enough",
    [19] = "sg_recover_role_amount_exceeded",


    --create_role
    [20] = "sg_create_role_name_exist",
    [21] = "sg_create_role_not_login",
    [22] = "sg_create_role_amount_exceeded",
    [23] = "sg_create_role_type_error",


    --register
    [24] = "sg_register_account_exist",


    --assistance
    [25] = "sg_assistance_no_req_list",
    [26] = "sg_assistance_select_id_not_in_list",
    [27] = "sg_assistance_get_lottery_item_err",


    --reborn
    [28] = "sg_reborn_emoney_not_enough",


    --push_tower
    [29] = "sg_push_tower_buy_emoney_not_enough",
    [30] = "sg_push_tower_buy_times_exceeded",
    [31] = "sg_push_tower_enter_level_nomatch",
    [32] = "sg_push_tower_times_exceeded",
    [33] = "sg_push_tower_settle_gameinfo_not_exist",
    [34] = "sg_push_tower_settle_items_not_right",
    [35] = "sg_push_tower_settle_round_not_enouth",
    [36] = "sg_push_tower_settle_cost_round_illegel",
    [37] = "sg_push_tower_settle_gameid_not_match",


    --game
    [38] = "sg_game_settle_error",
    [39] = "sg_game_settle_item_exceeded",
    [40] = "sg_game_settle_gold_exceeded",
    [41] = "sg_game_not_enough_power",
    [42] = "sg_game_not_enough_summon_stone",
    [43] = "sg_game_copy_lock",
    [44] = "sg_game_emoney_not_enough",
    [45] = "sg_game_level_not_enough",
    [46] = "sg_game_copy_not_pass",


    --challenge
    [47] = "sg_challenge_buy_times_not_enough_emoney",
    [48] = "sg_challenge_buy_times_exceeded",
    [49] = "sg_challenge_enemy_noexist",
    [50] = "sg_challenge_noreq_list",
    [51] = "sg_challenge_times_use_up",
    [52] = "sg_challenge_self",
    [53] = "sg_challenge_level_err",
    [54] = "sg_challenge_settle_not_info",
    [55] = "sg_challenge_settle_info_err",
    [56] = "sg_challenge_rank_award_in_cd",
    [57] = "sg_challenge_rank_award_not_in_rank",


    --equipment_takeoff
    [58] = "sg_equipment_takeoff_pack_full",
    [59] = "sg_equipment_takeoff_type_error",


    --equipment_puton
    [60] = "sg_equipment_puton_noexist",
    [61] = "sg_equipment_puton_levelerr",
    [62] = "sg_equipment_puton_roletypeerr",
    [63] = "sg_equipment_puton_notowner",
    [64] = "sg_equipment_puton_itemtypeerr",


    --equipment_streng
    [65] = "sg_equipment_streng_cannot_streng",
    [66] = "sg_equipment_streng_gold_not_enough",
    [67] = "sg_equipment_streng_item_not_enough",
    [68] = "sg_equipment_streng_streng_failed",
    [69] = "sg_equipment_streng_strenged_top",


    --equipment_advance
    [70] = "sg_equipment_advance_can_not_advance",
    [71] = "sg_equipment_advance_gold_not_enough",
    [72] = "sg_equipment_advance_item_not_enough",
    [73] = "sg_equipment_advance_level_not_enough",


    --equipment_recast
    [74] = "sg_equipment_recast_can_not_recast",
    [75] = "sg_equipment_recast_gold_not_enough",
    [76] = "sg_equipment_recast_item_not_enough",


    --equipment_resolve
    [77] = "sg_equipment_resolve_disable",
    [78] = "sg_equipment_resolve_on_body",
    [79] = "sg_equipment_resolve_not_exist",


    --gem_mount
    [80] = "sg_gem_mount_typeexist",
    [81] = "sg_gem_mount_not_trough",


    --equipment_save_recast
    [82] = "sg_equipment_save_recast_iderr",


    --gem_compound
    [83] = "sg_gem_compound_not_related",
    [84] = "sg_gem_compound_not_enough_gold",
    [85] = "sg_gem_compound_not_protect",
    [86] = "sg_gem_compound_gem_not_enough",
    [87] = "sg_gem_compound_pack_full",


    --gem_unmounted
    [88] = "sg_gem_unmounted_equip_notexist",
    [89] = "sg_gem_unmounted_pack_full",
    [90] = "sg_gem_unmounted_emoney_not_enough",
    [91] = "sg_gem_unmounted_notexist",


    --friend_add
    [92] = "sg_friend_add_limit_exceeded",
    [93] = "sg_friend_add_aim_limit_exceeded",
    [94] = "sg_friend_add_self",
    [95] = "sg_friend_add_exist",
    [96] = "sg_friend_add_offline",


    --mall_buy
    [97] = "sg_mall_buy_times_exceeded",
    [98] = "sg_mall_buy_money_not_enough",
    [99] = "sg_mall_buy_not_on_sale",
    [100] = "sg_mall_buy_pack_exceeded",


    --point_mall_buy
    [101] = "sg_point_mall_buy_rank_not_enough",
    [102] = "sg_point_mall_buy_point_not_enough",
    [103] = "sg_point_mall_buy_not_on_sale",
    [104] = "sg_point_mall_buy_pack_exceeded",


    --power_hp
    [105] = "sg_power_hp_emoney_not_enough",
    [106] = "sg_power_hp_limit_exceeded",


    --extend_pack
    [107] = "sg_extend_pack_is_max",
    [108] = "sg_extend_pack_emoney_not_enough",


    --pack_sale
    [109] = "sg_pack_sale_not_exists",
    [110] = "sg_pack_sale_amount_error",


    --summon_stone
    [111] = "sg_summon_stone_already_award",
    [112] = "sg_summon_stone_emoney_not_enough_to_buy",
    [113] = "sg_summon_stone_buy_times_exceeded",


    --sculpture
    [114] = "sg_sculpture_upgrade_money_not_enough",
    [115] = "sg_sculpture_upgrade_is_max_lev",
    [116] = "sg_sculpture_takeoff_empty",
    [117] = "sg_sculpture_puton_noexist",
    [118] = "sg_sculpture_puton_role_type_not_match",
    [119] = "sg_sculpture_divine_money_not_enough",
    [120] = "sg_sculpture_takeoff_pack_full",
    [121] = "sg_sculpture_puton_skill_repeat",
    [122] = "sg_sculpture_frag_not_enough",
    [123] = "sg_sculpture_divine_pack_full",
    [124] = "sg_sculpture_convert_pack_full",
    [125] = "sg_sculpture_divine_level_up",
    [126] = "sg_sculpture_divine_level_down",
    [127] = "sg_sculpture_pos_has_puton",
    [128] = "sg_sculpture_sale_is_on_body",
    [129] = "sg_sculpture_sale_noexist",
    [130] = "sg_sculpture_upgrade_is_expsculp",
    [131] = "sg_sculpture_puton_is_expsculpture",


    --task
    [132] = "sg_task_not_exist",
    [133] = "sg_task_monster_amount_not_enough",
    [134] = "sg_task_not_pass",
    [135] = "sg_task_not_full_star_pass",
    [136] = "sg_task_not_kill_all_pass",
    [137] = "sg_task_has_finished",
    [138] = "sg_task_player_level_not_enough",
    [139] = "sg_task_item_amount_not_enough",
    [140] = "sg_task_sculpture_upgrade_amount_not_enough",
    [141] = "sg_task_advance_equipment_amount_not_enough",
    [142] = "sg_task_equipment_resolve_amount_not_enough",
    [143] = "sg_task_sculpture_divine_amount_not_enough",


    --daily_award
    [144] = "sg_daily_award_get_already",
    [145] = "sg_daily_award_cannot_get",


    --broadcast
    [146] = "sg_broadcast_divine_sculpture_lev5",
    [147] = "sg_broadcast_convert_sculpture_lev6",
    [148] = "sg_broadcast_buy_sculpture_lev6",
    [149] = "sg_broadcast_advance_orange_equipment",
    [150] = "sg_broadcast_become_generalissimo",
    [151] = "sg_broadcast_become_vip",
    [152] = "sg_broadcast_buy_advanced_item",
    [153] = "sg_broadcast_advance_equipment_success",
    [154] = "sg_broadcast_advance_role_success",
    [155] = "sg_broadcast_advance_skill_success",


    --clean_up_copy
    [156] = "sg_clean_up_copy_not_card",
    [157] = "sg_clean_up_copy_not_max_score",
    [158] = "sg_clean_up_copy_not_base_copy",
    [159] = "sg_clean_up_copy_ph_not_enough",
    [160] = "sg_clean_up_copy_clean_up_card_not_enough",
    [161] = "sg_clean_up_copy_pass_copy_not_enough",


    --train_match
    [162] = "sg_train_match_buy_times_not_enough_emoney",
    [163] = "sg_train_match_buy_times_exceeded",
    [164] = "sg_train_match_refresh_not_enough_emoney",
    [165] = "sg_train_match_against_enemy_not_exist",
    [166] = "sg_train_match_against_leverr",
    [167] = "sg_train_match_times_exceeded",
    [168] = "sg_train_match_has_train",
    [169] = "sg_train_match_award_times_not_enough",
    [170] = "sg_train_match_award_has_get",
    [171] = "sg_train_match_settle_not_info",
    [172] = "sg_train_match_settle_info_error",


    --use_props
    [173] = "sg_use_props_not_props",
    [174] = "sg_use_props_not_exists",


    --benison
    [175] = "sg_benison_refresh_not_enough_gold",
    [176] = "sg_benison_bless_id_not_exist",
    [177] = "sg_benison_bless_emoney_not_enough",
    [178] = "sg_benison_bless_has_active",


    --activeness
    [179] = "sg_activeness_reward_point_not_enough",
    [180] = "sg_activeness_reward_has_gotten",


    --reconnect
    [181] = "sg_reconnect_token_err",
    [182] = "sg_reconnect_server_not_running",


    --ladder_match
    [183] = "sg_ladder_match_buy_times_exceeded",
    [184] = "sg_ladder_match_award_gotten",
    [185] = "sg_ladder_match_award_disable",
    [186] = "sg_ladder_match_times_exceeded",
    [187] = "sg_ladder_match_emoney_not_enough",
    [188] = "sg_ladder_match_settle_error",


    --equipment_exchange
    [189] = "sg_equipment_exchange_disable",
    [190] = "sg_equipment_exchange_gold_err",
    [191] = "sg_equipment_exchange_meterial",


    --online_award
    [192] = "sg_online_award_lev_err",
    [193] = "sg_online_award_time_err",
    [194] = "sg_online_award_has_gotten",


    --exchange
    [195] = "sg_exchange_item_not_enough",


    --military_rank
    [196] = "sg_military_rank_level_err",


    --mooncard
    [197] = "sg_mooncard_daily_award_gotten",
    [198] = "sg_mooncard_daily_award_disable",


    --invitation_code
    [199] = "sg_invitation_code_code_err",
    [200] = "sg_invitation_code_verify_code_succeed",
    [201] = "sg_invitation_code_disengage_err",
    [202] = "sg_invitation_code_invite_num_is_full",
    [203] = "sg_invitation_code_can_not_use_at_same_account",


    --world_chat
    [204] = "sg_world_chat_too_quick",
    [205] = "sg_world_chat_mute",
    [206] = "sg_world_chat_emoney_not_enough",


    --activity_copy
    [207] = "sg_activity_copy_times_use_up",
    [208] = "sg_activity_copy_ph_not_enough",
    [209] = "sg_activity_copy_level_not_enough",
    [210] = "sg_activity_copy_not_open",


    --friend_help
    [211] = "sg_friend_help_hp_has_send",


    --talent
    [212] = "sg_talent_layer_unlock",
    [213] = "sg_talent_server_error",
    [214] = "sg_talent_actived",
    [215] = "sg_talent_actived_two",
    [216] = "sg_talent_not_enough_frag",
    [217] = "sg_talent_max_level",
    [218] = "sg_talent_emoney_not_enough",
    [219] = "sg_talent_unactived",
    [220] = "sg_talent_actived_reseted"
}