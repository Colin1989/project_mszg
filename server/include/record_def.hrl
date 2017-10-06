-record(battle_prop,{life=0,atk=0,speed=0,hit_ratio=0,miss_ratio=0,critical_ratio=0,tenacity=0,power=0}).
-record(game_result_struct,{life=0,maxlife=0,monster_amount=0}).
-record(role_battle_info,{armor=0,weapon=0,jewelry=0,medal=0,sculpture1=0,sculpture2=0,sculpture3=0,sculpture4=0,level=1}).
-record(game_log_info,{game_id=0,user_operations=[],game_maps=[],game_result=#game_result_struct{},role_info=#role_battle_info{},create_time={}}).
-record(game_record_struct,{game_id=0,role_id=0,copy_id,result=0,score=0,final_item=0,pickup_items=[],create_time={}}).
-record(equip_extra_info,{temp_id=0,level=0,addition_gem=0,attach_info=[]}).

-record(role_attr_detail, {sculptures=[], equipments=[],talents=[],life=0, speed=0, atk=0, hit_ratio=0, miss_ratio=0, critical_ratio=0, tenacity=0, battle_power=0}).
-record(role_info_detail, {role_id=0, nickname=[], status=0, level=0, type=0, public=[], battle_prop=#role_attr_detail{}, potence_level = 100, advanced_level = 1, mitigation = 0}).
