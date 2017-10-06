require("class")
require("packet_type")
local binary_helper = require("binary_helper")
stime=class()
function stime:ctor(year, month, day, hour, minute, second)
    self.year = year
    self.month = month
    self.day = day
    self.hour = hour
    self.minute = minute
    self.second = second
end
function stime:encode()
    return
        binary_helper.to_binary(self.year, "int") ..
        binary_helper.to_binary(self.month, "int") ..
        binary_helper.to_binary(self.day, "int") ..
        binary_helper.to_binary(self.hour, "int") ..
        binary_helper.to_binary(self.minute, "int") ..
        binary_helper.to_binary(self.second, "int")
end
function stime:decode(binary)
    self.year, binary = binary_helper.to_value(binary, "int")
    self.month, binary = binary_helper.to_value(binary, "int")
    self.day, binary = binary_helper.to_value(binary, "int")
    self.hour, binary = binary_helper.to_value(binary, "int")
    self.minute, binary = binary_helper.to_value(binary, "int")
    self.second, binary = binary_helper.to_value(binary, "int")
    return binary
end
function stime:get_msgid()
    return msg_stime
end
req_login=class()
function req_login:ctor(version, account, password)
    self.version = version
    self.account = account
    self.password = password
end
function req_login:encode()
    return
        binary_helper.to_binary(self.version, "int") ..
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.password, "string")
end
function req_login:decode(binary)
    self.version, binary = binary_helper.to_value(binary, "int")
    self.account, binary = binary_helper.to_value(binary, "string")
    self.password, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_login:get_msgid()
    return msg_req_login
end
notify_login_result=class()
function notify_login_result:ctor(result, nick_name, sex, val_int64, val_uint64, t, array_int, array_time)
    self.result = result
    self.nick_name = nick_name
    self.sex = sex
    self.val_int64 = val_int64
    self.val_uint64 = val_uint64
    self.t = t
    self.array_int = array_int
    self.array_time = array_time
end
function notify_login_result:encode()
    return
        binary_helper.to_binary(self.result, "int") ..
        binary_helper.to_binary(self.nick_name, "string") ..
        binary_helper.to_binary(self.sex, "int") ..
        binary_helper.to_binary(self.val_int64, "int64") ..
        binary_helper.to_binary(self.val_uint64, "uint64") ..
        binary_helper.to_binary(self.t, "user_define") ..
        binary_helper.array_to_binary(self.array_int, "int") ..
        binary_helper.array_to_binary(self.array_time, "user_define")
end
function notify_login_result:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    self.nick_name, binary = binary_helper.to_value(binary, "string")
    self.sex, binary = binary_helper.to_value(binary, "int")
    self.val_int64, binary = binary_helper.to_value(binary, "int64")
    self.val_uint64, binary = binary_helper.to_value(binary, "uint64")
    self.t, binary = binary_helper.to_value(binary,stime)
    self.array_int, binary = binary_helper.to_array(binary, "int")
    self.array_time, binary = binary_helper.to_array(binary,stime)
    return binary
end
function notify_login_result:get_msgid()
    return msg_notify_login_result
end
point=class()
function point:ctor(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end
function point:encode()
    return
        binary_helper.to_binary(self.x, "number") ..
        binary_helper.to_binary(self.y, "number") ..
        binary_helper.to_binary(self.z, "number")
end
function point:decode(binary)
    self.x, binary = binary_helper.to_value(binary, "number")
    self.y, binary = binary_helper.to_value(binary, "number")
    self.z, binary = binary_helper.to_value(binary, "number")
    return binary
end
function point:get_msgid()
    return msg_point
end
grid_pos=class()
function grid_pos:ctor(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end
function grid_pos:encode()
    return
        binary_helper.to_binary(self.x, "int") ..
        binary_helper.to_binary(self.y, "int") ..
        binary_helper.to_binary(self.z, "int")
end
function grid_pos:decode(binary)
    self.x, binary = binary_helper.to_value(binary, "int")
    self.y, binary = binary_helper.to_value(binary, "int")
    self.z, binary = binary_helper.to_value(binary, "int")
    return binary
end
function grid_pos:get_msgid()
    return msg_grid_pos
end
item_property=class()
function item_property:ctor(key, value)
    self.key = key
    self.value = value
end
function item_property:encode()
    return
        binary_helper.to_binary(self.key, "string") ..
        binary_helper.to_binary(self.value, "int")
end
function item_property:decode(binary)
    self.key, binary = binary_helper.to_value(binary, "string")
    self.value, binary = binary_helper.to_value(binary, "int")
    return binary
end
function item_property:get_msgid()
    return msg_item_property
end
item=class()
function item:ctor(instance_id, template_id, del_time, property)
    self.instance_id = instance_id
    self.template_id = template_id
    self.del_time = del_time
    self.property = property
end
function item:encode()
    return
        binary_helper.to_binary(self.instance_id, "uint64") ..
        binary_helper.to_binary(self.template_id, "int") ..
        binary_helper.to_binary(self.del_time, "user_define") ..
        binary_helper.array_to_binary(self.property, "user_define")
end
function item:decode(binary)
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    self.template_id, binary = binary_helper.to_value(binary, "int")
    self.del_time, binary = binary_helper.to_value(binary,stime)
    self.property, binary = binary_helper.to_array(binary,item_property)
    return binary
end
function item:get_msgid()
    return msg_item
end
visit_log=class()
function visit_log:ctor(account, openid, visit_time)
    self.account = account
    self.openid = openid
    self.visit_time = visit_time
end
function visit_log:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.openid, "string") ..
        binary_helper.to_binary(self.visit_time, "user_define")
end
function visit_log:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.openid, binary = binary_helper.to_value(binary, "string")
    self.visit_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function visit_log:get_msgid()
    return msg_visit_log
end
guest_book=class()
function guest_book:ctor(id, account, content, opened, create_time)
    self.id = id
    self.account = account
    self.content = content
    self.opened = opened
    self.create_time = create_time
end
function guest_book:encode()
    return
        binary_helper.to_binary(self.id, "uint64") ..
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.content, "string") ..
        binary_helper.to_binary(self.opened, "int") ..
        binary_helper.to_binary(self.create_time, "user_define")
end
function guest_book:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "uint64")
    self.account, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    self.opened, binary = binary_helper.to_value(binary, "int")
    self.create_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function guest_book:get_msgid()
    return msg_guest_book
end
pack_grid=class()
function pack_grid:ctor(count, lock, item_data)
    self.count = count
    self.lock = lock
    self.item_data = item_data
end
function pack_grid:encode()
    return
        binary_helper.to_binary(self.count, "int") ..
        binary_helper.to_binary(self.lock, "int") ..
        binary_helper.to_binary(self.item_data, "user_define")
end
function pack_grid:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    self.lock, binary = binary_helper.to_value(binary, "int")
    self.item_data, binary = binary_helper.to_value(binary,item)
    return binary
end
function pack_grid:get_msgid()
    return msg_pack_grid
end
polymorph=class()
function polymorph:ctor(id, duration, start_at)
    self.id = id
    self.duration = duration
    self.start_at = start_at
end
function polymorph:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.duration, "int") ..
        binary_helper.to_binary(self.start_at, "user_define")
end
function polymorph:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.duration, binary = binary_helper.to_value(binary, "int")
    self.start_at, binary = binary_helper.to_value(binary,stime)
    return binary
end
function polymorph:get_msgid()
    return msg_polymorph
end
player_basic_data=class()
function player_basic_data:ctor(account, username, sex, skin_color, hair, face, beard, online_time, hair_color, last_login_time, house_id, mateup_status, hp, body, hp_update_time, create_time, first_photo_player, animal_type, birthday, star, height, salary, blood_type, education, contact, interest, signature, city, province, career, weight, alter_body, charm, produce_experience, produce_level)
    self.account = account
    self.username = username
    self.sex = sex
    self.skin_color = skin_color
    self.hair = hair
    self.face = face
    self.beard = beard
    self.online_time = online_time
    self.hair_color = hair_color
    self.last_login_time = last_login_time
    self.house_id = house_id
    self.mateup_status = mateup_status
    self.hp = hp
    self.body = body
    self.hp_update_time = hp_update_time
    self.create_time = create_time
    self.first_photo_player = first_photo_player
    self.animal_type = animal_type
    self.birthday = birthday
    self.star = star
    self.height = height
    self.salary = salary
    self.blood_type = blood_type
    self.education = education
    self.contact = contact
    self.interest = interest
    self.signature = signature
    self.city = city
    self.province = province
    self.career = career
    self.weight = weight
    self.alter_body = alter_body
    self.charm = charm
    self.produce_experience = produce_experience
    self.produce_level = produce_level
end
function player_basic_data:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.username, "string") ..
        binary_helper.to_binary(self.sex, "int") ..
        binary_helper.to_binary(self.skin_color, "int") ..
        binary_helper.to_binary(self.hair, "int") ..
        binary_helper.to_binary(self.face, "int") ..
        binary_helper.to_binary(self.beard, "int") ..
        binary_helper.to_binary(self.online_time, "number") ..
        binary_helper.to_binary(self.hair_color, "int") ..
        binary_helper.to_binary(self.last_login_time, "user_define") ..
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.mateup_status, "int") ..
        binary_helper.to_binary(self.hp, "int") ..
        binary_helper.array_to_binary(self.body, "user_define") ..
        binary_helper.to_binary(self.hp_update_time, "user_define") ..
        binary_helper.to_binary(self.create_time, "user_define") ..
        binary_helper.to_binary(self.first_photo_player, "string") ..
        binary_helper.to_binary(self.animal_type, "int") ..
        binary_helper.to_binary(self.birthday, "user_define") ..
        binary_helper.to_binary(self.star, "int") ..
        binary_helper.to_binary(self.height, "int") ..
        binary_helper.to_binary(self.salary, "int") ..
        binary_helper.to_binary(self.blood_type, "int") ..
        binary_helper.to_binary(self.education, "int") ..
        binary_helper.to_binary(self.contact, "string") ..
        binary_helper.to_binary(self.interest, "string") ..
        binary_helper.to_binary(self.signature, "string") ..
        binary_helper.to_binary(self.city, "int") ..
        binary_helper.to_binary(self.province, "int") ..
        binary_helper.to_binary(self.career, "string") ..
        binary_helper.to_binary(self.weight, "int") ..
        binary_helper.to_binary(self.alter_body, "user_define") ..
        binary_helper.to_binary(self.charm, "int") ..
        binary_helper.to_binary(self.produce_experience, "int") ..
        binary_helper.to_binary(self.produce_level, "int")
end
function player_basic_data:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.username, binary = binary_helper.to_value(binary, "string")
    self.sex, binary = binary_helper.to_value(binary, "int")
    self.skin_color, binary = binary_helper.to_value(binary, "int")
    self.hair, binary = binary_helper.to_value(binary, "int")
    self.face, binary = binary_helper.to_value(binary, "int")
    self.beard, binary = binary_helper.to_value(binary, "int")
    self.online_time, binary = binary_helper.to_value(binary, "number")
    self.hair_color, binary = binary_helper.to_value(binary, "int")
    self.last_login_time, binary = binary_helper.to_value(binary,stime)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.mateup_status, binary = binary_helper.to_value(binary, "int")
    self.hp, binary = binary_helper.to_value(binary, "int")
    self.body, binary = binary_helper.to_array(binary,pack_grid)
    self.hp_update_time, binary = binary_helper.to_value(binary,stime)
    self.create_time, binary = binary_helper.to_value(binary,stime)
    self.first_photo_player, binary = binary_helper.to_value(binary, "string")
    self.animal_type, binary = binary_helper.to_value(binary, "int")
    self.birthday, binary = binary_helper.to_value(binary,stime)
    self.star, binary = binary_helper.to_value(binary, "int")
    self.height, binary = binary_helper.to_value(binary, "int")
    self.salary, binary = binary_helper.to_value(binary, "int")
    self.blood_type, binary = binary_helper.to_value(binary, "int")
    self.education, binary = binary_helper.to_value(binary, "int")
    self.contact, binary = binary_helper.to_value(binary, "string")
    self.interest, binary = binary_helper.to_value(binary, "string")
    self.signature, binary = binary_helper.to_value(binary, "string")
    self.city, binary = binary_helper.to_value(binary, "int")
    self.province, binary = binary_helper.to_value(binary, "int")
    self.career, binary = binary_helper.to_value(binary, "string")
    self.weight, binary = binary_helper.to_value(binary, "int")
    self.alter_body, binary = binary_helper.to_value(binary,polymorph)
    self.charm, binary = binary_helper.to_value(binary, "int")
    self.produce_experience, binary = binary_helper.to_value(binary, "int")
    self.produce_level, binary = binary_helper.to_value(binary, "int")
    return binary
end
function player_basic_data:get_msgid()
    return msg_player_basic_data
end
player_info=class()
function player_info:ctor(basic_data, scenename)
    self.basic_data = basic_data
    self.scenename = scenename
end
function player_info:encode()
    return
        binary_helper.to_binary(self.basic_data, "user_define") ..
        binary_helper.to_binary(self.scenename, "string")
end
function player_info:decode(binary)
    self.basic_data, binary = binary_helper.to_value(binary,player_basic_data)
    self.scenename, binary = binary_helper.to_value(binary, "string")
    return binary
end
function player_info:get_msgid()
    return msg_player_info
end
npc_info=class()
function npc_info:ctor(npc_id, body, head, hair, equip1, equip2, skeleton, npc_name)
    self.npc_id = npc_id
    self.body = body
    self.head = head
    self.hair = hair
    self.equip1 = equip1
    self.equip2 = equip2
    self.skeleton = skeleton
    self.npc_name = npc_name
end
function npc_info:encode()
    return
        binary_helper.to_binary(self.npc_id, "int") ..
        binary_helper.to_binary(self.body, "int") ..
        binary_helper.to_binary(self.head, "int") ..
        binary_helper.to_binary(self.hair, "int") ..
        binary_helper.to_binary(self.equip1, "int") ..
        binary_helper.to_binary(self.equip2, "int") ..
        binary_helper.to_binary(self.skeleton, "int") ..
        binary_helper.to_binary(self.npc_name, "string")
end
function npc_info:decode(binary)
    self.npc_id, binary = binary_helper.to_value(binary, "int")
    self.body, binary = binary_helper.to_value(binary, "int")
    self.head, binary = binary_helper.to_value(binary, "int")
    self.hair, binary = binary_helper.to_value(binary, "int")
    self.equip1, binary = binary_helper.to_value(binary, "int")
    self.equip2, binary = binary_helper.to_value(binary, "int")
    self.skeleton, binary = binary_helper.to_value(binary, "int")
    self.npc_name, binary = binary_helper.to_value(binary, "string")
    return binary
end
function npc_info:get_msgid()
    return msg_npc_info
end
npc_map_mapping_info=class()
function npc_map_mapping_info:ctor(id, npc_id, npc_name, pos, script_id, action, npc_key, towards)
    self.id = id
    self.npc_id = npc_id
    self.npc_name = npc_name
    self.pos = pos
    self.script_id = script_id
    self.action = action
    self.npc_key = npc_key
    self.towards = towards
end
function npc_map_mapping_info:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.npc_id, "int") ..
        binary_helper.to_binary(self.npc_name, "string") ..
        binary_helper.to_binary(self.pos, "user_define") ..
        binary_helper.to_binary(self.script_id, "int") ..
        binary_helper.to_binary(self.action, "int") ..
        binary_helper.to_binary(self.npc_key, "string") ..
        binary_helper.to_binary(self.towards, "int")
end
function npc_map_mapping_info:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.npc_id, binary = binary_helper.to_value(binary, "int")
    self.npc_name, binary = binary_helper.to_value(binary, "string")
    self.pos, binary = binary_helper.to_value(binary,point)
    self.script_id, binary = binary_helper.to_value(binary, "int")
    self.action, binary = binary_helper.to_value(binary, "int")
    self.npc_key, binary = binary_helper.to_value(binary, "string")
    self.towards, binary = binary_helper.to_value(binary, "int")
    return binary
end
function npc_map_mapping_info:get_msgid()
    return msg_npc_map_mapping_info
end
furniture_position=class()
function furniture_position:ctor(position_index, is_used, used_account, status, func_id, use_time)
    self.position_index = position_index
    self.is_used = is_used
    self.used_account = used_account
    self.status = status
    self.func_id = func_id
    self.use_time = use_time
end
function furniture_position:encode()
    return
        binary_helper.to_binary(self.position_index, "int") ..
        binary_helper.to_binary(self.is_used, "int") ..
        binary_helper.to_binary(self.used_account, "string") ..
        binary_helper.to_binary(self.status, "int") ..
        binary_helper.to_binary(self.func_id, "int") ..
        binary_helper.to_binary(self.use_time, "user_define")
end
function furniture_position:decode(binary)
    self.position_index, binary = binary_helper.to_value(binary, "int")
    self.is_used, binary = binary_helper.to_value(binary, "int")
    self.used_account, binary = binary_helper.to_value(binary, "string")
    self.status, binary = binary_helper.to_value(binary, "int")
    self.func_id, binary = binary_helper.to_value(binary, "int")
    self.use_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function furniture_position:get_msgid()
    return msg_furniture_position
end
furniture_goods_data=class()
function furniture_goods_data:ctor(goods_id, x, z, height, floor, face)
    self.goods_id = goods_id
    self.x = x
    self.z = z
    self.height = height
    self.floor = floor
    self.face = face
end
function furniture_goods_data:encode()
    return
        binary_helper.to_binary(self.goods_id, "int") ..
        binary_helper.to_binary(self.x, "int") ..
        binary_helper.to_binary(self.z, "int") ..
        binary_helper.to_binary(self.height, "number") ..
        binary_helper.to_binary(self.floor, "int") ..
        binary_helper.to_binary(self.face, "int")
end
function furniture_goods_data:decode(binary)
    self.goods_id, binary = binary_helper.to_value(binary, "int")
    self.x, binary = binary_helper.to_value(binary, "int")
    self.z, binary = binary_helper.to_value(binary, "int")
    self.height, binary = binary_helper.to_value(binary, "number")
    self.floor, binary = binary_helper.to_value(binary, "int")
    self.face, binary = binary_helper.to_value(binary, "int")
    return binary
end
function furniture_goods_data:get_msgid()
    return msg_furniture_goods_data
end
setting_info=class()
function setting_info:ctor(name, value)
    self.name = name
    self.value = value
end
function setting_info:encode()
    return
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.value, "int")
end
function setting_info:decode(binary)
    self.name, binary = binary_helper.to_value(binary, "string")
    self.value, binary = binary_helper.to_value(binary, "int")
    return binary
end
function setting_info:get_msgid()
    return msg_setting_info
end
player_setting=class()
function player_setting:ctor(account, info)
    self.account = account
    self.info = info
end
function player_setting:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.array_to_binary(self.info, "user_define")
end
function player_setting:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.info, binary = binary_helper.to_array(binary,setting_info)
    return binary
end
function player_setting:get_msgid()
    return msg_player_setting
end
house_furniture=class()
function house_furniture:ctor(instance_id, template_id, x, z, height, floor, face, item_tempid, status, del_time, property)
    self.instance_id = instance_id
    self.template_id = template_id
    self.x = x
    self.z = z
    self.height = height
    self.floor = floor
    self.face = face
    self.item_tempid = item_tempid
    self.status = status
    self.del_time = del_time
    self.property = property
end
function house_furniture:encode()
    return
        binary_helper.to_binary(self.instance_id, "uint64") ..
        binary_helper.to_binary(self.template_id, "int") ..
        binary_helper.to_binary(self.x, "int") ..
        binary_helper.to_binary(self.z, "int") ..
        binary_helper.to_binary(self.height, "number") ..
        binary_helper.to_binary(self.floor, "int") ..
        binary_helper.to_binary(self.face, "int") ..
        binary_helper.to_binary(self.item_tempid, "int") ..
        binary_helper.to_binary(self.status, "int") ..
        binary_helper.to_binary(self.del_time, "user_define") ..
        binary_helper.array_to_binary(self.property, "user_define")
end
function house_furniture:decode(binary)
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    self.template_id, binary = binary_helper.to_value(binary, "int")
    self.x, binary = binary_helper.to_value(binary, "int")
    self.z, binary = binary_helper.to_value(binary, "int")
    self.height, binary = binary_helper.to_value(binary, "number")
    self.floor, binary = binary_helper.to_value(binary, "int")
    self.face, binary = binary_helper.to_value(binary, "int")
    self.item_tempid, binary = binary_helper.to_value(binary, "int")
    self.status, binary = binary_helper.to_value(binary, "int")
    self.del_time, binary = binary_helper.to_value(binary,stime)
    self.property, binary = binary_helper.to_array(binary,item_property)
    return binary
end
function house_furniture:get_msgid()
    return msg_house_furniture
end
room_tex=class()
function room_tex:ctor(room_id, type, tex, floor_id)
    self.room_id = room_id
    self.type = type
    self.tex = tex
    self.floor_id = floor_id
end
function room_tex:encode()
    return
        binary_helper.to_binary(self.room_id, "int") ..
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.tex, "string") ..
        binary_helper.to_binary(self.floor_id, "int")
end
function room_tex:decode(binary)
    self.room_id, binary = binary_helper.to_value(binary, "int")
    self.type, binary = binary_helper.to_value(binary, "int")
    self.tex, binary = binary_helper.to_value(binary, "string")
    self.floor_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function room_tex:get_msgid()
    return msg_room_tex
end
house_info=class()
function house_info:ctor(house_id, template_id, furniture_permission, furniture_vec, room_tex_vec, welcome_words, house_permission, visit_logs, buy_date, level, house_clean, boy, girl, name, mateup_status, decoration)
    self.house_id = house_id
    self.template_id = template_id
    self.furniture_permission = furniture_permission
    self.furniture_vec = furniture_vec
    self.room_tex_vec = room_tex_vec
    self.welcome_words = welcome_words
    self.house_permission = house_permission
    self.visit_logs = visit_logs
    self.buy_date = buy_date
    self.level = level
    self.house_clean = house_clean
    self.boy = boy
    self.girl = girl
    self.name = name
    self.mateup_status = mateup_status
    self.decoration = decoration
end
function house_info:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.template_id, "int") ..
        binary_helper.to_binary(self.furniture_permission, "user_define") ..
        binary_helper.array_to_binary(self.furniture_vec, "user_define") ..
        binary_helper.array_to_binary(self.room_tex_vec, "user_define") ..
        binary_helper.to_binary(self.welcome_words, "string") ..
        binary_helper.to_binary(self.house_permission, "user_define") ..
        binary_helper.array_to_binary(self.visit_logs, "user_define") ..
        binary_helper.to_binary(self.buy_date, "user_define") ..
        binary_helper.to_binary(self.level, "int") ..
        binary_helper.to_binary(self.house_clean, "int") ..
        binary_helper.to_binary(self.boy, "string") ..
        binary_helper.to_binary(self.girl, "string") ..
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.mateup_status, "int") ..
        binary_helper.to_binary(self.decoration, "int")
end
function house_info:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.template_id, binary = binary_helper.to_value(binary, "int")
    self.furniture_permission, binary = binary_helper.to_value(binary,furniture_permission_type)
    self.furniture_vec, binary = binary_helper.to_array(binary,house_furniture)
    self.room_tex_vec, binary = binary_helper.to_array(binary,room_tex)
    self.welcome_words, binary = binary_helper.to_value(binary, "string")
    self.house_permission, binary = binary_helper.to_value(binary,house_permission_type)
    self.visit_logs, binary = binary_helper.to_array(binary,visit_log)
    self.buy_date, binary = binary_helper.to_value(binary,stime)
    self.level, binary = binary_helper.to_value(binary, "int")
    self.house_clean, binary = binary_helper.to_value(binary, "int")
    self.boy, binary = binary_helper.to_value(binary, "string")
    self.girl, binary = binary_helper.to_value(binary, "string")
    self.name, binary = binary_helper.to_value(binary, "string")
    self.mateup_status, binary = binary_helper.to_value(binary, "int")
    self.decoration, binary = binary_helper.to_value(binary, "int")
    return binary
end
function house_info:get_msgid()
    return msg_house_info
end
notify_repeat_login=class()
function notify_repeat_login:ctor(account)
    self.account = account
end
function notify_repeat_login:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function notify_repeat_login:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_repeat_login:get_msgid()
    return msg_notify_repeat_login
end
req_create_role=class()
function req_create_role:ctor(basic_data, equips, iopenid)
    self.basic_data = basic_data
    self.equips = equips
    self.iopenid = iopenid
end
function req_create_role:encode()
    return
        binary_helper.to_binary(self.basic_data, "user_define") ..
        binary_helper.array_to_binary(self.equips, "user_define") ..
        binary_helper.to_binary(self.iopenid, "string")
end
function req_create_role:decode(binary)
    self.basic_data, binary = binary_helper.to_value(binary,player_basic_data)
    self.equips, binary = binary_helper.to_array(binary,item)
    self.iopenid, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_create_role:get_msgid()
    return msg_req_create_role
end
notify_create_role_result=class()
function notify_create_role_result:ctor(result)
    self.result = result
end
function notify_create_role_result:encode()
    return
        binary_helper.to_binary(self.result, "user_define")
end
function notify_create_role_result:decode(binary)
    self.result, binary = binary_helper.to_value(binary,create_role_result)
    return binary
end
function notify_create_role_result:get_msgid()
    return msg_notify_create_role_result
end
req_enter_game=class()
function req_enter_game:ctor()

end
function req_enter_game:encode()
    return

end
function req_enter_game:decode(binary)

    return binary
end
function req_enter_game:get_msgid()
    return msg_req_enter_game
end
notify_enter_game=class()
function notify_enter_game:ctor()

end
function notify_enter_game:encode()
    return

end
function notify_enter_game:decode(binary)

    return binary
end
function notify_enter_game:get_msgid()
    return msg_notify_enter_game
end
notify_body_data=class()
function notify_body_data:ctor(grid_vec)
    self.grid_vec = grid_vec
end
function notify_body_data:encode()
    return
        binary_helper.array_to_binary(self.grid_vec, "user_define")
end
function notify_body_data:decode(binary)
    self.grid_vec, binary = binary_helper.to_array(binary,pack_grid)
    return binary
end
function notify_body_data:get_msgid()
    return msg_notify_body_data
end
client_ready_for_pop_msg=class()
function client_ready_for_pop_msg:ctor()

end
function client_ready_for_pop_msg:encode()
    return

end
function client_ready_for_pop_msg:decode(binary)

    return binary
end
function client_ready_for_pop_msg:get_msgid()
    return msg_client_ready_for_pop_msg
end
pair_int=class()
function pair_int:ctor(key, value)
    self.key = key
    self.value = value
end
function pair_int:encode()
    return
        binary_helper.to_binary(self.key, "int") ..
        binary_helper.to_binary(self.value, "int")
end
function pair_int:decode(binary)
    self.key, binary = binary_helper.to_value(binary, "int")
    self.value, binary = binary_helper.to_value(binary, "int")
    return binary
end
function pair_int:get_msgid()
    return msg_pair_int
end
req_enter_player_house=class()
function req_enter_player_house:ctor(type, account)
    self.type = type
    self.account = account
end
function req_enter_player_house:encode()
    return
        binary_helper.to_binary(self.type, "user_define") ..
        binary_helper.to_binary(self.account, "string")
end
function req_enter_player_house:decode(binary)
    self.type, binary = binary_helper.to_value(binary,enter_house_type)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_enter_player_house:get_msgid()
    return msg_req_enter_player_house
end
notify_enter_player_house=class()
function notify_enter_player_house:ctor(house_tplt_id, data, enter_pos)
    self.house_tplt_id = house_tplt_id
    self.data = data
    self.enter_pos = enter_pos
end
function notify_enter_player_house:encode()
    return
        binary_helper.to_binary(self.house_tplt_id, "int") ..
        binary_helper.to_binary(self.data, "user_define") ..
        binary_helper.to_binary(self.enter_pos, "user_define")
end
function notify_enter_player_house:decode(binary)
    self.house_tplt_id, binary = binary_helper.to_value(binary, "int")
    self.data, binary = binary_helper.to_value(binary,house_info)
    self.enter_pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function notify_enter_player_house:get_msgid()
    return msg_notify_enter_player_house
end
req_scene_copy_list=class()
function req_scene_copy_list:ctor(template_id)
    self.template_id = template_id
end
function req_scene_copy_list:encode()
    return
        binary_helper.to_binary(self.template_id, "int")
end
function req_scene_copy_list:decode(binary)
    self.template_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_scene_copy_list:get_msgid()
    return msg_req_scene_copy_list
end
notify_scene_copy_list=class()
function notify_scene_copy_list:ctor(template_id, state_list)
    self.template_id = template_id
    self.state_list = state_list
end
function notify_scene_copy_list:encode()
    return
        binary_helper.to_binary(self.template_id, "int") ..
        binary_helper.array_to_binary(self.state_list, "int")
end
function notify_scene_copy_list:decode(binary)
    self.template_id, binary = binary_helper.to_value(binary, "int")
    self.state_list, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_scene_copy_list:get_msgid()
    return msg_notify_scene_copy_list
end
req_enter_common_scene=class()
function req_enter_common_scene:ctor(template_id, copy_id)
    self.template_id = template_id
    self.copy_id = copy_id
end
function req_enter_common_scene:encode()
    return
        binary_helper.to_binary(self.template_id, "int") ..
        binary_helper.to_binary(self.copy_id, "int")
end
function req_enter_common_scene:decode(binary)
    self.template_id, binary = binary_helper.to_value(binary, "int")
    self.copy_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_enter_common_scene:get_msgid()
    return msg_req_enter_common_scene
end
notify_enter_common_scene=class()
function notify_enter_common_scene:ctor(template_id, copy_id, enter_pos)
    self.template_id = template_id
    self.copy_id = copy_id
    self.enter_pos = enter_pos
end
function notify_enter_common_scene:encode()
    return
        binary_helper.to_binary(self.template_id, "int") ..
        binary_helper.to_binary(self.copy_id, "int") ..
        binary_helper.to_binary(self.enter_pos, "user_define")
end
function notify_enter_common_scene:decode(binary)
    self.template_id, binary = binary_helper.to_value(binary, "int")
    self.copy_id, binary = binary_helper.to_value(binary, "int")
    self.enter_pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function notify_enter_common_scene:get_msgid()
    return msg_notify_enter_common_scene
end
req_kick_guest=class()
function req_kick_guest:ctor(target_player)
    self.target_player = target_player
end
function req_kick_guest:encode()
    return
        binary_helper.to_binary(self.target_player, "string")
end
function req_kick_guest:decode(binary)
    self.target_player, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_kick_guest:get_msgid()
    return msg_req_kick_guest
end
notify_other_player_data=class()
function notify_other_player_data:ctor(player, curr_pos, dest_pos, type)
    self.player = player
    self.curr_pos = curr_pos
    self.dest_pos = dest_pos
    self.type = type
end
function notify_other_player_data:encode()
    return
        binary_helper.to_binary(self.player, "user_define") ..
        binary_helper.to_binary(self.curr_pos, "user_define") ..
        binary_helper.to_binary(self.dest_pos, "user_define") ..
        binary_helper.to_binary(self.type, "user_define")
end
function notify_other_player_data:decode(binary)
    self.player, binary = binary_helper.to_value(binary,player_info)
    self.curr_pos, binary = binary_helper.to_value(binary,point)
    self.dest_pos, binary = binary_helper.to_value(binary,point)
    self.type, binary = binary_helper.to_value(binary,walk_type)
    return binary
end
function notify_other_player_data:get_msgid()
    return msg_notify_other_player_data
end
notify_other_player_info=class()
function notify_other_player_info:ctor(player)
    self.player = player
end
function notify_other_player_info:encode()
    return
        binary_helper.to_binary(self.player, "user_define")
end
function notify_other_player_info:decode(binary)
    self.player, binary = binary_helper.to_value(binary,player_info)
    return binary
end
function notify_other_player_info:get_msgid()
    return msg_notify_other_player_info
end
req_other_player_info=class()
function req_other_player_info:ctor(account)
    self.account = account
end
function req_other_player_info:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_other_player_info:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_other_player_info:get_msgid()
    return msg_req_other_player_info
end
notify_player_leave_scene=class()
function notify_player_leave_scene:ctor(account)
    self.account = account
end
function notify_player_leave_scene:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function notify_player_leave_scene:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_player_leave_scene:get_msgid()
    return msg_notify_player_leave_scene
end
req_logout=class()
function req_logout:ctor()

end
function req_logout:encode()
    return

end
function req_logout:decode(binary)

    return binary
end
function req_logout:get_msgid()
    return msg_req_logout
end
notify_player_data=class()
function notify_player_data:ctor(basic_data)
    self.basic_data = basic_data
end
function notify_player_data:encode()
    return
        binary_helper.to_binary(self.basic_data, "user_define")
end
function notify_player_data:decode(binary)
    self.basic_data, binary = binary_helper.to_value(binary,player_basic_data)
    return binary
end
function notify_player_data:get_msgid()
    return msg_notify_player_data
end
req_start_walk=class()
function req_start_walk:ctor(curr_pos, dest_pos)
    self.curr_pos = curr_pos
    self.dest_pos = dest_pos
end
function req_start_walk:encode()
    return
        binary_helper.to_binary(self.curr_pos, "user_define") ..
        binary_helper.to_binary(self.dest_pos, "user_define")
end
function req_start_walk:decode(binary)
    self.curr_pos, binary = binary_helper.to_value(binary,point)
    self.dest_pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function req_start_walk:get_msgid()
    return msg_req_start_walk
end
notify_start_walk=class()
function notify_start_walk:ctor(account, curr_pos, dest_pos)
    self.account = account
    self.curr_pos = curr_pos
    self.dest_pos = dest_pos
end
function notify_start_walk:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.curr_pos, "user_define") ..
        binary_helper.to_binary(self.dest_pos, "user_define")
end
function notify_start_walk:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.curr_pos, binary = binary_helper.to_value(binary,point)
    self.dest_pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function notify_start_walk:get_msgid()
    return msg_notify_start_walk
end
req_stop_walk=class()
function req_stop_walk:ctor(pos)
    self.pos = pos
end
function req_stop_walk:encode()
    return
        binary_helper.to_binary(self.pos, "user_define")
end
function req_stop_walk:decode(binary)
    self.pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function req_stop_walk:get_msgid()
    return msg_req_stop_walk
end
notify_stop_walk=class()
function notify_stop_walk:ctor(account, pos)
    self.account = account
    self.pos = pos
end
function notify_stop_walk:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.pos, "user_define")
end
function notify_stop_walk:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function notify_stop_walk:get_msgid()
    return msg_notify_stop_walk
end
req_sync_walk_type=class()
function req_sync_walk_type:ctor(type)
    self.type = type
end
function req_sync_walk_type:encode()
    return
        binary_helper.to_binary(self.type, "user_define")
end
function req_sync_walk_type:decode(binary)
    self.type, binary = binary_helper.to_value(binary,walk_type)
    return binary
end
function req_sync_walk_type:get_msgid()
    return msg_req_sync_walk_type
end
notify_sync_walk_type=class()
function notify_sync_walk_type:ctor(account, type)
    self.account = account
    self.type = type
end
function notify_sync_walk_type:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.type, "user_define")
end
function notify_sync_walk_type:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.type, binary = binary_helper.to_value(binary,walk_type)
    return binary
end
function notify_sync_walk_type:get_msgid()
    return msg_notify_sync_walk_type
end
req_sync_position=class()
function req_sync_position:ctor(pos)
    self.pos = pos
end
function req_sync_position:encode()
    return
        binary_helper.to_binary(self.pos, "user_define")
end
function req_sync_position:decode(binary)
    self.pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function req_sync_position:get_msgid()
    return msg_req_sync_position
end
req_walk_for_use_furniture=class()
function req_walk_for_use_furniture:ctor(curr_pos, dest_pos, instance_id, function_id, furni_temp_id, status)
    self.curr_pos = curr_pos
    self.dest_pos = dest_pos
    self.instance_id = instance_id
    self.function_id = function_id
    self.furni_temp_id = furni_temp_id
    self.status = status
end
function req_walk_for_use_furniture:encode()
    return
        binary_helper.to_binary(self.curr_pos, "user_define") ..
        binary_helper.to_binary(self.dest_pos, "user_define") ..
        binary_helper.to_binary(self.instance_id, "uint64") ..
        binary_helper.to_binary(self.function_id, "int") ..
        binary_helper.to_binary(self.furni_temp_id, "int") ..
        binary_helper.to_binary(self.status, "int")
end
function req_walk_for_use_furniture:decode(binary)
    self.curr_pos, binary = binary_helper.to_value(binary,point)
    self.dest_pos, binary = binary_helper.to_value(binary,point)
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    self.function_id, binary = binary_helper.to_value(binary, "int")
    self.furni_temp_id, binary = binary_helper.to_value(binary, "int")
    self.status, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_walk_for_use_furniture:get_msgid()
    return msg_req_walk_for_use_furniture
end
player_basic_information=class()
function player_basic_information:ctor(account, imageurl, nickname, is_yellow_vip, is_yellow_year_vip, yellow_vip_level)
    self.account = account
    self.imageurl = imageurl
    self.nickname = nickname
    self.is_yellow_vip = is_yellow_vip
    self.is_yellow_year_vip = is_yellow_year_vip
    self.yellow_vip_level = yellow_vip_level
end
function player_basic_information:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.imageurl, "string") ..
        binary_helper.to_binary(self.nickname, "string") ..
        binary_helper.to_binary(self.is_yellow_vip, "int") ..
        binary_helper.to_binary(self.is_yellow_year_vip, "int") ..
        binary_helper.to_binary(self.yellow_vip_level, "int")
end
function player_basic_information:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.imageurl, binary = binary_helper.to_value(binary, "string")
    self.nickname, binary = binary_helper.to_value(binary, "string")
    self.is_yellow_vip, binary = binary_helper.to_value(binary, "int")
    self.is_yellow_year_vip, binary = binary_helper.to_value(binary, "int")
    self.yellow_vip_level, binary = binary_helper.to_value(binary, "int")
    return binary
end
function player_basic_information:get_msgid()
    return msg_player_basic_information
end
friend_item=class()
function friend_item:ctor(account, house_id, house_level, intimate, crop_event)
    self.account = account
    self.house_id = house_id
    self.house_level = house_level
    self.intimate = intimate
    self.crop_event = crop_event
end
function friend_item:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.house_level, "int") ..
        binary_helper.to_binary(self.intimate, "int") ..
        binary_helper.to_binary(self.crop_event, "int")
end
function friend_item:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.house_level, binary = binary_helper.to_value(binary, "int")
    self.intimate, binary = binary_helper.to_value(binary, "int")
    self.crop_event, binary = binary_helper.to_value(binary, "int")
    return binary
end
function friend_item:get_msgid()
    return msg_friend_item
end
req_friend_list=class()
function req_friend_list:ctor()

end
function req_friend_list:encode()
    return

end
function req_friend_list:decode(binary)

    return binary
end
function req_friend_list:get_msgid()
    return msg_req_friend_list
end
notify_player_friend_list=class()
function notify_player_friend_list:ctor(friend_list)
    self.friend_list = friend_list
end
function notify_player_friend_list:encode()
    return
        binary_helper.array_to_binary(self.friend_list, "user_define")
end
function notify_player_friend_list:decode(binary)
    self.friend_list, binary = binary_helper.to_array(binary,friend_item)
    return binary
end
function notify_player_friend_list:get_msgid()
    return msg_notify_player_friend_list
end
req_invite_list=class()
function req_invite_list:ctor()

end
function req_invite_list:encode()
    return

end
function req_invite_list:decode(binary)

    return binary
end
function req_invite_list:get_msgid()
    return msg_req_invite_list
end
notify_invite_list=class()
function notify_invite_list:ctor(friend_list)
    self.friend_list = friend_list
end
function notify_invite_list:encode()
    return
        binary_helper.array_to_binary(self.friend_list, "user_define")
end
function notify_invite_list:decode(binary)
    self.friend_list, binary = binary_helper.to_array(binary,friend_item)
    return binary
end
function notify_invite_list:get_msgid()
    return msg_notify_invite_list
end
req_chat_around=class()
function req_chat_around:ctor(content)
    self.content = content
end
function req_chat_around:encode()
    return
        binary_helper.to_binary(self.content, "string")
end
function req_chat_around:decode(binary)
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_chat_around:get_msgid()
    return msg_req_chat_around
end
notify_chat_around=class()
function notify_chat_around:ctor(account, player_name, content)
    self.account = account
    self.player_name = player_name
    self.content = content
end
function notify_chat_around:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.player_name, "string") ..
        binary_helper.to_binary(self.content, "string")
end
function notify_chat_around:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.player_name, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_chat_around:get_msgid()
    return msg_notify_chat_around
end
req_chat_tell=class()
function req_chat_tell:ctor(target_player, content)
    self.target_player = target_player
    self.content = content
end
function req_chat_tell:encode()
    return
        binary_helper.to_binary(self.target_player, "string") ..
        binary_helper.to_binary(self.content, "string")
end
function req_chat_tell:decode(binary)
    self.target_player, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_chat_tell:get_msgid()
    return msg_req_chat_tell
end
notify_chat_tell=class()
function notify_chat_tell:ctor(speaker, speaker_name, content)
    self.speaker = speaker
    self.speaker_name = speaker_name
    self.content = content
end
function notify_chat_tell:encode()
    return
        binary_helper.to_binary(self.speaker, "string") ..
        binary_helper.to_binary(self.speaker_name, "string") ..
        binary_helper.to_binary(self.content, "string")
end
function notify_chat_tell:decode(binary)
    self.speaker, binary = binary_helper.to_value(binary, "string")
    self.speaker_name, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_chat_tell:get_msgid()
    return msg_notify_chat_tell
end
req_chat_world=class()
function req_chat_world:ctor(content)
    self.content = content
end
function req_chat_world:encode()
    return
        binary_helper.to_binary(self.content, "string")
end
function req_chat_world:decode(binary)
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_chat_world:get_msgid()
    return msg_req_chat_world
end
notify_chat_world=class()
function notify_chat_world:ctor(account, player_name, content)
    self.account = account
    self.player_name = player_name
    self.content = content
end
function notify_chat_world:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.player_name, "string") ..
        binary_helper.to_binary(self.content, "string")
end
function notify_chat_world:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.player_name, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_chat_world:get_msgid()
    return msg_notify_chat_world
end
notify_house_data=class()
function notify_house_data:ctor(data)
    self.data = data
end
function notify_house_data:encode()
    return
        binary_helper.to_binary(self.data, "user_define")
end
function notify_house_data:decode(binary)
    self.data, binary = binary_helper.to_value(binary,house_info)
    return binary
end
function notify_house_data:get_msgid()
    return msg_notify_house_data
end
furniture_place_info=class()
function furniture_place_info:ctor(instance_id, x, z, height, floor, face)
    self.instance_id = instance_id
    self.x = x
    self.z = z
    self.height = height
    self.floor = floor
    self.face = face
end
function furniture_place_info:encode()
    return
        binary_helper.to_binary(self.instance_id, "uint64") ..
        binary_helper.to_binary(self.x, "int") ..
        binary_helper.to_binary(self.z, "int") ..
        binary_helper.to_binary(self.height, "number") ..
        binary_helper.to_binary(self.floor, "int") ..
        binary_helper.to_binary(self.face, "int")
end
function furniture_place_info:decode(binary)
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    self.x, binary = binary_helper.to_value(binary, "int")
    self.z, binary = binary_helper.to_value(binary, "int")
    self.height, binary = binary_helper.to_value(binary, "number")
    self.floor, binary = binary_helper.to_value(binary, "int")
    self.face, binary = binary_helper.to_value(binary, "int")
    return binary
end
function furniture_place_info:get_msgid()
    return msg_furniture_place_info
end
req_change_furnitures=class()
function req_change_furnitures:ctor(recovery_furnitures, placed_furnitures, move_furnitures, buy_goods_list)
    self.recovery_furnitures = recovery_furnitures
    self.placed_furnitures = placed_furnitures
    self.move_furnitures = move_furnitures
    self.buy_goods_list = buy_goods_list
end
function req_change_furnitures:encode()
    return
        binary_helper.array_to_binary(self.recovery_furnitures, "uint64") ..
        binary_helper.array_to_binary(self.placed_furnitures, "user_define") ..
        binary_helper.array_to_binary(self.move_furnitures, "user_define") ..
        binary_helper.array_to_binary(self.buy_goods_list, "user_define")
end
function req_change_furnitures:decode(binary)
    self.recovery_furnitures, binary = binary_helper.to_array(binary, "uint64")
    self.placed_furnitures, binary = binary_helper.to_array(binary,furniture_place_info)
    self.move_furnitures, binary = binary_helper.to_array(binary,furniture_place_info)
    self.buy_goods_list, binary = binary_helper.to_array(binary,furniture_goods_data)
    return binary
end
function req_change_furnitures:get_msgid()
    return msg_req_change_furnitures
end
notify_change_furnitures_fail=class()
function notify_change_furnitures_fail:ctor(error_code, unfind_bag_items)
    self.error_code = error_code
    self.unfind_bag_items = unfind_bag_items
end
function notify_change_furnitures_fail:encode()
    return
        binary_helper.to_binary(self.error_code, "int") ..
        binary_helper.array_to_binary(self.unfind_bag_items, "uint64")
end
function notify_change_furnitures_fail:decode(binary)
    self.error_code, binary = binary_helper.to_value(binary, "int")
    self.unfind_bag_items, binary = binary_helper.to_array(binary, "uint64")
    return binary
end
function notify_change_furnitures_fail:get_msgid()
    return msg_notify_change_furnitures_fail
end
notify_change_furnitures=class()
function notify_change_furnitures:ctor(del_furnitures, add_furnitures, move_furnitures, add_items, del_items, decoration)
    self.del_furnitures = del_furnitures
    self.add_furnitures = add_furnitures
    self.move_furnitures = move_furnitures
    self.add_items = add_items
    self.del_items = del_items
    self.decoration = decoration
end
function notify_change_furnitures:encode()
    return
        binary_helper.array_to_binary(self.del_furnitures, "uint64") ..
        binary_helper.array_to_binary(self.add_furnitures, "user_define") ..
        binary_helper.array_to_binary(self.move_furnitures, "user_define") ..
        binary_helper.array_to_binary(self.add_items, "user_define") ..
        binary_helper.array_to_binary(self.del_items, "uint64") ..
        binary_helper.to_binary(self.decoration, "int")
end
function notify_change_furnitures:decode(binary)
    self.del_furnitures, binary = binary_helper.to_array(binary, "uint64")
    self.add_furnitures, binary = binary_helper.to_array(binary,house_furniture)
    self.move_furnitures, binary = binary_helper.to_array(binary,house_furniture)
    self.add_items, binary = binary_helper.to_array(binary,pack_grid)
    self.del_items, binary = binary_helper.to_array(binary, "uint64")
    self.decoration, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_change_furnitures:get_msgid()
    return msg_notify_change_furnitures
end
req_start_edit_house=class()
function req_start_edit_house:ctor()

end
function req_start_edit_house:encode()
    return

end
function req_start_edit_house:decode(binary)

    return binary
end
function req_start_edit_house:get_msgid()
    return msg_req_start_edit_house
end
notify_start_edit_house=class()
function notify_start_edit_house:ctor(result)
    self.result = result
end
function notify_start_edit_house:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_start_edit_house:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_start_edit_house:get_msgid()
    return msg_notify_start_edit_house
end
req_end_edit_house=class()
function req_end_edit_house:ctor()

end
function req_end_edit_house:encode()
    return

end
function req_end_edit_house:decode(binary)

    return binary
end
function req_end_edit_house:get_msgid()
    return msg_req_end_edit_house
end
notify_end_edit_house=class()
function notify_end_edit_house:ctor()

end
function notify_end_edit_house:encode()
    return

end
function notify_end_edit_house:decode(binary)

    return binary
end
function notify_end_edit_house:get_msgid()
    return msg_notify_end_edit_house
end
req_set_house_welcome_words=class()
function req_set_house_welcome_words:ctor(words)
    self.words = words
end
function req_set_house_welcome_words:encode()
    return
        binary_helper.to_binary(self.words, "string")
end
function req_set_house_welcome_words:decode(binary)
    self.words, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_set_house_welcome_words:get_msgid()
    return msg_req_set_house_welcome_words
end
notify_set_house_welcome_words=class()
function notify_set_house_welcome_words:ctor(result)
    self.result = result
end
function notify_set_house_welcome_words:encode()
    return
        binary_helper.to_binary(self.result, "user_define")
end
function notify_set_house_welcome_words:decode(binary)
    self.result, binary = binary_helper.to_value(binary,set_house_welcome_words_result)
    return binary
end
function notify_set_house_welcome_words:get_msgid()
    return msg_notify_set_house_welcome_words
end
req_set_house_permission=class()
function req_set_house_permission:ctor(house_permission, furniture_permission)
    self.house_permission = house_permission
    self.furniture_permission = furniture_permission
end
function req_set_house_permission:encode()
    return
        binary_helper.to_binary(self.house_permission, "user_define") ..
        binary_helper.to_binary(self.furniture_permission, "user_define")
end
function req_set_house_permission:decode(binary)
    self.house_permission, binary = binary_helper.to_value(binary,house_permission_type)
    self.furniture_permission, binary = binary_helper.to_value(binary,furniture_permission_type)
    return binary
end
function req_set_house_permission:get_msgid()
    return msg_req_set_house_permission
end
notify_set_house_permission=class()
function notify_set_house_permission:ctor(result)
    self.result = result
end
function notify_set_house_permission:encode()
    return
        binary_helper.to_binary(self.result, "user_define")
end
function notify_set_house_permission:decode(binary)
    self.result, binary = binary_helper.to_value(binary,set_house_permission_result)
    return binary
end
function notify_set_house_permission:get_msgid()
    return msg_notify_set_house_permission
end
req_clear_house_log=class()
function req_clear_house_log:ctor()

end
function req_clear_house_log:encode()
    return

end
function req_clear_house_log:decode(binary)

    return binary
end
function req_clear_house_log:get_msgid()
    return msg_req_clear_house_log
end
notify_clear_house_log=class()
function notify_clear_house_log:ctor(result)
    self.result = result
end
function notify_clear_house_log:encode()
    return
        binary_helper.to_binary(self.result, "user_define")
end
function notify_clear_house_log:decode(binary)
    self.result, binary = binary_helper.to_value(binary,clear_house_log_result)
    return binary
end
function notify_clear_house_log:get_msgid()
    return msg_notify_clear_house_log
end
notify_start_use_furniture=class()
function notify_start_use_furniture:ctor(account, position_index, instance_id, function_id, walk_pos)
    self.account = account
    self.position_index = position_index
    self.instance_id = instance_id
    self.function_id = function_id
    self.walk_pos = walk_pos
end
function notify_start_use_furniture:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.position_index, "int") ..
        binary_helper.to_binary(self.instance_id, "uint64") ..
        binary_helper.to_binary(self.function_id, "int") ..
        binary_helper.to_binary(self.walk_pos, "user_define")
end
function notify_start_use_furniture:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.position_index, binary = binary_helper.to_value(binary, "int")
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    self.function_id, binary = binary_helper.to_value(binary, "int")
    self.walk_pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function notify_start_use_furniture:get_msgid()
    return msg_notify_start_use_furniture
end
req_stop_use_furniture=class()
function req_stop_use_furniture:ctor()

end
function req_stop_use_furniture:encode()
    return

end
function req_stop_use_furniture:decode(binary)

    return binary
end
function req_stop_use_furniture:get_msgid()
    return msg_req_stop_use_furniture
end
notify_stop_use_furniture=class()
function notify_stop_use_furniture:ctor(account, position_index, instance_id)
    self.account = account
    self.position_index = position_index
    self.instance_id = instance_id
end
function notify_stop_use_furniture:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.position_index, "int") ..
        binary_helper.to_binary(self.instance_id, "uint64")
end
function notify_stop_use_furniture:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.position_index, binary = binary_helper.to_value(binary, "int")
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_stop_use_furniture:get_msgid()
    return msg_notify_stop_use_furniture
end
notify_change_furniture_status=class()
function notify_change_furniture_status:ctor(account, instance_id, function_id, new_status)
    self.account = account
    self.instance_id = instance_id
    self.function_id = function_id
    self.new_status = new_status
end
function notify_change_furniture_status:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.instance_id, "uint64") ..
        binary_helper.to_binary(self.function_id, "int") ..
        binary_helper.to_binary(self.new_status, "int")
end
function notify_change_furniture_status:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    self.function_id, binary = binary_helper.to_value(binary, "int")
    self.new_status, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_change_furniture_status:get_msgid()
    return msg_notify_change_furniture_status
end
req_swap_item=class()
function req_swap_item:ctor(type, index1, index2)
    self.type = type
    self.index1 = index1
    self.index2 = index2
end
function req_swap_item:encode()
    return
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.index1, "int") ..
        binary_helper.to_binary(self.index2, "int")
end
function req_swap_item:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    self.index1, binary = binary_helper.to_value(binary, "int")
    self.index2, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_swap_item:get_msgid()
    return msg_req_swap_item
end
req_use_item=class()
function req_use_item:ctor(item_inst_id, target_list)
    self.item_inst_id = item_inst_id
    self.target_list = target_list
end
function req_use_item:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64") ..
        binary_helper.array_to_binary(self.target_list, "string")
end
function req_use_item:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.target_list, binary = binary_helper.to_array(binary, "string")
    return binary
end
function req_use_item:get_msgid()
    return msg_req_use_item
end
notify_use_item_result=class()
function notify_use_item_result:ctor(item_inst_id, item_tplt_id, result)
    self.item_inst_id = item_inst_id
    self.item_tplt_id = item_tplt_id
    self.result = result
end
function notify_use_item_result:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64") ..
        binary_helper.to_binary(self.item_tplt_id, "int") ..
        binary_helper.to_binary(self.result, "int")
end
function notify_use_item_result:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.item_tplt_id, binary = binary_helper.to_value(binary, "int")
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_use_item_result:get_msgid()
    return msg_notify_use_item_result
end
req_move_item=class()
function req_move_item:ctor(pack1_type, index1, pack2_type, index2)
    self.pack1_type = pack1_type
    self.index1 = index1
    self.pack2_type = pack2_type
    self.index2 = index2
end
function req_move_item:encode()
    return
        binary_helper.to_binary(self.pack1_type, "int") ..
        binary_helper.to_binary(self.index1, "int") ..
        binary_helper.to_binary(self.pack2_type, "int") ..
        binary_helper.to_binary(self.index2, "int")
end
function req_move_item:decode(binary)
    self.pack1_type, binary = binary_helper.to_value(binary, "int")
    self.index1, binary = binary_helper.to_value(binary, "int")
    self.pack2_type, binary = binary_helper.to_value(binary, "int")
    self.index2, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_move_item:get_msgid()
    return msg_req_move_item
end
req_delete_item=class()
function req_delete_item:ctor(grid_index)
    self.grid_index = grid_index
end
function req_delete_item:encode()
    return
        binary_helper.to_binary(self.grid_index, "int")
end
function req_delete_item:decode(binary)
    self.grid_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_delete_item:get_msgid()
    return msg_req_delete_item
end
req_split_item=class()
function req_split_item:ctor(type, src_gindex, target_gindex, count)
    self.type = type
    self.src_gindex = src_gindex
    self.target_gindex = target_gindex
    self.count = count
end
function req_split_item:encode()
    return
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.src_gindex, "int") ..
        binary_helper.to_binary(self.target_gindex, "int") ..
        binary_helper.to_binary(self.count, "int")
end
function req_split_item:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    self.src_gindex, binary = binary_helper.to_value(binary, "int")
    self.target_gindex, binary = binary_helper.to_value(binary, "int")
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_split_item:get_msgid()
    return msg_req_split_item
end
req_resize_player_pack=class()
function req_resize_player_pack:ctor()

end
function req_resize_player_pack:encode()
    return

end
function req_resize_player_pack:decode(binary)

    return binary
end
function req_resize_player_pack:get_msgid()
    return msg_req_resize_player_pack
end
req_extend_aging_item=class()
function req_extend_aging_item:ctor(item_inst_id)
    self.item_inst_id = item_inst_id
end
function req_extend_aging_item:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64")
end
function req_extend_aging_item:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_extend_aging_item:get_msgid()
    return msg_req_extend_aging_item
end
notify_extend_aging_item=class()
function notify_extend_aging_item:ctor()

end
function notify_extend_aging_item:encode()
    return

end
function notify_extend_aging_item:decode(binary)

    return binary
end
function notify_extend_aging_item:get_msgid()
    return msg_notify_extend_aging_item
end
notify_use_item_by_scene=class()
function notify_use_item_by_scene:ctor(account, item_id, item_inst_id, result)
    self.account = account
    self.item_id = item_id
    self.item_inst_id = item_inst_id
    self.result = result
end
function notify_use_item_by_scene:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.to_binary(self.item_inst_id, "uint64") ..
        binary_helper.to_binary(self.result, "int")
end
function notify_use_item_by_scene:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_use_item_by_scene:get_msgid()
    return msg_notify_use_item_by_scene
end
notify_sys_msg=class()
function notify_sys_msg:ctor(code, params)
    self.code = code
    self.params = params
end
function notify_sys_msg:encode()
    return
        binary_helper.to_binary(self.code, "int") ..
        binary_helper.array_to_binary(self.params, "string")
end
function notify_sys_msg:decode(binary)
    self.code, binary = binary_helper.to_value(binary, "int")
    self.params, binary = binary_helper.to_array(binary, "string")
    return binary
end
function notify_sys_msg:get_msgid()
    return msg_notify_sys_msg
end
notify_sys_broadcast=class()
function notify_sys_broadcast:ctor(id, type, content, play_times, priority, show_seconds, start_time)
    self.id = id
    self.type = type
    self.content = content
    self.play_times = play_times
    self.priority = priority
    self.show_seconds = show_seconds
    self.start_time = start_time
end
function notify_sys_broadcast:encode()
    return
        binary_helper.to_binary(self.id, "uint64") ..
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.content, "string") ..
        binary_helper.to_binary(self.play_times, "int") ..
        binary_helper.to_binary(self.priority, "int") ..
        binary_helper.to_binary(self.show_seconds, "int") ..
        binary_helper.to_binary(self.start_time, "user_define")
end
function notify_sys_broadcast:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "uint64")
    self.type, binary = binary_helper.to_value(binary, "int")
    self.content, binary = binary_helper.to_value(binary, "string")
    self.play_times, binary = binary_helper.to_value(binary, "int")
    self.priority, binary = binary_helper.to_value(binary, "int")
    self.show_seconds, binary = binary_helper.to_value(binary, "int")
    self.start_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_sys_broadcast:get_msgid()
    return msg_notify_sys_broadcast
end
req_fixed_broadcast=class()
function req_fixed_broadcast:ctor(type)
    self.type = type
end
function req_fixed_broadcast:encode()
    return
        binary_helper.to_binary(self.type, "int")
end
function req_fixed_broadcast:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_fixed_broadcast:get_msgid()
    return msg_req_fixed_broadcast
end
notify_del_broadcast=class()
function notify_del_broadcast:ctor(type, id)
    self.type = type
    self.id = id
end
function notify_del_broadcast:encode()
    return
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.id, "uint64")
end
function notify_del_broadcast:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    self.id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_del_broadcast:get_msgid()
    return msg_notify_del_broadcast
end
notify_gm_permission=class()
function notify_gm_permission:ctor(account, enable, money, item)
    self.account = account
    self.enable = enable
    self.money = money
    self.item = item
end
function notify_gm_permission:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.enable, "int") ..
        binary_helper.to_binary(self.money, "int") ..
        binary_helper.to_binary(self.item, "int")
end
function notify_gm_permission:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.enable, binary = binary_helper.to_value(binary, "int")
    self.money, binary = binary_helper.to_value(binary, "int")
    self.item, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_gm_permission:get_msgid()
    return msg_notify_gm_permission
end
req_gm_command=class()
function req_gm_command:ctor(command, params)
    self.command = command
    self.params = params
end
function req_gm_command:encode()
    return
        binary_helper.to_binary(self.command, "string") ..
        binary_helper.array_to_binary(self.params, "string")
end
function req_gm_command:decode(binary)
    self.command, binary = binary_helper.to_value(binary, "string")
    self.params, binary = binary_helper.to_array(binary, "string")
    return binary
end
function req_gm_command:get_msgid()
    return msg_req_gm_command
end
notify_npc_close_dialog=class()
function notify_npc_close_dialog:ctor()

end
function notify_npc_close_dialog:encode()
    return

end
function notify_npc_close_dialog:decode(binary)

    return binary
end
function notify_npc_close_dialog:get_msgid()
    return msg_notify_npc_close_dialog
end
req_npc_command=class()
function req_npc_command:ctor(npc_id, function_name)
    self.npc_id = npc_id
    self.function_name = function_name
end
function req_npc_command:encode()
    return
        binary_helper.to_binary(self.npc_id, "int") ..
        binary_helper.to_binary(self.function_name, "string")
end
function req_npc_command:decode(binary)
    self.npc_id, binary = binary_helper.to_value(binary, "int")
    self.function_name, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_npc_command:get_msgid()
    return msg_req_npc_command
end
button=class()
function button:ctor(name, function_name)
    self.name = name
    self.function_name = function_name
end
function button:encode()
    return
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.function_name, "string")
end
function button:decode(binary)
    self.name, binary = binary_helper.to_value(binary, "string")
    self.function_name, binary = binary_helper.to_value(binary, "string")
    return binary
end
function button:get_msgid()
    return msg_button
end
notify_npc_open_dialog=class()
function notify_npc_open_dialog:ctor(npc_id, talk, button_list)
    self.npc_id = npc_id
    self.talk = talk
    self.button_list = button_list
end
function notify_npc_open_dialog:encode()
    return
        binary_helper.to_binary(self.npc_id, "int") ..
        binary_helper.to_binary(self.talk, "string") ..
        binary_helper.array_to_binary(self.button_list, "user_define")
end
function notify_npc_open_dialog:decode(binary)
    self.npc_id, binary = binary_helper.to_value(binary, "int")
    self.talk, binary = binary_helper.to_value(binary, "string")
    self.button_list, binary = binary_helper.to_array(binary,button)
    return binary
end
function notify_npc_open_dialog:get_msgid()
    return msg_notify_npc_open_dialog
end
req_employ_waiter_data=class()
function req_employ_waiter_data:ctor(waiter_id)
    self.waiter_id = waiter_id
end
function req_employ_waiter_data:encode()
    return
        binary_helper.to_binary(self.waiter_id, "uint64")
end
function req_employ_waiter_data:decode(binary)
    self.waiter_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_employ_waiter_data:get_msgid()
    return msg_req_employ_waiter_data
end
req_up_waiter_data=class()
function req_up_waiter_data:ctor(waiter_id)
    self.waiter_id = waiter_id
end
function req_up_waiter_data:encode()
    return
        binary_helper.to_binary(self.waiter_id, "uint64")
end
function req_up_waiter_data:decode(binary)
    self.waiter_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_up_waiter_data:get_msgid()
    return msg_req_up_waiter_data
end
req_query_waiter_id=class()
function req_query_waiter_id:ctor(account)
    self.account = account
end
function req_query_waiter_id:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_query_waiter_id:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_query_waiter_id:get_msgid()
    return msg_req_query_waiter_id
end
notify_query_waiter_id=class()
function notify_query_waiter_id:ctor(waiter_id)
    self.waiter_id = waiter_id
end
function notify_query_waiter_id:encode()
    return
        binary_helper.to_binary(self.waiter_id, "uint64")
end
function notify_query_waiter_id:decode(binary)
    self.waiter_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_query_waiter_id:get_msgid()
    return msg_notify_query_waiter_id
end
waiter_info=class()
function waiter_info:ctor(waiter_type, waiter_id)
    self.waiter_type = waiter_type
    self.waiter_id = waiter_id
end
function waiter_info:encode()
    return
        binary_helper.to_binary(self.waiter_type, "int") ..
        binary_helper.to_binary(self.waiter_id, "uint64")
end
function waiter_info:decode(binary)
    self.waiter_type, binary = binary_helper.to_value(binary, "int")
    self.waiter_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function waiter_info:get_msgid()
    return msg_waiter_info
end
notify_employ_state=class()
function notify_employ_state:ctor(waiter_id, waiter_up)
    self.waiter_id = waiter_id
    self.waiter_up = waiter_up
end
function notify_employ_state:encode()
    return
        binary_helper.to_binary(self.waiter_id, "uint64") ..
        binary_helper.array_to_binary(self.waiter_up, "user_define")
end
function notify_employ_state:decode(binary)
    self.waiter_id, binary = binary_helper.to_value(binary, "uint64")
    self.waiter_up, binary = binary_helper.to_array(binary,waiter_info)
    return binary
end
function notify_employ_state:get_msgid()
    return msg_notify_employ_state
end
req_player_basic_data=class()
function req_player_basic_data:ctor()

end
function req_player_basic_data:encode()
    return

end
function req_player_basic_data:decode(binary)

    return binary
end
function req_player_basic_data:get_msgid()
    return msg_req_player_basic_data
end
notify_player_basic_data=class()
function notify_player_basic_data:ctor(basic_data)
    self.basic_data = basic_data
end
function notify_player_basic_data:encode()
    return
        binary_helper.to_binary(self.basic_data, "user_define")
end
function notify_player_basic_data:decode(binary)
    self.basic_data, binary = binary_helper.to_value(binary,player_basic_data)
    return binary
end
function notify_player_basic_data:get_msgid()
    return msg_notify_player_basic_data
end
req_start_body_action=class()
function req_start_body_action:ctor(action_status, action_type)
    self.action_status = action_status
    self.action_type = action_type
end
function req_start_body_action:encode()
    return
        binary_helper.to_binary(self.action_status, "string") ..
        binary_helper.to_binary(self.action_type, "string")
end
function req_start_body_action:decode(binary)
    self.action_status, binary = binary_helper.to_value(binary, "string")
    self.action_type, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_start_body_action:get_msgid()
    return msg_req_start_body_action
end
notify_start_body_action=class()
function notify_start_body_action:ctor(account, action_status, action_type)
    self.account = account
    self.action_status = action_status
    self.action_type = action_type
end
function notify_start_body_action:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.action_status, "string") ..
        binary_helper.to_binary(self.action_type, "string")
end
function notify_start_body_action:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.action_status, binary = binary_helper.to_value(binary, "string")
    self.action_type, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_start_body_action:get_msgid()
    return msg_notify_start_body_action
end
req_play_animation=class()
function req_play_animation:ctor(target_account, loop, ani, action)
    self.target_account = target_account
    self.loop = loop
    self.ani = ani
    self.action = action
end
function req_play_animation:encode()
    return
        binary_helper.to_binary(self.target_account, "string") ..
        binary_helper.to_binary(self.loop, "int") ..
        binary_helper.to_binary(self.ani, "string") ..
        binary_helper.to_binary(self.action, "string")
end
function req_play_animation:decode(binary)
    self.target_account, binary = binary_helper.to_value(binary, "string")
    self.loop, binary = binary_helper.to_value(binary, "int")
    self.ani, binary = binary_helper.to_value(binary, "string")
    self.action, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_play_animation:get_msgid()
    return msg_req_play_animation
end
notify_play_animation=class()
function notify_play_animation:ctor(player_account, target_account, loop, ani, action)
    self.player_account = player_account
    self.target_account = target_account
    self.loop = loop
    self.ani = ani
    self.action = action
end
function notify_play_animation:encode()
    return
        binary_helper.to_binary(self.player_account, "string") ..
        binary_helper.to_binary(self.target_account, "string") ..
        binary_helper.to_binary(self.loop, "int") ..
        binary_helper.to_binary(self.ani, "string") ..
        binary_helper.to_binary(self.action, "string")
end
function notify_play_animation:decode(binary)
    self.player_account, binary = binary_helper.to_value(binary, "string")
    self.target_account, binary = binary_helper.to_value(binary, "string")
    self.loop, binary = binary_helper.to_value(binary, "int")
    self.ani, binary = binary_helper.to_value(binary, "string")
    self.action, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_play_animation:get_msgid()
    return msg_notify_play_animation
end
req_end_body_action=class()
function req_end_body_action:ctor()

end
function req_end_body_action:encode()
    return

end
function req_end_body_action:decode(binary)

    return binary
end
function req_end_body_action:get_msgid()
    return msg_req_end_body_action
end
notify_end_body_action=class()
function notify_end_body_action:ctor(account)
    self.account = account
end
function notify_end_body_action:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function notify_end_body_action:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_end_body_action:get_msgid()
    return msg_notify_end_body_action
end
req_sync_body_state=class()
function req_sync_body_state:ctor(body_state)
    self.body_state = body_state
end
function req_sync_body_state:encode()
    return
        binary_helper.to_binary(self.body_state, "int")
end
function req_sync_body_state:decode(binary)
    self.body_state, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_sync_body_state:get_msgid()
    return msg_req_sync_body_state
end
notify_other_body_state=class()
function notify_other_body_state:ctor(other_account, body_state)
    self.other_account = other_account
    self.body_state = body_state
end
function notify_other_body_state:encode()
    return
        binary_helper.to_binary(self.other_account, "string") ..
        binary_helper.to_binary(self.body_state, "int")
end
function notify_other_body_state:decode(binary)
    self.other_account, binary = binary_helper.to_value(binary, "string")
    self.body_state, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_other_body_state:get_msgid()
    return msg_notify_other_body_state
end
req_start_change_looks=class()
function req_start_change_looks:ctor()

end
function req_start_change_looks:encode()
    return

end
function req_start_change_looks:decode(binary)

    return binary
end
function req_start_change_looks:get_msgid()
    return msg_req_start_change_looks
end
notify_start_change_looks=class()
function notify_start_change_looks:ctor(type)
    self.type = type
end
function notify_start_change_looks:encode()
    return
        binary_helper.to_binary(self.type, "int")
end
function notify_start_change_looks:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_start_change_looks:get_msgid()
    return msg_notify_start_change_looks
end
req_cancel_change_looks=class()
function req_cancel_change_looks:ctor()

end
function req_cancel_change_looks:encode()
    return

end
function req_cancel_change_looks:decode(binary)

    return binary
end
function req_cancel_change_looks:get_msgid()
    return msg_req_cancel_change_looks
end
req_end_change_looks=class()
function req_end_change_looks:ctor(new_hair, new_hair_color, new_face, new_skin_color, new_beard)
    self.new_hair = new_hair
    self.new_hair_color = new_hair_color
    self.new_face = new_face
    self.new_skin_color = new_skin_color
    self.new_beard = new_beard
end
function req_end_change_looks:encode()
    return
        binary_helper.to_binary(self.new_hair, "int") ..
        binary_helper.to_binary(self.new_hair_color, "int") ..
        binary_helper.to_binary(self.new_face, "int") ..
        binary_helper.to_binary(self.new_skin_color, "int") ..
        binary_helper.to_binary(self.new_beard, "int")
end
function req_end_change_looks:decode(binary)
    self.new_hair, binary = binary_helper.to_value(binary, "int")
    self.new_hair_color, binary = binary_helper.to_value(binary, "int")
    self.new_face, binary = binary_helper.to_value(binary, "int")
    self.new_skin_color, binary = binary_helper.to_value(binary, "int")
    self.new_beard, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_end_change_looks:get_msgid()
    return msg_req_end_change_looks
end
notify_change_looks=class()
function notify_change_looks:ctor(account, new_hair, new_hair_color, new_face, new_skin_color, new_beard)
    self.account = account
    self.new_hair = new_hair
    self.new_hair_color = new_hair_color
    self.new_face = new_face
    self.new_skin_color = new_skin_color
    self.new_beard = new_beard
end
function notify_change_looks:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.new_hair, "int") ..
        binary_helper.to_binary(self.new_hair_color, "int") ..
        binary_helper.to_binary(self.new_face, "int") ..
        binary_helper.to_binary(self.new_skin_color, "int") ..
        binary_helper.to_binary(self.new_beard, "int")
end
function notify_change_looks:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.new_hair, binary = binary_helper.to_value(binary, "int")
    self.new_hair_color, binary = binary_helper.to_value(binary, "int")
    self.new_face, binary = binary_helper.to_value(binary, "int")
    self.new_skin_color, binary = binary_helper.to_value(binary, "int")
    self.new_beard, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_change_looks:get_msgid()
    return msg_notify_change_looks
end
notify_end_change_looks=class()
function notify_end_change_looks:ctor()

end
function notify_end_change_looks:encode()
    return

end
function notify_end_change_looks:decode(binary)

    return binary
end
function notify_end_change_looks:get_msgid()
    return msg_notify_end_change_looks
end
req_start_change_dress=class()
function req_start_change_dress:ctor()

end
function req_start_change_dress:encode()
    return

end
function req_start_change_dress:decode(binary)

    return binary
end
function req_start_change_dress:get_msgid()
    return msg_req_start_change_dress
end
notify_start_change_dress=class()
function notify_start_change_dress:ctor(owner, lover)
    self.owner = owner
    self.lover = lover
end
function notify_start_change_dress:encode()
    return
        binary_helper.to_binary(self.owner, "user_define") ..
        binary_helper.to_binary(self.lover, "user_define")
end
function notify_start_change_dress:decode(binary)
    self.owner, binary = binary_helper.to_value(binary,player_basic_data)
    self.lover, binary = binary_helper.to_value(binary,player_basic_data)
    return binary
end
function notify_start_change_dress:get_msgid()
    return msg_notify_start_change_dress
end
req_change_dress=class()
function req_change_dress:ctor(type, goods_list, lover_goods_list, item_list, putoff_list)
    self.type = type
    self.goods_list = goods_list
    self.lover_goods_list = lover_goods_list
    self.item_list = item_list
    self.putoff_list = putoff_list
end
function req_change_dress:encode()
    return
        binary_helper.to_binary(self.type, "user_define") ..
        binary_helper.array_to_binary(self.goods_list, "int") ..
        binary_helper.array_to_binary(self.lover_goods_list, "int") ..
        binary_helper.array_to_binary(self.item_list, "user_define") ..
        binary_helper.array_to_binary(self.putoff_list, "uint64")
end
function req_change_dress:decode(binary)
    self.type, binary = binary_helper.to_value(binary,money_type)
    self.goods_list, binary = binary_helper.to_array(binary, "int")
    self.lover_goods_list, binary = binary_helper.to_array(binary, "int")
    self.item_list, binary = binary_helper.to_array(binary,item)
    self.putoff_list, binary = binary_helper.to_array(binary, "uint64")
    return binary
end
function req_change_dress:get_msgid()
    return msg_req_change_dress
end
notify_change_dress=class()
function notify_change_dress:ctor(type, item_list, body)
    self.type = type
    self.item_list = item_list
    self.body = body
end
function notify_change_dress:encode()
    return
        binary_helper.to_binary(self.type, "user_define") ..
        binary_helper.array_to_binary(self.item_list, "user_define") ..
        binary_helper.array_to_binary(self.body, "user_define")
end
function notify_change_dress:decode(binary)
    self.type, binary = binary_helper.to_value(binary,change_dress_type)
    self.item_list, binary = binary_helper.to_array(binary,item)
    self.body, binary = binary_helper.to_array(binary,pack_grid)
    return binary
end
function notify_change_dress:get_msgid()
    return msg_notify_change_dress
end
notify_around_change_dress=class()
function notify_around_change_dress:ctor(account, body)
    self.account = account
    self.body = body
end
function notify_around_change_dress:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.array_to_binary(self.body, "user_define")
end
function notify_around_change_dress:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.body, binary = binary_helper.to_array(binary,pack_grid)
    return binary
end
function notify_around_change_dress:get_msgid()
    return msg_notify_around_change_dress
end
req_invite_someone=class()
function req_invite_someone:ctor(target_list, type)
    self.target_list = target_list
    self.type = type
end
function req_invite_someone:encode()
    return
        binary_helper.array_to_binary(self.target_list, "string") ..
        binary_helper.to_binary(self.type, "int")
end
function req_invite_someone:decode(binary)
    self.target_list, binary = binary_helper.to_array(binary, "string")
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_invite_someone:get_msgid()
    return msg_req_invite_someone
end
notify_invitation=class()
function notify_invitation:ctor(invitor, invitor_name, type)
    self.invitor = invitor
    self.invitor_name = invitor_name
    self.type = type
end
function notify_invitation:encode()
    return
        binary_helper.to_binary(self.invitor, "string") ..
        binary_helper.to_binary(self.invitor_name, "string") ..
        binary_helper.to_binary(self.type, "int")
end
function notify_invitation:decode(binary)
    self.invitor, binary = binary_helper.to_value(binary, "string")
    self.invitor_name, binary = binary_helper.to_value(binary, "string")
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_invitation:get_msgid()
    return msg_notify_invitation
end
req_agree_invitation=class()
function req_agree_invitation:ctor(invitor, type)
    self.invitor = invitor
    self.type = type
end
function req_agree_invitation:encode()
    return
        binary_helper.to_binary(self.invitor, "string") ..
        binary_helper.to_binary(self.type, "int")
end
function req_agree_invitation:decode(binary)
    self.invitor, binary = binary_helper.to_value(binary, "string")
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_agree_invitation:get_msgid()
    return msg_req_agree_invitation
end
goods_atom=class()
function goods_atom:ctor(goods_id, count)
    self.goods_id = goods_id
    self.count = count
end
function goods_atom:encode()
    return
        binary_helper.to_binary(self.goods_id, "int") ..
        binary_helper.to_binary(self.count, "int")
end
function goods_atom:decode(binary)
    self.goods_id, binary = binary_helper.to_value(binary, "int")
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function goods_atom:get_msgid()
    return msg_goods_atom
end
req_buy_sys_shop_goods=class()
function req_buy_sys_shop_goods:ctor(goods_id, count)
    self.goods_id = goods_id
    self.count = count
end
function req_buy_sys_shop_goods:encode()
    return
        binary_helper.to_binary(self.goods_id, "int") ..
        binary_helper.to_binary(self.count, "int")
end
function req_buy_sys_shop_goods:decode(binary)
    self.goods_id, binary = binary_helper.to_value(binary, "int")
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_buy_sys_shop_goods:get_msgid()
    return msg_req_buy_sys_shop_goods
end
notify_buy_sys_shop_goods=class()
function notify_buy_sys_shop_goods:ctor()

end
function notify_buy_sys_shop_goods:encode()
    return

end
function notify_buy_sys_shop_goods:decode(binary)

    return binary
end
function notify_buy_sys_shop_goods:get_msgid()
    return msg_notify_buy_sys_shop_goods
end
req_mutli_buy_sys_shop_goods=class()
function req_mutli_buy_sys_shop_goods:ctor(goods_list)
    self.goods_list = goods_list
end
function req_mutli_buy_sys_shop_goods:encode()
    return
        binary_helper.array_to_binary(self.goods_list, "user_define")
end
function req_mutli_buy_sys_shop_goods:decode(binary)
    self.goods_list, binary = binary_helper.to_array(binary,goods_atom)
    return binary
end
function req_mutli_buy_sys_shop_goods:get_msgid()
    return msg_req_mutli_buy_sys_shop_goods
end
flag_info=class()
function flag_info:ctor(key, value, count)
    self.key = key
    self.value = value
    self.count = count
end
function flag_info:encode()
    return
        binary_helper.to_binary(self.key, "string") ..
        binary_helper.to_binary(self.value, "int") ..
        binary_helper.to_binary(self.count, "int")
end
function flag_info:decode(binary)
    self.key, binary = binary_helper.to_value(binary, "string")
    self.value, binary = binary_helper.to_value(binary, "int")
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function flag_info:get_msgid()
    return msg_flag_info
end
task_info=class()
function task_info:ctor(inst_id, task_id, type, give_date, complete_date, reward_date, info)
    self.inst_id = inst_id
    self.task_id = task_id
    self.type = type
    self.give_date = give_date
    self.complete_date = complete_date
    self.reward_date = reward_date
    self.info = info
end
function task_info:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.task_id, "int") ..
        binary_helper.to_binary(self.type, "user_define") ..
        binary_helper.to_binary(self.give_date, "user_define") ..
        binary_helper.to_binary(self.complete_date, "user_define") ..
        binary_helper.to_binary(self.reward_date, "user_define") ..
        binary_helper.array_to_binary(self.info, "user_define")
end
function task_info:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.task_id, binary = binary_helper.to_value(binary, "int")
    self.type, binary = binary_helper.to_value(binary,task_type)
    self.give_date, binary = binary_helper.to_value(binary,stime)
    self.complete_date, binary = binary_helper.to_value(binary,stime)
    self.reward_date, binary = binary_helper.to_value(binary,stime)
    self.info, binary = binary_helper.to_array(binary,flag_info)
    return binary
end
function task_info:get_msgid()
    return msg_task_info
end
notify_task_flag=class()
function notify_task_flag:ctor(inst_id, info)
    self.inst_id = inst_id
    self.info = info
end
function notify_task_flag:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.array_to_binary(self.info, "user_define")
end
function notify_task_flag:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.info, binary = binary_helper.to_array(binary,flag_info)
    return binary
end
function notify_task_flag:get_msgid()
    return msg_notify_task_flag
end
notify_task_list=class()
function notify_task_list:ctor(tasks)
    self.tasks = tasks
end
function notify_task_list:encode()
    return
        binary_helper.array_to_binary(self.tasks, "user_define")
end
function notify_task_list:decode(binary)
    self.tasks, binary = binary_helper.to_array(binary,task_info)
    return binary
end
function notify_task_list:get_msgid()
    return msg_notify_task_list
end
notify_add_task=class()
function notify_add_task:ctor(tasks)
    self.tasks = tasks
end
function notify_add_task:encode()
    return
        binary_helper.array_to_binary(self.tasks, "user_define")
end
function notify_add_task:decode(binary)
    self.tasks, binary = binary_helper.to_array(binary,task_info)
    return binary
end
function notify_add_task:get_msgid()
    return msg_notify_add_task
end
notify_dec_task=class()
function notify_dec_task:ctor(inst_ids)
    self.inst_ids = inst_ids
end
function notify_dec_task:encode()
    return
        binary_helper.array_to_binary(self.inst_ids, "uint64")
end
function notify_dec_task:decode(binary)
    self.inst_ids, binary = binary_helper.to_array(binary, "uint64")
    return binary
end
function notify_dec_task:get_msgid()
    return msg_notify_dec_task
end
notify_complete_task=class()
function notify_complete_task:ctor(info)
    self.info = info
end
function notify_complete_task:encode()
    return
        binary_helper.to_binary(self.info, "user_define")
end
function notify_complete_task:decode(binary)
    self.info, binary = binary_helper.to_value(binary,task_info)
    return binary
end
function notify_complete_task:get_msgid()
    return msg_notify_complete_task
end
notify_reward_task=class()
function notify_reward_task:ctor(info)
    self.info = info
end
function notify_reward_task:encode()
    return
        binary_helper.to_binary(self.info, "user_define")
end
function notify_reward_task:decode(binary)
    self.info, binary = binary_helper.to_value(binary,task_info)
    return binary
end
function notify_reward_task:get_msgid()
    return msg_notify_reward_task
end
req_get_task_reward=class()
function req_get_task_reward:ctor(inst_id, type)
    self.inst_id = inst_id
    self.type = type
end
function req_get_task_reward:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.type, "user_define")
end
function req_get_task_reward:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.type, binary = binary_helper.to_value(binary,task_type)
    return binary
end
function req_get_task_reward:get_msgid()
    return msg_req_get_task_reward
end
notify_get_task_reward=class()
function notify_get_task_reward:ctor(inst_id, task_id)
    self.inst_id = inst_id
    self.task_id = task_id
end
function notify_get_task_reward:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.task_id, "int")
end
function notify_get_task_reward:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.task_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_get_task_reward:get_msgid()
    return msg_notify_get_task_reward
end
req_change_task=class()
function req_change_task:ctor(inst_id, type)
    self.inst_id = inst_id
    self.type = type
end
function req_change_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.type, "user_define")
end
function req_change_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.type, binary = binary_helper.to_value(binary,task_type)
    return binary
end
function req_change_task:get_msgid()
    return msg_req_change_task
end
notify_change_task=class()
function notify_change_task:ctor(inst_id, info)
    self.inst_id = inst_id
    self.info = info
end
function notify_change_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.info, "user_define")
end
function notify_change_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.info, binary = binary_helper.to_value(binary,task_info)
    return binary
end
function notify_change_task:get_msgid()
    return msg_notify_change_task
end
req_immediate_complete=class()
function req_immediate_complete:ctor(inst_id, type)
    self.inst_id = inst_id
    self.type = type
end
function req_immediate_complete:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.type, "user_define")
end
function req_immediate_complete:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.type, binary = binary_helper.to_value(binary,task_type)
    return binary
end
function req_immediate_complete:get_msgid()
    return msg_req_immediate_complete
end
req_move_camera=class()
function req_move_camera:ctor()

end
function req_move_camera:encode()
    return

end
function req_move_camera:decode(binary)

    return binary
end
function req_move_camera:get_msgid()
    return msg_req_move_camera
end
req_move_player=class()
function req_move_player:ctor()

end
function req_move_player:encode()
    return

end
function req_move_player:decode(binary)

    return binary
end
function req_move_player:get_msgid()
    return msg_req_move_player
end
req_close_windows=class()
function req_close_windows:ctor(type)
    self.type = type
end
function req_close_windows:encode()
    return
        binary_helper.to_binary(self.type, "user_define")
end
function req_close_windows:decode(binary)
    self.type, binary = binary_helper.to_value(binary,close_window_type)
    return binary
end
function req_close_windows:get_msgid()
    return msg_req_close_windows
end
ring_task_atom=class()
function ring_task_atom:ctor(inst_id, ring_count, type, content_id, rule_id, complete_date, due_date, is_view, count)
    self.inst_id = inst_id
    self.ring_count = ring_count
    self.type = type
    self.content_id = content_id
    self.rule_id = rule_id
    self.complete_date = complete_date
    self.due_date = due_date
    self.is_view = is_view
    self.count = count
end
function ring_task_atom:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64") ..
        binary_helper.to_binary(self.ring_count, "int") ..
        binary_helper.to_binary(self.type, "user_define") ..
        binary_helper.to_binary(self.content_id, "int") ..
        binary_helper.to_binary(self.rule_id, "int") ..
        binary_helper.to_binary(self.complete_date, "user_define") ..
        binary_helper.to_binary(self.due_date, "user_define") ..
        binary_helper.to_binary(self.is_view, "user_define") ..
        binary_helper.to_binary(self.count, "int")
end
function ring_task_atom:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    self.ring_count, binary = binary_helper.to_value(binary, "int")
    self.type, binary = binary_helper.to_value(binary,pack_task_type)
    self.content_id, binary = binary_helper.to_value(binary, "int")
    self.rule_id, binary = binary_helper.to_value(binary, "int")
    self.complete_date, binary = binary_helper.to_value(binary,stime)
    self.due_date, binary = binary_helper.to_value(binary,stime)
    self.is_view, binary = binary_helper.to_value(binary,common_bool)
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function ring_task_atom:get_msgid()
    return msg_ring_task_atom
end
notify_add_ring_task=class()
function notify_add_ring_task:ctor(task)
    self.task = task
end
function notify_add_ring_task:encode()
    return
        binary_helper.to_binary(self.task, "user_define")
end
function notify_add_ring_task:decode(binary)
    self.task, binary = binary_helper.to_value(binary,ring_task_atom)
    return binary
end
function notify_add_ring_task:get_msgid()
    return msg_notify_add_ring_task
end
notify_show_ring_task=class()
function notify_show_ring_task:ctor()

end
function notify_show_ring_task:encode()
    return

end
function notify_show_ring_task:decode(binary)

    return binary
end
function notify_show_ring_task:get_msgid()
    return msg_notify_show_ring_task
end
notify_delete_ring_task=class()
function notify_delete_ring_task:ctor(inst_id)
    self.inst_id = inst_id
end
function notify_delete_ring_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64")
end
function notify_delete_ring_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    return binary
end
function notify_delete_ring_task:get_msgid()
    return msg_notify_delete_ring_task
end
req_give_up_ring_task=class()
function req_give_up_ring_task:ctor(inst_id)
    self.inst_id = inst_id
end
function req_give_up_ring_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64")
end
function req_give_up_ring_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    return binary
end
function req_give_up_ring_task:get_msgid()
    return msg_req_give_up_ring_task
end
req_stop_ring_task=class()
function req_stop_ring_task:ctor(inst_id)
    self.inst_id = inst_id
end
function req_stop_ring_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64")
end
function req_stop_ring_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    return binary
end
function req_stop_ring_task:get_msgid()
    return msg_req_stop_ring_task
end
notify_stop_ring_task=class()
function notify_stop_ring_task:ctor(inst_id, due_date)
    self.inst_id = inst_id
    self.due_date = due_date
end
function notify_stop_ring_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64") ..
        binary_helper.to_binary(self.due_date, "user_define")
end
function notify_stop_ring_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    self.due_date, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_stop_ring_task:get_msgid()
    return msg_notify_stop_ring_task
end
req_immediate_complete_ring_task=class()
function req_immediate_complete_ring_task:ctor(inst_id)
    self.inst_id = inst_id
end
function req_immediate_complete_ring_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64")
end
function req_immediate_complete_ring_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    return binary
end
function req_immediate_complete_ring_task:get_msgid()
    return msg_req_immediate_complete_ring_task
end
notify_complete_ring_task=class()
function notify_complete_ring_task:ctor(inst_id, complete_date)
    self.inst_id = inst_id
    self.complete_date = complete_date
end
function notify_complete_ring_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64") ..
        binary_helper.to_binary(self.complete_date, "user_define")
end
function notify_complete_ring_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    self.complete_date, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_complete_ring_task:get_msgid()
    return msg_notify_complete_ring_task
end
req_view_ring_task=class()
function req_view_ring_task:ctor(inst_id)
    self.inst_id = inst_id
end
function req_view_ring_task:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64")
end
function req_view_ring_task:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    return binary
end
function req_view_ring_task:get_msgid()
    return msg_req_view_ring_task
end
notify_view_ring_task=class()
function notify_view_ring_task:ctor(count)
    self.count = count
end
function notify_view_ring_task:encode()
    return
        binary_helper.to_binary(self.count, "int")
end
function notify_view_ring_task:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_view_ring_task:get_msgid()
    return msg_notify_view_ring_task
end
req_ring_task_target=class()
function req_ring_task_target:ctor(inst_id)
    self.inst_id = inst_id
end
function req_ring_task_target:encode()
    return
        binary_helper.to_binary(self.inst_id, "int64")
end
function req_ring_task_target:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "int64")
    return binary
end
function req_ring_task_target:get_msgid()
    return msg_req_ring_task_target
end
notify_ring_task_target=class()
function notify_ring_task_target:ctor(targets)
    self.targets = targets
end
function notify_ring_task_target:encode()
    return
        binary_helper.array_to_binary(self.targets, "int")
end
function notify_ring_task_target:decode(binary)
    self.targets, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_ring_task_target:get_msgid()
    return msg_notify_ring_task_target
end
req_mind_quiz_count=class()
function req_mind_quiz_count:ctor()

end
function req_mind_quiz_count:encode()
    return

end
function req_mind_quiz_count:decode(binary)

    return binary
end
function req_mind_quiz_count:get_msgid()
    return msg_req_mind_quiz_count
end
notify_mind_quiz_count=class()
function notify_mind_quiz_count:ctor(count, love_coin_count)
    self.count = count
    self.love_coin_count = love_coin_count
end
function notify_mind_quiz_count:encode()
    return
        binary_helper.to_binary(self.count, "int") ..
        binary_helper.to_binary(self.love_coin_count, "int")
end
function notify_mind_quiz_count:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    self.love_coin_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_mind_quiz_count:get_msgid()
    return msg_notify_mind_quiz_count
end
req_start_mind_quiz=class()
function req_start_mind_quiz:ctor()

end
function req_start_mind_quiz:encode()
    return

end
function req_start_mind_quiz:decode(binary)

    return binary
end
function req_start_mind_quiz:get_msgid()
    return msg_req_start_mind_quiz
end
notify_start_mind_quiz=class()
function notify_start_mind_quiz:ctor(result)
    self.result = result
end
function notify_start_mind_quiz:encode()
    return
        binary_helper.to_binary(self.result, "user_define")
end
function notify_start_mind_quiz:decode(binary)
    self.result, binary = binary_helper.to_value(binary,common_bool)
    return binary
end
function notify_start_mind_quiz:get_msgid()
    return msg_notify_start_mind_quiz
end
req_mind_quiz_reward=class()
function req_mind_quiz_reward:ctor(level)
    self.level = level
end
function req_mind_quiz_reward:encode()
    return
        binary_helper.to_binary(self.level, "int")
end
function req_mind_quiz_reward:decode(binary)
    self.level, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_mind_quiz_reward:get_msgid()
    return msg_req_mind_quiz_reward
end
notify_mind_quiz_reward=class()
function notify_mind_quiz_reward:ctor()

end
function notify_mind_quiz_reward:encode()
    return

end
function notify_mind_quiz_reward:decode(binary)

    return binary
end
function notify_mind_quiz_reward:get_msgid()
    return msg_notify_mind_quiz_reward
end
req_recharge_love_coin=class()
function req_recharge_love_coin:ctor(id)
    self.id = id
end
function req_recharge_love_coin:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_recharge_love_coin:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_recharge_love_coin:get_msgid()
    return msg_req_recharge_love_coin
end
notify_recharge_love_coin=class()
function notify_recharge_love_coin:ctor(love_coin)
    self.love_coin = love_coin
end
function notify_recharge_love_coin:encode()
    return
        binary_helper.to_binary(self.love_coin, "int")
end
function notify_recharge_love_coin:decode(binary)
    self.love_coin, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_recharge_love_coin:get_msgid()
    return msg_notify_recharge_love_coin
end
notify_init_love_coin=class()
function notify_init_love_coin:ctor(love_coin)
    self.love_coin = love_coin
end
function notify_init_love_coin:encode()
    return
        binary_helper.to_binary(self.love_coin, "int")
end
function notify_init_love_coin:decode(binary)
    self.love_coin, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_init_love_coin:get_msgid()
    return msg_notify_init_love_coin
end
notify_love_coin=class()
function notify_love_coin:ctor(love_coin)
    self.love_coin = love_coin
end
function notify_love_coin:encode()
    return
        binary_helper.to_binary(self.love_coin, "int")
end
function notify_love_coin:decode(binary)
    self.love_coin, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_love_coin:get_msgid()
    return msg_notify_love_coin
end
notify_open_recharge_ui=class()
function notify_open_recharge_ui:ctor()

end
function notify_open_recharge_ui:encode()
    return

end
function notify_open_recharge_ui:decode(binary)

    return binary
end
function notify_open_recharge_ui:get_msgid()
    return msg_notify_open_recharge_ui
end
notify_open_yy_recharge_ui=class()
function notify_open_yy_recharge_ui:ctor()

end
function notify_open_yy_recharge_ui:encode()
    return

end
function notify_open_yy_recharge_ui:decode(binary)

    return binary
end
function notify_open_yy_recharge_ui:get_msgid()
    return msg_notify_open_yy_recharge_ui
end
req_open_ui=class()
function req_open_ui:ctor(type)
    self.type = type
end
function req_open_ui:encode()
    return
        binary_helper.to_binary(self.type, "int")
end
function req_open_ui:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_open_ui:get_msgid()
    return msg_req_open_ui
end
notify_open_ui=class()
function notify_open_ui:ctor(type)
    self.type = type
end
function notify_open_ui:encode()
    return
        binary_helper.to_binary(self.type, "int")
end
function notify_open_ui:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_open_ui:get_msgid()
    return msg_notify_open_ui
end
req_sys_time=class()
function req_sys_time:ctor()

end
function req_sys_time:encode()
    return

end
function req_sys_time:decode(binary)

    return binary
end
function req_sys_time:get_msgid()
    return msg_req_sys_time
end
notify_sys_time=class()
function notify_sys_time:ctor(sys_time)
    self.sys_time = sys_time
end
function notify_sys_time:encode()
    return
        binary_helper.to_binary(self.sys_time, "user_define")
end
function notify_sys_time:decode(binary)
    self.sys_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_sys_time:get_msgid()
    return msg_notify_sys_time
end
notify_wallow_time=class()
function notify_wallow_time:ctor(wallow_seconds)
    self.wallow_seconds = wallow_seconds
end
function notify_wallow_time:encode()
    return
        binary_helper.to_binary(self.wallow_seconds, "int")
end
function notify_wallow_time:decode(binary)
    self.wallow_seconds, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_wallow_time:get_msgid()
    return msg_notify_wallow_time
end
notify_player_health_status=class()
function notify_player_health_status:ctor(status)
    self.status = status
end
function notify_player_health_status:encode()
    return
        binary_helper.to_binary(self.status, "user_define")
end
function notify_player_health_status:decode(binary)
    self.status, binary = binary_helper.to_value(binary,disease_type)
    return binary
end
function notify_player_health_status:get_msgid()
    return msg_notify_player_health_status
end
notify_disease_special_event=class()
function notify_disease_special_event:ctor(special_event_id)
    self.special_event_id = special_event_id
end
function notify_disease_special_event:encode()
    return
        binary_helper.to_binary(self.special_event_id, "int")
end
function notify_disease_special_event:decode(binary)
    self.special_event_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_disease_special_event:get_msgid()
    return msg_notify_disease_special_event
end
notify_show_picture=class()
function notify_show_picture:ctor(id)
    self.id = id
end
function notify_show_picture:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function notify_show_picture:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_show_picture:get_msgid()
    return msg_notify_show_picture
end
req_is_active_game=class()
function req_is_active_game:ctor(type)
    self.type = type
end
function req_is_active_game:encode()
    return
        binary_helper.to_binary(self.type, "int")
end
function req_is_active_game:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_is_active_game:get_msgid()
    return msg_req_is_active_game
end
notify_active_game_result=class()
function notify_active_game_result:ctor(result)
    self.result = result
end
function notify_active_game_result:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_active_game_result:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_active_game_result:get_msgid()
    return msg_notify_active_game_result
end
req_create_party=class()
function req_create_party:ctor(house_id, house_name, player_name, type, title, description, cost_items, food_ids)
    self.house_id = house_id
    self.house_name = house_name
    self.player_name = player_name
    self.type = type
    self.title = title
    self.description = description
    self.cost_items = cost_items
    self.food_ids = food_ids
end
function req_create_party:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.house_name, "string") ..
        binary_helper.to_binary(self.player_name, "string") ..
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.title, "string") ..
        binary_helper.to_binary(self.description, "string") ..
        binary_helper.array_to_binary(self.cost_items, "int") ..
        binary_helper.array_to_binary(self.food_ids, "int")
end
function req_create_party:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.house_name, binary = binary_helper.to_value(binary, "string")
    self.player_name, binary = binary_helper.to_value(binary, "string")
    self.type, binary = binary_helper.to_value(binary, "int")
    self.title, binary = binary_helper.to_value(binary, "string")
    self.description, binary = binary_helper.to_value(binary, "string")
    self.cost_items, binary = binary_helper.to_array(binary, "int")
    self.food_ids, binary = binary_helper.to_array(binary, "int")
    return binary
end
function req_create_party:get_msgid()
    return msg_req_create_party
end
notify_create_party_result=class()
function notify_create_party_result:ctor(result)
    self.result = result
end
function notify_create_party_result:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_create_party_result:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_create_party_result:get_msgid()
    return msg_notify_create_party_result
end
req_edit_party=class()
function req_edit_party:ctor(house_id, type, title, description)
    self.house_id = house_id
    self.type = type
    self.title = title
    self.description = description
end
function req_edit_party:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.title, "string") ..
        binary_helper.to_binary(self.description, "string")
end
function req_edit_party:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.type, binary = binary_helper.to_value(binary, "int")
    self.title, binary = binary_helper.to_value(binary, "string")
    self.description, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_edit_party:get_msgid()
    return msg_req_edit_party
end
notify_edit_party_result=class()
function notify_edit_party_result:ctor(result)
    self.result = result
end
function notify_edit_party_result:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_edit_party_result:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_edit_party_result:get_msgid()
    return msg_notify_edit_party_result
end
req_delete_party=class()
function req_delete_party:ctor(house_id)
    self.house_id = house_id
end
function req_delete_party:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_delete_party:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_delete_party:get_msgid()
    return msg_req_delete_party
end
notify_delete_party_result=class()
function notify_delete_party_result:ctor(result)
    self.result = result
end
function notify_delete_party_result:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_delete_party_result:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_delete_party_result:get_msgid()
    return msg_notify_delete_party_result
end
notify_private_party_need_item=class()
function notify_private_party_need_item:ctor(item_id)
    self.item_id = item_id
end
function notify_private_party_need_item:encode()
    return
        binary_helper.to_binary(self.item_id, "int")
end
function notify_private_party_need_item:decode(binary)
    self.item_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_private_party_need_item:get_msgid()
    return msg_notify_private_party_need_item
end
req_get_party_list=class()
function req_get_party_list:ctor(type, page)
    self.type = type
    self.page = page
end
function req_get_party_list:encode()
    return
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.page, "int")
end
function req_get_party_list:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    self.page, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_get_party_list:get_msgid()
    return msg_req_get_party_list
end
party_data=class()
function party_data:ctor(house_id, house_name, account, player_name, type, title, desc, create_time, freeze_seconds, rest_time, exp, cur_person, max_person)
    self.house_id = house_id
    self.house_name = house_name
    self.account = account
    self.player_name = player_name
    self.type = type
    self.title = title
    self.desc = desc
    self.create_time = create_time
    self.freeze_seconds = freeze_seconds
    self.rest_time = rest_time
    self.exp = exp
    self.cur_person = cur_person
    self.max_person = max_person
end
function party_data:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.house_name, "string") ..
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.player_name, "string") ..
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.title, "string") ..
        binary_helper.to_binary(self.desc, "string") ..
        binary_helper.to_binary(self.create_time, "user_define") ..
        binary_helper.to_binary(self.freeze_seconds, "int") ..
        binary_helper.to_binary(self.rest_time, "int") ..
        binary_helper.to_binary(self.exp, "int") ..
        binary_helper.to_binary(self.cur_person, "int") ..
        binary_helper.to_binary(self.max_person, "int")
end
function party_data:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.house_name, binary = binary_helper.to_value(binary, "string")
    self.account, binary = binary_helper.to_value(binary, "string")
    self.player_name, binary = binary_helper.to_value(binary, "string")
    self.type, binary = binary_helper.to_value(binary, "int")
    self.title, binary = binary_helper.to_value(binary, "string")
    self.desc, binary = binary_helper.to_value(binary, "string")
    self.create_time, binary = binary_helper.to_value(binary,stime)
    self.freeze_seconds, binary = binary_helper.to_value(binary, "int")
    self.rest_time, binary = binary_helper.to_value(binary, "int")
    self.exp, binary = binary_helper.to_value(binary, "int")
    self.cur_person, binary = binary_helper.to_value(binary, "int")
    self.max_person, binary = binary_helper.to_value(binary, "int")
    return binary
end
function party_data:get_msgid()
    return msg_party_data
end
notify_party_list=class()
function notify_party_list:ctor(max_page, partys, hot_partys)
    self.max_page = max_page
    self.partys = partys
    self.hot_partys = hot_partys
end
function notify_party_list:encode()
    return
        binary_helper.to_binary(self.max_page, "int") ..
        binary_helper.array_to_binary(self.partys, "user_define") ..
        binary_helper.array_to_binary(self.hot_partys, "user_define")
end
function notify_party_list:decode(binary)
    self.max_page, binary = binary_helper.to_value(binary, "int")
    self.partys, binary = binary_helper.to_array(binary,party_data)
    self.hot_partys, binary = binary_helper.to_array(binary,party_data)
    return binary
end
function notify_party_list:get_msgid()
    return msg_notify_party_list
end
req_get_my_party_info=class()
function req_get_my_party_info:ctor(house_id)
    self.house_id = house_id
end
function req_get_my_party_info:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_get_my_party_info:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_get_my_party_info:get_msgid()
    return msg_req_get_my_party_info
end
notify_my_party_info=class()
function notify_my_party_info:ctor(data, need_money)
    self.data = data
    self.need_money = need_money
end
function notify_my_party_info:encode()
    return
        binary_helper.to_binary(self.data, "user_define") ..
        binary_helper.to_binary(self.need_money, "int")
end
function notify_my_party_info:decode(binary)
    self.data, binary = binary_helper.to_value(binary,party_data)
    self.need_money, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_my_party_info:get_msgid()
    return msg_notify_my_party_info
end
notify_start_party_exp_timer=class()
function notify_start_party_exp_timer:ctor(seconds, hide_seconds, exp)
    self.seconds = seconds
    self.hide_seconds = hide_seconds
    self.exp = exp
end
function notify_start_party_exp_timer:encode()
    return
        binary_helper.to_binary(self.seconds, "int") ..
        binary_helper.to_binary(self.hide_seconds, "int") ..
        binary_helper.to_binary(self.exp, "int")
end
function notify_start_party_exp_timer:decode(binary)
    self.seconds, binary = binary_helper.to_value(binary, "int")
    self.hide_seconds, binary = binary_helper.to_value(binary, "int")
    self.exp, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_start_party_exp_timer:get_msgid()
    return msg_notify_start_party_exp_timer
end
notify_stop_party_exp_timer=class()
function notify_stop_party_exp_timer:ctor()

end
function notify_stop_party_exp_timer:encode()
    return

end
function notify_stop_party_exp_timer:decode(binary)

    return binary
end
function notify_stop_party_exp_timer:get_msgid()
    return msg_notify_stop_party_exp_timer
end
req_add_party_score=class()
function req_add_party_score:ctor()

end
function req_add_party_score:encode()
    return

end
function req_add_party_score:decode(binary)

    return binary
end
function req_add_party_score:get_msgid()
    return msg_req_add_party_score
end
notify_party_score=class()
function notify_party_score:ctor(score, has_vote, remain_times)
    self.score = score
    self.has_vote = has_vote
    self.remain_times = remain_times
end
function notify_party_score:encode()
    return
        binary_helper.to_binary(self.score, "int") ..
        binary_helper.to_binary(self.has_vote, "int") ..
        binary_helper.to_binary(self.remain_times, "int")
end
function notify_party_score:decode(binary)
    self.score, binary = binary_helper.to_value(binary, "int")
    self.has_vote, binary = binary_helper.to_value(binary, "int")
    self.remain_times, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_party_score:get_msgid()
    return msg_notify_party_score
end
notify_add_party_score=class()
function notify_add_party_score:ctor(total_score, add_score, guest_account, guest_name, master_account, master_name)
    self.total_score = total_score
    self.add_score = add_score
    self.guest_account = guest_account
    self.guest_name = guest_name
    self.master_account = master_account
    self.master_name = master_name
end
function notify_add_party_score:encode()
    return
        binary_helper.to_binary(self.total_score, "int") ..
        binary_helper.to_binary(self.add_score, "int") ..
        binary_helper.to_binary(self.guest_account, "string") ..
        binary_helper.to_binary(self.guest_name, "string") ..
        binary_helper.to_binary(self.master_account, "string") ..
        binary_helper.to_binary(self.master_name, "string")
end
function notify_add_party_score:decode(binary)
    self.total_score, binary = binary_helper.to_value(binary, "int")
    self.add_score, binary = binary_helper.to_value(binary, "int")
    self.guest_account, binary = binary_helper.to_value(binary, "string")
    self.guest_name, binary = binary_helper.to_value(binary, "string")
    self.master_account, binary = binary_helper.to_value(binary, "string")
    self.master_name, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_add_party_score:get_msgid()
    return msg_notify_add_party_score
end
notify_party_gain=class()
function notify_party_gain:ctor(grade_scores, score, item_id)
    self.grade_scores = grade_scores
    self.score = score
    self.item_id = item_id
end
function notify_party_gain:encode()
    return
        binary_helper.array_to_binary(self.grade_scores, "user_define") ..
        binary_helper.to_binary(self.score, "int") ..
        binary_helper.to_binary(self.item_id, "int")
end
function notify_party_gain:decode(binary)
    self.grade_scores, binary = binary_helper.to_array(binary,pair_int)
    self.score, binary = binary_helper.to_value(binary, "int")
    self.item_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_party_gain:get_msgid()
    return msg_notify_party_gain
end
notify_party_exp_buffs=class()
function notify_party_exp_buffs:ctor(buff_exps, lights, total_add_percent)
    self.buff_exps = buff_exps
    self.lights = lights
    self.total_add_percent = total_add_percent
end
function notify_party_exp_buffs:encode()
    return
        binary_helper.array_to_binary(self.buff_exps, "user_define") ..
        binary_helper.array_to_binary(self.lights, "int") ..
        binary_helper.to_binary(self.total_add_percent, "int")
end
function notify_party_exp_buffs:decode(binary)
    self.buff_exps, binary = binary_helper.to_array(binary,pair_int)
    self.lights, binary = binary_helper.to_array(binary, "int")
    self.total_add_percent, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_party_exp_buffs:get_msgid()
    return msg_notify_party_exp_buffs
end
notify_party_items=class()
function notify_party_items:ctor(items)
    self.items = items
end
function notify_party_items:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define")
end
function notify_party_items:decode(binary)
    self.items, binary = binary_helper.to_array(binary,pack_grid)
    return binary
end
function notify_party_items:get_msgid()
    return msg_notify_party_items
end
notify_update_party_items=class()
function notify_update_party_items:ctor(items)
    self.items = items
end
function notify_update_party_items:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define")
end
function notify_update_party_items:decode(binary)
    self.items, binary = binary_helper.to_array(binary,pack_grid)
    return binary
end
function notify_update_party_items:get_msgid()
    return msg_notify_update_party_items
end
notify_party_stop=class()
function notify_party_stop:ctor()

end
function notify_party_stop:encode()
    return

end
function notify_party_stop:decode(binary)

    return binary
end
function notify_party_stop:get_msgid()
    return msg_notify_party_stop
end
req_party_food_eat=class()
function req_party_food_eat:ctor(food_id)
    self.food_id = food_id
end
function req_party_food_eat:encode()
    return
        binary_helper.to_binary(self.food_id, "uint64")
end
function req_party_food_eat:decode(binary)
    self.food_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_party_food_eat:get_msgid()
    return msg_req_party_food_eat
end
notify_party_food_eat_count=class()
function notify_party_food_eat_count:ctor(count)
    self.count = count
end
function notify_party_food_eat_count:encode()
    return
        binary_helper.to_binary(self.count, "int")
end
function notify_party_food_eat_count:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_party_food_eat_count:get_msgid()
    return msg_notify_party_food_eat_count
end
notify_party_food_ids=class()
function notify_party_food_ids:ctor(food_ids)
    self.food_ids = food_ids
end
function notify_party_food_ids:encode()
    return
        binary_helper.array_to_binary(self.food_ids, "int")
end
function notify_party_food_ids:decode(binary)
    self.food_ids, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_party_food_ids:get_msgid()
    return msg_notify_party_food_ids
end
req_equip_off=class()
function req_equip_off:ctor(item_inst_id)
    self.item_inst_id = item_inst_id
end
function req_equip_off:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64")
end
function req_equip_off:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_equip_off:get_msgid()
    return msg_req_equip_off
end
notify_equip_off=class()
function notify_equip_off:ctor(account, equip_pos)
    self.account = account
    self.equip_pos = equip_pos
end
function notify_equip_off:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.equip_pos, "int")
end
function notify_equip_off:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.equip_pos, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_equip_off:get_msgid()
    return msg_notify_equip_off
end
req_equip_on=class()
function req_equip_on:ctor(item_inst_id)
    self.item_inst_id = item_inst_id
end
function req_equip_on:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64")
end
function req_equip_on:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_equip_on:get_msgid()
    return msg_req_equip_on
end
notify_equip_on=class()
function notify_equip_on:ctor(account, equip_pos, item_grid)
    self.account = account
    self.equip_pos = equip_pos
    self.item_grid = item_grid
end
function notify_equip_on:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.equip_pos, "int") ..
        binary_helper.to_binary(self.item_grid, "user_define")
end
function notify_equip_on:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.equip_pos, binary = binary_helper.to_value(binary, "int")
    self.item_grid, binary = binary_helper.to_value(binary,pack_grid)
    return binary
end
function notify_equip_on:get_msgid()
    return msg_notify_equip_on
end
notify_lover_package=class()
function notify_lover_package:ctor(grid_vec)
    self.grid_vec = grid_vec
end
function notify_lover_package:encode()
    return
        binary_helper.array_to_binary(self.grid_vec, "user_define")
end
function notify_lover_package:decode(binary)
    self.grid_vec, binary = binary_helper.to_array(binary,pack_grid)
    return binary
end
function notify_lover_package:get_msgid()
    return msg_notify_lover_package
end
notify_lover_diamond=class()
function notify_lover_diamond:ctor(amount)
    self.amount = amount
end
function notify_lover_diamond:encode()
    return
        binary_helper.to_binary(self.amount, "int")
end
function notify_lover_diamond:decode(binary)
    self.amount, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_lover_diamond:get_msgid()
    return msg_notify_lover_diamond
end
req_delete_lover_item=class()
function req_delete_lover_item:ctor(item_inst_ids)
    self.item_inst_ids = item_inst_ids
end
function req_delete_lover_item:encode()
    return
        binary_helper.array_to_binary(self.item_inst_ids, "uint64")
end
function req_delete_lover_item:decode(binary)
    self.item_inst_ids, binary = binary_helper.to_array(binary, "uint64")
    return binary
end
function req_delete_lover_item:get_msgid()
    return msg_req_delete_lover_item
end
notify_add_lover_items=class()
function notify_add_lover_items:ctor(items)
    self.items = items
end
function notify_add_lover_items:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define")
end
function notify_add_lover_items:decode(binary)
    self.items, binary = binary_helper.to_array(binary,pack_grid)
    return binary
end
function notify_add_lover_items:get_msgid()
    return msg_notify_add_lover_items
end
pair_item_count=class()
function pair_item_count:ctor(item_inst_id, count)
    self.item_inst_id = item_inst_id
    self.count = count
end
function pair_item_count:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64") ..
        binary_helper.to_binary(self.count, "int")
end
function pair_item_count:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function pair_item_count:get_msgid()
    return msg_pair_item_count
end
notify_update_items_count=class()
function notify_update_items_count:ctor(items)
    self.items = items
end
function notify_update_items_count:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define")
end
function notify_update_items_count:decode(binary)
    self.items, binary = binary_helper.to_array(binary,pair_item_count)
    return binary
end
function notify_update_items_count:get_msgid()
    return msg_notify_update_items_count
end
req_lock_lover_item=class()
function req_lock_lover_item:ctor(item_inst_id)
    self.item_inst_id = item_inst_id
end
function req_lock_lover_item:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64")
end
function req_lock_lover_item:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_lock_lover_item:get_msgid()
    return msg_req_lock_lover_item
end
req_unlock_lover_item=class()
function req_unlock_lover_item:ctor(item_inst_id)
    self.item_inst_id = item_inst_id
end
function req_unlock_lover_item:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64")
end
function req_unlock_lover_item:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_unlock_lover_item:get_msgid()
    return msg_req_unlock_lover_item
end
notify_lock_lover_item=class()
function notify_lock_lover_item:ctor(item_inst_id)
    self.item_inst_id = item_inst_id
end
function notify_lock_lover_item:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64")
end
function notify_lock_lover_item:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_lock_lover_item:get_msgid()
    return msg_notify_lock_lover_item
end
notify_unlock_lover_item=class()
function notify_unlock_lover_item:ctor(item_inst_id)
    self.item_inst_id = item_inst_id
end
function notify_unlock_lover_item:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64")
end
function notify_unlock_lover_item:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_unlock_lover_item:get_msgid()
    return msg_notify_unlock_lover_item
end
req_house_guest_book=class()
function req_house_guest_book:ctor(house_id)
    self.house_id = house_id
end
function req_house_guest_book:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_house_guest_book:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_house_guest_book:get_msgid()
    return msg_req_house_guest_book
end
notify_house_guest_book=class()
function notify_house_guest_book:ctor(account, lover_account, guest_books)
    self.account = account
    self.lover_account = lover_account
    self.guest_books = guest_books
end
function notify_house_guest_book:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.lover_account, "string") ..
        binary_helper.array_to_binary(self.guest_books, "user_define")
end
function notify_house_guest_book:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.lover_account, binary = binary_helper.to_value(binary, "string")
    self.guest_books, binary = binary_helper.to_array(binary,guest_book)
    return binary
end
function notify_house_guest_book:get_msgid()
    return msg_notify_house_guest_book
end
req_house_visit_log_add=class()
function req_house_visit_log_add:ctor(guest, openid, account)
    self.guest = guest
    self.openid = openid
    self.account = account
end
function req_house_visit_log_add:encode()
    return
        binary_helper.to_binary(self.guest, "string") ..
        binary_helper.to_binary(self.openid, "string") ..
        binary_helper.to_binary(self.account, "string")
end
function req_house_visit_log_add:decode(binary)
    self.guest, binary = binary_helper.to_value(binary, "string")
    self.openid, binary = binary_helper.to_value(binary, "string")
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_house_visit_log_add:get_msgid()
    return msg_req_house_visit_log_add
end
notify_house_visit_log_add=class()
function notify_house_visit_log_add:ctor()

end
function notify_house_visit_log_add:encode()
    return

end
function notify_house_visit_log_add:decode(binary)

    return binary
end
function notify_house_visit_log_add:get_msgid()
    return msg_notify_house_visit_log_add
end
req_house_visit_log=class()
function req_house_visit_log:ctor()

end
function req_house_visit_log:encode()
    return

end
function req_house_visit_log:decode(binary)

    return binary
end
function req_house_visit_log:get_msgid()
    return msg_req_house_visit_log
end
notify_house_visit_log=class()
function notify_house_visit_log:ctor(visit_logs)
    self.visit_logs = visit_logs
end
function notify_house_visit_log:encode()
    return
        binary_helper.array_to_binary(self.visit_logs, "user_define")
end
function notify_house_visit_log:decode(binary)
    self.visit_logs, binary = binary_helper.to_array(binary,visit_log)
    return binary
end
function notify_house_visit_log:get_msgid()
    return msg_notify_house_visit_log
end
req_guest_book_delete=class()
function req_guest_book_delete:ctor(account, id)
    self.account = account
    self.id = id
end
function req_guest_book_delete:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.id, "uint64")
end
function req_guest_book_delete:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_guest_book_delete:get_msgid()
    return msg_req_guest_book_delete
end
notify_guest_book_delete=class()
function notify_guest_book_delete:ctor(result, id)
    self.result = result
    self.id = id
end
function notify_guest_book_delete:encode()
    return
        binary_helper.to_binary(self.result, "int") ..
        binary_helper.to_binary(self.id, "uint64")
end
function notify_guest_book_delete:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    self.id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_guest_book_delete:get_msgid()
    return msg_notify_guest_book_delete
end
req_guest_book_add=class()
function req_guest_book_add:ctor(owner, guest, content, opened)
    self.owner = owner
    self.guest = guest
    self.content = content
    self.opened = opened
end
function req_guest_book_add:encode()
    return
        binary_helper.to_binary(self.owner, "string") ..
        binary_helper.to_binary(self.guest, "string") ..
        binary_helper.to_binary(self.content, "string") ..
        binary_helper.to_binary(self.opened, "int")
end
function req_guest_book_add:decode(binary)
    self.owner, binary = binary_helper.to_value(binary, "string")
    self.guest, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    self.opened, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_guest_book_add:get_msgid()
    return msg_req_guest_book_add
end
notify_new_guest_book=class()
function notify_new_guest_book:ctor()

end
function notify_new_guest_book:encode()
    return

end
function notify_new_guest_book:decode(binary)

    return binary
end
function notify_new_guest_book:get_msgid()
    return msg_notify_new_guest_book
end
notify_guest_book_add=class()
function notify_guest_book_add:ctor(result, item)
    self.result = result
    self.item = item
end
function notify_guest_book_add:encode()
    return
        binary_helper.to_binary(self.result, "int") ..
        binary_helper.to_binary(self.item, "user_define")
end
function notify_guest_book_add:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    self.item, binary = binary_helper.to_value(binary,guest_book)
    return binary
end
function notify_guest_book_add:get_msgid()
    return msg_notify_guest_book_add
end
req_guest_book_clear=class()
function req_guest_book_clear:ctor(account)
    self.account = account
end
function req_guest_book_clear:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_guest_book_clear:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_guest_book_clear:get_msgid()
    return msg_req_guest_book_clear
end
notify_guest_book_clear=class()
function notify_guest_book_clear:ctor(result)
    self.result = result
end
function notify_guest_book_clear:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_guest_book_clear:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_guest_book_clear:get_msgid()
    return msg_notify_guest_book_clear
end
req_create_flower=class()
function req_create_flower:ctor(house_id, flower_id)
    self.house_id = house_id
    self.flower_id = flower_id
end
function req_create_flower:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.flower_id, "int")
end
function req_create_flower:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.flower_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_create_flower:get_msgid()
    return msg_req_create_flower
end
req_get_flower=class()
function req_get_flower:ctor(house_id)
    self.house_id = house_id
end
function req_get_flower:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_get_flower:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_get_flower:get_msgid()
    return msg_req_get_flower
end
notify_flower_data=class()
function notify_flower_data:ctor(operate, house_id, id, level, grow, start_time, fruit_time)
    self.operate = operate
    self.house_id = house_id
    self.id = id
    self.level = level
    self.grow = grow
    self.start_time = start_time
    self.fruit_time = fruit_time
end
function notify_flower_data:encode()
    return
        binary_helper.to_binary(self.operate, "int") ..
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.level, "int") ..
        binary_helper.to_binary(self.grow, "int") ..
        binary_helper.to_binary(self.start_time, "user_define") ..
        binary_helper.to_binary(self.fruit_time, "user_define")
end
function notify_flower_data:decode(binary)
    self.operate, binary = binary_helper.to_value(binary, "int")
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.id, binary = binary_helper.to_value(binary, "int")
    self.level, binary = binary_helper.to_value(binary, "int")
    self.grow, binary = binary_helper.to_value(binary, "int")
    self.start_time, binary = binary_helper.to_value(binary,stime)
    self.fruit_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_flower_data:get_msgid()
    return msg_notify_flower_data
end
req_can_water_flower=class()
function req_can_water_flower:ctor(my_house_id, house_id)
    self.my_house_id = my_house_id
    self.house_id = house_id
end
function req_can_water_flower:encode()
    return
        binary_helper.to_binary(self.my_house_id, "uint64") ..
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_can_water_flower:decode(binary)
    self.my_house_id, binary = binary_helper.to_value(binary, "uint64")
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_can_water_flower:get_msgid()
    return msg_req_can_water_flower
end
notify_can_water_flower=class()
function notify_can_water_flower:ctor(result)
    self.result = result
end
function notify_can_water_flower:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_can_water_flower:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_can_water_flower:get_msgid()
    return msg_notify_can_water_flower
end
req_water_flower=class()
function req_water_flower:ctor(my_house_id, name, house_id)
    self.my_house_id = my_house_id
    self.name = name
    self.house_id = house_id
end
function req_water_flower:encode()
    return
        binary_helper.to_binary(self.my_house_id, "uint64") ..
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_water_flower:decode(binary)
    self.my_house_id, binary = binary_helper.to_value(binary, "uint64")
    self.name, binary = binary_helper.to_value(binary, "string")
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_water_flower:get_msgid()
    return msg_req_water_flower
end
req_fertilize_flower=class()
function req_fertilize_flower:ctor(my_house_id, name, house_id)
    self.my_house_id = my_house_id
    self.name = name
    self.house_id = house_id
end
function req_fertilize_flower:encode()
    return
        binary_helper.to_binary(self.my_house_id, "uint64") ..
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_fertilize_flower:decode(binary)
    self.my_house_id, binary = binary_helper.to_value(binary, "uint64")
    self.name, binary = binary_helper.to_value(binary, "string")
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_fertilize_flower:get_msgid()
    return msg_req_fertilize_flower
end
req_pick_fruit=class()
function req_pick_fruit:ctor(house_id)
    self.house_id = house_id
end
function req_pick_fruit:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_pick_fruit:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_pick_fruit:get_msgid()
    return msg_req_pick_fruit
end
req_change_flower=class()
function req_change_flower:ctor(house_id, flower_id)
    self.house_id = house_id
    self.flower_id = flower_id
end
function req_change_flower:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.flower_id, "int")
end
function req_change_flower:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.flower_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_change_flower:get_msgid()
    return msg_req_change_flower
end
flower_log=class()
function flower_log:ctor(name, op, time, grow)
    self.name = name
    self.op = op
    self.time = time
    self.grow = grow
end
function flower_log:encode()
    return
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.op, "int") ..
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.grow, "int")
end
function flower_log:decode(binary)
    self.name, binary = binary_helper.to_value(binary, "string")
    self.op, binary = binary_helper.to_value(binary, "int")
    self.time, binary = binary_helper.to_value(binary,stime)
    self.grow, binary = binary_helper.to_value(binary, "int")
    return binary
end
function flower_log:get_msgid()
    return msg_flower_log
end
req_flower_log=class()
function req_flower_log:ctor(house_id)
    self.house_id = house_id
end
function req_flower_log:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_flower_log:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_flower_log:get_msgid()
    return msg_req_flower_log
end
notify_flower_log=class()
function notify_flower_log:ctor(logs)
    self.logs = logs
end
function notify_flower_log:encode()
    return
        binary_helper.array_to_binary(self.logs, "user_define")
end
function notify_flower_log:decode(binary)
    self.logs, binary = binary_helper.to_array(binary,flower_log)
    return binary
end
function notify_flower_log:get_msgid()
    return msg_notify_flower_log
end
req_ask_today_water_flower=class()
function req_ask_today_water_flower:ctor(owner_house_id)
    self.owner_house_id = owner_house_id
end
function req_ask_today_water_flower:encode()
    return
        binary_helper.to_binary(self.owner_house_id, "uint64")
end
function req_ask_today_water_flower:decode(binary)
    self.owner_house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_ask_today_water_flower:get_msgid()
    return msg_req_ask_today_water_flower
end
notify_today_water_flower=class()
function notify_today_water_flower:ctor(result)
    self.result = result
end
function notify_today_water_flower:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_today_water_flower:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_today_water_flower:get_msgid()
    return msg_notify_today_water_flower
end
check_in=class()
function check_in:ctor(id, account, content, opened, create_date)
    self.id = id
    self.account = account
    self.content = content
    self.opened = opened
    self.create_date = create_date
end
function check_in:encode()
    return
        binary_helper.to_binary(self.id, "string") ..
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.content, "string") ..
        binary_helper.to_binary(self.opened, "int") ..
        binary_helper.to_binary(self.create_date, "user_define")
end
function check_in:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "string")
    self.account, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    self.opened, binary = binary_helper.to_value(binary, "int")
    self.create_date, binary = binary_helper.to_value(binary,stime)
    return binary
end
function check_in:get_msgid()
    return msg_check_in
end
req_checkin_add=class()
function req_checkin_add:ctor(account, content, opened)
    self.account = account
    self.content = content
    self.opened = opened
end
function req_checkin_add:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.content, "string") ..
        binary_helper.to_binary(self.opened, "int")
end
function req_checkin_add:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    self.opened, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_checkin_add:get_msgid()
    return msg_req_checkin_add
end
notify_checkin_add=class()
function notify_checkin_add:ctor(item)
    self.item = item
end
function notify_checkin_add:encode()
    return
        binary_helper.to_binary(self.item, "user_define")
end
function notify_checkin_add:decode(binary)
    self.item, binary = binary_helper.to_value(binary,check_in)
    return binary
end
function notify_checkin_add:get_msgid()
    return msg_notify_checkin_add
end
notify_new_checkin=class()
function notify_new_checkin:ctor()

end
function notify_new_checkin:encode()
    return

end
function notify_new_checkin:decode(binary)

    return binary
end
function notify_new_checkin:get_msgid()
    return msg_notify_new_checkin
end
req_last_checkins=class()
function req_last_checkins:ctor(owner)
    self.owner = owner
end
function req_last_checkins:encode()
    return
        binary_helper.to_binary(self.owner, "string")
end
function req_last_checkins:decode(binary)
    self.owner, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_last_checkins:get_msgid()
    return msg_req_last_checkins
end
notify_last_checkins=class()
function notify_last_checkins:ctor(owner, lover)
    self.owner = owner
    self.lover = lover
end
function notify_last_checkins:encode()
    return
        binary_helper.to_binary(self.owner, "user_define") ..
        binary_helper.to_binary(self.lover, "user_define")
end
function notify_last_checkins:decode(binary)
    self.owner, binary = binary_helper.to_value(binary,check_in)
    self.lover, binary = binary_helper.to_value(binary,check_in)
    return binary
end
function notify_last_checkins:get_msgid()
    return msg_notify_last_checkins
end
req_checkin_list=class()
function req_checkin_list:ctor(owner, start_id, page_index, page_size)
    self.owner = owner
    self.start_id = start_id
    self.page_index = page_index
    self.page_size = page_size
end
function req_checkin_list:encode()
    return
        binary_helper.to_binary(self.owner, "string") ..
        binary_helper.to_binary(self.start_id, "string") ..
        binary_helper.to_binary(self.page_index, "int") ..
        binary_helper.to_binary(self.page_size, "int")
end
function req_checkin_list:decode(binary)
    self.owner, binary = binary_helper.to_value(binary, "string")
    self.start_id, binary = binary_helper.to_value(binary, "string")
    self.page_index, binary = binary_helper.to_value(binary, "int")
    self.page_size, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_checkin_list:get_msgid()
    return msg_req_checkin_list
end
notify_checkin_list=class()
function notify_checkin_list:ctor(checkins)
    self.checkins = checkins
end
function notify_checkin_list:encode()
    return
        binary_helper.array_to_binary(self.checkins, "user_define")
end
function notify_checkin_list:decode(binary)
    self.checkins, binary = binary_helper.to_array(binary,check_in)
    return binary
end
function notify_checkin_list:get_msgid()
    return msg_notify_checkin_list
end
req_checkin_delete=class()
function req_checkin_delete:ctor(account, id)
    self.account = account
    self.id = id
end
function req_checkin_delete:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.id, "string")
end
function req_checkin_delete:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.id, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_checkin_delete:get_msgid()
    return msg_req_checkin_delete
end
notify_checkin_delete=class()
function notify_checkin_delete:ctor(result, id)
    self.result = result
    self.id = id
end
function notify_checkin_delete:encode()
    return
        binary_helper.to_binary(self.result, "int") ..
        binary_helper.to_binary(self.id, "string")
end
function notify_checkin_delete:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    self.id, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_checkin_delete:get_msgid()
    return msg_notify_checkin_delete
end
req_modify_love_time=class()
function req_modify_love_time:ctor(house_id, love_time)
    self.house_id = house_id
    self.love_time = love_time
end
function req_modify_love_time:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.love_time, "user_define")
end
function req_modify_love_time:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.love_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function req_modify_love_time:get_msgid()
    return msg_req_modify_love_time
end
req_get_love_time=class()
function req_get_love_time:ctor(house_id)
    self.house_id = house_id
end
function req_get_love_time:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_get_love_time:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_get_love_time:get_msgid()
    return msg_req_get_love_time
end
notify_love_time=class()
function notify_love_time:ctor(house_id, love_time)
    self.house_id = house_id
    self.love_time = love_time
end
function notify_love_time:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.love_time, "int")
end
function notify_love_time:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.love_time, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_love_time:get_msgid()
    return msg_notify_love_time
end
commemoration_day=class()
function commemoration_day:ctor(id, show_other, time, content)
    self.id = id
    self.show_other = show_other
    self.time = time
    self.content = content
end
function commemoration_day:encode()
    return
        binary_helper.to_binary(self.id, "uint64") ..
        binary_helper.to_binary(self.show_other, "int") ..
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.content, "string")
end
function commemoration_day:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "uint64")
    self.show_other, binary = binary_helper.to_value(binary, "int")
    self.time, binary = binary_helper.to_value(binary,stime)
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function commemoration_day:get_msgid()
    return msg_commemoration_day
end
req_add_commemoration=class()
function req_add_commemoration:ctor(house_id, time, show_other, content)
    self.house_id = house_id
    self.time = time
    self.show_other = show_other
    self.content = content
end
function req_add_commemoration:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.show_other, "int") ..
        binary_helper.to_binary(self.content, "string")
end
function req_add_commemoration:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.time, binary = binary_helper.to_value(binary,stime)
    self.show_other, binary = binary_helper.to_value(binary, "int")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_add_commemoration:get_msgid()
    return msg_req_add_commemoration
end
req_get_commemoration=class()
function req_get_commemoration:ctor(house_id, my_house_id, page)
    self.house_id = house_id
    self.my_house_id = my_house_id
    self.page = page
end
function req_get_commemoration:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.my_house_id, "uint64") ..
        binary_helper.to_binary(self.page, "int")
end
function req_get_commemoration:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.my_house_id, binary = binary_helper.to_value(binary, "uint64")
    self.page, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_get_commemoration:get_msgid()
    return msg_req_get_commemoration
end
notify_commemoration=class()
function notify_commemoration:ctor(days, total)
    self.days = days
    self.total = total
end
function notify_commemoration:encode()
    return
        binary_helper.array_to_binary(self.days, "user_define") ..
        binary_helper.to_binary(self.total, "int")
end
function notify_commemoration:decode(binary)
    self.days, binary = binary_helper.to_array(binary,commemoration_day)
    self.total, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_commemoration:get_msgid()
    return msg_notify_commemoration
end
req_delete_commemoration=class()
function req_delete_commemoration:ctor(house_id, id)
    self.house_id = house_id
    self.id = id
end
function req_delete_commemoration:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.id, "uint64")
end
function req_delete_commemoration:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_delete_commemoration:get_msgid()
    return msg_req_delete_commemoration
end
req_modify_commemoration=class()
function req_modify_commemoration:ctor(house_id, id, show_other, time, content)
    self.house_id = house_id
    self.id = id
    self.show_other = show_other
    self.time = time
    self.content = content
end
function req_modify_commemoration:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.id, "uint64") ..
        binary_helper.to_binary(self.show_other, "int") ..
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.content, "string")
end
function req_modify_commemoration:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.id, binary = binary_helper.to_value(binary, "uint64")
    self.show_other, binary = binary_helper.to_value(binary, "int")
    self.time, binary = binary_helper.to_value(binary,stime)
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_modify_commemoration:get_msgid()
    return msg_req_modify_commemoration
end
req_platform_info=class()
function req_platform_info:ctor(open_ids, token)
    self.open_ids = open_ids
    self.token = token
end
function req_platform_info:encode()
    return
        binary_helper.array_to_binary(self.open_ids, "string") ..
        binary_helper.to_binary(self.token, "int")
end
function req_platform_info:decode(binary)
    self.open_ids, binary = binary_helper.to_array(binary, "string")
    self.token, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_platform_info:get_msgid()
    return msg_req_platform_info
end
notify_platform_info=class()
function notify_platform_info:ctor(player_informations, token)
    self.player_informations = player_informations
    self.token = token
end
function notify_platform_info:encode()
    return
        binary_helper.array_to_binary(self.player_informations, "user_define") ..
        binary_helper.to_binary(self.token, "int")
end
function notify_platform_info:decode(binary)
    self.player_informations, binary = binary_helper.to_array(binary,player_basic_information)
    self.token, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_platform_info:get_msgid()
    return msg_notify_platform_info
end
req_daily_visit=class()
function req_daily_visit:ctor(account)
    self.account = account
end
function req_daily_visit:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_daily_visit:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_daily_visit:get_msgid()
    return msg_req_daily_visit
end
notify_daily_visit=class()
function notify_daily_visit:ctor(visit_firends)
    self.visit_firends = visit_firends
end
function notify_daily_visit:encode()
    return
        binary_helper.array_to_binary(self.visit_firends, "uint64")
end
function notify_daily_visit:decode(binary)
    self.visit_firends, binary = binary_helper.to_array(binary, "uint64")
    return binary
end
function notify_daily_visit:get_msgid()
    return msg_notify_daily_visit
end
req_player_guide=class()
function req_player_guide:ctor()

end
function req_player_guide:encode()
    return

end
function req_player_guide:decode(binary)

    return binary
end
function req_player_guide:get_msgid()
    return msg_req_player_guide
end
notify_player_guide=class()
function notify_player_guide:ctor(flags)
    self.flags = flags
end
function notify_player_guide:encode()
    return
        binary_helper.array_to_binary(self.flags, "int")
end
function notify_player_guide:decode(binary)
    self.flags, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_player_guide:get_msgid()
    return msg_notify_player_guide
end
req_update_player_guide=class()
function req_update_player_guide:ctor(flags)
    self.flags = flags
end
function req_update_player_guide:encode()
    return
        binary_helper.array_to_binary(self.flags, "int")
end
function req_update_player_guide:decode(binary)
    self.flags, binary = binary_helper.to_array(binary, "int")
    return binary
end
function req_update_player_guide:get_msgid()
    return msg_req_update_player_guide
end
notify_update_player_guide=class()
function notify_update_player_guide:ctor(result)
    self.result = result
end
function notify_update_player_guide:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_update_player_guide:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_update_player_guide:get_msgid()
    return msg_notify_update_player_guide
end
notify_active_holiday_gift=class()
function notify_active_holiday_gift:ctor()

end
function notify_active_holiday_gift:encode()
    return

end
function notify_active_holiday_gift:decode(binary)

    return binary
end
function notify_active_holiday_gift:get_msgid()
    return msg_notify_active_holiday_gift
end
req_get_holiday_gift=class()
function req_get_holiday_gift:ctor()

end
function req_get_holiday_gift:encode()
    return

end
function req_get_holiday_gift:decode(binary)

    return binary
end
function req_get_holiday_gift:get_msgid()
    return msg_req_get_holiday_gift
end
notify_get_holiday_gift_result=class()
function notify_get_holiday_gift_result:ctor(result, item_id, item_count, diamond)
    self.result = result
    self.item_id = item_id
    self.item_count = item_count
    self.diamond = diamond
end
function notify_get_holiday_gift_result:encode()
    return
        binary_helper.to_binary(self.result, "int") ..
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.to_binary(self.item_count, "int") ..
        binary_helper.to_binary(self.diamond, "int")
end
function notify_get_holiday_gift_result:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.item_count, binary = binary_helper.to_value(binary, "int")
    self.diamond, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_get_holiday_gift_result:get_msgid()
    return msg_notify_get_holiday_gift_result
end
lottery_item=class()
function lottery_item:ctor(item_id, item_count)
    self.item_id = item_id
    self.item_count = item_count
end
function lottery_item:encode()
    return
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.to_binary(self.item_count, "int")
end
function lottery_item:decode(binary)
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.item_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function lottery_item:get_msgid()
    return msg_lottery_item
end
notify_use_lottery_item_result=class()
function notify_use_lottery_item_result:ctor(item_inst_id, items, hit_index)
    self.item_inst_id = item_inst_id
    self.items = items
    self.hit_index = hit_index
end
function notify_use_lottery_item_result:encode()
    return
        binary_helper.to_binary(self.item_inst_id, "uint64") ..
        binary_helper.array_to_binary(self.items, "user_define") ..
        binary_helper.to_binary(self.hit_index, "int")
end
function notify_use_lottery_item_result:decode(binary)
    self.item_inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.items, binary = binary_helper.to_array(binary,lottery_item)
    self.hit_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_use_lottery_item_result:get_msgid()
    return msg_notify_use_lottery_item_result
end
notify_heartbeat=class()
function notify_heartbeat:ctor()

end
function notify_heartbeat:encode()
    return

end
function notify_heartbeat:decode(binary)

    return binary
end
function notify_heartbeat:get_msgid()
    return msg_notify_heartbeat
end
notify_player_setting=class()
function notify_player_setting:ctor(setting)
    self.setting = setting
end
function notify_player_setting:encode()
    return
        binary_helper.to_binary(self.setting, "user_define")
end
function notify_player_setting:decode(binary)
    self.setting, binary = binary_helper.to_value(binary,player_setting)
    return binary
end
function notify_player_setting:get_msgid()
    return msg_notify_player_setting
end
req_player_setting=class()
function req_player_setting:ctor(setting)
    self.setting = setting
end
function req_player_setting:encode()
    return
        binary_helper.to_binary(self.setting, "user_define")
end
function req_player_setting:decode(binary)
    self.setting, binary = binary_helper.to_value(binary,setting_info)
    return binary
end
function req_player_setting:get_msgid()
    return msg_req_player_setting
end
req_update_house_name=class()
function req_update_house_name:ctor(name, account)
    self.name = name
    self.account = account
end
function req_update_house_name:encode()
    return
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.account, "string")
end
function req_update_house_name:decode(binary)
    self.name, binary = binary_helper.to_value(binary, "string")
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_update_house_name:get_msgid()
    return msg_req_update_house_name
end
notify_update_house_name=class()
function notify_update_house_name:ctor(result)
    self.result = result
end
function notify_update_house_name:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_update_house_name:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_update_house_name:get_msgid()
    return msg_notify_update_house_name
end
req_mateup=class()
function req_mateup:ctor(boy_number, girl_number)
    self.boy_number = boy_number
    self.girl_number = girl_number
end
function req_mateup:encode()
    return
        binary_helper.to_binary(self.boy_number, "string") ..
        binary_helper.to_binary(self.girl_number, "string")
end
function req_mateup:decode(binary)
    self.boy_number, binary = binary_helper.to_value(binary, "string")
    self.girl_number, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_mateup:get_msgid()
    return msg_req_mateup
end
notify_mateup_list=class()
function notify_mateup_list:ctor(mateup_list)
    self.mateup_list = mateup_list
end
function notify_mateup_list:encode()
    return
        binary_helper.array_to_binary(self.mateup_list, "user_define")
end
function notify_mateup_list:decode(binary)
    self.mateup_list, binary = binary_helper.to_array(binary,player_basic_information)
    return binary
end
function notify_mateup_list:get_msgid()
    return msg_notify_mateup_list
end
notify_mateup_wait=class()
function notify_mateup_wait:ctor()

end
function notify_mateup_wait:encode()
    return

end
function notify_mateup_wait:decode(binary)

    return binary
end
function notify_mateup_wait:get_msgid()
    return msg_notify_mateup_wait
end
notify_mateup_fail=class()
function notify_mateup_fail:ctor(message)
    self.message = message
end
function notify_mateup_fail:encode()
    return
        binary_helper.to_binary(self.message, "string")
end
function notify_mateup_fail:decode(binary)
    self.message, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_mateup_fail:get_msgid()
    return msg_notify_mateup_fail
end
req_mateup_select=class()
function req_mateup_select:ctor(match_account)
    self.match_account = match_account
end
function req_mateup_select:encode()
    return
        binary_helper.to_binary(self.match_account, "string")
end
function req_mateup_select:decode(binary)
    self.match_account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_mateup_select:get_msgid()
    return msg_req_mateup_select
end
notify_mateup_success=class()
function notify_mateup_success:ctor(boy, girl)
    self.boy = boy
    self.girl = girl
end
function notify_mateup_success:encode()
    return
        binary_helper.to_binary(self.boy, "user_define") ..
        binary_helper.to_binary(self.girl, "user_define")
end
function notify_mateup_success:decode(binary)
    self.boy, binary = binary_helper.to_value(binary,player_basic_information)
    self.girl, binary = binary_helper.to_value(binary,player_basic_information)
    return binary
end
function notify_mateup_success:get_msgid()
    return msg_notify_mateup_success
end
req_mateup_number=class()
function req_mateup_number:ctor()

end
function req_mateup_number:encode()
    return

end
function req_mateup_number:decode(binary)

    return binary
end
function req_mateup_number:get_msgid()
    return msg_req_mateup_number
end
notify_mateup_number=class()
function notify_mateup_number:ctor(boy_number, girl_number)
    self.boy_number = boy_number
    self.girl_number = girl_number
end
function notify_mateup_number:encode()
    return
        binary_helper.to_binary(self.boy_number, "string") ..
        binary_helper.to_binary(self.girl_number, "string")
end
function notify_mateup_number:decode(binary)
    self.boy_number, binary = binary_helper.to_value(binary, "string")
    self.girl_number, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_mateup_number:get_msgid()
    return msg_notify_mateup_number
end
notify_house_warming=class()
function notify_house_warming:ctor(title, desc, summary)
    self.title = title
    self.desc = desc
    self.summary = summary
end
function notify_house_warming:encode()
    return
        binary_helper.to_binary(self.title, "string") ..
        binary_helper.to_binary(self.desc, "string") ..
        binary_helper.to_binary(self.summary, "string")
end
function notify_house_warming:decode(binary)
    self.title, binary = binary_helper.to_value(binary, "string")
    self.desc, binary = binary_helper.to_value(binary, "string")
    self.summary, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_house_warming:get_msgid()
    return msg_notify_house_warming
end
client_device_info=class()
function client_device_info:ctor(operate_system, cpu, cpu_count, memory, graphics_card, graphics_card_memory, graphics_card_id, graphics_card_verson, graphics_card_vendor, graphics_card_vendor_id, graphics_card_shader_level, graphics_card_pixel_fillrate, support_shadow, support_render_texture, support_image_effect, device_name, device_unique_identify, device_model, browser)
    self.operate_system = operate_system
    self.cpu = cpu
    self.cpu_count = cpu_count
    self.memory = memory
    self.graphics_card = graphics_card
    self.graphics_card_memory = graphics_card_memory
    self.graphics_card_id = graphics_card_id
    self.graphics_card_verson = graphics_card_verson
    self.graphics_card_vendor = graphics_card_vendor
    self.graphics_card_vendor_id = graphics_card_vendor_id
    self.graphics_card_shader_level = graphics_card_shader_level
    self.graphics_card_pixel_fillrate = graphics_card_pixel_fillrate
    self.support_shadow = support_shadow
    self.support_render_texture = support_render_texture
    self.support_image_effect = support_image_effect
    self.device_name = device_name
    self.device_unique_identify = device_unique_identify
    self.device_model = device_model
    self.browser = browser
end
function client_device_info:encode()
    return
        binary_helper.to_binary(self.operate_system, "string") ..
        binary_helper.to_binary(self.cpu, "string") ..
        binary_helper.to_binary(self.cpu_count, "int") ..
        binary_helper.to_binary(self.memory, "int") ..
        binary_helper.to_binary(self.graphics_card, "string") ..
        binary_helper.to_binary(self.graphics_card_memory, "int") ..
        binary_helper.to_binary(self.graphics_card_id, "int") ..
        binary_helper.to_binary(self.graphics_card_verson, "string") ..
        binary_helper.to_binary(self.graphics_card_vendor, "string") ..
        binary_helper.to_binary(self.graphics_card_vendor_id, "int") ..
        binary_helper.to_binary(self.graphics_card_shader_level, "int") ..
        binary_helper.to_binary(self.graphics_card_pixel_fillrate, "int") ..
        binary_helper.to_binary(self.support_shadow, "int") ..
        binary_helper.to_binary(self.support_render_texture, "int") ..
        binary_helper.to_binary(self.support_image_effect, "int") ..
        binary_helper.to_binary(self.device_name, "string") ..
        binary_helper.to_binary(self.device_unique_identify, "string") ..
        binary_helper.to_binary(self.device_model, "string") ..
        binary_helper.to_binary(self.browser, "string")
end
function client_device_info:decode(binary)
    self.operate_system, binary = binary_helper.to_value(binary, "string")
    self.cpu, binary = binary_helper.to_value(binary, "string")
    self.cpu_count, binary = binary_helper.to_value(binary, "int")
    self.memory, binary = binary_helper.to_value(binary, "int")
    self.graphics_card, binary = binary_helper.to_value(binary, "string")
    self.graphics_card_memory, binary = binary_helper.to_value(binary, "int")
    self.graphics_card_id, binary = binary_helper.to_value(binary, "int")
    self.graphics_card_verson, binary = binary_helper.to_value(binary, "string")
    self.graphics_card_vendor, binary = binary_helper.to_value(binary, "string")
    self.graphics_card_vendor_id, binary = binary_helper.to_value(binary, "int")
    self.graphics_card_shader_level, binary = binary_helper.to_value(binary, "int")
    self.graphics_card_pixel_fillrate, binary = binary_helper.to_value(binary, "int")
    self.support_shadow, binary = binary_helper.to_value(binary, "int")
    self.support_render_texture, binary = binary_helper.to_value(binary, "int")
    self.support_image_effect, binary = binary_helper.to_value(binary, "int")
    self.device_name, binary = binary_helper.to_value(binary, "string")
    self.device_unique_identify, binary = binary_helper.to_value(binary, "string")
    self.device_model, binary = binary_helper.to_value(binary, "string")
    self.browser, binary = binary_helper.to_value(binary, "string")
    return binary
end
function client_device_info:get_msgid()
    return msg_client_device_info
end
notify_level_exp=class()
function notify_level_exp:ctor(level, exp, max_exp)
    self.level = level
    self.exp = exp
    self.max_exp = max_exp
end
function notify_level_exp:encode()
    return
        binary_helper.to_binary(self.level, "int") ..
        binary_helper.to_binary(self.exp, "int") ..
        binary_helper.to_binary(self.max_exp, "int")
end
function notify_level_exp:decode(binary)
    self.level, binary = binary_helper.to_value(binary, "int")
    self.exp, binary = binary_helper.to_value(binary, "int")
    self.max_exp, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_level_exp:get_msgid()
    return msg_notify_level_exp
end
notify_hp=class()
function notify_hp:ctor(hp, max_hp, total_seconds, restore_seconds)
    self.hp = hp
    self.max_hp = max_hp
    self.total_seconds = total_seconds
    self.restore_seconds = restore_seconds
end
function notify_hp:encode()
    return
        binary_helper.to_binary(self.hp, "int") ..
        binary_helper.to_binary(self.max_hp, "int") ..
        binary_helper.to_binary(self.total_seconds, "int") ..
        binary_helper.to_binary(self.restore_seconds, "int")
end
function notify_hp:decode(binary)
    self.hp, binary = binary_helper.to_value(binary, "int")
    self.max_hp, binary = binary_helper.to_value(binary, "int")
    self.total_seconds, binary = binary_helper.to_value(binary, "int")
    self.restore_seconds, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_hp:get_msgid()
    return msg_notify_hp
end
req_start_recover_hp=class()
function req_start_recover_hp:ctor()

end
function req_start_recover_hp:encode()
    return

end
function req_start_recover_hp:decode(binary)

    return binary
end
function req_start_recover_hp:get_msgid()
    return msg_req_start_recover_hp
end
notify_start_recover_hp=class()
function notify_start_recover_hp:ctor(count, hp, love_coin)
    self.count = count
    self.hp = hp
    self.love_coin = love_coin
end
function notify_start_recover_hp:encode()
    return
        binary_helper.to_binary(self.count, "int") ..
        binary_helper.to_binary(self.hp, "int") ..
        binary_helper.to_binary(self.love_coin, "int")
end
function notify_start_recover_hp:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    self.hp, binary = binary_helper.to_value(binary, "int")
    self.love_coin, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_start_recover_hp:get_msgid()
    return msg_notify_start_recover_hp
end
req_recover_hp=class()
function req_recover_hp:ctor()

end
function req_recover_hp:encode()
    return

end
function req_recover_hp:decode(binary)

    return binary
end
function req_recover_hp:get_msgid()
    return msg_req_recover_hp
end
notify_recover_hp=class()
function notify_recover_hp:ctor()

end
function notify_recover_hp:encode()
    return

end
function notify_recover_hp:decode(binary)

    return binary
end
function notify_recover_hp:get_msgid()
    return msg_notify_recover_hp
end
req_add_attention=class()
function req_add_attention:ctor(account, name)
    self.account = account
    self.name = name
end
function req_add_attention:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.name, "string")
end
function req_add_attention:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.name, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_add_attention:get_msgid()
    return msg_req_add_attention
end
notify_add_attention=class()
function notify_add_attention:ctor(info)
    self.info = info
end
function notify_add_attention:encode()
    return
        binary_helper.to_binary(self.info, "user_define")
end
function notify_add_attention:decode(binary)
    self.info, binary = binary_helper.to_value(binary,friend_item)
    return binary
end
function notify_add_attention:get_msgid()
    return msg_notify_add_attention
end
req_cancel_attention=class()
function req_cancel_attention:ctor(account)
    self.account = account
end
function req_cancel_attention:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_cancel_attention:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_cancel_attention:get_msgid()
    return msg_req_cancel_attention
end
notify_cancel_attention=class()
function notify_cancel_attention:ctor(account)
    self.account = account
end
function notify_cancel_attention:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function notify_cancel_attention:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_cancel_attention:get_msgid()
    return msg_notify_cancel_attention
end
req_get_attention_list=class()
function req_get_attention_list:ctor()

end
function req_get_attention_list:encode()
    return

end
function req_get_attention_list:decode(binary)

    return binary
end
function req_get_attention_list:get_msgid()
    return msg_req_get_attention_list
end
notify_attention_list=class()
function notify_attention_list:ctor(attentions)
    self.attentions = attentions
end
function notify_attention_list:encode()
    return
        binary_helper.array_to_binary(self.attentions, "user_define")
end
function notify_attention_list:decode(binary)
    self.attentions, binary = binary_helper.to_array(binary,friend_item)
    return binary
end
function notify_attention_list:get_msgid()
    return msg_notify_attention_list
end
req_opposite_sex_photos=class()
function req_opposite_sex_photos:ctor()

end
function req_opposite_sex_photos:encode()
    return

end
function req_opposite_sex_photos:decode(binary)

    return binary
end
function req_opposite_sex_photos:get_msgid()
    return msg_req_opposite_sex_photos
end
notify_opposite_sex_photos=class()
function notify_opposite_sex_photos:ctor(photos)
    self.photos = photos
end
function notify_opposite_sex_photos:encode()
    return
        binary_helper.array_to_binary(self.photos, "user_define")
end
function notify_opposite_sex_photos:decode(binary)
    self.photos, binary = binary_helper.to_array(binary,player_basic_information)
    return binary
end
function notify_opposite_sex_photos:get_msgid()
    return msg_notify_opposite_sex_photos
end
gift_info=class()
function gift_info:ctor(gift_id, receiver, sender, gift_box, gift, date)
    self.gift_id = gift_id
    self.receiver = receiver
    self.sender = sender
    self.gift_box = gift_box
    self.gift = gift
    self.date = date
end
function gift_info:encode()
    return
        binary_helper.to_binary(self.gift_id, "uint64") ..
        binary_helper.to_binary(self.receiver, "string") ..
        binary_helper.to_binary(self.sender, "string") ..
        binary_helper.to_binary(self.gift_box, "int") ..
        binary_helper.to_binary(self.gift, "user_define") ..
        binary_helper.to_binary(self.date, "user_define")
end
function gift_info:decode(binary)
    self.gift_id, binary = binary_helper.to_value(binary, "uint64")
    self.receiver, binary = binary_helper.to_value(binary, "string")
    self.sender, binary = binary_helper.to_value(binary, "string")
    self.gift_box, binary = binary_helper.to_value(binary, "int")
    self.gift, binary = binary_helper.to_value(binary,item)
    self.date, binary = binary_helper.to_value(binary,stime)
    return binary
end
function gift_info:get_msgid()
    return msg_gift_info
end
house_gift_info=class()
function house_gift_info:ctor(gift_id, gift_box, date)
    self.gift_id = gift_id
    self.gift_box = gift_box
    self.date = date
end
function house_gift_info:encode()
    return
        binary_helper.to_binary(self.gift_id, "uint64") ..
        binary_helper.to_binary(self.gift_box, "int") ..
        binary_helper.to_binary(self.date, "user_define")
end
function house_gift_info:decode(binary)
    self.gift_id, binary = binary_helper.to_value(binary, "uint64")
    self.gift_box, binary = binary_helper.to_value(binary, "int")
    self.date, binary = binary_helper.to_value(binary,stime)
    return binary
end
function house_gift_info:get_msgid()
    return msg_house_gift_info
end
req_send_gift=class()
function req_send_gift:ctor(gift)
    self.gift = gift
end
function req_send_gift:encode()
    return
        binary_helper.to_binary(self.gift, "user_define")
end
function req_send_gift:decode(binary)
    self.gift, binary = binary_helper.to_value(binary,gift_info)
    return binary
end
function req_send_gift:get_msgid()
    return msg_req_send_gift
end
notify_send_gift=class()
function notify_send_gift:ctor(type)
    self.type = type
end
function notify_send_gift:encode()
    return
        binary_helper.to_binary(self.type, "user_define")
end
function notify_send_gift:decode(binary)
    self.type, binary = binary_helper.to_value(binary,notify_gift_type)
    return binary
end
function notify_send_gift:get_msgid()
    return msg_notify_send_gift
end
req_house_gift_box_list=class()
function req_house_gift_box_list:ctor(account)
    self.account = account
end
function req_house_gift_box_list:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_house_gift_box_list:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_house_gift_box_list:get_msgid()
    return msg_req_house_gift_box_list
end
notify_house_gift_box_list=class()
function notify_house_gift_box_list:ctor(boy, girl, boy_boxes, girl_boxes)
    self.boy = boy
    self.girl = girl
    self.boy_boxes = boy_boxes
    self.girl_boxes = girl_boxes
end
function notify_house_gift_box_list:encode()
    return
        binary_helper.to_binary(self.boy, "string") ..
        binary_helper.to_binary(self.girl, "string") ..
        binary_helper.array_to_binary(self.boy_boxes, "user_define") ..
        binary_helper.array_to_binary(self.girl_boxes, "user_define")
end
function notify_house_gift_box_list:decode(binary)
    self.boy, binary = binary_helper.to_value(binary, "string")
    self.girl, binary = binary_helper.to_value(binary, "string")
    self.boy_boxes, binary = binary_helper.to_array(binary,house_gift_info)
    self.girl_boxes, binary = binary_helper.to_array(binary,house_gift_info)
    return binary
end
function notify_house_gift_box_list:get_msgid()
    return msg_notify_house_gift_box_list
end
notify_add_house_gift_box=class()
function notify_add_house_gift_box:ctor(account, boxes)
    self.account = account
    self.boxes = boxes
end
function notify_add_house_gift_box:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.array_to_binary(self.boxes, "user_define")
end
function notify_add_house_gift_box:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.boxes, binary = binary_helper.to_array(binary,house_gift_info)
    return binary
end
function notify_add_house_gift_box:get_msgid()
    return msg_notify_add_house_gift_box
end
notify_del_house_gift_box=class()
function notify_del_house_gift_box:ctor(account, boxes)
    self.account = account
    self.boxes = boxes
end
function notify_del_house_gift_box:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.array_to_binary(self.boxes, "user_define")
end
function notify_del_house_gift_box:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.boxes, binary = binary_helper.to_array(binary,house_gift_info)
    return binary
end
function notify_del_house_gift_box:get_msgid()
    return msg_notify_del_house_gift_box
end
req_receive_gift=class()
function req_receive_gift:ctor(gift_ids)
    self.gift_ids = gift_ids
end
function req_receive_gift:encode()
    return
        binary_helper.array_to_binary(self.gift_ids, "uint64")
end
function req_receive_gift:decode(binary)
    self.gift_ids, binary = binary_helper.to_array(binary, "uint64")
    return binary
end
function req_receive_gift:get_msgid()
    return msg_req_receive_gift
end
notify_receive_gift=class()
function notify_receive_gift:ctor(type)
    self.type = type
end
function notify_receive_gift:encode()
    return
        binary_helper.to_binary(self.type, "user_define")
end
function notify_receive_gift:decode(binary)
    self.type, binary = binary_helper.to_value(binary,notify_gift_type)
    return binary
end
function notify_receive_gift:get_msgid()
    return msg_notify_receive_gift
end
req_receive_gift_list=class()
function req_receive_gift_list:ctor()

end
function req_receive_gift_list:encode()
    return

end
function req_receive_gift_list:decode(binary)

    return binary
end
function req_receive_gift_list:get_msgid()
    return msg_req_receive_gift_list
end
notify_receive_gift_list=class()
function notify_receive_gift_list:ctor(gift)
    self.gift = gift
end
function notify_receive_gift_list:encode()
    return
        binary_helper.array_to_binary(self.gift, "user_define")
end
function notify_receive_gift_list:decode(binary)
    self.gift, binary = binary_helper.to_array(binary,gift_info)
    return binary
end
function notify_receive_gift_list:get_msgid()
    return msg_notify_receive_gift_list
end
req_received_gift_list=class()
function req_received_gift_list:ctor()

end
function req_received_gift_list:encode()
    return

end
function req_received_gift_list:decode(binary)

    return binary
end
function req_received_gift_list:get_msgid()
    return msg_req_received_gift_list
end
notify_received_gift_list=class()
function notify_received_gift_list:ctor(gift)
    self.gift = gift
end
function notify_received_gift_list:encode()
    return
        binary_helper.array_to_binary(self.gift, "user_define")
end
function notify_received_gift_list:decode(binary)
    self.gift, binary = binary_helper.to_array(binary,gift_info)
    return binary
end
function notify_received_gift_list:get_msgid()
    return msg_notify_received_gift_list
end
req_wish_add=class()
function req_wish_add:ctor(goods_id, wish_type)
    self.goods_id = goods_id
    self.wish_type = wish_type
end
function req_wish_add:encode()
    return
        binary_helper.to_binary(self.goods_id, "uint64") ..
        binary_helper.to_binary(self.wish_type, "int")
end
function req_wish_add:decode(binary)
    self.goods_id, binary = binary_helper.to_value(binary, "uint64")
    self.wish_type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_wish_add:get_msgid()
    return msg_req_wish_add
end
player_love_wish=class()
function player_love_wish:ctor(account, wish_id, goods_id, wish_time, wish_type)
    self.account = account
    self.wish_id = wish_id
    self.goods_id = goods_id
    self.wish_time = wish_time
    self.wish_type = wish_type
end
function player_love_wish:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.wish_id, "uint64") ..
        binary_helper.to_binary(self.goods_id, "uint64") ..
        binary_helper.to_binary(self.wish_time, "user_define") ..
        binary_helper.to_binary(self.wish_type, "int")
end
function player_love_wish:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.wish_id, binary = binary_helper.to_value(binary, "uint64")
    self.goods_id, binary = binary_helper.to_value(binary, "uint64")
    self.wish_time, binary = binary_helper.to_value(binary,stime)
    self.wish_type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function player_love_wish:get_msgid()
    return msg_player_love_wish
end
notify_wish_add=class()
function notify_wish_add:ctor(wish)
    self.wish = wish
end
function notify_wish_add:encode()
    return
        binary_helper.to_binary(self.wish, "user_define")
end
function notify_wish_add:decode(binary)
    self.wish, binary = binary_helper.to_value(binary,player_love_wish)
    return binary
end
function notify_wish_add:get_msgid()
    return msg_notify_wish_add
end
notify_wish_add_fail=class()
function notify_wish_add_fail:ctor(message)
    self.message = message
end
function notify_wish_add_fail:encode()
    return
        binary_helper.to_binary(self.message, "string")
end
function notify_wish_add_fail:decode(binary)
    self.message, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_wish_add_fail:get_msgid()
    return msg_notify_wish_add_fail
end
req_wish_delete=class()
function req_wish_delete:ctor(account, wish_id)
    self.account = account
    self.wish_id = wish_id
end
function req_wish_delete:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.wish_id, "uint64")
end
function req_wish_delete:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.wish_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_wish_delete:get_msgid()
    return msg_req_wish_delete
end
notify_wish_delete=class()
function notify_wish_delete:ctor(wish_id)
    self.wish_id = wish_id
end
function notify_wish_delete:encode()
    return
        binary_helper.to_binary(self.wish_id, "uint64")
end
function notify_wish_delete:decode(binary)
    self.wish_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_wish_delete:get_msgid()
    return msg_notify_wish_delete
end
req_wish_list=class()
function req_wish_list:ctor(account)
    self.account = account
end
function req_wish_list:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_wish_list:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_wish_list:get_msgid()
    return msg_req_wish_list
end
notify_wish_list=class()
function notify_wish_list:ctor(wish_list)
    self.wish_list = wish_list
end
function notify_wish_list:encode()
    return
        binary_helper.array_to_binary(self.wish_list, "user_define")
end
function notify_wish_list:decode(binary)
    self.wish_list, binary = binary_helper.to_array(binary,player_love_wish)
    return binary
end
function notify_wish_list:get_msgid()
    return msg_notify_wish_list
end
player_love_wish_history=class()
function player_love_wish_history:ctor(goods_id, satisfy_account, wish_type)
    self.goods_id = goods_id
    self.satisfy_account = satisfy_account
    self.wish_type = wish_type
end
function player_love_wish_history:encode()
    return
        binary_helper.to_binary(self.goods_id, "uint64") ..
        binary_helper.to_binary(self.satisfy_account, "string") ..
        binary_helper.to_binary(self.wish_type, "int")
end
function player_love_wish_history:decode(binary)
    self.goods_id, binary = binary_helper.to_value(binary, "uint64")
    self.satisfy_account, binary = binary_helper.to_value(binary, "string")
    self.wish_type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function player_love_wish_history:get_msgid()
    return msg_player_love_wish_history
end
req_wish_history_list=class()
function req_wish_history_list:ctor(account)
    self.account = account
end
function req_wish_history_list:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_wish_history_list:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_wish_history_list:get_msgid()
    return msg_req_wish_history_list
end
notify_wish_history_list=class()
function notify_wish_history_list:ctor(history_list)
    self.history_list = history_list
end
function notify_wish_history_list:encode()
    return
        binary_helper.array_to_binary(self.history_list, "user_define")
end
function notify_wish_history_list:decode(binary)
    self.history_list, binary = binary_helper.to_array(binary,player_love_wish_history)
    return binary
end
function notify_wish_history_list:get_msgid()
    return msg_notify_wish_history_list
end
req_wish_satisfy=class()
function req_wish_satisfy:ctor(wish_id)
    self.wish_id = wish_id
end
function req_wish_satisfy:encode()
    return
        binary_helper.to_binary(self.wish_id, "uint64")
end
function req_wish_satisfy:decode(binary)
    self.wish_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_wish_satisfy:get_msgid()
    return msg_req_wish_satisfy
end
notify_wish_satisfy_successfully=class()
function notify_wish_satisfy_successfully:ctor(wish_id)
    self.wish_id = wish_id
end
function notify_wish_satisfy_successfully:encode()
    return
        binary_helper.to_binary(self.wish_id, "uint64")
end
function notify_wish_satisfy_successfully:decode(binary)
    self.wish_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_wish_satisfy_successfully:get_msgid()
    return msg_notify_wish_satisfy_successfully
end
notify_wish_satisfy_fail=class()
function notify_wish_satisfy_fail:ctor(wish_id, message)
    self.wish_id = wish_id
    self.message = message
end
function notify_wish_satisfy_fail:encode()
    return
        binary_helper.to_binary(self.wish_id, "uint64") ..
        binary_helper.to_binary(self.message, "string")
end
function notify_wish_satisfy_fail:decode(binary)
    self.wish_id, binary = binary_helper.to_value(binary, "uint64")
    self.message, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_wish_satisfy_fail:get_msgid()
    return msg_notify_wish_satisfy_fail
end
req_complete_share=class()
function req_complete_share:ctor(type)
    self.type = type
end
function req_complete_share:encode()
    return
        binary_helper.to_binary(self.type, "user_define")
end
function req_complete_share:decode(binary)
    self.type, binary = binary_helper.to_value(binary,share_type)
    return binary
end
function req_complete_share:get_msgid()
    return msg_req_complete_share
end
base_person_info=class()
function base_person_info:ctor(animal_type, birthday, star, city, province, height, salary, blood_type, career, education, contact, interest, weight, signature, name)
    self.animal_type = animal_type
    self.birthday = birthday
    self.star = star
    self.city = city
    self.province = province
    self.height = height
    self.salary = salary
    self.blood_type = blood_type
    self.career = career
    self.education = education
    self.contact = contact
    self.interest = interest
    self.weight = weight
    self.signature = signature
    self.name = name
end
function base_person_info:encode()
    return
        binary_helper.to_binary(self.animal_type, "int") ..
        binary_helper.to_binary(self.birthday, "user_define") ..
        binary_helper.to_binary(self.star, "int") ..
        binary_helper.to_binary(self.city, "int") ..
        binary_helper.to_binary(self.province, "int") ..
        binary_helper.to_binary(self.height, "int") ..
        binary_helper.to_binary(self.salary, "int") ..
        binary_helper.to_binary(self.blood_type, "int") ..
        binary_helper.to_binary(self.career, "string") ..
        binary_helper.to_binary(self.education, "int") ..
        binary_helper.to_binary(self.contact, "string") ..
        binary_helper.to_binary(self.interest, "string") ..
        binary_helper.to_binary(self.weight, "int") ..
        binary_helper.to_binary(self.signature, "string") ..
        binary_helper.to_binary(self.name, "string")
end
function base_person_info:decode(binary)
    self.animal_type, binary = binary_helper.to_value(binary, "int")
    self.birthday, binary = binary_helper.to_value(binary,stime)
    self.star, binary = binary_helper.to_value(binary, "int")
    self.city, binary = binary_helper.to_value(binary, "int")
    self.province, binary = binary_helper.to_value(binary, "int")
    self.height, binary = binary_helper.to_value(binary, "int")
    self.salary, binary = binary_helper.to_value(binary, "int")
    self.blood_type, binary = binary_helper.to_value(binary, "int")
    self.career, binary = binary_helper.to_value(binary, "string")
    self.education, binary = binary_helper.to_value(binary, "int")
    self.contact, binary = binary_helper.to_value(binary, "string")
    self.interest, binary = binary_helper.to_value(binary, "string")
    self.weight, binary = binary_helper.to_value(binary, "int")
    self.signature, binary = binary_helper.to_value(binary, "string")
    self.name, binary = binary_helper.to_value(binary, "string")
    return binary
end
function base_person_info:get_msgid()
    return msg_base_person_info
end
req_change_person_info=class()
function req_change_person_info:ctor(info)
    self.info = info
end
function req_change_person_info:encode()
    return
        binary_helper.to_binary(self.info, "user_define")
end
function req_change_person_info:decode(binary)
    self.info, binary = binary_helper.to_value(binary,base_person_info)
    return binary
end
function req_change_person_info:get_msgid()
    return msg_req_change_person_info
end
req_close_person_info=class()
function req_close_person_info:ctor()

end
function req_close_person_info:encode()
    return

end
function req_close_person_info:decode(binary)

    return binary
end
function req_close_person_info:get_msgid()
    return msg_req_close_person_info
end
person_info=class()
function person_info:ctor(account, username, sex, info)
    self.account = account
    self.username = username
    self.sex = sex
    self.info = info
end
function person_info:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.username, "string") ..
        binary_helper.to_binary(self.sex, "int") ..
        binary_helper.to_binary(self.info, "user_define")
end
function person_info:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.username, binary = binary_helper.to_value(binary, "string")
    self.sex, binary = binary_helper.to_value(binary, "int")
    self.info, binary = binary_helper.to_value(binary,base_person_info)
    return binary
end
function person_info:get_msgid()
    return msg_person_info
end
req_person_info=class()
function req_person_info:ctor(account)
    self.account = account
end
function req_person_info:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_person_info:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_person_info:get_msgid()
    return msg_req_person_info
end
notify_person_info=class()
function notify_person_info:ctor(info)
    self.info = info
end
function notify_person_info:encode()
    return
        binary_helper.to_binary(self.info, "user_define")
end
function notify_person_info:decode(binary)
    self.info, binary = binary_helper.to_value(binary,person_info)
    return binary
end
function notify_person_info:get_msgid()
    return msg_notify_person_info
end
notify_show_buy_dialog=class()
function notify_show_buy_dialog:ctor(token, params, context)
    self.token = token
    self.params = params
    self.context = context
end
function notify_show_buy_dialog:encode()
    return
        binary_helper.to_binary(self.token, "string") ..
        binary_helper.to_binary(self.params, "string") ..
        binary_helper.to_binary(self.context, "string")
end
function notify_show_buy_dialog:decode(binary)
    self.token, binary = binary_helper.to_value(binary, "string")
    self.params, binary = binary_helper.to_value(binary, "string")
    self.context, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_show_buy_dialog:get_msgid()
    return msg_notify_show_buy_dialog
end
req_cancel_qq_order=class()
function req_cancel_qq_order:ctor(context)
    self.context = context
end
function req_cancel_qq_order:encode()
    return
        binary_helper.to_binary(self.context, "string")
end
function req_cancel_qq_order:decode(binary)
    self.context, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_cancel_qq_order:get_msgid()
    return msg_req_cancel_qq_order
end
notify_cancel_order=class()
function notify_cancel_order:ctor()

end
function notify_cancel_order:encode()
    return

end
function notify_cancel_order:decode(binary)

    return binary
end
function notify_cancel_order:get_msgid()
    return msg_notify_cancel_order
end
req_vip_gift_receive_info=class()
function req_vip_gift_receive_info:ctor()

end
function req_vip_gift_receive_info:encode()
    return

end
function req_vip_gift_receive_info:decode(binary)

    return binary
end
function req_vip_gift_receive_info:get_msgid()
    return msg_req_vip_gift_receive_info
end
notify_vip_gift_receive_info=class()
function notify_vip_gift_receive_info:ctor(beginner, daily)
    self.beginner = beginner
    self.daily = daily
end
function notify_vip_gift_receive_info:encode()
    return
        binary_helper.to_binary(self.beginner, "int") ..
        binary_helper.to_binary(self.daily, "int")
end
function notify_vip_gift_receive_info:decode(binary)
    self.beginner, binary = binary_helper.to_value(binary, "int")
    self.daily, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_vip_gift_receive_info:get_msgid()
    return msg_notify_vip_gift_receive_info
end
vip_gift_item=class()
function vip_gift_item:ctor(item_id, count)
    self.item_id = item_id
    self.count = count
end
function vip_gift_item:encode()
    return
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.to_binary(self.count, "int")
end
function vip_gift_item:decode(binary)
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function vip_gift_item:get_msgid()
    return msg_vip_gift_item
end
req_receive_vip_beginner_gift=class()
function req_receive_vip_beginner_gift:ctor(items)
    self.items = items
end
function req_receive_vip_beginner_gift:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define")
end
function req_receive_vip_beginner_gift:decode(binary)
    self.items, binary = binary_helper.to_array(binary,vip_gift_item)
    return binary
end
function req_receive_vip_beginner_gift:get_msgid()
    return msg_req_receive_vip_beginner_gift
end
req_receive_vip_daily_gift=class()
function req_receive_vip_daily_gift:ctor(items)
    self.items = items
end
function req_receive_vip_daily_gift:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define")
end
function req_receive_vip_daily_gift:decode(binary)
    self.items, binary = binary_helper.to_array(binary,vip_gift_item)
    return binary
end
function req_receive_vip_daily_gift:get_msgid()
    return msg_req_receive_vip_daily_gift
end
notify_vip_gift=class()
function notify_vip_gift:ctor(status)
    self.status = status
end
function notify_vip_gift:encode()
    return
        binary_helper.to_binary(self.status, "int")
end
function notify_vip_gift:decode(binary)
    self.status, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_vip_gift:get_msgid()
    return msg_notify_vip_gift
end
login_info=class()
function login_info:ctor(login_date, reward_date)
    self.login_date = login_date
    self.reward_date = reward_date
end
function login_info:encode()
    return
        binary_helper.to_binary(self.login_date, "user_define") ..
        binary_helper.to_binary(self.reward_date, "user_define")
end
function login_info:decode(binary)
    self.login_date, binary = binary_helper.to_value(binary,stime)
    self.reward_date, binary = binary_helper.to_value(binary,stime)
    return binary
end
function login_info:get_msgid()
    return msg_login_info
end
req_give_login_reward=class()
function req_give_login_reward:ctor()

end
function req_give_login_reward:encode()
    return

end
function req_give_login_reward:decode(binary)

    return binary
end
function req_give_login_reward:get_msgid()
    return msg_req_give_login_reward
end
notify_give_login_reward=class()
function notify_give_login_reward:ctor()

end
function notify_give_login_reward:encode()
    return

end
function notify_give_login_reward:decode(binary)

    return binary
end
function notify_give_login_reward:get_msgid()
    return msg_notify_give_login_reward
end
req_login_list=class()
function req_login_list:ctor()

end
function req_login_list:encode()
    return

end
function req_login_list:decode(binary)

    return binary
end
function req_login_list:get_msgid()
    return msg_req_login_list
end
notify_login_list=class()
function notify_login_list:ctor(info, type)
    self.info = info
    self.type = type
end
function notify_login_list:encode()
    return
        binary_helper.array_to_binary(self.info, "user_define") ..
        binary_helper.to_binary(self.type, "user_define")
end
function notify_login_list:decode(binary)
    self.info, binary = binary_helper.to_array(binary,login_info)
    self.type, binary = binary_helper.to_value(binary,show_type)
    return binary
end
function notify_login_list:get_msgid()
    return msg_notify_login_list
end
req_offline_notify=class()
function req_offline_notify:ctor()

end
function req_offline_notify:encode()
    return

end
function req_offline_notify:decode(binary)

    return binary
end
function req_offline_notify:get_msgid()
    return msg_req_offline_notify
end
notify_offline_notify=class()
function notify_offline_notify:ctor(count)
    self.count = count
end
function notify_offline_notify:encode()
    return
        binary_helper.to_binary(self.count, "int")
end
function notify_offline_notify:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_offline_notify:get_msgid()
    return msg_notify_offline_notify
end
req_buy_house_right=class()
function req_buy_house_right:ctor(grade)
    self.grade = grade
end
function req_buy_house_right:encode()
    return
        binary_helper.to_binary(self.grade, "int")
end
function req_buy_house_right:decode(binary)
    self.grade, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_buy_house_right:get_msgid()
    return msg_req_buy_house_right
end
notify_house_right_grade=class()
function notify_house_right_grade:ctor(grade)
    self.grade = grade
end
function notify_house_right_grade:encode()
    return
        binary_helper.to_binary(self.grade, "int")
end
function notify_house_right_grade:decode(binary)
    self.grade, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_house_right_grade:get_msgid()
    return msg_notify_house_right_grade
end
req_unlock_special_house=class()
function req_unlock_special_house:ctor(id)
    self.id = id
end
function req_unlock_special_house:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_unlock_special_house:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_unlock_special_house:get_msgid()
    return msg_req_unlock_special_house
end
notify_unlock_special_house=class()
function notify_unlock_special_house:ctor(id)
    self.id = id
end
function notify_unlock_special_house:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function notify_unlock_special_house:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_unlock_special_house:get_msgid()
    return msg_notify_unlock_special_house
end
req_unlock_special_house_info=class()
function req_unlock_special_house_info:ctor()

end
function req_unlock_special_house_info:encode()
    return

end
function req_unlock_special_house_info:decode(binary)

    return binary
end
function req_unlock_special_house_info:get_msgid()
    return msg_req_unlock_special_house_info
end
notify_unlock_special_house_info=class()
function notify_unlock_special_house_info:ctor(ids)
    self.ids = ids
end
function notify_unlock_special_house_info:encode()
    return
        binary_helper.array_to_binary(self.ids, "int")
end
function notify_unlock_special_house_info:decode(binary)
    self.ids, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_unlock_special_house_info:get_msgid()
    return msg_notify_unlock_special_house_info
end
special_house_goods=class()
function special_house_goods:ctor(id, house_tplt_id, remain_count, q_coin)
    self.id = id
    self.house_tplt_id = house_tplt_id
    self.remain_count = remain_count
    self.q_coin = q_coin
end
function special_house_goods:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.house_tplt_id, "int") ..
        binary_helper.to_binary(self.remain_count, "int") ..
        binary_helper.to_binary(self.q_coin, "int")
end
function special_house_goods:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.house_tplt_id, binary = binary_helper.to_value(binary, "int")
    self.remain_count, binary = binary_helper.to_value(binary, "int")
    self.q_coin, binary = binary_helper.to_value(binary, "int")
    return binary
end
function special_house_goods:get_msgid()
    return msg_special_house_goods
end
req_special_house_list=class()
function req_special_house_list:ctor()

end
function req_special_house_list:encode()
    return

end
function req_special_house_list:decode(binary)

    return binary
end
function req_special_house_list:get_msgid()
    return msg_req_special_house_list
end
notify_special_house_list=class()
function notify_special_house_list:ctor(house_list)
    self.house_list = house_list
end
function notify_special_house_list:encode()
    return
        binary_helper.array_to_binary(self.house_list, "user_define")
end
function notify_special_house_list:decode(binary)
    self.house_list, binary = binary_helper.to_array(binary,special_house_goods)
    return binary
end
function notify_special_house_list:get_msgid()
    return msg_notify_special_house_list
end
notify_buy_special_house_success=class()
function notify_buy_special_house_success:ctor()

end
function notify_buy_special_house_success:encode()
    return

end
function notify_buy_special_house_success:decode(binary)

    return binary
end
function notify_buy_special_house_success:get_msgid()
    return msg_notify_buy_special_house_success
end
req_self_special_house_list=class()
function req_self_special_house_list:ctor()

end
function req_self_special_house_list:encode()
    return

end
function req_self_special_house_list:decode(binary)

    return binary
end
function req_self_special_house_list:get_msgid()
    return msg_req_self_special_house_list
end
notify_self_special_house_list=class()
function notify_self_special_house_list:ctor(house_list)
    self.house_list = house_list
end
function notify_self_special_house_list:encode()
    return
        binary_helper.array_to_binary(self.house_list, "int")
end
function notify_self_special_house_list:decode(binary)
    self.house_list, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_self_special_house_list:get_msgid()
    return msg_notify_self_special_house_list
end
req_buy_special_house=class()
function req_buy_special_house:ctor(house_tplt_id)
    self.house_tplt_id = house_tplt_id
end
function req_buy_special_house:encode()
    return
        binary_helper.to_binary(self.house_tplt_id, "int")
end
function req_buy_special_house:decode(binary)
    self.house_tplt_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_buy_special_house:get_msgid()
    return msg_req_buy_special_house
end
req_move_house=class()
function req_move_house:ctor(new_house_tplt_id)
    self.new_house_tplt_id = new_house_tplt_id
end
function req_move_house:encode()
    return
        binary_helper.to_binary(self.new_house_tplt_id, "int")
end
function req_move_house:decode(binary)
    self.new_house_tplt_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_move_house:get_msgid()
    return msg_req_move_house
end
notify_move_house_success=class()
function notify_move_house_success:ctor()

end
function notify_move_house_success:encode()
    return

end
function notify_move_house_success:decode(binary)

    return binary
end
function notify_move_house_success:get_msgid()
    return msg_notify_move_house_success
end
req_get_free_count_for_moving_special_house=class()
function req_get_free_count_for_moving_special_house:ctor()

end
function req_get_free_count_for_moving_special_house:encode()
    return

end
function req_get_free_count_for_moving_special_house:decode(binary)

    return binary
end
function req_get_free_count_for_moving_special_house:get_msgid()
    return msg_req_get_free_count_for_moving_special_house
end
notify_get_free_count_for_moving_special_house=class()
function notify_get_free_count_for_moving_special_house:ctor(count)
    self.count = count
end
function notify_get_free_count_for_moving_special_house:encode()
    return
        binary_helper.to_binary(self.count, "int")
end
function notify_get_free_count_for_moving_special_house:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_get_free_count_for_moving_special_house:get_msgid()
    return msg_notify_get_free_count_for_moving_special_house
end
req_invite_active=class()
function req_invite_active:ctor()

end
function req_invite_active:encode()
    return

end
function req_invite_active:decode(binary)

    return binary
end
function req_invite_active:get_msgid()
    return msg_req_invite_active
end
notify_invite_active=class()
function notify_invite_active:ctor(count, invite_list)
    self.count = count
    self.invite_list = invite_list
end
function notify_invite_active:encode()
    return
        binary_helper.to_binary(self.count, "int") ..
        binary_helper.array_to_binary(self.invite_list, "string")
end
function notify_invite_active:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    self.invite_list, binary = binary_helper.to_array(binary, "string")
    return binary
end
function notify_invite_active:get_msgid()
    return msg_notify_invite_active
end
req_invite_award=class()
function req_invite_award:ctor(count, diamond, item_id, invite_list)
    self.count = count
    self.diamond = diamond
    self.item_id = item_id
    self.invite_list = invite_list
end
function req_invite_award:encode()
    return
        binary_helper.to_binary(self.count, "int") ..
        binary_helper.to_binary(self.diamond, "int") ..
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.array_to_binary(self.invite_list, "string")
end
function req_invite_award:decode(binary)
    self.count, binary = binary_helper.to_value(binary, "int")
    self.diamond, binary = binary_helper.to_value(binary, "int")
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.invite_list, binary = binary_helper.to_array(binary, "string")
    return binary
end
function req_invite_award:get_msgid()
    return msg_req_invite_award
end
notify_invite_award=class()
function notify_invite_award:ctor(result)
    self.result = result
end
function notify_invite_award:encode()
    return
        binary_helper.to_binary(self.result, "int")
end
function notify_invite_award:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_invite_award:get_msgid()
    return msg_notify_invite_award
end
req_open_search_items_ui=class()
function req_open_search_items_ui:ctor()

end
function req_open_search_items_ui:encode()
    return

end
function req_open_search_items_ui:decode(binary)

    return binary
end
function req_open_search_items_ui:get_msgid()
    return msg_req_open_search_items_ui
end
notify_open_search_items_ui=class()
function notify_open_search_items_ui:ctor(rate, item_count)
    self.rate = rate
    self.item_count = item_count
end
function notify_open_search_items_ui:encode()
    return
        binary_helper.to_binary(self.rate, "int") ..
        binary_helper.to_binary(self.item_count, "int")
end
function notify_open_search_items_ui:decode(binary)
    self.rate, binary = binary_helper.to_value(binary, "int")
    self.item_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_open_search_items_ui:get_msgid()
    return msg_notify_open_search_items_ui
end
req_search_items=class()
function req_search_items:ctor(is_npc, friend_account, friend_name)
    self.is_npc = is_npc
    self.friend_account = friend_account
    self.friend_name = friend_name
end
function req_search_items:encode()
    return
        binary_helper.to_binary(self.is_npc, "int") ..
        binary_helper.to_binary(self.friend_account, "string") ..
        binary_helper.to_binary(self.friend_name, "string")
end
function req_search_items:decode(binary)
    self.is_npc, binary = binary_helper.to_value(binary, "int")
    self.friend_account, binary = binary_helper.to_value(binary, "string")
    self.friend_name, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_search_items:get_msgid()
    return msg_req_search_items
end
notify_searching_items=class()
function notify_searching_items:ctor(is_npc, friend_account, friend_name, remain_seconds, whip_count)
    self.is_npc = is_npc
    self.friend_account = friend_account
    self.friend_name = friend_name
    self.remain_seconds = remain_seconds
    self.whip_count = whip_count
end
function notify_searching_items:encode()
    return
        binary_helper.to_binary(self.is_npc, "int") ..
        binary_helper.to_binary(self.friend_account, "string") ..
        binary_helper.to_binary(self.friend_name, "string") ..
        binary_helper.to_binary(self.remain_seconds, "int") ..
        binary_helper.to_binary(self.whip_count, "int")
end
function notify_searching_items:decode(binary)
    self.is_npc, binary = binary_helper.to_value(binary, "int")
    self.friend_account, binary = binary_helper.to_value(binary, "string")
    self.friend_name, binary = binary_helper.to_value(binary, "string")
    self.remain_seconds, binary = binary_helper.to_value(binary, "int")
    self.whip_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_searching_items:get_msgid()
    return msg_notify_searching_items
end
req_quick_search_items=class()
function req_quick_search_items:ctor(whip_count)
    self.whip_count = whip_count
end
function req_quick_search_items:encode()
    return
        binary_helper.to_binary(self.whip_count, "int")
end
function req_quick_search_items:decode(binary)
    self.whip_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_quick_search_items:get_msgid()
    return msg_req_quick_search_items
end
req_whip=class()
function req_whip:ctor()

end
function req_whip:encode()
    return

end
function req_whip:decode(binary)

    return binary
end
function req_whip:get_msgid()
    return msg_req_whip
end
notify_search_items_result=class()
function notify_search_items_result:ctor(is_npc, friend_account, friend_name, grid_count, gain_items)
    self.is_npc = is_npc
    self.friend_account = friend_account
    self.friend_name = friend_name
    self.grid_count = grid_count
    self.gain_items = gain_items
end
function notify_search_items_result:encode()
    return
        binary_helper.to_binary(self.is_npc, "int") ..
        binary_helper.to_binary(self.friend_account, "string") ..
        binary_helper.to_binary(self.friend_name, "string") ..
        binary_helper.to_binary(self.grid_count, "int") ..
        binary_helper.array_to_binary(self.gain_items, "user_define")
end
function notify_search_items_result:decode(binary)
    self.is_npc, binary = binary_helper.to_value(binary, "int")
    self.friend_account, binary = binary_helper.to_value(binary, "string")
    self.friend_name, binary = binary_helper.to_value(binary, "string")
    self.grid_count, binary = binary_helper.to_value(binary, "int")
    self.gain_items, binary = binary_helper.to_array(binary,vip_gift_item)
    return binary
end
function notify_search_items_result:get_msgid()
    return msg_notify_search_items_result
end
notify_new_self_msgs=class()
function notify_new_self_msgs:ctor()

end
function notify_new_self_msgs:encode()
    return

end
function notify_new_self_msgs:decode(binary)

    return binary
end
function notify_new_self_msgs:get_msgid()
    return msg_notify_new_self_msgs
end
hire_msg=class()
function hire_msg:ctor(time, is_npc, friend_account, cost_money)
    self.time = time
    self.is_npc = is_npc
    self.friend_account = friend_account
    self.cost_money = cost_money
end
function hire_msg:encode()
    return
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.is_npc, "int") ..
        binary_helper.to_binary(self.friend_account, "string") ..
        binary_helper.to_binary(self.cost_money, "int")
end
function hire_msg:decode(binary)
    self.time, binary = binary_helper.to_value(binary,stime)
    self.is_npc, binary = binary_helper.to_value(binary, "int")
    self.friend_account, binary = binary_helper.to_value(binary, "string")
    self.cost_money, binary = binary_helper.to_value(binary, "int")
    return binary
end
function hire_msg:get_msgid()
    return msg_hire_msg
end
be_hire_msg=class()
function be_hire_msg:ctor(time, friend_account, gain_exp)
    self.time = time
    self.friend_account = friend_account
    self.gain_exp = gain_exp
end
function be_hire_msg:encode()
    return
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.friend_account, "string") ..
        binary_helper.to_binary(self.gain_exp, "int")
end
function be_hire_msg:decode(binary)
    self.time, binary = binary_helper.to_value(binary,stime)
    self.friend_account, binary = binary_helper.to_value(binary, "string")
    self.gain_exp, binary = binary_helper.to_value(binary, "int")
    return binary
end
function be_hire_msg:get_msgid()
    return msg_be_hire_msg
end
be_whip_msg=class()
function be_whip_msg:ctor(time, friend_account)
    self.time = time
    self.friend_account = friend_account
end
function be_whip_msg:encode()
    return
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.friend_account, "string")
end
function be_whip_msg:decode(binary)
    self.time, binary = binary_helper.to_value(binary,stime)
    self.friend_account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function be_whip_msg:get_msgid()
    return msg_be_whip_msg
end
whip_msg=class()
function whip_msg:ctor(time, account, is_npc, whip_count, friend_account)
    self.time = time
    self.account = account
    self.is_npc = is_npc
    self.whip_count = whip_count
    self.friend_account = friend_account
end
function whip_msg:encode()
    return
        binary_helper.to_binary(self.time, "user_define") ..
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.is_npc, "int") ..
        binary_helper.to_binary(self.whip_count, "int") ..
        binary_helper.to_binary(self.friend_account, "string")
end
function whip_msg:decode(binary)
    self.time, binary = binary_helper.to_value(binary,stime)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.is_npc, binary = binary_helper.to_value(binary, "int")
    self.whip_count, binary = binary_helper.to_value(binary, "int")
    self.friend_account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function whip_msg:get_msgid()
    return msg_whip_msg
end
req_self_msgs=class()
function req_self_msgs:ctor()

end
function req_self_msgs:encode()
    return

end
function req_self_msgs:decode(binary)

    return binary
end
function req_self_msgs:get_msgid()
    return msg_req_self_msgs
end
notify_self_msgs=class()
function notify_self_msgs:ctor(hire_msgs, be_hire_msgs, be_whip_msgs, whip_msgs)
    self.hire_msgs = hire_msgs
    self.be_hire_msgs = be_hire_msgs
    self.be_whip_msgs = be_whip_msgs
    self.whip_msgs = whip_msgs
end
function notify_self_msgs:encode()
    return
        binary_helper.array_to_binary(self.hire_msgs, "user_define") ..
        binary_helper.array_to_binary(self.be_hire_msgs, "user_define") ..
        binary_helper.array_to_binary(self.be_whip_msgs, "user_define") ..
        binary_helper.array_to_binary(self.whip_msgs, "user_define")
end
function notify_self_msgs:decode(binary)
    self.hire_msgs, binary = binary_helper.to_array(binary,hire_msg)
    self.be_hire_msgs, binary = binary_helper.to_array(binary,be_hire_msg)
    self.be_whip_msgs, binary = binary_helper.to_array(binary,be_whip_msg)
    self.whip_msgs, binary = binary_helper.to_array(binary,whip_msg)
    return binary
end
function notify_self_msgs:get_msgid()
    return msg_notify_self_msgs
end
req_update_search_items=class()
function req_update_search_items:ctor()

end
function req_update_search_items:encode()
    return

end
function req_update_search_items:decode(binary)

    return binary
end
function req_update_search_items:get_msgid()
    return msg_req_update_search_items
end
notify_polymorph_result=class()
function notify_polymorph_result:ctor(account, alter_body, message, user)
    self.account = account
    self.alter_body = alter_body
    self.message = message
    self.user = user
end
function notify_polymorph_result:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.alter_body, "user_define") ..
        binary_helper.to_binary(self.message, "string") ..
        binary_helper.to_binary(self.user, "string")
end
function notify_polymorph_result:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.alter_body, binary = binary_helper.to_value(binary,polymorph)
    self.message, binary = binary_helper.to_value(binary, "string")
    self.user, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_polymorph_result:get_msgid()
    return msg_notify_polymorph_result
end
req_purify_polymorph=class()
function req_purify_polymorph:ctor(target_account)
    self.target_account = target_account
end
function req_purify_polymorph:encode()
    return
        binary_helper.to_binary(self.target_account, "string")
end
function req_purify_polymorph:decode(binary)
    self.target_account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_purify_polymorph:get_msgid()
    return msg_req_purify_polymorph
end
req_player_info=class()
function req_player_info:ctor(account)
    self.account = account
end
function req_player_info:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_player_info:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_player_info:get_msgid()
    return msg_req_player_info
end
notify_player_info=class()
function notify_player_info:ctor(player)
    self.player = player
end
function notify_player_info:encode()
    return
        binary_helper.to_binary(self.player, "user_define")
end
function notify_player_info:decode(binary)
    self.player, binary = binary_helper.to_value(binary,player_basic_data)
    return binary
end
function notify_player_info:get_msgid()
    return msg_notify_player_info
end
req_produce=class()
function req_produce:ctor(produce_manual_id, lucky_stone_count, has_insurance)
    self.produce_manual_id = produce_manual_id
    self.lucky_stone_count = lucky_stone_count
    self.has_insurance = has_insurance
end
function req_produce:encode()
    return
        binary_helper.to_binary(self.produce_manual_id, "uint64") ..
        binary_helper.to_binary(self.lucky_stone_count, "int") ..
        binary_helper.to_binary(self.has_insurance, "int")
end
function req_produce:decode(binary)
    self.produce_manual_id, binary = binary_helper.to_value(binary, "uint64")
    self.lucky_stone_count, binary = binary_helper.to_value(binary, "int")
    self.has_insurance, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_produce:get_msgid()
    return msg_req_produce
end
notify_produce_ack=class()
function notify_produce_ack:ctor()

end
function notify_produce_ack:encode()
    return

end
function notify_produce_ack:decode(binary)

    return binary
end
function notify_produce_ack:get_msgid()
    return msg_notify_produce_ack
end
notify_produce=class()
function notify_produce:ctor(result, message, finished, player)
    self.result = result
    self.message = message
    self.finished = finished
    self.player = player
end
function notify_produce:encode()
    return
        binary_helper.to_binary(self.result, "int") ..
        binary_helper.to_binary(self.message, "string") ..
        binary_helper.to_binary(self.finished, "user_define") ..
        binary_helper.to_binary(self.player, "user_define")
end
function notify_produce:decode(binary)
    self.result, binary = binary_helper.to_value(binary, "int")
    self.message, binary = binary_helper.to_value(binary, "string")
    self.finished, binary = binary_helper.to_value(binary,item)
    self.player, binary = binary_helper.to_value(binary,player_basic_data)
    return binary
end
function notify_produce:get_msgid()
    return msg_notify_produce
end
notify_produce_level=class()
function notify_produce_level:ctor(level, experience)
    self.level = level
    self.experience = experience
end
function notify_produce_level:encode()
    return
        binary_helper.to_binary(self.level, "int") ..
        binary_helper.to_binary(self.experience, "int")
end
function notify_produce_level:decode(binary)
    self.level, binary = binary_helper.to_value(binary, "int")
    self.experience, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_produce_level:get_msgid()
    return msg_notify_produce_level
end
req_ranking=class()
function req_ranking:ctor(type)
    self.type = type
end
function req_ranking:encode()
    return
        binary_helper.to_binary(self.type, "int")
end
function req_ranking:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_ranking:get_msgid()
    return msg_req_ranking
end
ranking_data=class()
function ranking_data:ctor(account, data)
    self.account = account
    self.data = data
end
function ranking_data:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.data, "int")
end
function ranking_data:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.data, binary = binary_helper.to_value(binary, "int")
    return binary
end
function ranking_data:get_msgid()
    return msg_ranking_data
end
notify_ranking=class()
function notify_ranking:ctor(type, self_ranking, data)
    self.type = type
    self.self_ranking = self_ranking
    self.data = data
end
function notify_ranking:encode()
    return
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.self_ranking, "int") ..
        binary_helper.array_to_binary(self.data, "user_define")
end
function notify_ranking:decode(binary)
    self.type, binary = binary_helper.to_value(binary, "int")
    self.self_ranking, binary = binary_helper.to_value(binary, "int")
    self.data, binary = binary_helper.to_array(binary,ranking_data)
    return binary
end
function notify_ranking:get_msgid()
    return msg_notify_ranking
end
req_score_ranking=class()
function req_score_ranking:ctor()

end
function req_score_ranking:encode()
    return

end
function req_score_ranking:decode(binary)

    return binary
end
function req_score_ranking:get_msgid()
    return msg_req_score_ranking
end
notify_score_ranking=class()
function notify_score_ranking:ctor(self_score, data)
    self.self_score = self_score
    self.data = data
end
function notify_score_ranking:encode()
    return
        binary_helper.to_binary(self.self_score, "int") ..
        binary_helper.array_to_binary(self.data, "user_define")
end
function notify_score_ranking:decode(binary)
    self.self_score, binary = binary_helper.to_value(binary, "int")
    self.data, binary = binary_helper.to_array(binary,ranking_data)
    return binary
end
function notify_score_ranking:get_msgid()
    return msg_notify_score_ranking
end
req_set_guest_book_opened=class()
function req_set_guest_book_opened:ctor(id, opened)
    self.id = id
    self.opened = opened
end
function req_set_guest_book_opened:encode()
    return
        binary_helper.to_binary(self.id, "uint64") ..
        binary_helper.to_binary(self.opened, "int")
end
function req_set_guest_book_opened:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "uint64")
    self.opened, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_set_guest_book_opened:get_msgid()
    return msg_req_set_guest_book_opened
end
notify_set_guest_book_opened=class()
function notify_set_guest_book_opened:ctor(id, opened)
    self.id = id
    self.opened = opened
end
function notify_set_guest_book_opened:encode()
    return
        binary_helper.to_binary(self.id, "uint64") ..
        binary_helper.to_binary(self.opened, "int")
end
function notify_set_guest_book_opened:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "uint64")
    self.opened, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_set_guest_book_opened:get_msgid()
    return msg_notify_set_guest_book_opened
end
req_set_checkin_opened=class()
function req_set_checkin_opened:ctor(id, opened)
    self.id = id
    self.opened = opened
end
function req_set_checkin_opened:encode()
    return
        binary_helper.to_binary(self.id, "string") ..
        binary_helper.to_binary(self.opened, "int")
end
function req_set_checkin_opened:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "string")
    self.opened, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_set_checkin_opened:get_msgid()
    return msg_req_set_checkin_opened
end
notify_set_checkin_opened=class()
function notify_set_checkin_opened:ctor(id, opened)
    self.id = id
    self.opened = opened
end
function notify_set_checkin_opened:encode()
    return
        binary_helper.to_binary(self.id, "string") ..
        binary_helper.to_binary(self.opened, "int")
end
function notify_set_checkin_opened:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "string")
    self.opened, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_set_checkin_opened:get_msgid()
    return msg_notify_set_checkin_opened
end
crop_event=class()
function crop_event:ctor(id, type, time)
    self.id = id
    self.type = type
    self.time = time
end
function crop_event:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.type, "int") ..
        binary_helper.to_binary(self.time, "int")
end
function crop_event:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.type, binary = binary_helper.to_value(binary, "int")
    self.time, binary = binary_helper.to_value(binary, "int")
    return binary
end
function crop_event:get_msgid()
    return msg_crop_event
end
crop_data=class()
function crop_data:ctor(inst_id, item_id, rest_time, fruit_id, fruit_count, evt)
    self.inst_id = inst_id
    self.item_id = item_id
    self.rest_time = rest_time
    self.fruit_id = fruit_id
    self.fruit_count = fruit_count
    self.evt = evt
end
function crop_data:encode()
    return
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.to_binary(self.rest_time, "int") ..
        binary_helper.array_to_binary(self.fruit_id, "int") ..
        binary_helper.array_to_binary(self.fruit_count, "int") ..
        binary_helper.array_to_binary(self.evt, "user_define")
end
function crop_data:decode(binary)
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.rest_time, binary = binary_helper.to_value(binary, "int")
    self.fruit_id, binary = binary_helper.to_array(binary, "int")
    self.fruit_count, binary = binary_helper.to_array(binary, "int")
    self.evt, binary = binary_helper.to_array(binary,crop_event)
    return binary
end
function crop_data:get_msgid()
    return msg_crop_data
end
req_plant_crop=class()
function req_plant_crop:ctor(flowerpot_id, seed_id)
    self.flowerpot_id = flowerpot_id
    self.seed_id = seed_id
end
function req_plant_crop:encode()
    return
        binary_helper.to_binary(self.flowerpot_id, "uint64") ..
        binary_helper.to_binary(self.seed_id, "uint64")
end
function req_plant_crop:decode(binary)
    self.flowerpot_id, binary = binary_helper.to_value(binary, "uint64")
    self.seed_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_plant_crop:get_msgid()
    return msg_req_plant_crop
end
notify_farm_data=class()
function notify_farm_data:ctor(house_id, crops, water_limit)
    self.house_id = house_id
    self.crops = crops
    self.water_limit = water_limit
end
function notify_farm_data:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.array_to_binary(self.crops, "user_define") ..
        binary_helper.to_binary(self.water_limit, "int")
end
function notify_farm_data:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.crops, binary = binary_helper.to_array(binary,crop_data)
    self.water_limit, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_farm_data:get_msgid()
    return msg_notify_farm_data
end
req_crop_event=class()
function req_crop_event:ctor(house_id, inst_id, event_type, event_id)
    self.house_id = house_id
    self.inst_id = inst_id
    self.event_type = event_type
    self.event_id = event_id
end
function req_crop_event:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.inst_id, "uint64") ..
        binary_helper.to_binary(self.event_type, "int") ..
        binary_helper.to_binary(self.event_id, "int")
end
function req_crop_event:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.inst_id, binary = binary_helper.to_value(binary, "uint64")
    self.event_type, binary = binary_helper.to_value(binary, "int")
    self.event_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_crop_event:get_msgid()
    return msg_req_crop_event
end
req_all_crop_event=class()
function req_all_crop_event:ctor(house_id, event_type)
    self.house_id = house_id
    self.event_type = event_type
end
function req_all_crop_event:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.event_type, "int")
end
function req_all_crop_event:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.event_type, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_all_crop_event:get_msgid()
    return msg_req_all_crop_event
end
req_delete_crop=class()
function req_delete_crop:ctor(crop_id)
    self.crop_id = crop_id
end
function req_delete_crop:encode()
    return
        binary_helper.to_binary(self.crop_id, "uint64")
end
function req_delete_crop:decode(binary)
    self.crop_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_delete_crop:get_msgid()
    return msg_req_delete_crop
end
notify_delete_crop=class()
function notify_delete_crop:ctor(crop_id, result)
    self.crop_id = crop_id
    self.result = result
end
function notify_delete_crop:encode()
    return
        binary_helper.to_binary(self.crop_id, "uint64") ..
        binary_helper.to_binary(self.result, "int")
end
function notify_delete_crop:decode(binary)
    self.crop_id, binary = binary_helper.to_value(binary, "uint64")
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_delete_crop:get_msgid()
    return msg_notify_delete_crop
end
notify_crop_data=class()
function notify_crop_data:ctor(house_id, op, crop, water_limit)
    self.house_id = house_id
    self.op = op
    self.crop = crop
    self.water_limit = water_limit
end
function notify_crop_data:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.op, "int") ..
        binary_helper.to_binary(self.crop, "user_define") ..
        binary_helper.to_binary(self.water_limit, "int")
end
function notify_crop_data:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.op, binary = binary_helper.to_value(binary, "int")
    self.crop, binary = binary_helper.to_value(binary,crop_data)
    self.water_limit, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_crop_data:get_msgid()
    return msg_notify_crop_data
end
req_pick_crop_fruit=class()
function req_pick_crop_fruit:ctor(crop_id)
    self.crop_id = crop_id
end
function req_pick_crop_fruit:encode()
    return
        binary_helper.to_binary(self.crop_id, "uint64")
end
function req_pick_crop_fruit:decode(binary)
    self.crop_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_pick_crop_fruit:get_msgid()
    return msg_req_pick_crop_fruit
end
notify_pick_crop_fruit=class()
function notify_pick_crop_fruit:ctor(house_id, crop_id, result)
    self.house_id = house_id
    self.crop_id = crop_id
    self.result = result
end
function notify_pick_crop_fruit:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.crop_id, "uint64") ..
        binary_helper.to_binary(self.result, "int")
end
function notify_pick_crop_fruit:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.crop_id, binary = binary_helper.to_value(binary, "uint64")
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_pick_crop_fruit:get_msgid()
    return msg_notify_pick_crop_fruit
end
req_house_max_flowerpot=class()
function req_house_max_flowerpot:ctor()

end
function req_house_max_flowerpot:encode()
    return

end
function req_house_max_flowerpot:decode(binary)

    return binary
end
function req_house_max_flowerpot:get_msgid()
    return msg_req_house_max_flowerpot
end
notify_house_max_flowerpot=class()
function notify_house_max_flowerpot:ctor(house_id, owner_number, max_number)
    self.house_id = house_id
    self.owner_number = owner_number
    self.max_number = max_number
end
function notify_house_max_flowerpot:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.owner_number, "int") ..
        binary_helper.to_binary(self.max_number, "int")
end
function notify_house_max_flowerpot:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.owner_number, binary = binary_helper.to_value(binary, "int")
    self.max_number, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_house_max_flowerpot:get_msgid()
    return msg_notify_house_max_flowerpot
end
req_add_flowerpot_number=class()
function req_add_flowerpot_number:ctor()

end
function req_add_flowerpot_number:encode()
    return

end
function req_add_flowerpot_number:decode(binary)

    return binary
end
function req_add_flowerpot_number:get_msgid()
    return msg_req_add_flowerpot_number
end
req_breakup=class()
function req_breakup:ctor(diamond, expect_items)
    self.diamond = diamond
    self.expect_items = expect_items
end
function req_breakup:encode()
    return
        binary_helper.to_binary(self.diamond, "int") ..
        binary_helper.array_to_binary(self.expect_items, "user_define")
end
function req_breakup:decode(binary)
    self.diamond, binary = binary_helper.to_value(binary, "int")
    self.expect_items, binary = binary_helper.to_array(binary,item)
    return binary
end
function req_breakup:get_msgid()
    return msg_req_breakup
end
notify_breakup_ack=class()
function notify_breakup_ack:ctor()

end
function notify_breakup_ack:encode()
    return

end
function notify_breakup_ack:decode(binary)

    return binary
end
function notify_breakup_ack:get_msgid()
    return msg_notify_breakup_ack
end
notify_breakup_error=class()
function notify_breakup_error:ctor()

end
function notify_breakup_error:encode()
    return

end
function notify_breakup_error:decode(binary)

    return binary
end
function notify_breakup_error:get_msgid()
    return msg_notify_breakup_error
end
req_player_breakup=class()
function req_player_breakup:ctor()

end
function req_player_breakup:encode()
    return

end
function req_player_breakup:decode(binary)

    return binary
end
function req_player_breakup:get_msgid()
    return msg_req_player_breakup
end
notify_player_breakup_none=class()
function notify_player_breakup_none:ctor()

end
function notify_player_breakup_none:encode()
    return

end
function notify_player_breakup_none:decode(binary)

    return binary
end
function notify_player_breakup_none:get_msgid()
    return msg_notify_player_breakup_none
end
notify_player_breakup=class()
function notify_player_breakup:ctor(account, diamond, unobtained_items)
    self.account = account
    self.diamond = diamond
    self.unobtained_items = unobtained_items
end
function notify_player_breakup:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.diamond, "int") ..
        binary_helper.array_to_binary(self.unobtained_items, "int")
end
function notify_player_breakup:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.diamond, binary = binary_helper.to_value(binary, "int")
    self.unobtained_items, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_player_breakup:get_msgid()
    return msg_notify_player_breakup
end
req_player_breakup_diamond=class()
function req_player_breakup_diamond:ctor()

end
function req_player_breakup_diamond:encode()
    return

end
function req_player_breakup_diamond:decode(binary)

    return binary
end
function req_player_breakup_diamond:get_msgid()
    return msg_req_player_breakup_diamond
end
notify_player_breakup_diamond=class()
function notify_player_breakup_diamond:ctor()

end
function notify_player_breakup_diamond:encode()
    return

end
function notify_player_breakup_diamond:decode(binary)

    return binary
end
function notify_player_breakup_diamond:get_msgid()
    return msg_notify_player_breakup_diamond
end
notify_player_be_breakuped=class()
function notify_player_be_breakuped:ctor()

end
function notify_player_be_breakuped:encode()
    return

end
function notify_player_be_breakuped:decode(binary)

    return binary
end
function notify_player_be_breakuped:get_msgid()
    return msg_notify_player_be_breakuped
end
require_item_atom=class()
function require_item_atom:ctor(item_id, item_count, content)
    self.item_id = item_id
    self.item_count = item_count
    self.content = content
end
function require_item_atom:encode()
    return
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.to_binary(self.item_count, "int") ..
        binary_helper.to_binary(self.content, "string")
end
function require_item_atom:decode(binary)
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.item_count, binary = binary_helper.to_value(binary, "int")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function require_item_atom:get_msgid()
    return msg_require_item_atom
end
reward_item_atom=class()
function reward_item_atom:ctor(item_id, item_count)
    self.item_id = item_id
    self.item_count = item_count
end
function reward_item_atom:encode()
    return
        binary_helper.to_binary(self.item_id, "int") ..
        binary_helper.to_binary(self.item_count, "int")
end
function reward_item_atom:decode(binary)
    self.item_id, binary = binary_helper.to_value(binary, "int")
    self.item_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function reward_item_atom:get_msgid()
    return msg_reward_item_atom
end
req_open_post_reward_ui=class()
function req_open_post_reward_ui:ctor()

end
function req_open_post_reward_ui:encode()
    return

end
function req_open_post_reward_ui:decode(binary)

    return binary
end
function req_open_post_reward_ui:get_msgid()
    return msg_req_open_post_reward_ui
end
notify_open_post_reward_ui=class()
function notify_open_post_reward_ui:ctor(content, require_items, reward_items, reward_diamond, reward_exp)
    self.content = content
    self.require_items = require_items
    self.reward_items = reward_items
    self.reward_diamond = reward_diamond
    self.reward_exp = reward_exp
end
function notify_open_post_reward_ui:encode()
    return
        binary_helper.to_binary(self.content, "string") ..
        binary_helper.array_to_binary(self.require_items, "user_define") ..
        binary_helper.array_to_binary(self.reward_items, "user_define") ..
        binary_helper.to_binary(self.reward_diamond, "int") ..
        binary_helper.to_binary(self.reward_exp, "int")
end
function notify_open_post_reward_ui:decode(binary)
    self.content, binary = binary_helper.to_value(binary, "string")
    self.require_items, binary = binary_helper.to_array(binary,require_item_atom)
    self.reward_items, binary = binary_helper.to_array(binary,reward_item_atom)
    self.reward_diamond, binary = binary_helper.to_value(binary, "int")
    self.reward_exp, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_open_post_reward_ui:get_msgid()
    return msg_notify_open_post_reward_ui
end
req_complete_post_reward=class()
function req_complete_post_reward:ctor()

end
function req_complete_post_reward:encode()
    return

end
function req_complete_post_reward:decode(binary)

    return binary
end
function req_complete_post_reward:get_msgid()
    return msg_req_complete_post_reward
end
notify_complete_post_reward=class()
function notify_complete_post_reward:ctor(result)
    self.result = result
end
function notify_complete_post_reward:encode()
    return
        binary_helper.to_binary(self.result, "user_define")
end
function notify_complete_post_reward:decode(binary)
    self.result, binary = binary_helper.to_value(binary,complete_post_reward_type)
    return binary
end
function notify_complete_post_reward:get_msgid()
    return msg_notify_complete_post_reward
end
notify_active_score_lottery=class()
function notify_active_score_lottery:ctor()

end
function notify_active_score_lottery:encode()
    return

end
function notify_active_score_lottery:decode(binary)

    return binary
end
function notify_active_score_lottery:get_msgid()
    return msg_notify_active_score_lottery
end
req_open_score_lottery_ui=class()
function req_open_score_lottery_ui:ctor()

end
function req_open_score_lottery_ui:encode()
    return

end
function req_open_score_lottery_ui:decode(binary)

    return binary
end
function req_open_score_lottery_ui:get_msgid()
    return msg_req_open_score_lottery_ui
end
notify_open_score_lottery_ui=class()
function notify_open_score_lottery_ui:ctor(items, remain_count)
    self.items = items
    self.remain_count = remain_count
end
function notify_open_score_lottery_ui:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define") ..
        binary_helper.to_binary(self.remain_count, "int")
end
function notify_open_score_lottery_ui:decode(binary)
    self.items, binary = binary_helper.to_array(binary,lottery_item)
    self.remain_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_open_score_lottery_ui:get_msgid()
    return msg_notify_open_score_lottery_ui
end
req_score_lottery=class()
function req_score_lottery:ctor()

end
function req_score_lottery:encode()
    return

end
function req_score_lottery:decode(binary)

    return binary
end
function req_score_lottery:get_msgid()
    return msg_req_score_lottery
end
notify_score_lottery_result=class()
function notify_score_lottery_result:ctor(items, hit_index, remain_count)
    self.items = items
    self.hit_index = hit_index
    self.remain_count = remain_count
end
function notify_score_lottery_result:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define") ..
        binary_helper.to_binary(self.hit_index, "int") ..
        binary_helper.to_binary(self.remain_count, "int")
end
function notify_score_lottery_result:decode(binary)
    self.items, binary = binary_helper.to_array(binary,lottery_item)
    self.hit_index, binary = binary_helper.to_value(binary, "int")
    self.remain_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_score_lottery_result:get_msgid()
    return msg_notify_score_lottery_result
end
req_refresh_score_lottery_ui=class()
function req_refresh_score_lottery_ui:ctor()

end
function req_refresh_score_lottery_ui:encode()
    return

end
function req_refresh_score_lottery_ui:decode(binary)

    return binary
end
function req_refresh_score_lottery_ui:get_msgid()
    return msg_req_refresh_score_lottery_ui
end
notify_refresh_score_lottery_ui=class()
function notify_refresh_score_lottery_ui:ctor(items, remain_count)
    self.items = items
    self.remain_count = remain_count
end
function notify_refresh_score_lottery_ui:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define") ..
        binary_helper.to_binary(self.remain_count, "int")
end
function notify_refresh_score_lottery_ui:decode(binary)
    self.items, binary = binary_helper.to_array(binary,lottery_item)
    self.remain_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_refresh_score_lottery_ui:get_msgid()
    return msg_notify_refresh_score_lottery_ui
end
req_daily_reward_ui=class()
function req_daily_reward_ui:ctor()

end
function req_daily_reward_ui:encode()
    return

end
function req_daily_reward_ui:decode(binary)

    return binary
end
function req_daily_reward_ui:get_msgid()
    return msg_req_daily_reward_ui
end
notify_daily_reward_ui=class()
function notify_daily_reward_ui:ctor(progress_list, reward_score_list, has_reward_list)
    self.progress_list = progress_list
    self.reward_score_list = reward_score_list
    self.has_reward_list = has_reward_list
end
function notify_daily_reward_ui:encode()
    return
        binary_helper.array_to_binary(self.progress_list, "int") ..
        binary_helper.array_to_binary(self.reward_score_list, "int") ..
        binary_helper.array_to_binary(self.has_reward_list, "int")
end
function notify_daily_reward_ui:decode(binary)
    self.progress_list, binary = binary_helper.to_array(binary, "int")
    self.reward_score_list, binary = binary_helper.to_array(binary, "int")
    self.has_reward_list, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_daily_reward_ui:get_msgid()
    return msg_notify_daily_reward_ui
end
req_daily_reward=class()
function req_daily_reward:ctor(score)
    self.score = score
end
function req_daily_reward:encode()
    return
        binary_helper.to_binary(self.score, "int")
end
function req_daily_reward:decode(binary)
    self.score, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_daily_reward:get_msgid()
    return msg_req_daily_reward
end
notify_daily_active_can_reward=class()
function notify_daily_active_can_reward:ctor()

end
function notify_daily_active_can_reward:encode()
    return

end
function notify_daily_active_can_reward:decode(binary)

    return binary
end
function notify_daily_active_can_reward:get_msgid()
    return msg_notify_daily_active_can_reward
end
req_close_daily_reward_ui=class()
function req_close_daily_reward_ui:ctor()

end
function req_close_daily_reward_ui:encode()
    return

end
function req_close_daily_reward_ui:decode(binary)

    return binary
end
function req_close_daily_reward_ui:get_msgid()
    return msg_req_close_daily_reward_ui
end
req_immediate_complete_daily_reward=class()
function req_immediate_complete_daily_reward:ctor(index)
    self.index = index
end
function req_immediate_complete_daily_reward:encode()
    return
        binary_helper.to_binary(self.index, "int")
end
function req_immediate_complete_daily_reward:decode(binary)
    self.index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_immediate_complete_daily_reward:get_msgid()
    return msg_req_immediate_complete_daily_reward
end
req_open_daily_task_ui=class()
function req_open_daily_task_ui:ctor()

end
function req_open_daily_task_ui:encode()
    return

end
function req_open_daily_task_ui:decode(binary)

    return binary
end
function req_open_daily_task_ui:get_msgid()
    return msg_req_open_daily_task_ui
end
req_close_daily_task_ui=class()
function req_close_daily_task_ui:ctor()

end
function req_close_daily_task_ui:encode()
    return

end
function req_close_daily_task_ui:decode(binary)

    return binary
end
function req_close_daily_task_ui:get_msgid()
    return msg_req_close_daily_task_ui
end
req_get_buff=class()
function req_get_buff:ctor()

end
function req_get_buff:encode()
    return

end
function req_get_buff:decode(binary)

    return binary
end
function req_get_buff:get_msgid()
    return msg_req_get_buff
end
player_buff_data=class()
function player_buff_data:ctor(id, rest_time)
    self.id = id
    self.rest_time = rest_time
end
function player_buff_data:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.rest_time, "int")
end
function player_buff_data:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.rest_time, binary = binary_helper.to_value(binary, "int")
    return binary
end
function player_buff_data:get_msgid()
    return msg_player_buff_data
end
notify_player_buff=class()
function notify_player_buff:ctor(account, buffs)
    self.account = account
    self.buffs = buffs
end
function notify_player_buff:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.array_to_binary(self.buffs, "user_define")
end
function notify_player_buff:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.buffs, binary = binary_helper.to_array(binary,player_buff_data)
    return binary
end
function notify_player_buff:get_msgid()
    return msg_notify_player_buff
end
notify_add_buff=class()
function notify_add_buff:ctor(buff)
    self.buff = buff
end
function notify_add_buff:encode()
    return
        binary_helper.to_binary(self.buff, "user_define")
end
function notify_add_buff:decode(binary)
    self.buff, binary = binary_helper.to_value(binary,player_buff_data)
    return binary
end
function notify_add_buff:get_msgid()
    return msg_notify_add_buff
end
pub_account_info=class()
function pub_account_info:ctor(account, name, level)
    self.account = account
    self.name = name
    self.level = level
end
function pub_account_info:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.name, "string") ..
        binary_helper.to_binary(self.level, "int")
end
function pub_account_info:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.name, binary = binary_helper.to_value(binary, "string")
    self.level, binary = binary_helper.to_value(binary, "int")
    return binary
end
function pub_account_info:get_msgid()
    return msg_pub_account_info
end
pub_info=class()
function pub_info:ctor(pub_id, owner_info, pub_name, person_count1, person_count2, max_person, status, admin_list, voice_id)
    self.pub_id = pub_id
    self.owner_info = owner_info
    self.pub_name = pub_name
    self.person_count1 = person_count1
    self.person_count2 = person_count2
    self.max_person = max_person
    self.status = status
    self.admin_list = admin_list
    self.voice_id = voice_id
end
function pub_info:encode()
    return
        binary_helper.to_binary(self.pub_id, "uint64") ..
        binary_helper.to_binary(self.owner_info, "user_define") ..
        binary_helper.to_binary(self.pub_name, "string") ..
        binary_helper.to_binary(self.person_count1, "int") ..
        binary_helper.to_binary(self.person_count2, "int") ..
        binary_helper.to_binary(self.max_person, "int") ..
        binary_helper.to_binary(self.status, "int") ..
        binary_helper.array_to_binary(self.admin_list, "user_define") ..
        binary_helper.to_binary(self.voice_id, "uint64")
end
function pub_info:decode(binary)
    self.pub_id, binary = binary_helper.to_value(binary, "uint64")
    self.owner_info, binary = binary_helper.to_value(binary,pub_account_info)
    self.pub_name, binary = binary_helper.to_value(binary, "string")
    self.person_count1, binary = binary_helper.to_value(binary, "int")
    self.person_count2, binary = binary_helper.to_value(binary, "int")
    self.max_person, binary = binary_helper.to_value(binary, "int")
    self.status, binary = binary_helper.to_value(binary, "int")
    self.admin_list, binary = binary_helper.to_array(binary,pub_account_info)
    self.voice_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function pub_info:get_msgid()
    return msg_pub_info
end
req_pub_list=class()
function req_pub_list:ctor(page)
    self.page = page
end
function req_pub_list:encode()
    return
        binary_helper.to_binary(self.page, "int")
end
function req_pub_list:decode(binary)
    self.page, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_pub_list:get_msgid()
    return msg_req_pub_list
end
notify_pub_list=class()
function notify_pub_list:ctor(my_channel_id, max_page, pubs)
    self.my_channel_id = my_channel_id
    self.max_page = max_page
    self.pubs = pubs
end
function notify_pub_list:encode()
    return
        binary_helper.to_binary(self.my_channel_id, "uint64") ..
        binary_helper.to_binary(self.max_page, "int") ..
        binary_helper.array_to_binary(self.pubs, "user_define")
end
function notify_pub_list:decode(binary)
    self.my_channel_id, binary = binary_helper.to_value(binary, "uint64")
    self.max_page, binary = binary_helper.to_value(binary, "int")
    self.pubs, binary = binary_helper.to_array(binary,pub_info)
    return binary
end
function notify_pub_list:get_msgid()
    return msg_notify_pub_list
end
req_leave_pub_channel=class()
function req_leave_pub_channel:ctor(pub_id)
    self.pub_id = pub_id
end
function req_leave_pub_channel:encode()
    return
        binary_helper.to_binary(self.pub_id, "uint64")
end
function req_leave_pub_channel:decode(binary)
    self.pub_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_leave_pub_channel:get_msgid()
    return msg_req_leave_pub_channel
end
req_enter_pub_channel=class()
function req_enter_pub_channel:ctor(pub_id)
    self.pub_id = pub_id
end
function req_enter_pub_channel:encode()
    return
        binary_helper.to_binary(self.pub_id, "uint64")
end
function req_enter_pub_channel:decode(binary)
    self.pub_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_enter_pub_channel:get_msgid()
    return msg_req_enter_pub_channel
end
notify_enter_pub_channel=class()
function notify_enter_pub_channel:ctor(info, accounts)
    self.info = info
    self.accounts = accounts
end
function notify_enter_pub_channel:encode()
    return
        binary_helper.to_binary(self.info, "user_define") ..
        binary_helper.array_to_binary(self.accounts, "user_define")
end
function notify_enter_pub_channel:decode(binary)
    self.info, binary = binary_helper.to_value(binary,pub_info)
    self.accounts, binary = binary_helper.to_array(binary,pub_account_info)
    return binary
end
function notify_enter_pub_channel:get_msgid()
    return msg_notify_enter_pub_channel
end
req_update_pub_voice_id=class()
function req_update_pub_voice_id:ctor(pub_id, voice_id)
    self.pub_id = pub_id
    self.voice_id = voice_id
end
function req_update_pub_voice_id:encode()
    return
        binary_helper.to_binary(self.pub_id, "uint64") ..
        binary_helper.to_binary(self.voice_id, "uint64")
end
function req_update_pub_voice_id:decode(binary)
    self.pub_id, binary = binary_helper.to_value(binary, "uint64")
    self.voice_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_update_pub_voice_id:get_msgid()
    return msg_req_update_pub_voice_id
end
notify_update_pub_voice_id=class()
function notify_update_pub_voice_id:ctor(pub_id, voice_id)
    self.pub_id = pub_id
    self.voice_id = voice_id
end
function notify_update_pub_voice_id:encode()
    return
        binary_helper.to_binary(self.pub_id, "uint64") ..
        binary_helper.to_binary(self.voice_id, "uint64")
end
function notify_update_pub_voice_id:decode(binary)
    self.pub_id, binary = binary_helper.to_value(binary, "uint64")
    self.voice_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function notify_update_pub_voice_id:get_msgid()
    return msg_notify_update_pub_voice_id
end
req_chat_channel=class()
function req_chat_channel:ctor(channel_id, content)
    self.channel_id = channel_id
    self.content = content
end
function req_chat_channel:encode()
    return
        binary_helper.to_binary(self.channel_id, "uint64") ..
        binary_helper.to_binary(self.content, "string")
end
function req_chat_channel:decode(binary)
    self.channel_id, binary = binary_helper.to_value(binary, "uint64")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_chat_channel:get_msgid()
    return msg_req_chat_channel
end
notify_chat_channel=class()
function notify_chat_channel:ctor(channel_id, account, player_name, content)
    self.channel_id = channel_id
    self.account = account
    self.player_name = player_name
    self.content = content
end
function notify_chat_channel:encode()
    return
        binary_helper.to_binary(self.channel_id, "uint64") ..
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.player_name, "string") ..
        binary_helper.to_binary(self.content, "string")
end
function notify_chat_channel:decode(binary)
    self.channel_id, binary = binary_helper.to_value(binary, "uint64")
    self.account, binary = binary_helper.to_value(binary, "string")
    self.player_name, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_chat_channel:get_msgid()
    return msg_notify_chat_channel
end
notify_channel_add_player=class()
function notify_channel_add_player:ctor(channel_id, account_info)
    self.channel_id = channel_id
    self.account_info = account_info
end
function notify_channel_add_player:encode()
    return
        binary_helper.to_binary(self.channel_id, "uint64") ..
        binary_helper.to_binary(self.account_info, "user_define")
end
function notify_channel_add_player:decode(binary)
    self.channel_id, binary = binary_helper.to_value(binary, "uint64")
    self.account_info, binary = binary_helper.to_value(binary,pub_account_info)
    return binary
end
function notify_channel_add_player:get_msgid()
    return msg_notify_channel_add_player
end
notify_channel_del_player=class()
function notify_channel_del_player:ctor(channel_id, account)
    self.channel_id = channel_id
    self.account = account
end
function notify_channel_del_player:encode()
    return
        binary_helper.to_binary(self.channel_id, "uint64") ..
        binary_helper.to_binary(self.account, "string")
end
function notify_channel_del_player:decode(binary)
    self.channel_id, binary = binary_helper.to_value(binary, "uint64")
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_channel_del_player:get_msgid()
    return msg_notify_channel_del_player
end
req_channel_tell=class()
function req_channel_tell:ctor(target_player, content)
    self.target_player = target_player
    self.content = content
end
function req_channel_tell:encode()
    return
        binary_helper.to_binary(self.target_player, "string") ..
        binary_helper.to_binary(self.content, "string")
end
function req_channel_tell:decode(binary)
    self.target_player, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_channel_tell:get_msgid()
    return msg_req_channel_tell
end
notify_channel_tell=class()
function notify_channel_tell:ctor(speaker, speaker_name, content)
    self.speaker = speaker
    self.speaker_name = speaker_name
    self.content = content
end
function notify_channel_tell:encode()
    return
        binary_helper.to_binary(self.speaker, "string") ..
        binary_helper.to_binary(self.speaker_name, "string") ..
        binary_helper.to_binary(self.content, "string")
end
function notify_channel_tell:decode(binary)
    self.speaker, binary = binary_helper.to_value(binary, "string")
    self.speaker_name, binary = binary_helper.to_value(binary, "string")
    self.content, binary = binary_helper.to_value(binary, "string")
    return binary
end
function notify_channel_tell:get_msgid()
    return msg_notify_channel_tell
end
broadcast_kick_pub_player=class()
function broadcast_kick_pub_player:ctor(kicker, be_kicket)
    self.kicker = kicker
    self.be_kicket = be_kicket
end
function broadcast_kick_pub_player:encode()
    return
        binary_helper.to_binary(self.kicker, "string") ..
        binary_helper.to_binary(self.be_kicket, "string")
end
function broadcast_kick_pub_player:decode(binary)
    self.kicker, binary = binary_helper.to_value(binary, "string")
    self.be_kicket, binary = binary_helper.to_value(binary, "string")
    return binary
end
function broadcast_kick_pub_player:get_msgid()
    return msg_broadcast_kick_pub_player
end
notify_update_pub_player_count=class()
function notify_update_pub_player_count:ctor(person_count1, max_count1, person_count2, max_count2)
    self.person_count1 = person_count1
    self.max_count1 = max_count1
    self.person_count2 = person_count2
    self.max_count2 = max_count2
end
function notify_update_pub_player_count:encode()
    return
        binary_helper.to_binary(self.person_count1, "int") ..
        binary_helper.to_binary(self.max_count1, "int") ..
        binary_helper.to_binary(self.person_count2, "int") ..
        binary_helper.to_binary(self.max_count2, "int")
end
function notify_update_pub_player_count:decode(binary)
    self.person_count1, binary = binary_helper.to_value(binary, "int")
    self.max_count1, binary = binary_helper.to_value(binary, "int")
    self.person_count2, binary = binary_helper.to_value(binary, "int")
    self.max_count2, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_update_pub_player_count:get_msgid()
    return msg_notify_update_pub_player_count
end
req_send_yy_gift=class()
function req_send_yy_gift:ctor(recver_account, gift_id, gift_count)
    self.recver_account = recver_account
    self.gift_id = gift_id
    self.gift_count = gift_count
end
function req_send_yy_gift:encode()
    return
        binary_helper.to_binary(self.recver_account, "string") ..
        binary_helper.to_binary(self.gift_id, "int") ..
        binary_helper.to_binary(self.gift_count, "int")
end
function req_send_yy_gift:decode(binary)
    self.recver_account, binary = binary_helper.to_value(binary, "string")
    self.gift_id, binary = binary_helper.to_value(binary, "int")
    self.gift_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_send_yy_gift:get_msgid()
    return msg_req_send_yy_gift
end
broadcast_send_yy_gift=class()
function broadcast_send_yy_gift:ctor(gift_id, gift_count, sender_info, recver_info)
    self.gift_id = gift_id
    self.gift_count = gift_count
    self.sender_info = sender_info
    self.recver_info = recver_info
end
function broadcast_send_yy_gift:encode()
    return
        binary_helper.to_binary(self.gift_id, "int") ..
        binary_helper.to_binary(self.gift_count, "int") ..
        binary_helper.to_binary(self.sender_info, "user_define") ..
        binary_helper.to_binary(self.recver_info, "user_define")
end
function broadcast_send_yy_gift:decode(binary)
    self.gift_id, binary = binary_helper.to_value(binary, "int")
    self.gift_count, binary = binary_helper.to_value(binary, "int")
    self.sender_info, binary = binary_helper.to_value(binary,pub_account_info)
    self.recver_info, binary = binary_helper.to_value(binary,pub_account_info)
    return binary
end
function broadcast_send_yy_gift:get_msgid()
    return msg_broadcast_send_yy_gift
end
req_kick_channel_player=class()
function req_kick_channel_player:ctor(account)
    self.account = account
end
function req_kick_channel_player:encode()
    return
        binary_helper.to_binary(self.account, "string")
end
function req_kick_channel_player:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    return binary
end
function req_kick_channel_player:get_msgid()
    return msg_req_kick_channel_player
end
notify_unlock_furniture_list=class()
function notify_unlock_furniture_list:ctor(unlock_list)
    self.unlock_list = unlock_list
end
function notify_unlock_furniture_list:encode()
    return
        binary_helper.array_to_binary(self.unlock_list, "int")
end
function notify_unlock_furniture_list:decode(binary)
    self.unlock_list, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_unlock_furniture_list:get_msgid()
    return msg_notify_unlock_furniture_list
end
req_unlock_furniture=class()
function req_unlock_furniture:ctor(id)
    self.id = id
end
function req_unlock_furniture:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_unlock_furniture:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_unlock_furniture:get_msgid()
    return msg_req_unlock_furniture
end
notify_unlock_furniture=class()
function notify_unlock_furniture:ctor()

end
function notify_unlock_furniture:encode()
    return

end
function notify_unlock_furniture:decode(binary)

    return binary
end
function notify_unlock_furniture:get_msgid()
    return msg_notify_unlock_furniture
end
req_exchange=class()
function req_exchange:ctor(id)
    self.id = id
end
function req_exchange:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_exchange:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_exchange:get_msgid()
    return msg_req_exchange
end
notify_exchange=class()
function notify_exchange:ctor()

end
function notify_exchange:encode()
    return

end
function notify_exchange:decode(binary)

    return binary
end
function notify_exchange:get_msgid()
    return msg_notify_exchange
end
notify_friend_intimate=class()
function notify_friend_intimate:ctor(account, intimate)
    self.account = account
    self.intimate = intimate
end
function notify_friend_intimate:encode()
    return
        binary_helper.to_binary(self.account, "string") ..
        binary_helper.to_binary(self.intimate, "int")
end
function notify_friend_intimate:decode(binary)
    self.account, binary = binary_helper.to_value(binary, "string")
    self.intimate, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_friend_intimate:get_msgid()
    return msg_notify_friend_intimate
end
req_flower_shake=class()
function req_flower_shake:ctor(house_id, shake_count, enable_props)
    self.house_id = house_id
    self.shake_count = shake_count
    self.enable_props = enable_props
end
function req_flower_shake:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64") ..
        binary_helper.to_binary(self.shake_count, "int") ..
        binary_helper.to_binary(self.enable_props, "int")
end
function req_flower_shake:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    self.shake_count, binary = binary_helper.to_value(binary, "int")
    self.enable_props, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_flower_shake:get_msgid()
    return msg_req_flower_shake
end
req_flower_love_coin_shake=class()
function req_flower_love_coin_shake:ctor(house_id)
    self.house_id = house_id
end
function req_flower_love_coin_shake:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_flower_love_coin_shake:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_flower_love_coin_shake:get_msgid()
    return msg_req_flower_love_coin_shake
end
notify_flower_shake=class()
function notify_flower_shake:ctor(diamond, exp, items, shake_prop_count, free_shake)
    self.diamond = diamond
    self.exp = exp
    self.items = items
    self.shake_prop_count = shake_prop_count
    self.free_shake = free_shake
end
function notify_flower_shake:encode()
    return
        binary_helper.to_binary(self.diamond, "int") ..
        binary_helper.to_binary(self.exp, "int") ..
        binary_helper.array_to_binary(self.items, "user_define") ..
        binary_helper.to_binary(self.shake_prop_count, "int") ..
        binary_helper.to_binary(self.free_shake, "int")
end
function notify_flower_shake:decode(binary)
    self.diamond, binary = binary_helper.to_value(binary, "int")
    self.exp, binary = binary_helper.to_value(binary, "int")
    self.items, binary = binary_helper.to_array(binary,lottery_item)
    self.shake_prop_count, binary = binary_helper.to_value(binary, "int")
    self.free_shake, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_flower_shake:get_msgid()
    return msg_notify_flower_shake
end
notify_flower_shake_prop_required=class()
function notify_flower_shake_prop_required:ctor()

end
function notify_flower_shake_prop_required:encode()
    return

end
function notify_flower_shake_prop_required:decode(binary)

    return binary
end
function notify_flower_shake_prop_required:get_msgid()
    return msg_notify_flower_shake_prop_required
end
req_flower_shaked=class()
function req_flower_shaked:ctor(house_id)
    self.house_id = house_id
end
function req_flower_shaked:encode()
    return
        binary_helper.to_binary(self.house_id, "uint64")
end
function req_flower_shaked:decode(binary)
    self.house_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_flower_shaked:get_msgid()
    return msg_req_flower_shaked
end
notify_flower_shaked=class()
function notify_flower_shaked:ctor(free_shake, total_shake_count, free_shake_time)
    self.free_shake = free_shake
    self.total_shake_count = total_shake_count
    self.free_shake_time = free_shake_time
end
function notify_flower_shaked:encode()
    return
        binary_helper.to_binary(self.free_shake, "int") ..
        binary_helper.to_binary(self.total_shake_count, "int") ..
        binary_helper.to_binary(self.free_shake_time, "int")
end
function notify_flower_shaked:decode(binary)
    self.free_shake, binary = binary_helper.to_value(binary, "int")
    self.total_shake_count, binary = binary_helper.to_value(binary, "int")
    self.free_shake_time, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_flower_shaked:get_msgid()
    return msg_notify_flower_shaked
end
notify_flower_love_coin_shaked=class()
function notify_flower_love_coin_shaked:ctor(total_shake_count, love_coin_shake)
    self.total_shake_count = total_shake_count
    self.love_coin_shake = love_coin_shake
end
function notify_flower_love_coin_shaked:encode()
    return
        binary_helper.to_binary(self.total_shake_count, "int") ..
        binary_helper.to_binary(self.love_coin_shake, "int")
end
function notify_flower_love_coin_shaked:decode(binary)
    self.total_shake_count, binary = binary_helper.to_value(binary, "int")
    self.love_coin_shake, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_flower_love_coin_shaked:get_msgid()
    return msg_notify_flower_love_coin_shaked
end
notify_flower_shake_overflow=class()
function notify_flower_shake_overflow:ctor(available)
    self.available = available
end
function notify_flower_shake_overflow:encode()
    return
        binary_helper.to_binary(self.available, "int")
end
function notify_flower_shake_overflow:decode(binary)
    self.available, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_flower_shake_overflow:get_msgid()
    return msg_notify_flower_shake_overflow
end
req_first_payment_return_status=class()
function req_first_payment_return_status:ctor()

end
function req_first_payment_return_status:encode()
    return

end
function req_first_payment_return_status:decode(binary)

    return binary
end
function req_first_payment_return_status:get_msgid()
    return msg_req_first_payment_return_status
end
notify_first_payment_return_status=class()
function notify_first_payment_return_status:ctor(returned)
    self.returned = returned
end
function notify_first_payment_return_status:encode()
    return
        binary_helper.to_binary(self.returned, "int")
end
function notify_first_payment_return_status:decode(binary)
    self.returned, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_first_payment_return_status:get_msgid()
    return msg_notify_first_payment_return_status
end
req_first_payment_return_reward=class()
function req_first_payment_return_reward:ctor()

end
function req_first_payment_return_reward:encode()
    return

end
function req_first_payment_return_reward:decode(binary)

    return binary
end
function req_first_payment_return_reward:get_msgid()
    return msg_req_first_payment_return_reward
end
notify_first_payment_return_reward=class()
function notify_first_payment_return_reward:ctor(returned)
    self.returned = returned
end
function notify_first_payment_return_reward:encode()
    return
        binary_helper.to_binary(self.returned, "int")
end
function notify_first_payment_return_reward:decode(binary)
    self.returned, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_first_payment_return_reward:get_msgid()
    return msg_notify_first_payment_return_reward
end
single_payment_return_item=class()
function single_payment_return_item:ctor(return_diamond, return_count)
    self.return_diamond = return_diamond
    self.return_count = return_count
end
function single_payment_return_item:encode()
    return
        binary_helper.to_binary(self.return_diamond, "int") ..
        binary_helper.to_binary(self.return_count, "int")
end
function single_payment_return_item:decode(binary)
    self.return_diamond, binary = binary_helper.to_value(binary, "int")
    self.return_count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function single_payment_return_item:get_msgid()
    return msg_single_payment_return_item
end
req_single_payment_return=class()
function req_single_payment_return:ctor()

end
function req_single_payment_return:encode()
    return

end
function req_single_payment_return:decode(binary)

    return binary
end
function req_single_payment_return:get_msgid()
    return msg_req_single_payment_return
end
notify_single_payment_return=class()
function notify_single_payment_return:ctor(items)
    self.items = items
end
function notify_single_payment_return:encode()
    return
        binary_helper.array_to_binary(self.items, "user_define")
end
function notify_single_payment_return:decode(binary)
    self.items, binary = binary_helper.to_array(binary,single_payment_return_item)
    return binary
end
function notify_single_payment_return:get_msgid()
    return msg_notify_single_payment_return
end
req_single_payment_return_reward=class()
function req_single_payment_return_reward:ctor(return_diamond)
    self.return_diamond = return_diamond
end
function req_single_payment_return_reward:encode()
    return
        binary_helper.to_binary(self.return_diamond, "int")
end
function req_single_payment_return_reward:decode(binary)
    self.return_diamond, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_single_payment_return_reward:get_msgid()
    return msg_req_single_payment_return_reward
end
notify_single_payment_return_reward=class()
function notify_single_payment_return_reward:ctor(returned)
    self.returned = returned
end
function notify_single_payment_return_reward:encode()
    return
        binary_helper.to_binary(self.returned, "int")
end
function notify_single_payment_return_reward:decode(binary)
    self.returned, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_single_payment_return_reward:get_msgid()
    return msg_notify_single_payment_return_reward
end
total_payment_return_item=class()
function total_payment_return_item:ctor(consume_amount, return_items, returned)
    self.consume_amount = consume_amount
    self.return_items = return_items
    self.returned = returned
end
function total_payment_return_item:encode()
    return
        binary_helper.to_binary(self.consume_amount, "int") ..
        binary_helper.array_to_binary(self.return_items, "user_define") ..
        binary_helper.to_binary(self.returned, "int")
end
function total_payment_return_item:decode(binary)
    self.consume_amount, binary = binary_helper.to_value(binary, "int")
    self.return_items, binary = binary_helper.to_array(binary,lottery_item)
    self.returned, binary = binary_helper.to_value(binary, "int")
    return binary
end
function total_payment_return_item:get_msgid()
    return msg_total_payment_return_item
end
req_total_payment_return=class()
function req_total_payment_return:ctor()

end
function req_total_payment_return:encode()
    return

end
function req_total_payment_return:decode(binary)

    return binary
end
function req_total_payment_return:get_msgid()
    return msg_req_total_payment_return
end
notify_total_payment_return=class()
function notify_total_payment_return:ctor(total_amount, items)
    self.total_amount = total_amount
    self.items = items
end
function notify_total_payment_return:encode()
    return
        binary_helper.to_binary(self.total_amount, "int") ..
        binary_helper.array_to_binary(self.items, "user_define")
end
function notify_total_payment_return:decode(binary)
    self.total_amount, binary = binary_helper.to_value(binary, "int")
    self.items, binary = binary_helper.to_array(binary,total_payment_return_item)
    return binary
end
function notify_total_payment_return:get_msgid()
    return msg_notify_total_payment_return
end
req_total_payment_return_reward=class()
function req_total_payment_return_reward:ctor(consume_amount)
    self.consume_amount = consume_amount
end
function req_total_payment_return_reward:encode()
    return
        binary_helper.to_binary(self.consume_amount, "int")
end
function req_total_payment_return_reward:decode(binary)
    self.consume_amount, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_total_payment_return_reward:get_msgid()
    return msg_req_total_payment_return_reward
end
notify_total_payment_return_reward=class()
function notify_total_payment_return_reward:ctor(returned)
    self.returned = returned
end
function notify_total_payment_return_reward:encode()
    return
        binary_helper.to_binary(self.returned, "int")
end
function notify_total_payment_return_reward:decode(binary)
    self.returned, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_total_payment_return_reward:get_msgid()
    return msg_notify_total_payment_return_reward
end
req_item_upgrade=class()
function req_item_upgrade:ctor(instance_id)
    self.instance_id = instance_id
end
function req_item_upgrade:encode()
    return
        binary_helper.to_binary(self.instance_id, "uint64")
end
function req_item_upgrade:decode(binary)
    self.instance_id, binary = binary_helper.to_value(binary, "uint64")
    return binary
end
function req_item_upgrade:get_msgid()
    return msg_req_item_upgrade
end
notify_item_upgrade=class()
function notify_item_upgrade:ctor(upgrade_item_instanceid, result)
    self.upgrade_item_instanceid = upgrade_item_instanceid
    self.result = result
end
function notify_item_upgrade:encode()
    return
        binary_helper.to_binary(self.upgrade_item_instanceid, "uint64") ..
        binary_helper.to_binary(self.result, "int")
end
function notify_item_upgrade:decode(binary)
    self.upgrade_item_instanceid, binary = binary_helper.to_value(binary, "uint64")
    self.result, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_item_upgrade:get_msgid()
    return msg_notify_item_upgrade
end
req_mutli_item_upgrade=class()
function req_mutli_item_upgrade:ctor(inst_ids)
    self.inst_ids = inst_ids
end
function req_mutli_item_upgrade:encode()
    return
        binary_helper.array_to_binary(self.inst_ids, "uint64")
end
function req_mutli_item_upgrade:decode(binary)
    self.inst_ids, binary = binary_helper.to_array(binary, "uint64")
    return binary
end
function req_mutli_item_upgrade:get_msgid()
    return msg_req_mutli_item_upgrade
end
notify_mutli_item_upgrade=class()
function notify_mutli_item_upgrade:ctor(furnitures, decoration)
    self.furnitures = furnitures
    self.decoration = decoration
end
function notify_mutli_item_upgrade:encode()
    return
        binary_helper.array_to_binary(self.furnitures, "user_define") ..
        binary_helper.to_binary(self.decoration, "int")
end
function notify_mutli_item_upgrade:decode(binary)
    self.furnitures, binary = binary_helper.to_array(binary,house_furniture)
    self.decoration, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_mutli_item_upgrade:get_msgid()
    return msg_notify_mutli_item_upgrade
end
notify_make_up_info=class()
function notify_make_up_info:ctor(level)
    self.level = level
end
function notify_make_up_info:encode()
    return
        binary_helper.to_binary(self.level, "int")
end
function notify_make_up_info:decode(binary)
    self.level, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_make_up_info:get_msgid()
    return msg_notify_make_up_info
end
req_enter_pub_scene=class()
function req_enter_pub_scene:ctor()

end
function req_enter_pub_scene:encode()
    return

end
function req_enter_pub_scene:decode(binary)

    return binary
end
function req_enter_pub_scene:get_msgid()
    return msg_req_enter_pub_scene
end
notify_enter_pub_scene=class()
function notify_enter_pub_scene:ctor(template_id, info, accounts, enter_pos)
    self.template_id = template_id
    self.info = info
    self.accounts = accounts
    self.enter_pos = enter_pos
end
function notify_enter_pub_scene:encode()
    return
        binary_helper.to_binary(self.template_id, "int") ..
        binary_helper.to_binary(self.info, "user_define") ..
        binary_helper.array_to_binary(self.accounts, "user_define") ..
        binary_helper.to_binary(self.enter_pos, "user_define")
end
function notify_enter_pub_scene:decode(binary)
    self.template_id, binary = binary_helper.to_value(binary, "int")
    self.info, binary = binary_helper.to_value(binary,pub_info)
    self.accounts, binary = binary_helper.to_array(binary,pub_account_info)
    self.enter_pos, binary = binary_helper.to_value(binary,point)
    return binary
end
function notify_enter_pub_scene:get_msgid()
    return msg_notify_enter_pub_scene
end
req_get_sprites=class()
function req_get_sprites:ctor()

end
function req_get_sprites:encode()
    return

end
function req_get_sprites:decode(binary)

    return binary
end
function req_get_sprites:get_msgid()
    return msg_req_get_sprites
end
req_click_sprite=class()
function req_click_sprite:ctor(id)
    self.id = id
end
function req_click_sprite:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_click_sprite:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_click_sprite:get_msgid()
    return msg_req_click_sprite
end
sprite=class()
function sprite:ctor(id, curr_exp, level, remain_time)
    self.id = id
    self.curr_exp = curr_exp
    self.level = level
    self.remain_time = remain_time
end
function sprite:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.curr_exp, "int") ..
        binary_helper.to_binary(self.level, "int") ..
        binary_helper.to_binary(self.remain_time, "int")
end
function sprite:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.curr_exp, binary = binary_helper.to_value(binary, "int")
    self.level, binary = binary_helper.to_value(binary, "int")
    self.remain_time, binary = binary_helper.to_value(binary, "int")
    return binary
end
function sprite:get_msgid()
    return msg_sprite
end
notify_sprite_data=class()
function notify_sprite_data:ctor(appraise, sprites)
    self.appraise = appraise
    self.sprites = sprites
end
function notify_sprite_data:encode()
    return
        binary_helper.to_binary(self.appraise, "int") ..
        binary_helper.array_to_binary(self.sprites, "user_define")
end
function notify_sprite_data:decode(binary)
    self.appraise, binary = binary_helper.to_value(binary, "int")
    self.sprites, binary = binary_helper.to_array(binary,sprite)
    return binary
end
function notify_sprite_data:get_msgid()
    return msg_notify_sprite_data
end
notify_del_sprite=class()
function notify_del_sprite:ctor(id, del)
    self.id = id
    self.del = del
end
function notify_del_sprite:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.del, "int")
end
function notify_del_sprite:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.del, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_del_sprite:get_msgid()
    return msg_notify_del_sprite
end
req_click_guest=class()
function req_click_guest:ctor(appraise)
    self.appraise = appraise
end
function req_click_guest:encode()
    return
        binary_helper.to_binary(self.appraise, "int")
end
function req_click_guest:decode(binary)
    self.appraise, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_click_guest:get_msgid()
    return msg_req_click_guest
end
notify_can_click_guest=class()
function notify_can_click_guest:ctor(canClick)
    self.canClick = canClick
end
function notify_can_click_guest:encode()
    return
        binary_helper.to_binary(self.canClick, "int")
end
function notify_can_click_guest:decode(binary)
    self.canClick, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_can_click_guest:get_msgid()
    return msg_notify_can_click_guest
end
notify_sprite_upgrade=class()
function notify_sprite_upgrade:ctor(id, level)
    self.id = id
    self.level = level
end
function notify_sprite_upgrade:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.level, "int")
end
function notify_sprite_upgrade:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.level, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_sprite_upgrade:get_msgid()
    return msg_notify_sprite_upgrade
end
req_unlock_food=class()
function req_unlock_food:ctor(id)
    self.id = id
end
function req_unlock_food:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_unlock_food:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_unlock_food:get_msgid()
    return msg_req_unlock_food
end
notify_unlock_food=class()
function notify_unlock_food:ctor(id)
    self.id = id
end
function notify_unlock_food:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function notify_unlock_food:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_unlock_food:get_msgid()
    return msg_notify_unlock_food
end
req_unlock_food_info=class()
function req_unlock_food_info:ctor()

end
function req_unlock_food_info:encode()
    return

end
function req_unlock_food_info:decode(binary)

    return binary
end
function req_unlock_food_info:get_msgid()
    return msg_req_unlock_food_info
end
notify_unlock_food_info=class()
function notify_unlock_food_info:ctor(ids)
    self.ids = ids
end
function notify_unlock_food_info:encode()
    return
        binary_helper.array_to_binary(self.ids, "int")
end
function notify_unlock_food_info:decode(binary)
    self.ids, binary = binary_helper.to_array(binary, "int")
    return binary
end
function notify_unlock_food_info:get_msgid()
    return msg_notify_unlock_food_info
end
req_expand_food_stock=class()
function req_expand_food_stock:ctor(id)
    self.id = id
end
function req_expand_food_stock:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_expand_food_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_expand_food_stock:get_msgid()
    return msg_req_expand_food_stock
end
food_stock_info=class()
function food_stock_info:ctor(id, size, value, seconds, due_time)
    self.id = id
    self.size = size
    self.value = value
    self.seconds = seconds
    self.due_time = due_time
end
function food_stock_info:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.size, "int") ..
        binary_helper.to_binary(self.value, "int") ..
        binary_helper.to_binary(self.seconds, "int") ..
        binary_helper.to_binary(self.due_time, "user_define")
end
function food_stock_info:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.size, binary = binary_helper.to_value(binary, "int")
    self.value, binary = binary_helper.to_value(binary, "int")
    self.seconds, binary = binary_helper.to_value(binary, "int")
    self.due_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function food_stock_info:get_msgid()
    return msg_food_stock_info
end
notify_expand_food_stock=class()
function notify_expand_food_stock:ctor(id, due_time)
    self.id = id
    self.due_time = due_time
end
function notify_expand_food_stock:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.due_time, "user_define")
end
function notify_expand_food_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.due_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_expand_food_stock:get_msgid()
    return msg_notify_expand_food_stock
end
notify_settlement_expand_food_stock=class()
function notify_settlement_expand_food_stock:ctor(id, size)
    self.id = id
    self.size = size
end
function notify_settlement_expand_food_stock:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.size, "int")
end
function notify_settlement_expand_food_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.size, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_settlement_expand_food_stock:get_msgid()
    return msg_notify_settlement_expand_food_stock
end
req_food_stock_info=class()
function req_food_stock_info:ctor()

end
function req_food_stock_info:encode()
    return

end
function req_food_stock_info:decode(binary)

    return binary
end
function req_food_stock_info:get_msgid()
    return msg_req_food_stock_info
end
notify_food_stock_info=class()
function notify_food_stock_info:ctor(stock_info)
    self.stock_info = stock_info
end
function notify_food_stock_info:encode()
    return
        binary_helper.array_to_binary(self.stock_info, "user_define")
end
function notify_food_stock_info:decode(binary)
    self.stock_info, binary = binary_helper.to_array(binary,food_stock_info)
    return binary
end
function notify_food_stock_info:get_msgid()
    return msg_notify_food_stock_info
end
req_cancel_expand_food_stock=class()
function req_cancel_expand_food_stock:ctor(id)
    self.id = id
end
function req_cancel_expand_food_stock:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_cancel_expand_food_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_cancel_expand_food_stock:get_msgid()
    return msg_req_cancel_expand_food_stock
end
notify_cancel_expand_food_stock=class()
function notify_cancel_expand_food_stock:ctor(id)
    self.id = id
end
function notify_cancel_expand_food_stock:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function notify_cancel_expand_food_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_cancel_expand_food_stock:get_msgid()
    return msg_notify_cancel_expand_food_stock
end
req_complete_expand_food_stock=class()
function req_complete_expand_food_stock:ctor(id, grid_index)
    self.id = id
    self.grid_index = grid_index
end
function req_complete_expand_food_stock:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.grid_index, "int")
end
function req_complete_expand_food_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.grid_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_complete_expand_food_stock:get_msgid()
    return msg_req_complete_expand_food_stock
end
notify_complete_expand_food_stock=class()
function notify_complete_expand_food_stock:ctor(id, grid_index)
    self.id = id
    self.grid_index = grid_index
end
function notify_complete_expand_food_stock:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.grid_index, "int")
end
function notify_complete_expand_food_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.grid_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_complete_expand_food_stock:get_msgid()
    return msg_notify_complete_expand_food_stock
end
req_immediately_complete_expand_stock=class()
function req_immediately_complete_expand_stock:ctor(id, grid_index)
    self.id = id
    self.grid_index = grid_index
end
function req_immediately_complete_expand_stock:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.grid_index, "int")
end
function req_immediately_complete_expand_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.grid_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_immediately_complete_expand_stock:get_msgid()
    return msg_req_immediately_complete_expand_stock
end
notify_immediately_complete_expand_stock=class()
function notify_immediately_complete_expand_stock:ctor(id, grid_index)
    self.id = id
    self.grid_index = grid_index
end
function notify_immediately_complete_expand_stock:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.grid_index, "int")
end
function notify_immediately_complete_expand_stock:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.grid_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_immediately_complete_expand_stock:get_msgid()
    return msg_notify_immediately_complete_expand_stock
end
req_expand_produce_area=class()
function req_expand_produce_area:ctor(grid_index)
    self.grid_index = grid_index
end
function req_expand_produce_area:encode()
    return
        binary_helper.to_binary(self.grid_index, "int")
end
function req_expand_produce_area:decode(binary)
    self.grid_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_expand_produce_area:get_msgid()
    return msg_req_expand_produce_area
end
notify_expand_produce_area=class()
function notify_expand_produce_area:ctor(number, grid_index)
    self.number = number
    self.grid_index = grid_index
end
function notify_expand_produce_area:encode()
    return
        binary_helper.to_binary(self.number, "int") ..
        binary_helper.to_binary(self.grid_index, "int")
end
function notify_expand_produce_area:decode(binary)
    self.number, binary = binary_helper.to_value(binary, "int")
    self.grid_index, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_expand_produce_area:get_msgid()
    return msg_notify_expand_produce_area
end
req_produce_area=class()
function req_produce_area:ctor()

end
function req_produce_area:encode()
    return

end
function req_produce_area:decode(binary)

    return binary
end
function req_produce_area:get_msgid()
    return msg_req_produce_area
end
notify_produce_area=class()
function notify_produce_area:ctor(number)
    self.number = number
end
function notify_produce_area:encode()
    return
        binary_helper.to_binary(self.number, "int")
end
function notify_produce_area:decode(binary)
    self.number, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_produce_area:get_msgid()
    return msg_notify_produce_area
end
req_upgrade_food=class()
function req_upgrade_food:ctor(id)
    self.id = id
end
function req_upgrade_food:encode()
    return
        binary_helper.to_binary(self.id, "int")
end
function req_upgrade_food:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_upgrade_food:get_msgid()
    return msg_req_upgrade_food
end
notify_upgrade_food=class()
function notify_upgrade_food:ctor(id, upgrade_id)
    self.id = id
    self.upgrade_id = upgrade_id
end
function notify_upgrade_food:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.upgrade_id, "int")
end
function notify_upgrade_food:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.upgrade_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_upgrade_food:get_msgid()
    return msg_notify_upgrade_food
end
food_upgrade_info=class()
function food_upgrade_info:ctor(id, upgrade_id)
    self.id = id
    self.upgrade_id = upgrade_id
end
function food_upgrade_info:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.upgrade_id, "int")
end
function food_upgrade_info:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.upgrade_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function food_upgrade_info:get_msgid()
    return msg_food_upgrade_info
end
req_food_upgrade_info=class()
function req_food_upgrade_info:ctor()

end
function req_food_upgrade_info:encode()
    return

end
function req_food_upgrade_info:decode(binary)

    return binary
end
function req_food_upgrade_info:get_msgid()
    return msg_req_food_upgrade_info
end
notify_food_upgrade_info=class()
function notify_food_upgrade_info:ctor(upgrade_info)
    self.upgrade_info = upgrade_info
end
function notify_food_upgrade_info:encode()
    return
        binary_helper.array_to_binary(self.upgrade_info, "user_define")
end
function notify_food_upgrade_info:decode(binary)
    self.upgrade_info, binary = binary_helper.to_array(binary,food_upgrade_info)
    return binary
end
function notify_food_upgrade_info:get_msgid()
    return msg_notify_food_upgrade_info
end
product_atom=class()
function product_atom:ctor(id, copies)
    self.id = id
    self.copies = copies
end
function product_atom:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.copies, "int")
end
function product_atom:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.copies, binary = binary_helper.to_value(binary, "int")
    return binary
end
function product_atom:get_msgid()
    return msg_product_atom
end
req_make_product=class()
function req_make_product:ctor(products, start_time)
    self.products = products
    self.start_time = start_time
end
function req_make_product:encode()
    return
        binary_helper.array_to_binary(self.products, "user_define") ..
        binary_helper.to_binary(self.start_time, "user_define")
end
function req_make_product:decode(binary)
    self.products, binary = binary_helper.to_array(binary,product_atom)
    self.start_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function req_make_product:get_msgid()
    return msg_req_make_product
end
notify_make_product=class()
function notify_make_product:ctor(start_time)
    self.start_time = start_time
end
function notify_make_product:encode()
    return
        binary_helper.to_binary(self.start_time, "user_define")
end
function notify_make_product:decode(binary)
    self.start_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_make_product:get_msgid()
    return msg_notify_make_product
end
req_remove_product=class()
function req_remove_product:ctor(position)
    self.position = position
end
function req_remove_product:encode()
    return
        binary_helper.to_binary(self.position, "int")
end
function req_remove_product:decode(binary)
    self.position, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_remove_product:get_msgid()
    return msg_req_remove_product
end
notify_remove_product=class()
function notify_remove_product:ctor(start_time)
    self.start_time = start_time
end
function notify_remove_product:encode()
    return
        binary_helper.to_binary(self.start_time, "user_define")
end
function notify_remove_product:decode(binary)
    self.start_time, binary = binary_helper.to_value(binary,stime)
    return binary
end
function notify_remove_product:get_msgid()
    return msg_notify_remove_product
end
req_complete_product=class()
function req_complete_product:ctor()

end
function req_complete_product:encode()
    return

end
function req_complete_product:decode(binary)

    return binary
end
function req_complete_product:get_msgid()
    return msg_req_complete_product
end
notify_complete_product=class()
function notify_complete_product:ctor()

end
function notify_complete_product:encode()
    return

end
function notify_complete_product:decode(binary)

    return binary
end
function notify_complete_product:get_msgid()
    return msg_notify_complete_product
end
req_immediately_complete_product=class()
function req_immediately_complete_product:ctor()

end
function req_immediately_complete_product:encode()
    return

end
function req_immediately_complete_product:decode(binary)

    return binary
end
function req_immediately_complete_product:get_msgid()
    return msg_req_immediately_complete_product
end
notify_immediately_complete_product=class()
function notify_immediately_complete_product:ctor()

end
function notify_immediately_complete_product:encode()
    return

end
function notify_immediately_complete_product:decode(binary)

    return binary
end
function notify_immediately_complete_product:get_msgid()
    return msg_notify_immediately_complete_product
end
req_products=class()
function req_products:ctor()

end
function req_products:encode()
    return

end
function req_products:decode(binary)

    return binary
end
function req_products:get_msgid()
    return msg_req_products
end
product_info=class()
function product_info:ctor(id, product_id, copies)
    self.id = id
    self.product_id = product_id
    self.copies = copies
end
function product_info:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.product_id, "int") ..
        binary_helper.to_binary(self.copies, "int")
end
function product_info:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.product_id, binary = binary_helper.to_value(binary, "int")
    self.copies, binary = binary_helper.to_value(binary, "int")
    return binary
end
function product_info:get_msgid()
    return msg_product_info
end
notify_products=class()
function notify_products:ctor(start_time, info)
    self.start_time = start_time
    self.info = info
end
function notify_products:encode()
    return
        binary_helper.to_binary(self.start_time, "user_define") ..
        binary_helper.array_to_binary(self.info, "user_define")
end
function notify_products:decode(binary)
    self.start_time, binary = binary_helper.to_value(binary,stime)
    self.info, binary = binary_helper.to_array(binary,product_info)
    return binary
end
function notify_products:get_msgid()
    return msg_notify_products
end
notify_food_settlement_diamond=class()
function notify_food_settlement_diamond:ctor(diamond)
    self.diamond = diamond
end
function notify_food_settlement_diamond:encode()
    return
        binary_helper.to_binary(self.diamond, "int")
end
function notify_food_settlement_diamond:decode(binary)
    self.diamond, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_food_settlement_diamond:get_msgid()
    return msg_notify_food_settlement_diamond
end
notify_reset_temp_diamond=class()
function notify_reset_temp_diamond:ctor()

end
function notify_reset_temp_diamond:encode()
    return

end
function notify_reset_temp_diamond:decode(binary)

    return binary
end
function notify_reset_temp_diamond:get_msgid()
    return msg_notify_reset_temp_diamond
end
req_ask_drink_count=class()
function req_ask_drink_count:ctor(drink_id)
    self.drink_id = drink_id
end
function req_ask_drink_count:encode()
    return
        binary_helper.to_binary(self.drink_id, "int")
end
function req_ask_drink_count:decode(binary)
    self.drink_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_ask_drink_count:get_msgid()
    return msg_req_ask_drink_count
end
shout_data=class()
function shout_data:ctor(id, count)
    self.id = id
    self.count = count
end
function shout_data:encode()
    return
        binary_helper.to_binary(self.id, "int") ..
        binary_helper.to_binary(self.count, "int")
end
function shout_data:decode(binary)
    self.id, binary = binary_helper.to_value(binary, "int")
    self.count, binary = binary_helper.to_value(binary, "int")
    return binary
end
function shout_data:get_msgid()
    return msg_shout_data
end
notify_drink_count=class()
function notify_drink_count:ctor(scene_player_count, cost, shout)
    self.scene_player_count = scene_player_count
    self.cost = cost
    self.shout = shout
end
function notify_drink_count:encode()
    return
        binary_helper.to_binary(self.scene_player_count, "int") ..
        binary_helper.to_binary(self.cost, "int") ..
        binary_helper.array_to_binary(self.shout, "user_define")
end
function notify_drink_count:decode(binary)
    self.scene_player_count, binary = binary_helper.to_value(binary, "int")
    self.cost, binary = binary_helper.to_value(binary, "int")
    self.shout, binary = binary_helper.to_array(binary,shout_data)
    return binary
end
function notify_drink_count:get_msgid()
    return msg_notify_drink_count
end
req_party_drink=class()
function req_party_drink:ctor(drink_id)
    self.drink_id = drink_id
end
function req_party_drink:encode()
    return
        binary_helper.to_binary(self.drink_id, "int")
end
function req_party_drink:decode(binary)
    self.drink_id, binary = binary_helper.to_value(binary, "int")
    return binary
end
function req_party_drink:get_msgid()
    return msg_req_party_drink
end
req_calc_player_charm=class()
function req_calc_player_charm:ctor()

end
function req_calc_player_charm:encode()
    return

end
function req_calc_player_charm:decode(binary)

    return binary
end
function req_calc_player_charm:get_msgid()
    return msg_req_calc_player_charm
end
notify_calc_player_charm=class()
function notify_calc_player_charm:ctor(charm)
    self.charm = charm
end
function notify_calc_player_charm:encode()
    return
        binary_helper.to_binary(self.charm, "int")
end
function notify_calc_player_charm:decode(binary)
    self.charm, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_calc_player_charm:get_msgid()
    return msg_notify_calc_player_charm
end
notify_init_party_coin=class()
function notify_init_party_coin:ctor(coin)
    self.coin = coin
end
function notify_init_party_coin:encode()
    return
        binary_helper.to_binary(self.coin, "int")
end
function notify_init_party_coin:decode(binary)
    self.coin, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_init_party_coin:get_msgid()
    return msg_notify_init_party_coin
end
notify_party_score_coin=class()
function notify_party_score_coin:ctor(coin)
    self.coin = coin
end
function notify_party_score_coin:encode()
    return
        binary_helper.to_binary(self.coin, "int")
end
function notify_party_score_coin:decode(binary)
    self.coin, binary = binary_helper.to_value(binary, "int")
    return binary
end
function notify_party_score_coin:get_msgid()
    return msg_notify_party_score_coin
end
