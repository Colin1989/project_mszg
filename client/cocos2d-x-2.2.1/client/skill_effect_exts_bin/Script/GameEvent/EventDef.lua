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
	"ED_UPDATE_ROLE_INFO",   				-- 初始化主界面玩家数据
	"ED_UPDATE_FIGHT_SHOW",					-- 更新战斗界面
	"ED_UPDATE_TASK_LIST",					-- 更新任务列表
	"ED_KILL_MONSTER",						-- 击杀怪物
	"ED_PASS_LOCATION",						-- 通关
	"ED_COLLECT_ITEM",						-- 收集物品
}
----------------------------------------------------------------------
EventDef = EventDef_enum(EventDef)

