--系统常量配置



-- 所有 程序中用到的文字
--LANGUAGE 全局变量 

GameString = {
	Cn = {
		Physical_strength = "体力值",
		BuyPp = "买体力吗?今天你已买%s次",
		Ppfull="体力值已经满了",
		ATK = "攻击：%d",
		DEF = "防御：%d",
		Hit = "命中：%d",
		CRI = "暴击：%d",
		
		buyTime = "要购花费X(待定)买推塔次数吗？",
		sure = "确定",
		cancle = "取消",
		Profession = "职业",
		
		-- 竞技场
		GameRank_BUY_TIMES = "确实花费%d个钻石购买%d次挑战吗?",
		GameRank_MSG_TIPS = "%s 挑战你, 你%s",
		GameRank_MSG_SUCESS = "成功了!",
		GameRank_MSG_FAIL = "失败了!",	
		-- 援助
		Assistance_XZYZDX_TIPS = "请选择援助对象!",
		ATK5 = "攻击：%05d",
		LIF5 = "生命：%05d",
		SPE5 = "速度：%05d",
		HIT5 = "命中：%05d",
		CRT5 = "暴击：%05d",
		MIS5 = "闪避：%05d",
		RXP5 = "韧性：%05d"
		
	},
	En = {
		Physical_strength = "Physical_strength",
		BuyPp = "Buy physical yet? Today, you have to buy% d times",
		Ppfull="体力值已经满了",
		ATK = "ATK：%d",
	}
}

--获取当前 文字 支持 N个参数
function GameString.get(strkey,...)

	local s = GameString[LANGUAGE][strkey]
	local finals  = string.format(s,...)
	return finals
end