----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-11-21
-- 描述：游戏逻辑数据表
----------------------------------------------------------------------
require "XmlTable"

-- 各数据表
local mRandomNameTable = XmlTable_load("random_name_tplt.xml", "id")					-- 随机姓字库
local mRandomSecondNameTable = XmlTable_load("random_secondname_tplt.xml", "id")		-- 随机名字库
local mGame_discrete_date = XmlTable_load("game_discrete_date.xml", "gamedate")
local mTaskTable = XmlTable_load("task_tplt.xml", "id")									-- 任务数据表
local mGiftBagTable = XmlTable_load("gift_bag_tplt.xml", "id")							-- 礼包表
local mDailyAwardTable = XmlTable_load("daily_award_tplt.xml", "level_range")			-- 每日奖励表
local mExpressionTable = XmlTable_load("expression_tplt.xml", "id")						-- 公示表
local mError_Code = XmlTable_load("error_code_tplt.xml", "id")							-- 错误代码表
local mItem_Pack = XmlTable_load("item_tplt.xml", "id")									-- 物品表
local mExtendPack = XmlTable_load("extend_pack_price.xml", "the_time")					-- 拓展背包价格表
-- 商城物品
local mTbProductsInfo = XmlTable_load("mall_item.xml", "id")
-- 商城公告xml 
local mTbPostInfo = XmlTable_load("mall_post.xml", "id")
-- (商城)分页按钮 
local mtbRadioBtnInfo = XmlTable_load("mall_radio.xml", "id")
-- 积分商城物品
local mTbGameRankProductsInfo = XmlTable_load("point_mall_tplt.xml", "id")
-- 音频
local mTbAudioInfo = XmlTable_load("music_tplt.xml", "id")
-- 引导事件表
local mTbGuideEventInfo = XmlTable_load("NoviceData.xml", "id")
-- 引导位置表
local mTbGuideLocationInfo = XmlTable_load("LocationData.xml", "id")
-- 引导行为表
local mTbGuideBehaviorInfo = XmlTable_load("BehaviorData.xml", "id")
-- 活跃任务表
local mActivenessTaskTable = XmlTable_load("activeness_task_tplt.xml", "id")
-- 活跃度奖励表
local mActivenessRewardTable = XmlTable_load("activeness_reward_tplt.xml", "id")
-- 奖励表
local mRewardItemTable = XmlTable_load("reward_item_tplt.xml", "id")
-- 装备分解
local mTbEquipResolve = XmlTable_load("equipment_resolve_tplt.xml", "id")
-- 装备升介
local mTbEquipAdvance = XmlTable_load("equipment_advance_tplt.xml", "id")
-- 装备重铸
local mTbEquipRecast = XmlTable_load("equipment_recast_tplt.xml", "id")
-- 装备转换表
local mEquipExchangeTable = XmlTable_load("equipment_exchange.xml", "id")
-- 祝福模板表
local mBlessTpltTable = XmlTable_load("benison_tplt.xml", "id")
-- 祝福属性表
local mBlessPropTable = XmlTable_load("benison_status_tplt.xml", "id")
-- 军衔表
local mMiltitaryRankTable = XmlTable_load("military_rank_tplt.xml", "id")
-- 活动开关表
local mActivitySwitchTable = XmlTable_load("activity_switch_tplt.xml", "id")
-- 冲级活动表
local mLevelGiftTable = XmlTable_load("upgrade_task_tplt.xml", "id")
-- 友情点奖励表
local mFriendPointTable = XmlTable_load("friend_point_lottery_tplt.xml", "id")
-- 炼金术表
local mGetCoinTable = XmlTable_load("alchemy_tplt.xml", "id")
-- 副本解锁表
local mCopyUnlockTb = XmlTable_load("function_unlock_tplt.xml", "id")
-- 充值表
local mRechargeTable = XmlTable_load("recharge_tplt.xml", "id")
-- 在线奖励表
local mOnlineRewardTable = XmlTable_load("online_award_tplt.xml", "id")
-- 打折限购表
local mDiscountTable = XmlTable_load("discount_mall_item_tplt.xml", "id")
-- 物品兑换表
local mExchangeItemTable = XmlTable_load("exchange_item_tplt.xml", "id")
-- 副本群
local mGame_CopyGroup = XmlTable_load("copy_group_tplt.xml", "id")  
-- 副本
local mGame_Copy = XmlTable_load("copy_tplt.xml", "id")
-- 提示功能表
local mTipFunctionTable = XmlTable_load("tip_function_tplt.xml", "id")
-- 层数表
local mGameMapTable = XmlTable_load("game_map_tplt.xml", "id")
-- 分组赛额外奖励表
local mSpecialAwardTable = XmlTable_load("ladder_match_special_award.xml", "id")
-- 邀请码奖励表
local mInviteCodeRewardTb = XmlTable_load("invite_code_reward_tplt.xml", "id")
-- 邀请码帮助奖励表
local mInviteCodeHelpRewardTb = XmlTable_load("invite_help_reward_tplt.xml", "id")
-- 排位赛奖励表
local mChallengeAwardTable = XmlTable_load("challenge_reward_tplt.xml", "id")
-- 月卡每日奖励表
local mMonthCardDailyAwardTable = XmlTable_load("mooncard_daily_award_tplt.xml", "id")
-- 活动副本群表
local mActivityCopyGroupTable = XmlTable_load("activities_tplt.xml", "id")
-- 活动副本表
local mActivityCopyTable = XmlTable_load("activity_copy_tplt.xml", "id")
-- 社交入口表
local mSocialContactTable = XmlTable_load("social_contact_switch_tplt.xml", "id")
-- 地图规则
local mGameMapRuleTable = XmlTable_load("game_map_rule_tplt.xml", "id")
-- BOSS回合
local mBossRound = XmlTable_load("boss_round_tplt.xml", "id")
-- BOSS回合事件
local mBossRoundRuler = XmlTable_load("boss_round_event_tplt.xml","id")
--天赋数据表
local mTalentTable = XmlTable_load("talent_tplt.xml", "id")
--天赋表现表
--local mTalentPerformTable = XmlTable_load("talent_perform_tplt_mapping.xml", "id")
--天赋升级表
local mTalentLelUpTable = XmlTable_load("talent_level_up_tplt.xml", "level_up_id")
-- 更新公告表
local mUpdateNoticeTable = XmlTable_load("update_notice.xml", "id")
-- 公告资源表
local mResourcesNoticeTable = XmlTable_load("resources_notice.xml", "id")
-- 公告标签表
local mMarkNoticeTable = XmlTable_load("mark_notice.xml", "id")
-- 跳转接口数据
local mInterFaceDataTable = XmlTable_load("interface_data.xml", "id")
--限时奖励表
local mTimeLimitRewardTable = XmlTable_load("time_limit_reward_tplt.xml", "id")
-- 用户协议
local mRegisterProtocalTable = XmlTable_load("register_protocal.xml", "id")

LogicTable = {
}

-- 获取用户协议
LogicTable.getRegisterProtocal = function()
	local tb = {}
	for k, v in pairs(mRegisterProtocalTable.map) do
		local row = {}
		
		row.id = v.id + 0
		row.icon = v.icon + 0
		row.mark_id = v.mark_id + 0
		row.title = v.title
		row.sub_title = v.sub_title
		row.text = v.text
		row.type = v.type + 0
		row.top_pic = v.top_pic
		row.form = true
		
		table.insert(tb, row)
	end
	
	return tb
end

-- 获得所有更新公告
LogicTable.getAllUpdateNotice = function()
	local tb = {}
	for k, v in pairs(mUpdateNoticeTable.map) do
		local row = {}
		
		row.id = v.id + 0
		row.icon = v.icon + 0
		row.mark_id = v.mark_id + 0
		row.title = v.title
		row.sub_title = v.sub_title
		row.text = v.text
		row.type = v.type + 0
		row.top_pic = v.top_pic
		row.form = true
		
		table.insert(tb, row)
	end
	
	return tb
end

-- 获取更新公告
LogicTable.getUpdateNoticeById = function(id)
	local res = XmlTable_getRow(mUpdateNoticeTable, id, true)
	local row = {}
	
	row.id = res.id + 0
	row.icon = res.icon + 0
	row.mark_id = res.mark_id + 0
	row.title = res.title
	row.sub_title = res.sub_title
	row.text = res.text
	row.type = res.type + 0
	row.top_pic = res.top_pic
	row.form = true
	
	return row
end

-- 获得所有公告资源
LogicTable.getAllResourcesNotice = function()
	local tb = {}
	for k, v in pairs(mResourcesNoticeTable.map) do
		local row = {}
		
		row.id = v.id + 0
		row.icon = v.icon
		row.picture = v.picture
		
		table.insert(tb, row)
	end
	
	return tb
end

-- 获取公告资源
LogicTable.getResourcesNoticeById = function(id)
	local res = XmlTable_getRow(mResourcesNoticeTable, id, true)
	local row = {}

	row.id = res.id + 0
	row.icon = res.icon
	row.picture = res.picture
	
	return row
end

-- 获得所有公告标签
LogicTable.getAllMarkNotice = function()
	local tb = {}
	for k, v in pairs(mMarkNoticeTable.map) do
		local row = {}
		
		row.id = v.id + 0
		row.mark = v.mark
		
		table.insert(tb, row)
	end
	
	return tb
end

-- 获取公告标签
LogicTable.getMarkNoticeById = function(id)
	local res = XmlTable_getRow(mMarkNoticeTable, id, true)
	local row = {}
	
	row.id = res.id + 0
	row.mark = res.mark
	
	return row
end

-- 获得所有跳转接口数据
LogicTable.getAllInterface = function()
	local tb = {}
	for k, v in pairs(mInterFaceDataTable.map) do
		local row = {}
		
		row.id = v.id + 0
		row.interface = v.interface
		
		table.insert(tb, row)
	end
	
	return tb
end

-- 获取跳转接口数据
LogicTable.getInterfaceById = function(id)
	local res = XmlTable_getRow(mInterFaceDataTable, id, true)
	local row = {}
	
	row.id = res.id + 0
	row.interface = res.interface
	
	return row
end

--判断物品id是否在表中
LogicTable.getBossRoundInfo= function(id)
	return mBossRound.map[tostring(id)]
end
LogicTable.getBossRounEventdInfo= function(id)
	return mBossRoundRuler.map[tostring(id)]
end

--判断物品id是否在表中
LogicTable.IsExistItemID = function(id)
	local res = XmlTable_getRow(mItem_Pack, id, false)
	return (res ~= nil)
end

---  背包转到各种 类型 的中转表（通过物品id，获得物品信息）
LogicTable.getItemById = function(id)
	local res = XmlTable_getRow(mItem_Pack, id, true)

	local row = {}

	row.id = res.id + 0
	row.type = res.type + 0		-- 1装备, 2符文, 3宝石, 4杂物, 5道具
	row.name = res.name
	row.overlay_count = res.overlay_count
	row.sell_price = res.sell_price
	row.sub_id = res.sub_id
	row.icon = res.icon
	row.describe = res.describe
	row.quality = res.quality + 0
	row.bind_type = res.bind_type
	row.role_type = res.role_type  -- 0表示通用，1~4对应职业ID

	return row
end

-- 错误代码
LogicTable.getErrorById = function(id)
	local res = XmlTable_getRow(mError_Code, id, false)
	if nil == res then
		return nil
	end
	
	local row = {}
	row.id = res.id					-- 消息id		
	row.type = res.type				-- 类型
	row.text = res.text				-- 内容
	row.eventtype = res.eventtype	-- 事件类型

	return row
end


--获得扩展背包费用
LogicTable.getExpandPrice = function(the_time)
	local res = XmlTable_getRow(mExtendPack, the_time, true)
	local row = {}

	row.the_time = res.the_time	
	row.price = res.price + 0

	return row.price
end

-- 获取姓
LogicTable.getRadomNameTable = function(id)
	local res = XmlTable_getRow(mRandomNameTable, id, true)
	local row = {}

	row.id = res.id
	row.relate_id = res.relate_id
	row.probability = res.probability
	row.content = CommonFunc_split(res.content, ",")

	return row
end
-- 获取名
LogicTable.getRadomSecondNameTable = function(id)
	local res = XmlTable_getRow(mRandomSecondNameTable, id, true)
	local row = {}

	row.id = res.id
	row.content = CommonFunc_split(res.content, ",")

	return row
end

-- 游戏离散数据
LogicTable.getGameDateTable = function()
	local res = XmlTable_getRow(mGame_discrete_date, "gamedate", true)
	local row = {}

	row.speed = res.speed
	row.attack = res.attack

	return row
end

-- 获取排位赛奖励
LogicTable.getChallengeAward = function()
	local tb = {}
	for k, v in pairs(mChallengeAwardTable.map) do
		-- local data = mChallengeAwardTable.map[tostring(100 + k)]
		local row = {}
		
		row.rank_range = CommonFunc_split(v.rank_range, ",", true)
		row.amounts = CommonFunc_split(v.amounts, ",")
		row.ids = CommonFunc_split(v.ids, ",")
		row.id = v.id + 0
		
		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	
	return tb
end

-- 获取分组赛额外奖励表
LogicTable.getLadderMatchSpecialAward = function(id)
	local tb = {}
	for i=1,4 do 
		-- cclog("id--------------->"..id..", mSpecialAwardTable.map[tostring(id*100 + i)]----------------->")
		-- Log(mSpecialAwardTable.map[tostring(id*100 + i)])
		-- print("Error:!",id,mSpecialAwardTable.map[tostring(id*100 + i)],mSpecialAwardTable.map[id*100 + i])
		local data = mSpecialAwardTable.map[tostring(id*100 + i)]
		local row = {}
		
		row.rank_range = CommonFunc_split(data.rank_range, ",", true)
		row.weekiy_award_amounts = CommonFunc_split(data.weekiy_award_amounts, ",")
		row.weekiy_award_ids = CommonFunc_split(data.weekiy_award_ids, ",")
		row.id = data.id + 0
		row.lev_pool_id = data.lev_pool_id + 0
		
		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	
	return tb
end

--获取所有副本群
LogicTable.getAllCopyGroup = function()
	local tb = {}
	for k, v in pairs(mGame_CopyGroup.map) do
		local row = {}

		row.id = v.id
		row.name = v.name
		row.type = v.type
		row.next_group_id = v.next_group_id
		row.icon = v.icon
		row.first_copy_id = v.first_copy_id

		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)

	return tb
end

--获取所有副本
LogicTable.getGameAllFB = function()
	local tb = {}
	for k, v in pairs(mGame_Copy.map) do
		local row = {}

		row.id = v.id + 0
		row.type = v.type
		row.name = v.name
		row.icon = v.icon
		row.copy_group_id = v.copy_group_id + 0
		row.need_power = v.need_power
		row.win_need_power = v.win_need_power
		row.gold = v.gold
		row.exp = v.exp
		row.award = v.award
		row.describe = v.describe
		row.first_map_id = v.first_map_id
		row.pre_copy = CommonFunc_split(v.pre_copy, ",")
		row.need_stone = v.need_stone + 0
		row.dropitems = CommonFunc_split(v.dropitems, ",")
		row.small_icon = v.small_icon
		row.recommended_battle_power = v.recommended_battle_power + 0
		row.new_monsters = v.new_monsters
		row.need_level = v.need_level
		row.dialog_groupid = v.dialog_groupid
		row.min_life_percent = v.min_life_percent
		row.min_cost_round = v.min_cost_round
		row.clean_up_reward_ids = CommonFunc_split(v.clean_up_reward_ids, ",")
		row.clean_up_reward_amounts = CommonFunc_split(v.clean_up_reward_amounts, ",")
		
		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)

	return tb
end

LogicTable.getCopyGroupById = function(id)
	if id == nil then return end
	local res = XmlTable_getRow(mGame_CopyGroup, id, true)
	local row = {}

	row.id = res.id	
	row.type = res.type
	row.name = res.name
	row.next_group_id = res.next_group_id
	row.icon = res.icon
	row.first_copy_id = res.first_copy_id
	row.last_copy_id = res.last_copy_id

	return row
end

LogicTable.getCopyById = function(id)
	local res = XmlTable_getRow(mGame_Copy, id, true)
	local row = {}

	row.id = res.id
	row.type = res.type
	row.name = res.name
	row.icon = res.icon
	row.copy_group_id = res.copy_group_id
	row.need_power = res.need_power
	row.win_need_power = res.win_need_power
	row.gold = res.gold
	row.exp = res.exp
	row.award = res.award
	row.describe = res.describe
	row.first_map_id = res.first_map_id
	row.pre_copy = CommonFunc_split(res.pre_copy, ",")
	row.need_stone = res.need_stone
	row.small_icon = res.small_icon
	row.dropitems = CommonFunc_split(res.dropitems, ",")
	row.new_monsters = res.new_monsters
	row.need_level = res.need_level
    row.dialog_groupid = res.dialog_groupid
    row.min_life_percent = res.min_life_percent
    row.min_cost_round = res.min_cost_round
	row.clean_up_reward_ids = CommonFunc_split(res.clean_up_reward_ids, ",")
	row.clean_up_reward_amounts = CommonFunc_split(res.clean_up_reward_amounts, ",")
	
	return row
end


local mAwardTb = XmlTable_load("game_award.xml", "id") 
--获得副本的奖励信息
LogicTable.getCopyAwardById = function(id)
	local res = XmlTable_getRow(mAwardTb, id, true)
	local row = {}
	row.id = res.id
	--[[
	cclog(res.id_list1,res.id_list1[1],res.id_list1[2])
	row.id_list1 = CommonFunc_split(res.id_list1)
	row.amount_list1 = CommonFunc_split(res.amount_list1)
	row.list1_ratio = res.list1_ratio
	
	row.id_list2 = CommonFunc_split(res.id_list2, ",")
	row.amount_list2 = CommonFunc_split(res.amount_list2)
	row.list2_ratio = CommonFunc_split(res.list2_ratio, ",")
	
	row.id_list3 = CommonFunc_split(res.id_list3, ",")
	row.amount_list3 = CommonFunc_split(res.amount_list3, ",")
	row.list3_ratio = res.list3_ratio
	]]--
	row.need_emoney = res.need_emoney

	
	return row
end



LogicTable.getAllItems = function()
	local tb = {}
	for k, v in pairs(mItem_Pack.map) do
		local row = {}

		row.id = v.id + 0
		row.type = v.type + 0
		row.name = v.name
		row.overlay_count = v.overlay_count + 0
		row.sell_price = v.sell_price + 0
		row.sub_id = v.sub_id + 0
		row.icon = v.icon
		row.describe = v.describe
		row.bind_type = v.bind_type + 0
		row.role_type = v.role_type + 0
		row.quality = v.quality + 0

        table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

-- 根据任务id获取任务信息
LogicTable.getTaskRow = function(task_id)
	local res = XmlTable_getRow(mTaskTable, task_id, true)
	local row = {}
	
	row.id = tonumber(res.id)											-- 任务id
	row.title = res.title												-- 任务标题
	row.main_type = tonumber(res.main_type)								-- 任务主类型,1-主线,2-支线,3-新手任务
	row.need_level = tonumber(res.need_level)							-- 任务等级要求
	row.next_ids = CommonFunc_split(res.next_ids, ",")					-- 后置任务id
	row.sub_type = tonumber(res.sub_type)								-- 任务子类型,1-击杀怪物,2-通关副本,3-收集物品,4-符文充能,5-强化装备,6-分解装备,7-占卜次数
	row.monster_id = tonumber(res.monster_id)							-- 怪物id
	row.clear_type = tonumber(res.clear_type)							-- 通关类型
	row.collect_id = tonumber(res.collect_id)							-- 收集物品id
	row.location = tonumber(res.location)								-- 任务地点
	row.number = tonumber(res.number)									-- 任务要求数量
	row.text = res.text													-- 任务描述
	row.reward_ids = CommonFunc_split(res.reward_ids, ",")				-- 奖励id列表
	row.reward_amounts = CommonFunc_split(res.reward_amounts, ",")		-- 奖励数量列表
	
	return row
end

-- 获取商城物品信息
LogicTable.getProductData = function()
	local function func(row)
		return ("1" == row.show)
	end
	return XmlTable_getRowArray(mTbProductsInfo, func)
end

-- 获取商城所有物品信息
LogicTable.getAllProductInfo = function()
	local tb = {}
	for k, v in pairs(mTbProductsInfo.map) do
		local row = {}
		
		row.id = v.id
		row.item_id = v.item_id
		row.item_amount = v.item_amount
		row.price_type = v.price_type
		row.price = v.price + 0
		row.vip_discount = v.vip_discount + 0
		row.mark = v.mark
		row.buy_limit = v.buy_limit + 0
		row.tag_id = v.tag_id
		row.profession = v.profession
		row.level = v.level + 0
		row.client_show = v.client_show
		row.item_sources = v.item_sources
		
		table.insert(tb, row)
	end
	return tb
end

-- 通过物品id获取商城物品信息
LogicTable.getProductInfoById = function(id)
	local row = XmlTable_getRow(mTbProductsInfo, id, true)
	local tbRow = {}

	tbRow.id = row.id	
	tbRow.item_id = row.item_id
	tbRow.item_amount = row.item_amount
	tbRow.price_type = row.price_type
	tbRow.price = row.price + 0
	tbRow.vip_discount = row.vip_discount + 0
	tbRow.mark = row.mark
	tbRow.buy_limit = row.buy_limit + 0
	tbRow.tag_id = row.tag_id
	tbRow.profession = row.profession
	tbRow.level = row.level + 0
	tbRow.client_show = row.client_show
	tbRow.item_sources = row.item_sources
	
	return tbRow
end

-- 获取积分商城物品信息
LogicTable.getGameRankProductData = function()
	local function func(row)
		return "1" == row.show
	end
	return XmlTable_getRowArray(mTbGameRankProductsInfo, func)
end

-- 通过物品id获取积分商城物品信息
LogicTable.getGameRankProductInfoById = function(id)
	local row = XmlTable_getRow(mTbGameRankProductsInfo, id, true)
	local tbRow = {}
	
	tbRow.id = row.id
	tbRow.mall_item_type = row.mall_item_type	-- 1 物品, 2 符文
	tbRow.item_id = row.item_id
	tbRow.item_amount = row.item_amount
	tbRow.need_ids = row.need_ids + 0
	tbRow.need_amounts = row.need_amounts + 0
	tbRow.tag_id = row.tag_id
	tbRow.need_rank = row.need_rank + 0
	tbRow.show = row.show
	tbRow.profession = row.profession
	tbRow.level = row.level + 0
	
	return tbRow
end

-- 公告
LogicTable.getPostsData = function()
	return mTbPostInfo.map
end

-- 通过公告id获取公告信息
LogicTable.getPostsInfoById = function(id)
	local row = XmlTable_getRow(mTbPostInfo, id, true)
	local tbRow = {}
	
	tbRow.id = row.id
	tbRow.text = row.text
	tbRow.display = row.display
	
	return tbRow
end

-- 通过type获取(商城)分页按钮, type:1->商城, 2->积分商城, ...
LogicTable.getRadioDataByType = function(type)
	local function func(row)
		return tostring(type) == row.mall_type
	end
	return XmlTable_getRowArray(mtbRadioBtnInfo, func)
end

-- 根据礼包id获取礼包信息
LogicTable.getGiftBagRow = function(gift_bag_id)
	local res = XmlTable_getRow(mGiftBagTable, gift_bag_id, true)
	local row = {}
	
	row.id = res.id						-- 礼包id
	row.name = res.name					-- 礼包名称
	row.icon = res.icon					-- 礼包图标
	if "-1" == res.item_id then			-- 物品,对应reward_item_tplt.xml的id
		row.reward_item_ids = {}
	else
		row.reward_item_ids = CommonFunc_split(res.item_id, ",")
	end
	if "-1" == res.item_amount then		-- 数量
		row.reward_item_amounts = {}
	else
		row.reward_item_amounts = CommonFunc_split(res.item_amount, ",")
	end
	row.desc = res.desc					-- 礼包描述

	return row
end

-- 根据玩家等级获取每日奖励信息
LogicTable.getDailyAwardRow = function(player_level)
	local row = {}
	for k, v in pairs(mDailyAwardTable.map) do
		row.level_range = CommonFunc_split(v.level_range, ",")	-- 玩家等级范围
		row.days1_award = v.days1_award			-- 登录1天礼包id
		row.days3_award = v.days3_award			-- 连续登录3天礼包id
		row.days7_award = v.days7_award			-- 连续登录7天礼包id		
		row.days15_award = v.days15_award		-- 连续登录15天礼包id
		if 1 == #row.level_range then
			if tonumber(player_level) >= tonumber(row.level_range[1]) then
				break
			end
		elseif 2 == #row.level_range then
			if tonumber(player_level) >= tonumber(row.level_range[1]) and 
			   tonumber(player_level) <= tonumber(row.level_range[2]) then
				break
			end
		end
	end
	return row
end

-- 获取公式信息
LogicTable.getExpressionRow = function(id)
	local row = XmlTable_getRow(mExpressionTable, id, true)
	local expresionRow = {}
	
	--[[
	1.本符文能提供多少经验
	2.符文需要多少经验能升至下一级
	3.符文被用于充能需要多少金币
	4.符文出售的售价
	5.
	6.生命
	7.速度
	8.攻击
	9.命中
	10.闪避
	11.暴击
	12.韧性
	]]
	expresionRow.id = row.id + 0				-- 公式id
	expresionRow.expression = row.expression	-- 公式
	
	return expresionRow
end

-- 通过类型获取所有音频文件
LogicTable.getAudioFileTbByType = function(type)
	local function func(row)
		return tostring(type) == row.type
	end
	return XmlTable_getRowArray(mTbAudioInfo, func)
end
	
-- 通过id获取音频文件信息
LogicTable.getAudioInfoById = function(id)
	local row = XmlTable_getRow(mTbAudioInfo, id, true)
	local data = {}
	
	data.id = row.id
	data.type = row.type
	data.name = row.name
	
	return data
end

-- 通过id获取音频文件名
LogicTable.getAudioFileNameById = function(id)
	id = tostring(id)
	return LogicTable.getAudioInfoById(id).name
end

-- 通过组id获取某组事件tb并排序
LogicTable.getGroupEventInfoById = function(groupId)
	local tbData = {}
	for k1, v1 in next, (mTbGuideEventInfo.map) do
		if groupId == v1.group_id then
			table.insert(tbData, v1)
		end
	end	
	
	table.sort(tbData, function(a, b) return tonumber(a.behavior_id) < tonumber(b.behavior_id) end)
	
	return tbData
end

-- 通过事件id获取事件信息
LogicTable.getEventInfoById = function(id)
	local tb = XmlTable_getRow(mTbGuideEventInfo, id, true)
	local tbRow = {}
	
	tbRow.id = tb.id
	tbRow.group_id = tb.group_id	
	tbRow.trigger_type = tb.trigger_type
	tbRow.trigger_val = tb.trigger_val + 0
	tbRow.nextEvent_id = tb.nextEvent_id
	tbRow.behavior_id = tb.behavior_id
	tbRow.assist_id = tb.assist_id
	tbRow.dialog_id = tb.dialog_id			
	
	return tbRow
end

-- 通过行为id获取行为信息
local scaleVal = 1.125
LogicTable.geBehaviorInfoById = function(id)
	local tb = XmlTable_getRow(mTbGuideBehaviorInfo, id, true)
	local tbRow = {}

	tbRow.id = tb.id
	tbRow.type = tb.type	
	tbRow.posX = (tb.posX + 0)*scaleVal
	tbRow.posY = (tb.posY + 0)*scaleVal
	tbRow.width = (tb.width + 0)*scaleVal
	tbRow.height = (tb.height + 0)*scaleVal		
	
	return tbRow
end

-- 通过助理/对话框id获取位置/图片信息
LogicTable.getLocInfoById = function(id)
	local tb = XmlTable_getRow(mTbGuideLocationInfo, id, false)
	if nil == tb then
		return nil
	end
	
	local tbRow = {}	
	tbRow.id = tb.id
	tbRow.desc = tb.desc
		
	return tbRow
end

-- 获取活跃任务信息
LogicTable.getActivenessTaskRow = function(id)
	local row = XmlTable_getRow(mActivenessTaskTable, id, true)
	local data = {}
	
	data.id = tonumber(row.id)							-- 活跃任务id
	data.name = row.name								-- 活跃任务名称
	data.max_times = tonumber(row.max_times)			-- 当前完成目标次数
	data.award_pertime = tonumber(row.award_pertime)	-- 每次奖励活跃度
	
	return data
end

-- 获取活跃度奖励信息
LogicTable.getActivenessRewardRow = function(id)
	local row = XmlTable_getRow(mActivenessRewardTable, id, true)
	local data = {}
	
	data.id = tonumber(row.id)
	data.ids = CommonFunc_split(row.ids, ",")
	data.amounts = CommonFunc_split(row.amounts, ",")
	data.need_activess = tonumber(row.need_activess)
	
	return data
end

local mRewardName = XmlTable_load("typetoname_tplt.xml", "type")

LogicTable.getRewardTypeDate = function(key)
	key = tostring(key)
	return mRewardName.map[key]
end

-- 获取地图规则
LogicTable.getGameMapRuleRow = function(id)
	local row = XmlTable_getRow(mGameMapRuleTable, id, true)
	local data = {}
	
	data.id = row.id + 0
	data.monster = CommonFunc_split(row.monster, ",")
	data.monster_pos = CommonFunc_split(row.monster_pos, ",")
	data.door = row.door
	data.awards = CommonFunc_parseStringTuple(row.awards)
	data.barries_pos = row.barries_pos
	data.boss_amount = row.boss_amount + 0
	data.boss = CommonFunc_parseStringTuple(row.boss)
	data.boss_rule = row.boss_rule
	return data
end

-- 获取层数表
LogicTable.getGameMapItemRow = function(id)
	
	local row = XmlTable_getRow(mGameMapTable, id, true)
	local data = {}
	
	data.copy_id = row.copy_id + 0
	data.trap = CommonFunc_split(row.trap, ",")
	data.map_rule_id = row.map_rule_id + 0
	data.next_map = row.next_map + 0
	data.room = row.room + 0
	data.monster = CommonFunc_split(row.monster, ",")
	data.friend_role = row.friend_role + 0
	data.key_monster = row.key_monster
	data.buff = CommonFunc_split(row.buff, ",")
	data.barries_amount = row.barries_amount + 0
	data.name = row.name
	data.id = row.id + 0
	
	return data
end

-- 获取奖励物品表
LogicTable.getRewardItemRow = function(id)
	local row = XmlTable_getRow(mRewardItemTable, id, true)
	local data = {}
	
	data.id = row.id + 0					-- 奖励id
	data.type = row.type + 0				-- 奖励类型
	data.name = ""							-- 奖励名称
	data.icon = nil							-- 奖励图标
	data.temp_id = row.temp_id 				-- 对应的模板id
	data.sell_price = 0
	if string.sub(row.temp_id,-1,-1)== "}" and string.sub(row.temp_id,1,1)== "{" then
		row.temp_id = string.sub(row.temp_id,2,string.len(row.temp_id)-1)
		data.temp_id = CommonFunc_split(row.temp_id, ",")		--wu
	else
		data.temp_id = row.temp_id + 0	-- 对应物品表或符文表的id
	end
	
	data.description = row.description		-- 奖励描述
	if 1 == data.type then			-- 1.金币
		data.name = GameString.get("PUBLIC_GOLD")
		data.icon = "icon_money.png"
	elseif 2 == data.type then		-- 2.经验
		data.name = GameString.get("PUBLIC_EXP")
		data.icon = "icon_exp.png"
	elseif 3 == data.type then		-- 3.魔石
		data.name = GameString.get("PUBLIC_MAGIC_STONE")
		data.icon = "icon_magic_stone.png"
	elseif 4 == data.type then		-- 4.体力
		data.name = GameString.get("PUBLIC_HP")
		data.icon = "icon_hp.png"
	elseif 5 == data.type then		-- 5.战绩
		data.name = GameString.get("PUBLIC_COMBAT_GAINS")
		data.icon = "icon_combat_gains.png"
	elseif 6 == data.type then		-- 6.荣誉
		data.name = GameString.get("PUBLIC_HONOR")
		data.icon = "icon_honor.png"
	elseif 7 == data.type and type(data.temp_id) =="number" then		-- 7.物品,需要查找物品表
		local itemRow = LogicTable.getItemById(row.temp_id)
		data.name = itemRow.name
		data.icon = itemRow.icon
		data.description = itemRow.describe
		data.role_type = itemRow.role_type
		data.sell_price = itemRow.sell_price
	elseif 7 == data.type and type(data.temp_id) == "table" then
		for key, val in pairs(data.temp_id) do
			local itemRow = LogicTable.getItemById(val)
			if tonumber(itemRow.role_type) == tonumber(ModelPlayer.getRoleType()) then
				data.temp_id = val
				data.name = itemRow.name
				data.icon = itemRow.icon
				data.description = itemRow.description
				data.role_type = itemRow.role_type
				data.sell_price = itemRow.sell_price
				break
			end
		end
	elseif 8 == data.type and type(data.temp_id) =="number" then		-- 8,技能，
		local itemRow = SkillConfig.getSkillBaseInfo(row.temp_id)
		data.name = itemRow.name
		data.icon = itemRow.icon
		data.description = itemRow.description
		data.role_type = itemRow.role_type
	elseif 8 == data.type and type(data.temp_id) == "table" then
		for key, val in pairs(data.temp_id) do
			local itemRow = SkillConfig.getSkillInfo(val)
			local itemCell = SkillConfig.getSkillBaseInfo(val)
			if tonumber(itemRow.role_type) == tonumber(ModelPlayer.getRoleType()) then
				data.temp_id = val
				data.name = itemCell.name
				data.icon = itemCell.icon
				data.description = itemCell.description
				data.role_type = itemRow.role_type
				break
			end
		end
	elseif 9 == data.type then		-- 9.召唤石
		data.name = GameString.get("PUBLIC_SUMMON_STONE")
		data.icon = "icon_summon_stone.png"
	elseif 10 == data.type then		-- 10.可溢出体力药剂
		data.name = GameString.get("PUBLIC_HP_DRUG")
		data.icon = "icon_hp_drug.png"
	elseif 11 == data.type then		-- 11.积分
		data.name = GameString.get("PUBLIC_SCORE")
		data.icon = "icon_score.png"
	elseif 12 == data.type then		-- 12.战魂
		data.name = GameString.get("PUBLIC_ZH")
		data.icon = "icon_zhanhun.png"
	elseif 13 == data.type and type(data.temp_id) =="number" then
		local skillFragInfo = SkillConfig.getSkillFragInfo(data.temp_id)
		data.name = skillFragInfo.name
		data.icon = skillFragInfo.icon
	elseif 13 == data.type and type(data.temp_id) == "table" then		-- 13.技能碎片
		for key, val in pairs(data.temp_id) do
			local skillFragInfo = SkillConfig.getSkillFragInfo(val)
			if tonumber(skillFragInfo.role_type) == tonumber(ModelPlayer.getRoleType()) or tonumber(skillFragInfo.role_type) == 0 then
				data.temp_id = val
				data.name = skillFragInfo.name
				data.icon = skillFragInfo.icon
				data.description = skillFragInfo.desc
				data.role_type = skillFragInfo.role_type
				break
			end
		end
	end
	return data
end

-- 通过分解装备ID获取分解装备信息
LogicTable.getResolveInfoById = function(id)
	local tb = XmlTable_getRow(mTbEquipResolve, id)
	if tb == nil then
		return nil
	end
	
	local tbRow = {}
	tbRow.id = tb.id
	tbRow.material_resolved = tb.material_resolved		
		
	return tbRow
end

-- 通过装备ID获取升介后装备信息
LogicTable.getAdvanceInfoById = function(id)
	local tb = XmlTable_getRow(mTbEquipAdvance, id)
	if tb == nil then
		return nil
	end
	
	local tbRow = {}
	tbRow.id = tb.id
	tbRow.need_material = tb.need_material
	tbRow.need_type = tb.need_type + 0
	tbRow.need_amount = tb.need_amount + 0
	tbRow.advance_id = tb.advance_id	
		
	return tbRow
end

-- 装备升介所需材料
LogicTable.getAdvanceNeedMaterialById = function(id)
	local tb = XmlTable_getRow(mTbEquipAdvance, id)
	if tb == nil then
		return nil
	end
	
	local tbData = tb.need_material
	local tbArr = CommonFunc_split(tbData, ",")
	local tbMa = {}
	for k = 1, #(tbArr), 2 do
		local tbTemp = {}
		tbTemp.temp_id = string.sub(tbArr[k], 2)
		tbTemp.amount = tonumber(string.sub(tbArr[k + 1], 1, -2))
		table.insert(tbMa, tbTemp)
	end
	
	return tbMa
end

-- 通过装备ID获取重铸装备信息
LogicTable.getRecastInfoById = function(id)
	local tb = XmlTable_getRow(mTbEquipRecast, id)
	if tb == nil then
		return nil
	end
	
	local tbRow = {}
	tbRow.id = tb.id
	tbRow.need_material = tb.need_material	
	tbRow.need_gold = tb.need_gold + 0
	tbRow.mf_rule_id = tb.mf_rule_id	
		
	return tbRow
end

-- 获取装备转换信息
LogicTable.getEquipExchangeRow = function(id)
	local row = XmlTable_getRow(mEquipExchangeTable, id, false)
	if nil == row then
		return nil
	end
	
	local equipExchangeRow = {}	
	equipExchangeRow.id = row.id + 0		-- 转换前的装备id
	equipExchangeRow.exchange_ids = CommonFunc_split(row.exchange_ids, ",")	-- 可转换的物品id
	equipExchangeRow.need_gold = row.need_gold + 0	-- 转换所需金币
	equipExchangeRow.need_meterials = CommonFunc_split(row.need_meterials, ",")	-- 转化所需材料
	equipExchangeRow.amounts = CommonFunc_split(row.amounts, ",")	-- 所需材料数量
	
	return equipExchangeRow
end

-- 装备重铸所需材料
LogicTable.getRecastNeedMaterialById = function(id)
	local tb = XmlTable_getRow(mTbEquipRecast, id)
	if tb == nil then
		return nil
	end
	
	local tbData = tb.need_material
	local tbArr = CommonFunc_split(tbData, ",")
	local tbMa = {}
	for k = 1, #(tbArr), 2 do
		local tbTemp = {}
		tbTemp.temp_id = string.sub(tbArr[k], 2)
		tbTemp.amount = tonumber(string.sub(tbArr[k + 1], 1, -2))
		table.insert(tbMa, tbTemp)
	end
	
	return tbMa
end

-- 通过祝福id获取祝福信息
LogicTable.getBlessInfoById = function(id)
	local tb = XmlTable_getRow(mBlessTpltTable, id, true)
	local tbRow = {}
	tbRow.id = tb.id + 0						-- 唯一id
	tbRow.name = tb.name						-- 名称
	tbRow.icon = tb.icon						-- 图标
	tbRow.status_ids = tb.status_ids + 0		-- 属性id
	tbRow.duration = tb.duration + 0			-- 持续时间
	tbRow.need_emoney = tb.need_emoney + 0		-- 消耗金币
	return tbRow
end

-- 通过祝福属性id获取相应的属性
LogicTable.getBlessProInfoById = function(id)
	local tb = XmlTable_getRow(mBlessPropTable, id, true)
	local tbRow = {}
	tbRow.id = tb.id + 0						-- id
	tbRow.attr_type = tb.attr_type + 0 			-- 属性:1-生命,2-攻击,3-速度,4-命中,5-暴击,6-闪避,7-韧性
	tbRow.value_type = tb.value_type + 0		-- 类型:1-百分比,2-固定数值
	tbRow.value = tb.value + 0					-- 数值
	return tbRow
end

-- 获取军衔排名信息
LogicTable.getMiltitaryRankTable = function()
	local tb = {}
	for key, val in pairs(mMiltitaryRankTable.map) do
		local row = {}
		row.id = val.id + 0														-- 军衔id
		row.name = val.name														-- 称号
		row.icon = val.icon														-- 图标
		row.need_honour = val.need_honour + 0									-- 所需荣誉
		row.need_rank = CommonFunc_split(val.need_rank, ",")					-- 排名区间
		row.reward_ids = CommonFunc_split(val.reward_ids, ",")					-- 奖励id
		row.reward_amounts = CommonFunc_split(val.reward_amounts, ",")			-- 奖励数量
		
		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

-- 获取军衔排名信息
LogicTable.getMiltitaryRankRow = function(id)
	local row = XmlTable_getRow(mMiltitaryRankTable, id, true)
	local miltitaryRow = {}

	miltitaryRow.id = row.id + 0												-- 军衔id
	miltitaryRow.name = row.name												-- 称号
	miltitaryRow.icon = row.icon												-- 图标
	miltitaryRow.need_honour = row.need_honour + 0								-- 所需荣誉
	miltitaryRow.need_rank = CommonFunc_split(row.need_rank, ",")				-- 排名区间
	miltitaryRow.reward_ids = CommonFunc_split(row.reward_ids, ",")				-- 奖励id
	miltitaryRow.reward_amounts = CommonFunc_split(row.reward_amounts, ",")		-- 奖励数量
	
	return miltitaryRow
end

-- 获取活动开关表
LogicTable.getActivitySwitchTable = function()
	local tb = {}
	for key, val in pairs(mActivitySwitchTable.map) do
		local row = {}
		row.id = val.id + 0					-- id
		--[[
		类型:
			0.等待开启
			1.每日奖励
			2.每日活跃
			3.首充奖励
			4.冲级活动
			5.领取体力
			6.充值返利
			7.炼金术
			8.在线奖励
			9.打折限购
			10.魔塔
			11.BOSS挑战
			12.空虚之门
		]]--
		row.type = val.type + 0
		row.icon = val.icon					-- 图标
		if "null" == val.start_date then	-- 开启时间
			row.start_date = {year=2000, month=1, day=1, hour=0, minute=0, seconds=0}
		else
			local sStr = CommonFunc_split(val.start_date, "-")
			row.start_date = {year=sStr[1]+0, month=sStr[2]+0, day=sStr[3]+0, hour=sStr[4]+0, minute=sStr[5]+0, seconds=sStr[6]+0}
		end
		if "null" == val.end_date then		-- 结束时间
			row.end_date = {year=2100, month=1, day=1, hour=0, minute=0, seconds=0}
		else
			local eStr = CommonFunc_split(val.end_date, "-")
			row.end_date = {year=eStr[1]+0, month=eStr[2]+0, day=eStr[3]+0, hour=eStr[4]+0, minute=eStr[5]+0, seconds=eStr[6]+0}
		end
		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

--根据id，获取冲级活动信息
LogicTable.getlevelGiftInfoById = function(id)
	local tb = XmlTable_getRow(mLevelGiftTable, id, true)
	local tbRow = {}
	tbRow.id = tb.id + 0												-- id
	tbRow.level = tb.level + 0 											--等级
	tbRow.reward_ids = CommonFunc_split(tb.reward_ids, ",")				--奖励id
	tbRow.reward_amounts = CommonFunc_split(tb.reward_amounts, ",")		--奖励数值
	return tbRow
end

--获得活动的所有信息
LogicTable.getlevelGiftInfo = function()
	local tb = {}
	for key, val in pairs(mLevelGiftTable.map) do
		local tbRow = {}
		tbRow.id = val.id + 0												-- id
		tbRow.level = val.level + 0 											--等级
		tbRow.reward_ids = CommonFunc_split(val.reward_ids, ",")				--奖励id
		tbRow.reward_amounts = CommonFunc_split(val.reward_amounts, ",")		--奖励数值
		table.insert(tb, tbRow)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

--根据id，获取友情点奖励活动信息
LogicTable.getFriendPointInfoById = function(id)
	local tb = XmlTable_getRow(mFriendPointTable, id, true)
	local tbRow = {}
	tbRow.id = tb.id + 0												-- id
	tbRow.times = tb.times + 0 											--抽奖第几次
	tbRow.need_point = tb.need_point + 0 								--抽奖所需友情点
	return tbRow
end

--获得友情点奖励的所有信息
LogicTable.getFriendPointInfo = function()
	local tb = {}
	for key, val in pairs(mFriendPointTable.map) do
		local tbRow = {}
		tbRow.id = val.id + 0												-- id
		tbRow.times = val.times + 0 											--抽奖第几次
		tbRow.need_point = val.need_point + 0 								--抽奖所需友情点
		table.insert(tb, tbRow)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

--根据id，获取炼金术的信息
LogicTable.getCoinInfoById = function(id)
	local tb = XmlTable_getRow(mGetCoinTable, id, true)
	local tbRow = {}
	tbRow.id = tb.id + 0												-- id
	tbRow.level = tb.level + 0 											--等级
	tbRow.normal_reward_gold = tb.normal_reward_gold + 0 				--炼金金币							
	tbRow.advanced_reward_gold = tb.advanced_reward_gold + 0 			--高级炼金金币							--
	tbRow.reward_ids = CommonFunc_split(tb.reward_ids, ",")				--奖励id
	tbRow.reward_amounts = CommonFunc_split(tb.reward_amounts, ",")		--奖励数值
	return tbRow
end

--获得打折限购的所有信息
LogicTable.getDiscountInfo = function()
	local tb = {}
	for key, val in pairs(mDiscountTable.map) do
		local tbRow = {}
		tbRow.id = val.id + 0												
		tbRow.type = val.type + 0 											
		tbRow.temp_id = val.temp_id + 0 
		tbRow.amount = val.amount + 0 
		tbRow.price = val.price + 0 
		tbRow.discount_price = val.discount_price + 0 
		tbRow.limit_times = val.limit_times + 0 
		tbRow.show = val.show + 0 
		table.insert(tb, tbRow)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

--根据id，获取打折限购的信息
LogicTable.getDisInfoById = function(id)
	local tb = XmlTable_getRow(mDiscountTable, id, true)
	local tbRow = {}
	tbRow.id = tb.id + 0
	tbRow.type = tb.type + 0
	tbRow.temp_id = tb.temp_id + 0 
	tbRow.amount = tb.amount + 0 
	tbRow.price = tb.price + 0 
	tbRow.discount_price = tb.discount_price + 0 
	tbRow.limit_times = tb.limit_times + 0 
	tbRow.show = tb.show + 0 
	return tbRow
end

-- 根据解锁id，获得解锁的信息
LogicTable.getDelockInfo = function(id)
	local res = XmlTable_getRow(mCopyUnlockTb, id, true)
	local row = {}

	row.id = res.id + 0
	row.icon = res.icon
	row.name = res.name
	row.copy_id = res.copy_id 
	row.description = res.description
	if tonumber(res.copy_id) >= tonumber(1001) then
		row.fbName = LogicTable.getCopyById(res.copy_id or 1001).name
	else
		row.fbName ="新手引导关"
	end
	return row
end

-- 读取解锁表的所有信息
LogicTable.getAllDelockInfo = function()
	local tb = {}
	for k, v in pairs(mCopyUnlockTb.map) do
		local row = {}

		row.id =v.id + 0
		row.icon = v.icon
		row.name = v.name
		row.copy_id = v.copy_id
		row.description = v.description
		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)

	return tb
end

-- 获取充值表
LogicTable.getRechargeTable = function(channelId)
	local rechargeTable = {}
	for key, val in pairs(mRechargeTable.map) do
		local rechargeRow = {}
		rechargeRow.id = val.id + 0									-- id
		rechargeRow.type = val.type + 0								-- 类型:1.月卡,2.魔石
		rechargeRow.channel_id = val.channel_id + 0					-- 渠道id
		rechargeRow.money = val.money + 0							-- 价格(分)
		rechargeRow.recharge_emoney = val.recharge_emoney + 0		-- 购买数量
		rechargeRow.reward_emoney = val.reward_emoney + 0			-- 返利数量
		if "null" == val.desc then									-- 充值描述
			rechargeRow.desc = ""
		else
			rechargeRow.desc = val.desc
		end
		if tonumber(channelId) == rechargeRow.channel_id then
			table.insert(rechargeTable, rechargeRow)
		end
	end
	-- 类型(从小到大) -> id(从小到大)
	local function sortFunc(a, b)
		if a.type == b.type then
			return a.id < b.id
		end
		return a.type < b.type
	end
	table.sort(rechargeTable, sortFunc)
	return rechargeTable
end

LogicTable.getRechargeRow = function(id)
	local row = XmlTable_getRow(mRechargeTable, id, true)
	local rechargeRow = {}
	
	rechargeRow.id = row.id + 0									-- id
	rechargeRow.type = row.type + 0								-- 类型:1.月卡,2.魔石
	rechargeRow.channel_id = row.channel_id + 0					-- 渠道id
	rechargeRow.money = row.money + 0							-- 价格(分)
	rechargeRow.recharge_emoney = row.recharge_emoney + 0		-- 购买数量
	rechargeRow.reward_emoney = row.reward_emoney + 0			-- 返利数量
	if "null" == row.desc then									-- 充值描述
		rechargeRow.desc = ""
	else
		rechargeRow.desc = row.desc
	end
	
	return rechargeRow
end

-- 获取在线奖励信息
LogicTable.getOnlineRewardRow = function(playerLevel, minutes)
	for key, val in pairs(mOnlineRewardTable.map) do
		local row = {}
		row.id = val.id + 0											-- id
		row.lev_range = CommonFunc_split(val.lev_range, ",")		-- 玩家等级
		row.minutes = val.minutes + 0								-- 在线时长(分钟)
		row.ids = CommonFunc_split(val.ids, ",")					-- 奖励id
		row.amounts = CommonFunc_split(val.amounts, ",")			-- 奖励数量
		if tonumber(minutes) == row.minutes then
			if 1 == #row.lev_range then
				if tonumber(playerLevel) >= tonumber(row.lev_range[1]) then
					return row
				end
			elseif 2 == #row.lev_range then
				if tonumber(playerLevel) >= tonumber(row.lev_range[1]) and tonumber(playerLevel) <= tonumber(row.lev_range[2]) then
					return row
				end
			end
		end
	end
	return nil
end

-- 获取物品兑换表
LogicTable.getExchangeItemTable = function()
	local exchageItemTable = {}
	for key, val in pairs(mExchangeItemTable.map) do
		local exchangeItemRow = {}
		exchangeItemRow.id = val.id + 0												-- id
		exchangeItemRow.aim_item_id = val.aim_item_id + 0							-- 兑换物品id
		exchangeItemRow.aim_item_amount = val.aim_item_amount + 0					-- 兑换物品数量
		exchangeItemRow.need_items = CommonFunc_split(val.need_items, ",")			-- 需要物品id
		exchangeItemRow.need_amounts = CommonFunc_split(val.need_amounts, ",")		-- 需要物品数量
		table.insert(exchageItemTable, exchangeItemRow)
	end
	table.sort(exchageItemTable, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return exchageItemTable
end

-- 获取物品兑换信息
LogicTable.getExchangeItemRow = function(id)
	local row = XmlTable_getRow(mExchangeItemTable, id, true)
	local exchangeItemRow = {}

	exchangeItemRow.id = row.id + 0												-- id
	exchangeItemRow.aim_item_id = row.aim_item_id + 0							-- 兑换物品id
	exchangeItemRow.aim_item_amount = row.aim_item_amount + 0					-- 兑换物品数量
	exchangeItemRow.need_items = CommonFunc_split(row.need_items, ",")			-- 需要物品id
	exchangeItemRow.need_amounts = CommonFunc_split(row.need_amounts, ",")		-- 需要物品数量

	return exchangeItemRow
end

-- 获取提示功能表
LogicTable.getTipFunctionTable = function()
	local tipFunctionTable = {}
	for key, val in pairs(mTipFunctionTable.map) do
		local row = {}
		
		row.id = val.id + 0					-- 提示id
		row.type = val.type + 0				-- 提醒类型(0.我要强化,1.每日提醒)
		row.title = val.title				-- 标题
		row.icon = val.icon					-- 图标
		row.desc = val.desc					-- 描述
		row.count = val.count + 0			-- 计数(仅当类型为1时才有效,表示该提醒功能当日可可完成次数)
		
		table.insert(tipFunctionTable, row)
	end
	table.sort(tipFunctionTable, function(a, b) return a.id < b.id end)
	return tipFunctionTable
end

-- 获取提示功能信息
LogicTable.getTipFunctionRow = function(id)
	local row = XmlTable_getRow(mTipFunctionTable, id, true)
	local tipFunctionRow = {}
	
	tipFunctionRow.id = row.id + 0					-- 提示id
	tipFunctionRow.type = row.type + 0				-- 提醒类型(0.我要强化,1.每日提醒)
	tipFunctionRow.title = row.title				-- 标题
	tipFunctionRow.icon = row.icon					-- 图标
	tipFunctionRow.desc = row.desc					-- 描述
	tipFunctionRow.count = row.count + 0			-- 计数(仅当类型为1时才有效,表示该提醒功能当日可可完成次数)
	
	return tipFunctionRow
end

-- 获取邀请码奖励所有的信息
LogicTable.getInviteCodeReward = function()
	local inviteRewardTable = {}
	for key, val in pairs(mInviteCodeRewardTb.map) do
		local row = {}
		
		row.id = val.id + 0									-- 等级
		row.pretince_ids = val.pretince_ids + 0				-- 新手奖励id
		row.prentince_amounts = val.prentince_amounts + 0	-- 新手奖励数量
		row.master_ids = val.master_ids + 0					-- 邀请人奖励id
		row.master_amounts = val.master_amounts	+ 0			-- 邀请人奖励数量
		
		table.insert(inviteRewardTable, row)
	end
	table.sort(inviteRewardTable, function(a, b) return a.id < b.id end)
	return inviteRewardTable
end

-- 根据等级（id）获取邀请码奖励信息
LogicTable.getInviteCodeRewardByLevel = function(id)
	local row = XmlTable_getRow(mInviteCodeRewardTb, id, true)
	local rewardRow = {}

	rewardRow.id = row.id + 0										-- 等级
	rewardRow.pretince_ids = row.pretince_ids + 0					-- 新手奖励id
	rewardRow.prentince_amounts = row.prentince_amounts + 0			-- 新手奖励数量
	rewardRow.master_ids = row.master_ids + 0						-- 邀请人奖励id
	rewardRow.master_amounts = row.master_amounts + 0				-- 邀请人奖励数量

	return rewardRow
end

-- 获取邀请码帮助奖励所有的信息
LogicTable.getInviteHelpReward = function()
	local helpRewardTable = {}
	for key, val in pairs(mInviteCodeHelpRewardTb.map) do
		local row = {}
		
		row.id = val.id + 0									-- 等级
		row.ids = val.ids + 0				-- 帮助奖励id
		row.amounts = val.amounts + 0		-- 帮助奖励数量
		row.need_level = val.need_level + 0	--领取帮助需要等级
		table.insert(helpRewardTable, row)
	end
	table.sort(helpRewardTable, function(a, b) return a.id < b.id end)
	return helpRewardTable
end

-- 根据等级（id）获取邀请码帮助奖励信息
LogicTable.getInviteHelpRewardByLevel = function(id)
	local row = XmlTable_getRow(mInviteCodeHelpRewardTb, id, true)
	local helpRewardRow = {}

	helpRewardRow.id = row.id + 0								-- 等级
	helpRewardRow.ids = row.ids + 0					-- 帮助奖励id
	helpRewardRow.amounts = row.amounts + 0			-- 帮助奖励数量
	helpRewardRow.need_level = row.need_level + 0				-- 领取需要等级
	
	return helpRewardRow
end

-- 获取月卡每日奖励信息
LogicTable.getMonthCardDaiylAwardRow = function(id)
	local row = XmlTable_getRow(mMonthCardDailyAwardTable, id, true)
	local monthCardDaiylAwardRow = {}

	monthCardDaiylAwardRow.id = row.id + 0										-- id
	monthCardDaiylAwardRow.day_amount = row.day_amount + 0						-- 月卡持续天数
	monthCardDaiylAwardRow.award_ids = CommonFunc_split(row.award_ids, ",")		-- 奖励id列表
	monthCardDaiylAwardRow.amount = CommonFunc_split(row.amount, ",")			-- 奖励数量列表

	return monthCardDaiylAwardRow
end

-- 获取活动副本群表
LogicTable.getActivityCopyGroupTable = function()
	local activityCopyGroupTable = {}
	for key, val in pairs(mActivityCopyGroupTable.map) do
		local row = {}
		row.id = val.id + 0											-- id
		row.icon = val.icon											-- 图标
		row.time_type = val.time_type + 0							-- 时间类型(1-周:星期,小时,分钟;2-月:日数(-1等于每月最后一天),小时,分钟;3-年:月,日,小时,分钟)
		row.begin_time_array = CommonFunc_parseStringTuple(val.begin_time_array, true)		-- 开始时间
		row.end_time_array = CommonFunc_parseStringTuple(val.end_time_array, true)			-- 结束时间
		row.describe = val.describe									-- 副本群描述
		table.insert(activityCopyGroupTable, row)
	end
	table.sort(activityCopyGroupTable, function(a, b) return a.id < b.id end)
	return activityCopyGroupTable
end

-- 获取活动副本表
LogicTable.getActivityCopyTable = function(copyGroupId)
	local activityCopyTable = {}
	for key, val in pairs(mActivityCopyTable.map) do
		local row = {}
		row.id = val.id + 0													-- id
		row.name = val.name													-- 名字
		row.copy_group_id = val.copy_group_id + 0							-- 所属副本群id
		row.need_power = val.need_power + 0									-- 所需体力
		row.gold = val.gold + 0												-- 金币奖励
		row.exp = val.exp + 0												-- 经验奖励
		row.describe = val.describe											-- 描述
		row.first_map_id = val.first_map_id + 0								-- 第一层地图id
		row.dropitems = CommonFunc_split(val.dropitems, ",", true)			-- 掉落物品
		row.small_icon = val.small_icon										-- 副本图标
		row.recommended_battle_power = val.recommended_battle_power + 0		-- 推荐战斗力
		row.need_level = val.need_level + 0									-- 所需等级
		if tonumber(copyGroupId) == row.copy_group_id then
			table.insert(activityCopyTable, row)
		end
	end
	table.sort(activityCopyTable, function(a, b) return a.id < b.id end)
	return activityCopyTable
end

-- 获取活动副本
LogicTable.getActivityCopyRow = function(id)
	local row = XmlTable_getRow(mActivityCopyTable, id, true)
	local activityCopyRow = {}
	
	activityCopyRow.id = row.id + 0													-- id
	activityCopyRow.name = row.name													-- 名字
	activityCopyRow.copy_group_id = row.copy_group_id + 0							-- 所属副本群id
	activityCopyRow.need_power = row.need_power + 0									-- 所需体力
	activityCopyRow.gold = row.gold + 0												-- 金币奖励
	activityCopyRow.exp = row.exp + 0												-- 经验奖励
	activityCopyRow.describe = row.describe											-- 描述
	activityCopyRow.first_map_id = row.first_map_id + 0								-- 第一层地图id
	activityCopyRow.dropitems = CommonFunc_split(row.dropitems, ",", true)			-- 掉落物品
	activityCopyRow.small_icon = row.small_icon										-- 副本图标
	activityCopyRow.recommended_battle_power = row.recommended_battle_power + 0		-- 推荐战斗力
	activityCopyRow.need_level = row.need_level + 0									-- 所需等级
	
	return activityCopyRow
end

-- 获取社交活动表
LogicTable.getSocialContactTable = function(id)
	local socialContactTable = {}
	for key, val in pairs(mSocialContactTable.map) do
		local row = {}
		row.id = val.id + 0								-- id
		row.icon = val.icon								-- 图片
		row.open = val.open + 0							-- 是否开启
		table.insert(socialContactTable, row)
	end
	table.sort(socialContactTable, function(a, b) return a.id < b.id end)
	return socialContactTable
end

-- 获取社交活动表的某一项
LogicTable.getSocialContactRow = function(id)
	local row = XmlTable_getRow(mSocialContactTable, id, true)
	local socialContactRow = {}
	
	socialContactRow.id = row.id + 0					-- id
	socialContactRow.name = row.icon					-- 图片
	socialContactRow.open = row.open + 0				-- 是否开启

	return socialContactRow
end

-- 获取天赋数据表
LogicTable.getTalentTable = function()
	local talentTable = {}
	for key, val in pairs(mTalentTable.map) do
		local row = {}
		row.id = val.id + 0								-- id
		row.name = val.name								-- 名字
		row.icon = val.icon								-- 图片
		row.max_level = val.max_level + 0				-- 可升到的最高等级
		row.job = val.job + 0							-- 职业
		row.position = val.position + 0					-- 位置
		row.layer = val.layer + 0						-- 层数
		row.level_up_id = val.level_up_id + 0			-- 升级表中的第一位
		if row.job ==  ModelPlayer.getRoleType() then
			table.insert(talentTable,row)
		end
	end
	table.sort(talentTable, function(a, b) return a.id < b.id end)
	return talentTable
end

-- 获取天赋数据表中的某一项
LogicTable.getTalentTableRow = function(id)
	local row = XmlTable_getRow(mTalentTable, id, true)
	local talentTable = {}

	talentTable.id = row.id + 0								-- id
	talentTable.name = row.name								-- 名字
	talentTable.icon = row.icon								-- 图片
	talentTable.max_level = row.max_level + 0				-- 可升到的最高等级
	talentTable.job = row.job + 0							-- 职业
	talentTable.position = row.position	+ 0					-- 位置
	talentTable.layer = row.layer + 0 						-- 层数
	talentTable.level_up_id = row.level_up_id + 0			-- 升级表中的第一位
	--talentTable.describe = row.describe						-- 描述
	return talentTable
end

-- 获取天赋升级表的某一项
LogicTable.getTalentlelUpTableRow = function(level_up_id)
	local row = XmlTable_getRow(mTalentLelUpTable, level_up_id, true)
	local talentTable = {}

	talentTable.level_up_id = row.level_up_id + 0		-- id，第一位表示层数，后两位表示级数（101,102）
	talentTable.skill_piece_id = row.skill_piece_id		-- 技能碎片ID(原符文碎片)
	talentTable.skill_piece_num = row.skill_piece_num	-- 所需技能碎片数量
	talentTable.describe =""							-- 天赋描述
	local des = CommonFunc_split(row.describe,"\\n",false)
	for k,v in pairs(des) do
		if k == 1 then
			talentTable.describe =string.format("%s",v)
		else
			talentTable.describe =string.format("%s\n%s",talentTable.describe,v)
		end
	end
	return talentTable
end

LogicTable.getTalentlelUpInfo= function(level_up_id)
    return mTalentLelUpTable.map[tostring(level_up_id)]
end

-- 获取限时奖励信息
LogicTable.getTimeLimitRewardRow = function(id)
	local row = XmlTable_getRow(mTimeLimitRewardTable, id, true)
	
	local timeLimitRewardRow = {}
	timeLimitRewardRow.id = tonumber(row.id)							-- id
	timeLimitRewardRow.start_time = CommonFunc_parseTuple(row.start_time, true)		-- 开始时间(时分秒)
	timeLimitRewardRow.end_time = CommonFunc_parseTuple(row.end_time, true)			-- 结束时间(时分秒)
	timeLimitRewardRow.count = tonumber(row.count)						-- 可领取次数
	timeLimitRewardRow.cd_time = tonumber(row.cd_time)					-- 每次领取完的冷却时间
	timeLimitRewardRow.ids = CommonFunc_parseTuple(row.ids, true)		-- 奖励id,对应奖励表
	timeLimitRewardRow.amounts = tonumber(row.amounts)					-- 奖励数量
	
	return timeLimitRewardRow
end

