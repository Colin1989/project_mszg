---region GridBoss.lua
--Author : shenl
--Date   : 2014/10/13

GridBossBody = class(Grid)


function GridBossBody:ctor()    end

--绑定数据 refecne_id：点击事件被关联function GridBossBody:bindData(refecne_id)    self:setConfig("refences_id", refecne_id)end

--外部触发事件function GridBossBody:onEvent()	local id = self:getConfig("refences_id")    local ref = GridMgr.getGridByIdx(id)    ref:onEvent()end

