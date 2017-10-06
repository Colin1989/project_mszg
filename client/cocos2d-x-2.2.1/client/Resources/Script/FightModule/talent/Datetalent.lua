--region Datetalent.lua
--Author : shenl
--Date   : 2014/10/23

--天赋数据
Datetalent = class()


function Datetalent:ctor(id)
    self.mConfigTB	= {}
end

function Datetalent:init(tanlent_id)    local tanlentInfo = LogicTable.getTalentlelUpInfo(tanlent_id)    self.mConfigTB["tanlent_id"]			= 	tanlent_id    self.mConfigTB["talent_trigger_id"]			= 	tanlentInfo.talent_trigger_id	    self.mConfigTB["talent_result_id"]			= 	tanlentInfo.talent_result_id
    self.mConfigTB["talent_trigger_Info"]       =   talentTrigger.new()
    self.mConfigTB["talent_trigger_Info"]:init(tanlentInfo.talent_trigger_id)
    self.mConfigTB["talent_result_tb"]          =   {}

    for k,talent_result_id in pairs(CommonFunc_split(tanlentInfo.talent_result_id, ",")) do 
        local tr = talentResult.new()
        tr:init(talent_result_id,tanlent_id%100)
        table.insert(self.mConfigTB["talent_result_tb"] ,tr)
    end 

end
--获得数据function Datetalent:getConfig(name)	return self.mConfigTB[name]end--设置数据function Datetalent:setConfig(name, value)	self.mConfigTB[name] = valueend






