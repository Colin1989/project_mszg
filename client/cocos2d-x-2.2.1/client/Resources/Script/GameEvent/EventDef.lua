----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-12-24
-- 描述：事件枚举值定义
----------------------------------------------------------------------

local function EventDef_enum(tb)
	local enum = {}
	for k, v in pairs(tb) do
		enum[v] = k
	end
	return enum
end
----------------------------------------------------------------------
EventDef = 
{
	"ED_GAME_INIT",							-- 游戏初始
	"ED_CHECK_VERSION",						-- 检查版本
	"ED_LOGIN_SUCCESS",						-- 登录成功
	"ED_UPDATE_BACKPACK",					-- 更新玩家背包数据
	"ED_UPDATE_SKILLPACK",					-- 更新技能背包数据
	"ED_UPDATE_ROLE_INFO",   				-- 更新玩家数据
	"ED_UPDATE_FIGHT_SHOW",					-- 更新战斗界面
	"ED_UPDATE_TASK_LIST",					-- 更新任务列表
	"ED_TASK_FINISHED",						-- 任务完成
	"ED_KILL_MONSTER",						-- 击杀怪物
	"ED_PASS_LOCATION",						-- 通关
	"ED_COLLECT_ITEM",						-- 收集物品
	"ED_SETTLE_GAMEBG",						-- 设置游戏背景
	"ED_TaskToCopy",						-- 立即前往指定副本
	"ED_DAILY_AWARD",						-- 每日奖励
	"ED_DAILY_GET_AWARD",					-- 每日奖励领取
	"ED_EQUIPMENT_PUTON",					-- 穿上装备
	"ED_EQUIPMENT_TAKEOFF",					-- 脱下装备
	"ED_GEM_COMPOUND",						-- 宝石合成
	"ED_GEM_MOUNT",							-- 宝石镶嵌
	"ED_GEM_UNMOUNT",						-- 宝石卸下
	"ED_ITEM_SALE",							-- 单个物品出售
	"ED_ITEMS_SALE",						-- 多个物品出售
	"ED_ACTIVENESS_AWARD",					-- 活跃任务
	"ED_ACTIVENESS_AWARD_GET",				-- 活跃度奖励领取
	"ED_USE_PROPS",							-- 使用道具
	"ED_EQUIPMENT_STRENGTHEN",				-- 装备强化
	"ED_EQUIPMENT_RESLOVE",					-- 装备分解
	"ED_EQUIPMENT_UPGRADE",					-- 装备进阶
	"ED_BUY_POWER_HP",						-- 购买体力
	"ED_SHOPMALL_PUR",						-- 商城购买
	"ED_SCOREMALL_PUR",						-- 积分商城购买
	"ED_TRAINGAME_TIMES",					-- 训练赛挑战次数信息
	"ED_RANKGAME_TIMES",					-- 排位赛挑战次数信息
	"ED_LADDERGAME_TIMES",					-- 分组赛挑战次数信息
	"ED_PUSHTOWER_TIMES",					-- 魔塔挑战次数信息
	"ED_MILTITARY_RANK_GET_REWARD",			-- 领取军衔奖励
	"ED_BLESS_BUFF",						-- 祝福buff
	"ED_BENISON_LIST",						-- 祝福列表
	"ED_BLESS_TIMER_RUN",					-- 祝福定时器触发
	"ED_BLESS_TIMER_OVER",					-- 祝福定时器停止
	"ED_LEVEL_GET_GIFT",					-- 冲级活动，领取奖励刷新界面
	"ED_DONOR_LIST",						-- 援军列表
	"ED_SELECT_DONOR",						-- 选择援军
	"ED_FRIEND_POINT_GET",					-- 领取友情点奖励
	"ED_FRIEND_POINT_TIME_OVER",			-- 到了新的一天刷新友情点
	"ED_FRIEND_POINT_REFRESH",				-- 刷新友情点奖励列表
	"ED_EQUIP_EXCHANGE",					-- 装备转换
	"ED_ALCHEMY_GET",						-- 炼金信息获得
	"ED_ALCHEMY",							-- 通知炼金信息
	"ED_ONLINE_AWARD_INFO",					-- 在线奖励信息
	"ED_GET_ONLINE_AWARD",					-- 获取在线奖励
	"ED_ONLINE_TIMER",						-- 在线计时
	"ED_DIS_BUY_SUC",						-- 打折限购成功
	"ED_EXCHANGE_ITEM",						-- 兑换物品
	"ED_FIRSTR_ECHARGE_GET",				-- 首充领取奖励
	"ED_ENTER_RECHARGE",					-- 进入充值界面
	"ED_ENTER_VIP",							-- 进入VIP界面
	"ED_SELECT_BAG_GRID",					-- 选择背包格子
	"ED_UPDATE_ROLEUP_INFO",				-- 更变是否可以提升潜能
	"ED_EMAIL_LIST",						-- 邮件列表
	"ED_COPY_INFOS",						-- 副本信息
	"ED_LADDER_MATCH_INFO",					-- 分组赛信息
	"ED_CLEAR_DATA",						-- 清除数据
	"ED_BUY_MALL_ITEM",						-- 购买商城物品
	"ED_BUY_POINT_MALL_ITEM",				-- 购买积分商城物品
	"ED_TOWER_INFO",						-- 魔塔信息
	"ED_SUMMON_STONE",						-- 召唤石
	"ED_REGISTER_SUCCESS",					-- 注册成功
	"ED_GUIDE_GROUP",						-- 新手引导组
	"ED_BROKEN_LINE",						-- 断开连接
	"ED_RECONNECT",							-- 重新连接
	"ED_POST",								-- 公告
	"ED_MONTH_CARD_INFO",					-- 月卡信息
	"ED_GET_MONTH_CARD_REWARD",				-- 领取月卡每日奖励
	"ED_INVITE_CODE_UPDATE",				-- 邀请码帮帮按钮重置
	"ED_FRIEND_LIST",						-- 好友领取奖励状态重置
	"ED_CHAT_IN_WORLD",						-- 世界频道聊天
	"ED_ROLE_DETAIL_INFO",					-- 角色详细信息
	"ED_MY_WORLD_CHAT_INFO",				-- 我的世界频道聊天信息
	"ED_ACTIVITY_COPY_INFO",				-- 活动副本信息
	"ED_UPDATE_FOR_ONE_KEY",				-- 一键补齐数据更新
	"ED_ROLETALENT_LEVELUP",				-- 英雄天赋升级
	"ED_ROLETALENT_Time",					-- 英雄天赋冷却时间
	"ED_ROLETALENT",						-- 英雄天赋（感叹号变化）
	"ED_SKILL_UNLOCK",						-- 技能解锁
	"ED_SKILL_UPGRADE",						-- 技能升级
	"ED_SKILL_ADVANCE",						-- 技能晋阶
	"ED_SKILL_PUTON",						-- 技能穿上
	"ED_SKILL_TAKEOFF",						-- 技能脱下
	"ED_SKILL_GROUP_CHANGE",				-- 技能组改变
	"ED_ENTER_NOTICE",						-- 进入公告界面
	"ED_NOTICE_LIST",						-- 获取公告列表
	"ED_NOTICE_ITEM_DETAIL",				-- 获取公告详情
	"ED_ADD_NOTICE_ITEM",					-- 增加活动公告
	"ED_DEL_NOTICE_ITEM",					-- 删除活动公告
	"ED_TIME_LIMIT_REWARD_LIST",			-- 限时奖励列表
	"ED_TIME_LIMIT_REWARD_GET",				-- 领取限时奖励
	"ED_LV_UP",								-- 升级
	"ED_SPRING_PROGRESS",					-- 刷新抽奖信息
}
----------------------------------------------------------------------
DataDef = 
{
	"DD_PLAYER_LEVEL",						-- 玩家等级
}
----------------------------------------------------------------------
EventDef = EventDef_enum(EventDef)
DataDef = EventDef_enum(DataDef)

