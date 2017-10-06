-record(event_game_copy, {copy_id = 0, score = 0,  monsterids=[], count = 0}).
-record(event_divine, {times = 0, type = 0}).
-record(event_equipment_strengthen, {times = 0}).
-record(event_sculpture_upgrade, {amount = 0}).


-record(event_login, {year = 0,month = 0,day = 0}).
-record(event_activity_copy, {result = 0}).
-record(event_push_tower, {result = 0}).
-record(event_train_match, {result = 0}).
-record(event_ladder_match, {result = 0}).
-record(event_challenge, {result = 0}).

-record(event_task_finish_times_update, {amount = 0, sub_type}).
