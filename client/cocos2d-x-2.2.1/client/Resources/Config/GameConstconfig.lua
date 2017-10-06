FileRead("config.txt")


LIMIT_EQIP_STREN   = LogicTable.getDelockInfo(8)	-- 英雄--装备--强化
LIMIT_MAIN         = LogicTable.getDelockInfo(1)	-- 主城
LIMIT_HERO         = LogicTable.getDelockInfo(2)	-- 英雄
LIMIT_MISSION      = LogicTable.getDelockInfo(3)	-- 任务
LIMIT_Social       = LogicTable.getDelockInfo(4)	-- 社交
LIMIT_SHOP         = LogicTable.getDelockInfo(5)	-- 商城
LIMIT_SYSTEM       = LogicTable.getDelockInfo(6)	-- 系统
LIMIT_ACTIVITY     = LogicTable.getDelockInfo(7)	-- 活动
LIMIT_FORGE        = LogicTable.getDelockInfo(8)	-- 锻造
LIMIT_EXP          = LogicTable.getDelockInfo(9)	-- 历练
LIMIT_HERO_UP_LEVEL= LogicTable.getDelockInfo(10)	-- 英雄殿（升阶）
LIMIT_SKILL        = LogicTable.getDelockInfo(11)	-- 铭文大师
LIMIT_RANK_LIST    = LogicTable.getDelockInfo(12)	-- 排行榜
LIMIT_JJC          = LogicTable.getDelockInfo(13)	-- 竞技场
LIMIT_HERO_STREN   = LogicTable.getDelockInfo(14)	-- 英雄强化(潜能中的升阶)
LIMIT_EQUIP_JYFB   = LogicTable.getDelockInfo(15)	-- 精英副本
LIMIT_ENTER_BOSS   = LogicTable.getDelockInfo(16)	-- BOSS挑战(16为“function_unlock_tplt”中的id)
LIMIT_TOWER        = LogicTable.getDelockInfo(17)	-- 无尽魔塔
LIMIT_AUTO_FIGHT   = LogicTable.getDelockInfo(18)  	-- 自动战斗
LIMIT_TRAIN_GAME   = LogicTable.getDelockInfo(19) 	-- 训练赛
LIMIT_CHAL_SHOP    = LogicTable.getDelockInfo(20)   -- 竞技商城
LIMIT_LADDERMATCH  = LogicTable.getDelockInfo(21)   -- 分组赛
LIMIT_CHAL_CONVERT = LogicTable.getDelockInfo(22)   -- 竞技兑换
LIMIT_GEM_INLAY    = LogicTable.getDelockInfo(23)   -- 宝石镶嵌
LIMIT_RANK_GAME    = LogicTable.getDelockInfo(24)   -- 排位赛
LIMIT_ASSISTANCE   = LogicTable.getDelockInfo(25)   -- 援军
LIMIT_FORGE_UPGRADE= LogicTable.getDelockInfo(26)   -- 装备进阶
LIMIT_SKILL_CHARGE = LogicTable.getDelockInfo(27)   -- 技能充能(技能升级)
LIMIT_ACTIVITY_COPY = LogicTable.getDelockInfo(28)  -- 活动副本
LIMIT_SKILL_GROUP2 = LogicTable.getDelockInfo(29)	-- 技能穿戴组2
LIMIT_SKILL_GROUP3 = LogicTable.getDelockInfo(30)	-- 技能穿戴组3
LIMIT_TALENT       = LogicTable.getDelockInfo(31)	-- 天赋开启
LIMIT_FRIEND       = LogicTable.getDelockInfo(4)	-- 好友
LIMIT_SKILL_ADVANCE	= LogicTable.getDelockInfo(39)	-- 技能晋阶
LIMIT_SWEEP			= LogicTable.getDelockInfo(40)	-- 扫荡
--次数限制
LIMIT_JIHUOMA_ERRORTIME  = 10    -- 激活码输错次数
LIMIT_Train_free_refreshtimes =1 --竞技场训练赛每日可以免费刷新次数
LIMIT_Buy_train_times = 2		 --训练赛购买上限次数
LIMIT_Buy_challenge_times = 2	 --排位赛购买上限次数
LIMIT_Buy_match_times = 4		 --分组赛购买上限次数
LIMIT_Buy_tower_times = 1		 --魔塔挑战，每日可购买的最大次数
LIMIT_Buy_summon_stone = 2		 --boss挑战，每日可购买的最大次数



LIMIT_Mail = 6 				-- 邮件解锁等级	
LIMIT_Active_Reward = 6		-- 兑换码解锁等级									
LIMIT_PTFB_SWEEP = 20		-- PT副本扫荡 荣誉	
								
BUY_PUSH_TIMES = 1			-- 推塔可以购买回合数次数
PUSH_TOTAL_ROUND = 200  	-- 推塔起始回合数
Tower_Ora_Chan_Times = 1 	-- 推塔每日可免费挑战次数

RUNE_DEBRIS_ID = 41000			--符文碎片
EVERY_GET_BOSSSTONE = 2 		--每天可以领取的魔石数量(boss挑战，召唤石数量)
ASSIST_FREE_REFRESH_TIMES = 2	--每天援军免费刷新次数
--扫荡
Sweep_Pub_Default_Times = 5		--普通副本的默认扫荡次数
Sweep_Spe_Default_Times = 3		--精英副本的默认扫荡次数
--商城（积分商城）物品购买
Shop_Add_More_Times = 10		--每次可以增加的个数


--祝福
BLESS_REFRESH_COIN = 2000		--刷新祝福需要消耗的金币

ACTIVITY_COPY_COST_PH = 15		--活动副本挑战消耗体力
ACTIVITY_COPY_PLAY_TIMES = 2	--活动副本每天可挑战次数

--聊天
CHAT_FREE_COUNT = 20				--每个角色每日可免费发送信息条数
CHAT_PAY_EMONEY = 10			--免费聊天次数用完后购买所花费的魔石
CHAT_BUY_TIMES = 30				--每次花费魔石所能购买到的发送信息条数
CHAT_MIN_INTERVALS = 5			--发送消息两次最小时间间隔
CHAT_HOW_LONG_TIME = 10			--*秒内可发送信息数的上限时间
CHAT_TIMES_LIMIT = 3			--CHAT_HOW_LONG_TIME秒内最多可发送CHAT_TIMES_LIMIT次

--英雄天赋
RoleTalent_Reset_Emoney = 20			--重置天赋所需的魔石
RoleTalent_Reset_Time = 72				--重置天赋的冷却时间（3天）
RoleTalent_FragId = 65535				--天赋升级、进阶所需要的天赋碎片Id


--友情点奖励 --保存八个物品的位置
FriendPoint_ItemPosition = {
	ccp(-291,57),ccp(-122,57),ccp(49,57),
	ccp(49,-92),ccp(49,-240),ccp(-122,-240),
	ccp(-291,-240),ccp(-291,-92)
	}				

--体力
PowerConfig = 						-- 体力恢复配置
{
	["init_max"] = 60,				-- 初始体力上限(恢复上限)
	["upgrade_add"] = 0,			-- 升级额外增加体力上限
	["recover_power_hp"] = 1,		-- 每次恢复多少体力
	["recover_seconds"] = 600,		-- 每隔多少秒恢复一次体力
	["real_max"] = 500,				-- 实际上限
	["power_hp_price"] = 50,		-- 每次购买体力花费多少魔石
	["buy_times"] = 2				-- 非vip每日购买体力次数
}

--vip 
VIP_DESC = {
	"每日多领取%d个召唤石",--1
	"每日训练赛挑战次数增加%d次",
	"每日分组赛挑战重置次数增加%d次",--3
	"每日排位赛挑战次数增加%d次",
	"每日魔塔挑战次数增加%d次",--5
	"每日普通炼金次数增加%d次",
	"每日魔石炼金次数增加%d次",--7
	"每日购买体力次数增加%d次",
    "每日虚空之门挑战次数增加%d次"--9
}

--首充奖励物品奖励表中的id（reward_item_tplt）
FirstRecharge_RewardTb = 
{
	{["id"] = 1,["amount"] = 5000},
	{["id"] = 9,["amount"] = 200},
	{["id"] = 65535,["amount"] = 50},
	{["id"] = 13001,["amount"] = 1},
}

--炼金术
Alchemy_Pub_Times = 1 						-- 每日普通炼金次数
Alchemy_Spe_Times = 10000 						-- 每日魔石炼金次数
Alchemy_Pub_Get_Exp = 100			--普通炼金，获得经验
Alchemy_Spe_Get_Exp = 190			--高级炼金，获得经验
-- Alchemy_Spe_Cost_Emony = 10			--每次高级炼金，消耗魔石数量
Alchemy_ExpQua = {200,400,600,800,1000}		--领取物品需要的经验
Alchemy_CoolTime = 300				--普通炼金冷却时间
Alchemy_Cover_Color = ccc3(105, 105, 105)	--不可领取的遮罩颜色

--好友
Friend_Max_Count = 30				--好友上限
Friend_Max_ChatMsg = 30				--留言或聊天最大条数
Friend_Send_HP_Num = 5				--每次赠送体力的数目

--邀请码
Invite_Code_Max_Friend = 4			--每个角色最多绑定四个战友
Invire_Code_Open_Lel = 10			--邀请码开启等级
--Invite_Code_Master_Gift_id = 60114	--带人绑定礼包（师傅）
Invite_Code_Prentince_Gift_id = 60115--新人绑定礼包（徒弟）
Invire_Code_Max_Lel = 40			 --最大可领取帮助奖励的等级

--物品掉落概率区间
Drop_Rate_Region = {1, 50, 1000, 4000, 10000}

--寻宝冷却时间
RUNE_NORMAL_COUNT = 3				-- 每日普通寻宝免费次数
RUNE_SPECIAL_COUNT = 1				-- 每日特殊寻宝免费次数
RUNE_NORMAL_CD = 28800				-- 每日普通寻宝CD
RUNE_SPECIAL_CD = 172800			-- 每日特殊寻宝CD
RUNE_ONE_NORMAL_PAY = 10000			-- 单次普通寻宝价格
RUNE_TEN_NORMAL_PAY = 90000			-- 十次普通寻宝价格
RUNE_ONE_SPECIAL_PAY = 100			-- 单次特殊寻宝价格
RUNE_TEN_SPECIAL_PAY = 900			-- 十次特殊寻宝价格

-- 战斗失败结算
FIGHT_FAILED_CD = 10				-- 复活时间限制

-- 新多人分组赛
RESET_TEAMMATE_EMONEY = 10			-- 更换队友所需魔石
RECOVER_FREE_COUNT = 1				-- 免费恢复血量次数
RECOVER_NEED_EMONEY = 50			-- 每次恢复血量所需魔石
RESET_FREE_COUNT = 1				-- 每日可重置次数
-- VIP_RESET_COUNT = 2					-- VIP每日可重置次数
RESET_NEED_EMONEY = 100				-- 重置所需魔石

-- 春节抽奖 12个奖励坐标
ActivityRecharge_ItemPosition = {
	ccp(-176,151),ccp(-57,151),ccp(59,151),ccp(177,151),
	ccp(177,50),ccp(177,-50),
	ccp(177,-151),ccp(59,-151),ccp(-57,-151),ccp(-176,-151),
	ccp(-176,-50),ccp(-176,50)
}

-- 15/02/11 补齐功能各个变量
Exchange_Rate = 100					-- 金币与魔石的汇率  100:1
One_Time_Purchase = 1				-- 一次性购买 宝石/潜能 保护符的数量


STORY_1 = {
    {
	    "  |  |在|无|数|英|雄|的|努|力|下|，|长|期|战|乱|的|萌|兽|大|陆|，|",
	    "终|于|迎|来|了|和|平|的|曙|光|。|",
	    "  |  |然|而|，|当|人|们|在|为|和|平|狂|欢|之|时|，|一|伙|神|秘|的|",
	    "势|力|悄|悄|地|伸|出|他|的|黑|手|。|",
	    "  |  |而|你|，|则|将|意|外|的|卷|入|这|场|阴|谋|之|中|…|…|"
    }
}

STORY_2 = {
    {	
	    "  |  |这|天|，|雪|山|上|来|了|一|群|神|秘|的|长|袍|怪|人|…|…|"
    }
}

FIGHT_GRID_WIDTH  =  128
FIGHT_GRID_HEIGHT =  120 