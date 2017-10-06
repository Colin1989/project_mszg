
function req_login ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_login"]
    end
    tb.version = 0
    tb.account = ""
    tb.password = ""

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.version)
    	byteArray.write_string(tb.account)
    	byteArray.write_string(tb.password)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.version = byteArray.read_int();
        tb.account = byteArray.read_string();
        tb.password = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_login"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_login_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_login_result"]
    end
    tb.id = 0
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.id)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.id = byteArray.read_uint64();
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_login_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sys_msg ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sys_msg"]
    end
    tb.code = 0
    tb.Params = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.code)
        byteArray.write_uint16(#(tb.Params))
        for k, v in pairs (tb.Params) do
            byteArray.write_string(v)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.code = byteArray.read_int();
        local countOfParams = byteArray.read_uint16()
        tb.Params = {}
        for i = 1, countOfParams do
             table.insert(tb.Params, byteArray.read_string())
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sys_msg"])
        return tb.encode(byteArray)
    end

    return tb

end

function player_data ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_player_data"]
    end
    tb.account = ""
    tb.username = ""
    tb.sex = 0

    tb.encode = function(byteArray)
    	byteArray.write_string(tb.account)
    	byteArray.write_string(tb.username)
    	byteArray.write_int(tb.sex)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.account = byteArray.read_string();
        tb.username = byteArray.read_string();
        tb.sex = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_player_data"])
        return tb.encode(byteArray)
    end

    return tb

end

function stime ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_stime"]
    end
    tb.year = 0
    tb.month = 0
    tb.day = 0
    tb.hour = 0
    tb.minute = 0
    tb.second = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.year)
    	byteArray.write_int(tb.month)
    	byteArray.write_int(tb.day)
    	byteArray.write_int(tb.hour)
    	byteArray.write_int(tb.minute)
    	byteArray.write_int(tb.second)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.year = byteArray.read_int();
        tb.month = byteArray.read_int();
        tb.day = byteArray.read_int();
        tb.hour = byteArray.read_int();
        tb.minute = byteArray.read_int();
        tb.second = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_stime"])
        return tb.encode(byteArray)
    end

    return tb

end

function smonster ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_smonster"]
    end
    tb.pos = 0
    tb.monsterid = 0
    tb.dropout = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.pos)
    	byteArray.write_int(tb.monsterid)
    	byteArray.write_int(tb.dropout)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.pos = byteArray.read_int();
        tb.monsterid = byteArray.read_int();
        tb.dropout = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_smonster"])
        return tb.encode(byteArray)
    end

    return tb

end

function strap ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_strap"]
    end
    tb.pos = 0
    tb.trapid = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.pos)
    	byteArray.write_int(tb.trapid)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.pos = byteArray.read_int();
        tb.trapid = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_strap"])
        return tb.encode(byteArray)
    end

    return tb

end

function saward ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_saward"]
    end
    tb.pos = 0
    tb.awardid = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.pos)
    	byteArray.write_int(tb.awardid)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.pos = byteArray.read_int();
        tb.awardid = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_saward"])
        return tb.encode(byteArray)
    end

    return tb

end

function sfriend ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_sfriend"]
    end
    tb.pos = 0
    tb.friend_role_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.pos)
    	byteArray.write_int(tb.friend_role_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.pos = byteArray.read_int();
        tb.friend_role_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_sfriend"])
        return tb.encode(byteArray)
    end

    return tb

end

function battle_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_battle_info"]
    end
    tb.sculpture = {}
    tb.life = 0
    tb.speed = 0
    tb.atk = 0
    tb.hit_ratio = 0
    tb.miss_ratio = 0
    tb.critical_ratio = 0
    tb.tenacity = 0
    tb.power = 0

    tb.encode = function(byteArray)
        byteArray.write_uint16(#(tb.sculpture))
        for k, v in pairs (tb.sculpture) do
            byteArray.write_int(v)
        end
    	byteArray.write_int(tb.life)
    	byteArray.write_int(tb.speed)
    	byteArray.write_int(tb.atk)
    	byteArray.write_int(tb.hit_ratio)
    	byteArray.write_int(tb.miss_ratio)
    	byteArray.write_int(tb.critical_ratio)
    	byteArray.write_int(tb.tenacity)
    	byteArray.write_int(tb.power)
        return byteArray
    end

    tb.decode = function(byteArray)
        local countOfsculpture = byteArray.read_uint16()
        tb.sculpture = {}
        for i = 1, countOfsculpture do
             table.insert(tb.sculpture, byteArray.read_int())
        end
        tb.life = byteArray.read_int();
        tb.speed = byteArray.read_int();
        tb.atk = byteArray.read_int();
        tb.hit_ratio = byteArray.read_int();
        tb.miss_ratio = byteArray.read_int();
        tb.critical_ratio = byteArray.read_int();
        tb.tenacity = byteArray.read_int();
        tb.power = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_battle_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function senemy ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_senemy"]
    end
    tb.pos = 0
    tb.type = 0
    tb.battle_prop = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.pos)
    	byteArray.write_int(tb.type)
        tb.battle_prop.encode(byteArray);
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.pos = byteArray.read_int();
        tb.type = byteArray.read_int();
        tb.battle_prop = battle_info();
        tb.battle_prop.decode(byteArray);
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_senemy"])
        return tb.encode(byteArray)
    end

    return tb

end

function game_map ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_game_map"]
    end
    tb.monster = {}
    tb.door = 0
    tb.start = 0
    tb.award = {}
    tb.trap = {}
    tb.barrier = {}
    tb.friend = {}
    tb.scene = 0
    tb.enemy = {}

    tb.encode = function(byteArray)
        byteArray.write_uint16(#(tb.monster))
        for k, v in pairs(tb.monster) do
            byteArray = v.encode(byteArray)
        end
    	byteArray.write_int(tb.door)
    	byteArray.write_int(tb.start)
        byteArray.write_uint16(#(tb.award))
        for k, v in pairs(tb.award) do
            byteArray = v.encode(byteArray)
        end
        byteArray.write_uint16(#(tb.trap))
        for k, v in pairs(tb.trap) do
            byteArray = v.encode(byteArray)
        end
        byteArray.write_uint16(#(tb.barrier))
        for k, v in pairs (tb.barrier) do
            byteArray.write_int(v)
        end
        byteArray.write_uint16(#(tb.friend))
        for k, v in pairs(tb.friend) do
            byteArray = v.encode(byteArray)
        end
    	byteArray.write_int(tb.scene)
        byteArray.write_uint16(#(tb.enemy))
        for k, v in pairs(tb.enemy) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        local countOfmonster = byteArray.read_uint16()
        tb.monster = {}
        for i = 1, countOfmonster do
            local temp = smonster()
            temp.decode(byteArray)
            table.insert(tb.monster, temp)
        end
        tb.door = byteArray.read_int();
        tb.start = byteArray.read_int();
        local countOfaward = byteArray.read_uint16()
        tb.award = {}
        for i = 1, countOfaward do
            local temp = saward()
            temp.decode(byteArray)
            table.insert(tb.award, temp)
        end
        local countOftrap = byteArray.read_uint16()
        tb.trap = {}
        for i = 1, countOftrap do
            local temp = strap()
            temp.decode(byteArray)
            table.insert(tb.trap, temp)
        end
        local countOfbarrier = byteArray.read_uint16()
        tb.barrier = {}
        for i = 1, countOfbarrier do
             table.insert(tb.barrier, byteArray.read_int())
        end
        local countOffriend = byteArray.read_uint16()
        tb.friend = {}
        for i = 1, countOffriend do
            local temp = sfriend()
            temp.decode(byteArray)
            table.insert(tb.friend, temp)
        end
        tb.scene = byteArray.read_int();
        local countOfenemy = byteArray.read_uint16()
        tb.enemy = {}
        for i = 1, countOfenemy do
            local temp = senemy()
            temp.decode(byteArray)
            table.insert(tb.enemy, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_game_map"])
        return tb.encode(byteArray)
    end

    return tb

end

function item ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_item"]
    end
    tb.inst_id = 0
    tb.temp_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.inst_id)
    	byteArray.write_int(tb.temp_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.inst_id = byteArray.read_uint64();
        tb.temp_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_item"])
        return tb.encode(byteArray)
    end

    return tb

end

function pack_item ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_pack_item"]
    end
    tb.id = 0
    tb.itemid = 0
    tb.itemtype = 0
    tb.amount = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.id)
    	byteArray.write_int(tb.itemid)
    	byteArray.write_int(tb.itemtype)
    	byteArray.write_int(tb.amount)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.id = byteArray.read_uint64();
        tb.itemid = byteArray.read_int();
        tb.itemtype = byteArray.read_int();
        tb.amount = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_pack_item"])
        return tb.encode(byteArray)
    end

    return tb

end

function copy_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_copy_info"]
    end
    tb.copy_id = 0
    tb.max_score = 0
    tb.pass_times = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.copy_id)
    	byteArray.write_int(tb.max_score)
    	byteArray.write_int(tb.pass_times)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.copy_id = byteArray.read_int();
        tb.max_score = byteArray.read_int();
        tb.pass_times = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_copy_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function equipmentinfo ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_equipmentinfo"]
    end
    tb.equipment_id = 0
    tb.temp_id = 0
    tb.strengthen_level = 0
    tb.gems = {}
    tb.attr_ids = {}
    tb.gem_extra = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.equipment_id)
    	byteArray.write_int(tb.temp_id)
    	byteArray.write_int(tb.strengthen_level)
        byteArray.write_uint16(#(tb.gems))
        for k, v in pairs (tb.gems) do
            byteArray.write_int(v)
        end
        byteArray.write_uint16(#(tb.attr_ids))
        for k, v in pairs (tb.attr_ids) do
            byteArray.write_int(v)
        end
    	byteArray.write_int(tb.gem_extra)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.equipment_id = byteArray.read_uint64();
        tb.temp_id = byteArray.read_int();
        tb.strengthen_level = byteArray.read_int();
        local countOfgems = byteArray.read_uint16()
        tb.gems = {}
        for i = 1, countOfgems do
             table.insert(tb.gems, byteArray.read_int())
        end
        local countOfattr_ids = byteArray.read_uint16()
        tb.attr_ids = {}
        for i = 1, countOfattr_ids do
             table.insert(tb.attr_ids, byteArray.read_int())
        end
        tb.gem_extra = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_equipmentinfo"])
        return tb.encode(byteArray)
    end

    return tb

end

function extra_item ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_extra_item"]
    end
    tb.item_id = 0
    tb.count = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.item_id)
    	byteArray.write_int(tb.count)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.item_id = byteArray.read_int();
        tb.count = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_extra_item"])
        return tb.encode(byteArray)
    end

    return tb

end

function friend_data ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_friend_data"]
    end
    tb.nickname = ""
    tb.status = 0
    tb.head = 0
    tb.level = 0
    tb.public = ""
    tb.battle_prop = {}

    tb.encode = function(byteArray)
    	byteArray.write_string(tb.nickname)
    	byteArray.write_int(tb.status)
    	byteArray.write_int(tb.head)
    	byteArray.write_int(tb.level)
    	byteArray.write_string(tb.public)
        tb.battle_prop.encode(byteArray);
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.nickname = byteArray.read_string();
        tb.status = byteArray.read_int();
        tb.head = byteArray.read_int();
        tb.level = byteArray.read_int();
        tb.public = byteArray.read_string();
        tb.battle_prop = battle_info();
        tb.battle_prop.decode(byteArray);
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_friend_data"])
        return tb.encode(byteArray)
    end

    return tb

end

function friend_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_friend_info"]
    end
    tb.friend_id = 0
    tb.nickname = ""
    tb.status = 0
    tb.head = 0
    tb.level = 0
    tb.public = ""
    tb.battle_prop = {}

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.friend_id)
    	byteArray.write_string(tb.nickname)
    	byteArray.write_int(tb.status)
    	byteArray.write_int(tb.head)
    	byteArray.write_int(tb.level)
    	byteArray.write_string(tb.public)
        tb.battle_prop.encode(byteArray);
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.friend_id = byteArray.read_uint64();
        tb.nickname = byteArray.read_string();
        tb.status = byteArray.read_int();
        tb.head = byteArray.read_int();
        tb.level = byteArray.read_int();
        tb.public = byteArray.read_string();
        tb.battle_prop = battle_info();
        tb.battle_prop.decode(byteArray);
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_friend_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function award_item ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_award_item"]
    end
    tb.temp_id = 0
    tb.amount = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.temp_id)
    	byteArray.write_int(tb.amount)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.temp_id = byteArray.read_int();
        tb.amount = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_award_item"])
        return tb.encode(byteArray)
    end

    return tb

end

function challenge_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_challenge_info"]
    end
    tb.name = ""
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_string(tb.name)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.name = byteArray.read_string();
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_challenge_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function rank_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_rank_info"]
    end
    tb.role_id = 0
    tb.name = ""
    tb.type = 0
    tb.rank = 0
    tb.level = 0
    tb.power = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.role_id)
    	byteArray.write_string(tb.name)
    	byteArray.write_int(tb.type)
    	byteArray.write_int(tb.rank)
    	byteArray.write_int(tb.level)
    	byteArray.write_int(tb.power)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.role_id = byteArray.read_uint64();
        tb.name = byteArray.read_string();
        tb.type = byteArray.read_int();
        tb.rank = byteArray.read_int();
        tb.level = byteArray.read_int();
        tb.power = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_rank_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function donor ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_donor"]
    end
    tb.role_id = 0
    tb.rel = 0
    tb.level = 0
    tb.role_type = 0
    tb.nick_name = ""
    tb.friend_point = 0
    tb.power = 0
    tb.sculpture = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.role_id)
    	byteArray.write_int(tb.rel)
    	byteArray.write_int(tb.level)
    	byteArray.write_int(tb.role_type)
    	byteArray.write_string(tb.nick_name)
    	byteArray.write_int(tb.friend_point)
    	byteArray.write_int(tb.power)
    	byteArray.write_int(tb.sculpture)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.role_id = byteArray.read_uint64();
        tb.rel = byteArray.read_int();
        tb.level = byteArray.read_int();
        tb.role_type = byteArray.read_int();
        tb.nick_name = byteArray.read_string();
        tb.friend_point = byteArray.read_int();
        tb.power = byteArray.read_int();
        tb.sculpture = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_donor"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_heartbeat ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_heartbeat"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_heartbeat"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_repeat_login ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_repeat_login"]
    end
    tb.account = ""

    tb.encode = function(byteArray)
    	byteArray.write_string(tb.account)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.account = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_repeat_login"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_register ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_register"]
    end
    tb.account = ""
    tb.channelid = 0
    tb.platformid = 0
    tb.password = ""

    tb.encode = function(byteArray)
    	byteArray.write_string(tb.account)
    	byteArray.write_int(tb.channelid)
    	byteArray.write_int(tb.platformid)
    	byteArray.write_string(tb.password)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.account = byteArray.read_string();
        tb.channelid = byteArray.read_int();
        tb.platformid = byteArray.read_int();
        tb.password = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_register"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_register_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_register_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_register_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_create_role ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_create_role"]
    end
    tb.roletype = 0
    tb.nickname = ""

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.roletype)
    	byteArray.write_string(tb.nickname)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.roletype = byteArray.read_int();
        tb.nickname = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_create_role"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_create_role_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_create_role_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_create_role_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_roleinfo_msg ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_roleinfo_msg"]
    end
    tb.id = 0
    tb.nickname = ""
    tb.roletype = 0
    tb.armor = 0
    tb.weapon = 0
    tb.ring = 0
    tb.necklace = 0
    tb.medal = 0
    tb.jewelry = 0
    tb.skill1 = 0
    tb.skill2 = 0
    tb.sculpture1 = 0
    tb.sculpture2 = 0
    tb.sculpture3 = 0
    tb.sculpture4 = 0
    tb.divine_level1 = 0
    tb.divine_level2 = 0
    tb.divine_level3 = 0
    tb.level = 0
    tb.exp = 0
    tb.gold = 0
    tb.emoney = 0
    tb.power_hp = 0
    tb.recover_time_left = 0
    tb.power_hp_buy_times = 0
    tb.pack_space = 0
    tb.friend_point = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.id)
    	byteArray.write_string(tb.nickname)
    	byteArray.write_int(tb.roletype)
    	byteArray.write_uint64(tb.armor)
    	byteArray.write_uint64(tb.weapon)
    	byteArray.write_uint64(tb.ring)
    	byteArray.write_uint64(tb.necklace)
    	byteArray.write_uint64(tb.medal)
    	byteArray.write_uint64(tb.jewelry)
    	byteArray.write_int(tb.skill1)
    	byteArray.write_int(tb.skill2)
    	byteArray.write_uint64(tb.sculpture1)
    	byteArray.write_uint64(tb.sculpture2)
    	byteArray.write_uint64(tb.sculpture3)
    	byteArray.write_uint64(tb.sculpture4)
    	byteArray.write_int(tb.divine_level1)
    	byteArray.write_int(tb.divine_level2)
    	byteArray.write_int(tb.divine_level3)
    	byteArray.write_int(tb.level)
    	byteArray.write_int(tb.exp)
    	byteArray.write_int(tb.gold)
    	byteArray.write_int(tb.emoney)
    	byteArray.write_int(tb.power_hp)
    	byteArray.write_int(tb.recover_time_left)
    	byteArray.write_int(tb.power_hp_buy_times)
    	byteArray.write_int(tb.pack_space)
    	byteArray.write_int(tb.friend_point)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.id = byteArray.read_uint64();
        tb.nickname = byteArray.read_string();
        tb.roletype = byteArray.read_int();
        tb.armor = byteArray.read_uint64();
        tb.weapon = byteArray.read_uint64();
        tb.ring = byteArray.read_uint64();
        tb.necklace = byteArray.read_uint64();
        tb.medal = byteArray.read_uint64();
        tb.jewelry = byteArray.read_uint64();
        tb.skill1 = byteArray.read_int();
        tb.skill2 = byteArray.read_int();
        tb.sculpture1 = byteArray.read_uint64();
        tb.sculpture2 = byteArray.read_uint64();
        tb.sculpture3 = byteArray.read_uint64();
        tb.sculpture4 = byteArray.read_uint64();
        tb.divine_level1 = byteArray.read_int();
        tb.divine_level2 = byteArray.read_int();
        tb.divine_level3 = byteArray.read_int();
        tb.level = byteArray.read_int();
        tb.exp = byteArray.read_int();
        tb.gold = byteArray.read_int();
        tb.emoney = byteArray.read_int();
        tb.power_hp = byteArray.read_int();
        tb.recover_time_left = byteArray.read_int();
        tb.power_hp_buy_times = byteArray.read_int();
        tb.pack_space = byteArray.read_int();
        tb.friend_point = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_roleinfo_msg"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_enter_game ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_enter_game"]
    end
    tb.id = 0
    tb.gametype = 0
    tb.copy_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.id)
    	byteArray.write_int(tb.gametype)
    	byteArray.write_int(tb.copy_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.id = byteArray.read_uint64();
        tb.gametype = byteArray.read_int();
        tb.copy_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_enter_game"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_enter_game ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_enter_game"]
    end
    tb.result = 0
    tb.game_id = 0
    tb.gamemaps = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
    	byteArray.write_uint64(tb.game_id)
        byteArray.write_uint16(#(tb.gamemaps))
        for k, v in pairs(tb.gamemaps) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
        tb.game_id = byteArray.read_uint64();
        local countOfgamemaps = byteArray.read_uint16()
        tb.gamemaps = {}
        for i = 1, countOfgamemaps do
            local temp = game_map()
            temp.decode(byteArray)
            table.insert(tb.gamemaps, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_enter_game"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_last_copy ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_last_copy"]
    end
    tb.last_copy_id = 0
    tb.copyinfos = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.last_copy_id)
        byteArray.write_uint16(#(tb.copyinfos))
        for k, v in pairs(tb.copyinfos) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.last_copy_id = byteArray.read_int();
        local countOfcopyinfos = byteArray.read_uint16()
        tb.copyinfos = {}
        for i = 1, countOfcopyinfos do
            local temp = copy_info()
            temp.decode(byteArray)
            table.insert(tb.copyinfos, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_last_copy"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_last_copy ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_last_copy"]
    end
    tb.roleid = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.roleid)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.roleid = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_last_copy"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_buy_power_hp ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_buy_power_hp"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_buy_power_hp"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_buy_power_hp_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_buy_power_hp_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_buy_power_hp_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_power_hp_msg ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_power_hp_msg"]
    end
    tb.result = 0
    tb.power_hp = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
    	byteArray.write_int(tb.power_hp)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
        tb.power_hp = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_power_hp_msg"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_player_pack ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_player_pack"]
    end
    tb.type = 0
    tb.pack_items = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.type)
        byteArray.write_uint16(#(tb.pack_items))
        for k, v in pairs(tb.pack_items) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.type = byteArray.read_int();
        local countOfpack_items = byteArray.read_uint16()
        tb.pack_items = {}
        for i = 1, countOfpack_items do
            local temp = pack_item()
            temp.decode(byteArray)
            table.insert(tb.pack_items, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_player_pack"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_game_settle ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_game_settle"]
    end
    tb.game_id = 0
    tb.result = 0
    tb.life = 0
    tb.maxlife = 0
    tb.monsterkill = 0
    tb.pickup_items = {}
    tb.user_operations = {}
    tb.gold = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.game_id)
    	byteArray.write_int(tb.result)
    	byteArray.write_int(tb.life)
    	byteArray.write_int(tb.maxlife)
    	byteArray.write_int(tb.monsterkill)
        byteArray.write_uint16(#(tb.pickup_items))
        for k, v in pairs (tb.pickup_items) do
            byteArray.write_int(v)
        end
        byteArray.write_uint16(#(tb.user_operations))
        for k, v in pairs (tb.user_operations) do
            byteArray.write_int(v)
        end
    	byteArray.write_int(tb.gold)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.game_id = byteArray.read_uint64();
        tb.result = byteArray.read_int();
        tb.life = byteArray.read_int();
        tb.maxlife = byteArray.read_int();
        tb.monsterkill = byteArray.read_int();
        local countOfpickup_items = byteArray.read_uint16()
        tb.pickup_items = {}
        for i = 1, countOfpickup_items do
             table.insert(tb.pickup_items, byteArray.read_int())
        end
        local countOfuser_operations = byteArray.read_uint16()
        tb.user_operations = {}
        for i = 1, countOfuser_operations do
             table.insert(tb.user_operations, byteArray.read_int())
        end
        tb.gold = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_game_settle"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_game_settle ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_game_settle"]
    end
    tb.game_id = 0
    tb.result = 0
    tb.score = 0
    tb.final_item = 0
    tb.ratio_items = {}

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.game_id)
    	byteArray.write_int(tb.result)
    	byteArray.write_int(tb.score)
    	byteArray.write_int(tb.final_item)
        byteArray.write_uint16(#(tb.ratio_items))
        for k, v in pairs (tb.ratio_items) do
            byteArray.write_int(v)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.game_id = byteArray.read_uint64();
        tb.result = byteArray.read_int();
        tb.score = byteArray.read_int();
        tb.final_item = byteArray.read_int();
        local countOfratio_items = byteArray.read_uint16()
        tb.ratio_items = {}
        for i = 1, countOfratio_items do
             table.insert(tb.ratio_items, byteArray.read_int())
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_game_settle"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_game_reconnect ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_game_reconnect"]
    end
    tb.version = 0
    tb.account = ""
    tb.password = ""

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.version)
    	byteArray.write_string(tb.account)
    	byteArray.write_string(tb.password)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.version = byteArray.read_int();
        tb.account = byteArray.read_string();
        tb.password = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_game_reconnect"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_reconnect_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_reconnect_result"]
    end
    tb.id = 0
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.id)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.id = byteArray.read_uint64();
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_reconnect_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_equipment_strengthen ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_equipment_strengthen"]
    end
    tb.equipment_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.equipment_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.equipment_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_equipment_strengthen"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_equipment_strengthen_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_equipment_strengthen_result"]
    end
    tb.strengthen_result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.strengthen_result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.strengthen_result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_equipment_strengthen_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_equipment_mountgem ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_equipment_mountgem"]
    end
    tb.equipment_id = 0
    tb.gem_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.equipment_id)
    	byteArray.write_uint64(tb.gem_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.equipment_id = byteArray.read_uint64();
        tb.gem_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_equipment_mountgem"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_equipment_mountgem_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_equipment_mountgem_result"]
    end
    tb.mountgem_result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.mountgem_result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.mountgem_result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_equipment_mountgem_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_equipment_puton ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_equipment_puton"]
    end
    tb.equipment_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.equipment_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.equipment_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_equipment_puton"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_equipment_puton_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_equipment_puton_result"]
    end
    tb.puton_result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.puton_result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.puton_result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_equipment_puton_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_equipment_infos ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_equipment_infos"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_equipment_infos"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_equipment_infos ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_equipment_infos"]
    end
    tb.type = 0
    tb.equipment_infos = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.type)
        byteArray.write_uint16(#(tb.equipment_infos))
        for k, v in pairs(tb.equipment_infos) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.type = byteArray.read_int();
        local countOfequipment_infos = byteArray.read_uint16()
        tb.equipment_infos = {}
        for i = 1, countOfequipment_infos do
            local temp = equipmentinfo()
            temp.decode(byteArray)
            table.insert(tb.equipment_infos, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_equipment_infos"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_equipment_takeoff ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_equipment_takeoff"]
    end
    tb.position = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.position)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.position = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_equipment_takeoff"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_equipment_takeoff_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_equipment_takeoff_result"]
    end
    tb.takeoff_result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.takeoff_result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.takeoff_result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_equipment_takeoff_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_gold_update ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_gold_update"]
    end
    tb.gold = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.gold)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.gold = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_gold_update"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_emoney_update ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_emoney_update"]
    end
    tb.emoney = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.emoney)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.emoney = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_emoney_update"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_player_pack_exceeded ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_player_pack_exceeded"]
    end
    tb.new_extra = {}

    tb.encode = function(byteArray)
        byteArray.write_uint16(#(tb.new_extra))
        for k, v in pairs(tb.new_extra) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        local countOfnew_extra = byteArray.read_uint16()
        tb.new_extra = {}
        for i = 1, countOfnew_extra do
            local temp = extra_item()
            temp.decode(byteArray)
            table.insert(tb.new_extra, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_player_pack_exceeded"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_extend_pack ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_extend_pack"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_extend_pack"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_extend_pack_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_extend_pack_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_extend_pack_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_sale_item ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_sale_item"]
    end
    tb.inst_id = 0
    tb.amount = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.inst_id)
    	byteArray.write_int(tb.amount)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.inst_id = byteArray.read_uint64();
        tb.amount = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_sale_item"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sale_item_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sale_item_result"]
    end
    tb.result = 0
    tb.gold = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
    	byteArray.write_int(tb.gold)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
        tb.gold = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sale_item_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_search_friend ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_search_friend"]
    end
    tb.nickname = ""

    tb.encode = function(byteArray)
    	byteArray.write_string(tb.nickname)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.nickname = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_search_friend"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_search_friend_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_search_friend_result"]
    end
    tb.result = 0
    tb.role_info = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        tb.role_info.encode(byteArray);
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
        tb.role_info = friend_info();
        tb.role_info.decode(byteArray);
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_search_friend_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_add_friend ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_add_friend"]
    end
    tb.friend_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.friend_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.friend_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_add_friend"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_add_friend_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_add_friend_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_add_friend_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_req_for_add_friend ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_req_for_add_friend"]
    end
    tb.friend_id = 0
    tb.role_data = {}

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.friend_id)
        tb.role_data.encode(byteArray);
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.friend_id = byteArray.read_uint64();
        tb.role_data = friend_data();
        tb.role_data.decode(byteArray);
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_req_for_add_friend"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_proc_reqfor_add_friend ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_proc_reqfor_add_friend"]
    end
    tb.answer = 0
    tb.friend_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.answer)
    	byteArray.write_uint64(tb.friend_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.answer = byteArray.read_int();
        tb.friend_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_proc_reqfor_add_friend"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_del_friend ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_del_friend"]
    end
    tb.friend_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.friend_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.friend_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_del_friend"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_del_friend_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_del_friend_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_del_friend_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_get_friends ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_get_friends"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_get_friends"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_friend_list ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_friend_list"]
    end
    tb.type = 0
    tb.friends = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.type)
        byteArray.write_uint16(#(tb.friends))
        for k, v in pairs(tb.friends) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.type = byteArray.read_int();
        local countOffriends = byteArray.read_uint16()
        tb.friends = {}
        for i = 1, countOffriends do
            local temp = friend_info()
            temp.decode(byteArray)
            table.insert(tb.friends, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_friend_list"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_send_chat_msg ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_send_chat_msg"]
    end
    tb.friend_id = 0
    tb.chat_msg = ""

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.friend_id)
    	byteArray.write_string(tb.chat_msg)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.friend_id = byteArray.read_uint64();
        tb.chat_msg = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_send_chat_msg"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_send_chat_msg_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_send_chat_msg_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_send_chat_msg_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_receive_chat_msg ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_receive_chat_msg"]
    end
    tb.friend_id = 0
    tb.chat_msg = ""

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.friend_id)
    	byteArray.write_string(tb.chat_msg)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.friend_id = byteArray.read_uint64();
        tb.chat_msg = byteArray.read_string();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_receive_chat_msg"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_push_tower_map_settle ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_push_tower_map_settle"]
    end
    tb.game_id = 0
    tb.result = 0
    tb.cost_round = 0
    tb.life = 0
    tb.pickup_items = {}

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.game_id)
    	byteArray.write_int(tb.result)
    	byteArray.write_int(tb.cost_round)
    	byteArray.write_int(tb.life)
        byteArray.write_uint16(#(tb.pickup_items))
        for k, v in pairs (tb.pickup_items) do
            byteArray.write_int(v)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.game_id = byteArray.read_uint64();
        tb.result = byteArray.read_int();
        tb.cost_round = byteArray.read_int();
        tb.life = byteArray.read_int();
        local countOfpickup_items = byteArray.read_uint16()
        tb.pickup_items = {}
        for i = 1, countOfpickup_items do
             table.insert(tb.pickup_items, byteArray.read_int())
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_push_tower_map_settle"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_push_tower_map_settle ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_push_tower_map_settle"]
    end
    tb.result = 0
    tb.gamemap = {}
    tb.awards = {}
    tb.gold = 0
    tb.exp = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        byteArray.write_uint16(#(tb.gamemap))
        for k, v in pairs(tb.gamemap) do
            byteArray = v.encode(byteArray)
        end
        byteArray.write_uint16(#(tb.awards))
        for k, v in pairs(tb.awards) do
            byteArray = v.encode(byteArray)
        end
    	byteArray.write_int(tb.gold)
    	byteArray.write_int(tb.exp)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
        local countOfgamemap = byteArray.read_uint16()
        tb.gamemap = {}
        for i = 1, countOfgamemap do
            local temp = game_map()
            temp.decode(byteArray)
            table.insert(tb.gamemap, temp)
        end
        local countOfawards = byteArray.read_uint16()
        tb.awards = {}
        for i = 1, countOfawards do
            local temp = award_item()
            temp.decode(byteArray)
            table.insert(tb.awards, temp)
        end
        tb.gold = byteArray.read_int();
        tb.exp = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_push_tower_map_settle"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_push_tower_buy_round ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_push_tower_buy_round"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_push_tower_buy_round"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_push_tower_buy_round ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_push_tower_buy_round"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_push_tower_buy_round"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_push_tower_buy_playtimes ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_push_tower_buy_playtimes"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_push_tower_buy_playtimes"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_push_tower_buy_playtimes ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_push_tower_buy_playtimes"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_push_tower_buy_playtimes"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_reborn ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_reborn"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_reborn"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_reborn_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_reborn_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_reborn_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_gem_compound ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_gem_compound"]
    end
    tb.temp_id = 0
    tb.is_protect = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.temp_id)
    	byteArray.write_int(tb.is_protect)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.temp_id = byteArray.read_int();
        tb.is_protect = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_gem_compound"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_gem_compound_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_gem_compound_result"]
    end
    tb.result = 0
    tb.lost_gem_amount = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
    	byteArray.write_int(tb.lost_gem_amount)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
        tb.lost_gem_amount = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_gem_compound_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_gem_unmounted ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_gem_unmounted"]
    end
    tb.equipment_id = 0
    tb.gem_temp_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.equipment_id)
    	byteArray.write_int(tb.gem_temp_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.equipment_id = byteArray.read_uint64();
        tb.gem_temp_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_gem_unmounted"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_gem_unmounted_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_gem_unmounted_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_gem_unmounted_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_push_tower_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_push_tower_info"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_push_tower_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_push_tower_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_push_tower_info"]
    end
    tb.play_times = 0
    tb.max_times = 0
    tb.max_floor = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.play_times)
    	byteArray.write_int(tb.max_times)
    	byteArray.write_int(tb.max_floor)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.play_times = byteArray.read_int();
        tb.max_times = byteArray.read_int();
        tb.max_floor = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_push_tower_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function task_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_task_info"]
    end
    tb.task_id = 0
    tb.has_finished = 0
    tb.args = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.task_id)
    	byteArray.write_int(tb.has_finished)
        byteArray.write_uint16(#(tb.args))
        for k, v in pairs (tb.args) do
            byteArray.write_int(v)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.task_id = byteArray.read_int();
        tb.has_finished = byteArray.read_int();
        local countOfargs = byteArray.read_uint16()
        tb.args = {}
        for i = 1, countOfargs do
             table.insert(tb.args, byteArray.read_int())
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_task_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_task_infos ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_task_infos"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_task_infos"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_task_infos ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_task_infos"]
    end
    tb.type = 0
    tb.infos = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.type)
        byteArray.write_uint16(#(tb.infos))
        for k, v in pairs(tb.infos) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.type = byteArray.read_int();
        local countOfinfos = byteArray.read_uint16()
        tb.infos = {}
        for i = 1, countOfinfos do
            local temp = task_info()
            temp.decode(byteArray)
            table.insert(tb.infos, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_task_infos"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_finish_task ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_finish_task"]
    end
    tb.task_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.task_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.task_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_finish_task"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_finish_task ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_finish_task"]
    end
    tb.is_success = 0
    tb.task_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.is_success)
    	byteArray.write_int(tb.task_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.is_success = byteArray.read_int();
        tb.task_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_finish_task"])
        return tb.encode(byteArray)
    end

    return tb

end

function sculpture_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_sculpture_info"]
    end
    tb.sculpture_id = 0
    tb.temp_id = 0
    tb.exp = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.sculpture_id)
    	byteArray.write_int(tb.temp_id)
    	byteArray.write_int(tb.exp)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.sculpture_id = byteArray.read_uint64();
        tb.temp_id = byteArray.read_int();
        tb.exp = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_sculpture_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_sculpture_infos ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_sculpture_infos"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_sculpture_infos"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sculpture_infos ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sculpture_infos"]
    end
    tb.type = 0
    tb.sculpture_infos = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.type)
        byteArray.write_uint16(#(tb.sculpture_infos))
        for k, v in pairs(tb.sculpture_infos) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.type = byteArray.read_int();
        local countOfsculpture_infos = byteArray.read_uint16()
        tb.sculpture_infos = {}
        for i = 1, countOfsculpture_infos do
            local temp = sculpture_info()
            temp.decode(byteArray)
            table.insert(tb.sculpture_infos, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sculpture_infos"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_sculpture_puton ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_sculpture_puton"]
    end
    tb.position = 0
    tb.inst_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.position)
    	byteArray.write_uint64(tb.inst_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.position = byteArray.read_int();
        tb.inst_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_sculpture_puton"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sculpture_puton ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sculpture_puton"]
    end
    tb.is_success = 0
    tb.position = 0
    tb.inst_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.is_success)
    	byteArray.write_int(tb.position)
    	byteArray.write_uint64(tb.inst_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.is_success = byteArray.read_int();
        tb.position = byteArray.read_int();
        tb.inst_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sculpture_puton"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_sculpture_takeoff ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_sculpture_takeoff"]
    end
    tb.position = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.position)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.position = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_sculpture_takeoff"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sculpture_takeoff ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sculpture_takeoff"]
    end
    tb.is_success = 0
    tb.position = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.is_success)
    	byteArray.write_int(tb.position)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.is_success = byteArray.read_int();
        tb.position = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sculpture_takeoff"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_sculpture_convert ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_sculpture_convert"]
    end
    tb.target_item_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.target_item_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.target_item_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_sculpture_convert"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sculpture_convert ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sculpture_convert"]
    end
    tb.is_success = 0
    tb.target_item_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.is_success)
    	byteArray.write_int(tb.target_item_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.is_success = byteArray.read_int();
        tb.target_item_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sculpture_convert"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_sculpture_upgrade ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_sculpture_upgrade"]
    end
    tb.main_id = 0
    tb.eat_ids = {}

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.main_id)
        byteArray.write_uint16(#(tb.eat_ids))
        for k, v in pairs (tb.eat_ids) do
            byteArray.write_uint64(v)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.main_id = byteArray.read_uint64();
        local countOfeat_ids = byteArray.read_uint16()
        tb.eat_ids = {}
        for i = 1, countOfeat_ids do
             table.insert(tb.eat_ids, byteArray.read_uint64())
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_sculpture_upgrade"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sculpture_upgrade ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sculpture_upgrade"]
    end
    tb.is_success = 0
    tb.main_id = 0
    tb.eat_ids = {}
    tb.main_new_temp_id = 0
    tb.main_exp = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.is_success)
    	byteArray.write_uint64(tb.main_id)
        byteArray.write_uint16(#(tb.eat_ids))
        for k, v in pairs (tb.eat_ids) do
            byteArray.write_uint64(v)
        end
    	byteArray.write_int(tb.main_new_temp_id)
    	byteArray.write_int(tb.main_exp)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.is_success = byteArray.read_int();
        tb.main_id = byteArray.read_uint64();
        local countOfeat_ids = byteArray.read_uint16()
        tb.eat_ids = {}
        for i = 1, countOfeat_ids do
             table.insert(tb.eat_ids, byteArray.read_uint64())
        end
        tb.main_new_temp_id = byteArray.read_int();
        tb.main_exp = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sculpture_upgrade"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_sculpture_divine ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_sculpture_divine"]
    end
    tb.money_type = 0
    tb.times = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.money_type)
    	byteArray.write_int(tb.times)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.money_type = byteArray.read_int();
        tb.times = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_sculpture_divine"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_sculpture_divine ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_sculpture_divine"]
    end
    tb.is_success = 0
    tb.divine_level = 0
    tb.awards = {}

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.is_success)
    	byteArray.write_int(tb.divine_level)
        byteArray.write_uint16(#(tb.awards))
        for k, v in pairs(tb.awards) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.is_success = byteArray.read_int();
        tb.divine_level = byteArray.read_int();
        local countOfawards = byteArray.read_uint16()
        tb.awards = {}
        for i = 1, countOfawards do
            local temp = award_item()
            temp.decode(byteArray)
            table.insert(tb.awards, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_sculpture_divine"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_challenge_other_player ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_challenge_other_player"]
    end
    tb.role_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.role_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.role_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_challenge_other_player"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_challenge_other_player_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_challenge_other_player_result"]
    end
    tb.game_id = 0
    tb.result = 0
    tb.map = {}

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.game_id)
    	byteArray.write_int(tb.result)
        byteArray.write_uint16(#(tb.map))
        for k, v in pairs(tb.map) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.game_id = byteArray.read_uint64();
        tb.result = byteArray.read_int();
        local countOfmap = byteArray.read_uint16()
        tb.map = {}
        for i = 1, countOfmap do
            local temp = game_map()
            temp.decode(byteArray)
            table.insert(tb.map, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_challenge_other_player_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_challenge_settle ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_challenge_settle"]
    end
    tb.game_id = 0
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.game_id)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.game_id = byteArray.read_uint64();
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_challenge_settle"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_challenge_settle ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_challenge_settle"]
    end
    tb.result = 0
    tb.point = 0
    tb.honour = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
    	byteArray.write_int(tb.point)
    	byteArray.write_int(tb.honour)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
        tb.point = byteArray.read_int();
        tb.honour = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_challenge_settle"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_be_challenged_times ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_be_challenged_times"]
    end
    tb.times = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.times)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.times = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_be_challenged_times"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_get_be_challenged_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_get_be_challenged_info"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_get_be_challenged_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_challenge_info_list ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_challenge_info_list"]
    end
    tb.infos = {}

    tb.encode = function(byteArray)
        byteArray.write_uint16(#(tb.infos))
        for k, v in pairs(tb.infos) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        local countOfinfos = byteArray.read_uint16()
        tb.infos = {}
        for i = 1, countOfinfos do
            local temp = challenge_info()
            temp.decode(byteArray)
            table.insert(tb.infos, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_challenge_info_list"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_get_challenge_rank ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_get_challenge_rank"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_get_challenge_rank"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_challenge_rank_list ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_challenge_rank_list"]
    end
    tb.infos = {}

    tb.encode = function(byteArray)
        byteArray.write_uint16(#(tb.infos))
        for k, v in pairs(tb.infos) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        local countOfinfos = byteArray.read_uint16()
        tb.infos = {}
        for i = 1, countOfinfos do
            local temp = rank_info()
            temp.decode(byteArray)
            table.insert(tb.infos, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_challenge_rank_list"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_get_can_challenge_role ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_get_can_challenge_role"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_get_can_challenge_role"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_can_challenge_lists ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_can_challenge_lists"]
    end
    tb.infos = {}

    tb.encode = function(byteArray)
        byteArray.write_uint16(#(tb.infos))
        for k, v in pairs(tb.infos) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        local countOfinfos = byteArray.read_uint16()
        tb.infos = {}
        for i = 1, countOfinfos do
            local temp = rank_info()
            temp.decode(byteArray)
            table.insert(tb.infos, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_can_challenge_lists"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_buy_challenge_times ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_buy_challenge_times"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_buy_challenge_times"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_buy_challenge_times_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_buy_challenge_times_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_buy_challenge_times_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_get_challenge_times_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_get_challenge_times_info"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_get_challenge_times_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_challenge_times_info ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_challenge_times_info"]
    end
    tb.buy_times = 0
    tb.org_times = 0
    tb.play_times = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.buy_times)
    	byteArray.write_int(tb.org_times)
    	byteArray.write_int(tb.play_times)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.buy_times = byteArray.read_int();
        tb.org_times = byteArray.read_int();
        tb.play_times = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_challenge_times_info"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_assistance_list ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_assistance_list"]
    end

    tb.encode = function(byteArray)
        return byteArray
    end

    tb.decode = function(byteArray)
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_assistance_list"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_assistance_list ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_assistance_list"]
    end
    tb.donors = {}

    tb.encode = function(byteArray)
        byteArray.write_uint16(#(tb.donors))
        for k, v in pairs(tb.donors) do
            byteArray = v.encode(byteArray)
        end
        return byteArray
    end

    tb.decode = function(byteArray)
        local countOfdonors = byteArray.read_uint16()
        tb.donors = {}
        for i = 1, countOfdonors do
            local temp = donor()
            temp.decode(byteArray)
            table.insert(tb.donors, temp)
        end
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_assistance_list"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_select_donor ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_select_donor"]
    end
    tb.donor_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_uint64(tb.donor_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.donor_id = byteArray.read_uint64();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_select_donor"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_select_donor_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_select_donor_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_select_donor_result"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_role_info_change ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_role_info_change"]
    end
    tb.type = ""
    tb.new_value = 0

    tb.encode = function(byteArray)
    	byteArray.write_string(tb.type)
    	byteArray.write_int(tb.new_value)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.type = byteArray.read_string();
        tb.new_value = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_role_info_change"])
        return tb.encode(byteArray)
    end

    return tb

end

function req_buy_mall_item ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_req_buy_mall_item"]
    end
    tb.mallitem_id = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.mallitem_id)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.mallitem_id = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_req_buy_mall_item"])
        return tb.encode(byteArray)
    end

    return tb

end

function notify_buy_mall_item_result ()
    local tb = {}
    tb.getMsgID = function()
        return NetMsgType["msg_notify_buy_mall_item_result"]
    end
    tb.result = 0

    tb.encode = function(byteArray)
    	byteArray.write_int(tb.result)
        return byteArray
    end

    tb.decode = function(byteArray)
        tb.result = byteArray.read_int();
    end

    tb.build = function(byteArray)
        byteArray.write_uint16(NetMsgType["msg_notify_buy_mall_item_result"])
        return tb.encode(byteArray)
    end

    return tb

end
