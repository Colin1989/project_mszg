--region AINodeOpenGird.lua
--Author : Administrator
--Date   : 2015/1/6
--此文件由[BabeLua]插件自动生成

--开格子行为

AINodeOpenGird = class(AINodeRole)


function  getGirdOpenable()
    local tb = GridMgr.getConfig("gmc_grid_table")
    local idtb = {}

	for key, grid in pairs(tb) do
		--未打开的格子
        --print("key",key,"is_opened",grid:getConfig("is_opened"),"grid:isCanOpened()",grid:isCanOpened())
		if grid:getConfig("is_opened") == false then
			if grid:isCanOpened() then            
                  table.insert(idtb,grid:getConfig("grid_id"))
                  --cclog("------------------可以开的格子---------------------",grid:getConfig("grid_id"))
            end
        end 
    end
    return idtb
end 

function AINodeOpenGird:ctor()
    self.mFinnalGrid = -1
end

function AINodeOpenGird:VirualInit()
   self:setConfig("widget",2)
   self.mConfigTB["interrupt"]  = true 
end 

function AINodeOpenGird:CalcResult()
    local _role = self:getConfig("role")   
    if _role:getConfig("is_leader") ~= 1 then --如果不是是队长
        return false
    end 

    local idtb = getGirdOpenable()

    if #idtb <= 0 then 
        return false
    else 
        local randomIndex = math.random(1, #idtb)
        self.mFinnalGrid = idtb[randomIndex]
    end 


    local playerTB = RoleMgr.getConfig("rmc_player_table")
    if  self:isDominant() ~= true then --人数没占优就开格子！
        return true
    elseif #playerTB <= 0 then --场上没有玩家 也开格子
        return true 
    end 
  
    return false
end 


function AINodeOpenGird:excultResult(curTime)
    --随机一个格子
    if self.mFinnalGrid  <= 0 then 
        return
    end 
    --cclog(randomIndex,"------------------最终开的格子---------------------",self.mFinnalGrid)
    BattleMgr.openGridEventSet(self:getConfig("role"), self.mFinnalGrid, "AI_RANDOM", curTime)

end 


--endregion
