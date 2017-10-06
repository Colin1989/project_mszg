----------------------------------------------------------------------
-- ���ߣ�Lihq
-- ���ڣ�2014-3-27
-- ���������������ģ
----------------------------------------------------------------------
ModelPower = {}

local mPowerHpPriceTable = XmlTable_load("power_hp_price.xml", "the_time")		-- �����۸��
----------------------------------------------------------------------
-- ��ȡ�����۸���Ϣ
ModelPower.getPowerHpPriceRow = function(theTime)
	local row = XmlTable_getRow(mPowerHpPriceTable, theTime, true)
	local powerHpPriceRow = {}
	
	powerHpPriceRow.the_time = row.the_time + 0			-- �������
	powerHpPriceRow.price = row.price + 0				-- �۸�(����)
	
	return powerHpPriceRow
end
----------------------------------------------------------------------
-- ������ҵȼ���ȡ��������ֵ
ModelPower.getMaxPowerHp = function(level)
	return  PowerConfig["real_max"]
	--return PowerConfig["init_max"] + (level - 1)*PowerConfig["upgrade_add"]
end
----------------------------------------------------------------------
-- ÿ�λָ���������
ModelPower.getRecoverPowerHp = function()
	return PowerConfig["recover_power_hp"]
end
----------------------------------------------------------------------
-- ÿ��������ָ�һ������
ModelPower.getRecoverSeconds = function()
	return PowerConfig["recover_seconds"]
end
----------------------------------------------------------------------
-- ÿ�ι����������Ѷ���ħʯ
ModelPower.getPowerHpPrice = function()
	return PowerConfig["power_hp_price"]
end
----------------------------------------------------------------------
-- ����������
ModelPower.requestBuyPowerHp = function()
	local req = req_buy_power_hp()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_buy_power_hp_result"])
end
----------------------------------------------------------------------
-- ����֪ͨ�����������������Ϣ�¼�
local function handleNotifyBuyPowerHpResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
		-- ���չ��������1
		ModelPlayer.setHpPowerBuyTimes(ModelPlayer.getHpPowerBuyTimes() + 1)
		--ModelPlayer.setHpPower(PowerConfig["init_max"])
		EventCenter_post(EventDef["ED_UPDATE_ROLE_INFO"], "power_hp")
	end
	EventCenter_post(EventDef["ED_BUY_POWER_HP"], success)
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_buy_power_hp_result"], notify_buy_power_hp_result, handleNotifyBuyPowerHpResult)

