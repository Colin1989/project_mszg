sex_type = 
{
    ["boy"]= 1,
    ["girl"] = 2
}
game_type = 
{
    ["common"]= 1,
    ["push_tower"] = 2
}
user_operation = 
{
    ["opt_open"]= 1,
    ["opt_atk_monster"]= 2,
    ["opt_pickup_item"]= 3,
    ["opt_use_skill"]= 4,
    ["opt_use_item"]= 5,
    ["opt_pass"] = 6
}
game_result = 
{
    ["game_win"]= 1,
    ["game_lost"]= 2,
    ["game_error"] = 3
}
register_result = 
{
    ["register_success"]= 1,
    ["register_failed"] = 2
}
login_result = 
{
    ["login_success"]= 1,
    ["login_noregister"]= 2,
    ["login_passworderror"]= 3,
    ["login_norole"]= 4,
    ["login_versionerror"] = 5
}
reconnect_result = 
{
    ["reconnect_success"]= 1,
    ["reconnect_noregister"]= 2,
    ["reconnect_passworderror"]= 3,
    ["reconnect_versionerror"] = 4
}
create_role_result = 
{
    ["create_role_success"]= 1,
    ["create_role_failed"]= 2,
    ["create_role_nologin"]= 3,
    ["create_role_typeerror"]= 4,
    ["create_role_nameexisted"] = 5
}
enter_game_result = 
{
    ["enter_game_success"]= 1,
    ["enter_game_failed"]= 2,
    ["enter_game_unlogin"] = 3
}
common_result = 
{
    ["common_success"]= 1,
    ["common_failed"]= 2,
    ["common_error"] = 3
}
equipment_type = 
{
    ["weapon"]= 1,
    ["armor"]= 2,
    ["necklace"]= 3,
    ["ring"]= 4,
    ["jewelry"]= 5,
    ["medal"] = 6
}
item_type = 
{
    ["equipment"]= 1,
    ["sculpture"]= 2,
    ["gem"]= 3,
    ["property"] = 4
}
quality_type = 
{
    ["white"]= 1,
    ["green"]= 2,
    ["blue"]= 3,
    ["purple"]= 4,
    ["orange"] = 5
}
data_type = 
{
    ["init"]= 1,
    ["append"]= 2,
    ["delete"]= 3,
    ["modify"] = 4
}
role_status = 
{
    ["online"]= 1,
    ["offline"] = 2
}
answer_type = 
{
    ["agree"]= 1,
    ["defuse"] = 2
}
map_settle_result = 
{
    ["map_settle_next_map"]= 1,
    ["map_settle_finish"]= 2,
    ["map_settle_died"]= 3,
    ["map_settle_error"] = 4
}
relation = 
{
    ["friend"]= 1,
    ["other"] = 2
}
price_type = 
{
    ["price_type_gold"]= 1,
    ["price_type_emoney"] = 2
}
mall_item_state = 
{
    ["on_sale"]= 1,
    ["not_on_sale"] = 2
}

function get_proto_version()

    return 36;
end
