----------------------------------------------------------------------
-- ���ߣ�������
-- ���ڣ�2014-3-3
-- ��������ʯ���Խ�ģ
----------------------------------------------------------------------

ModelGem = {}
local mGemAttributesTable = XmlTable_load("gem_attributes.xml", "id")	-- ��ʯ�������Ա�
local mGemCompoundTable = XmlTable_load("gem_compound.xml", "id")		-- ��ʯ�ϳɱ�
----------------------------------------------------------------------
-- ��ȡ��ʯ����������Ϣ
ModelGem.getGemAttrRow = function(id)
	local row = XmlTable_getRow(mGemAttributesTable, id, true)
	local gemAttrRow = {}
	
	gemAttrRow.id = row.id + 0										-- ��ʯid
	gemAttrRow.name = row.name										-- ����
	gemAttrRow.type = row.type + 0									-- ��������:1.����,2.����,3.����,4.����,5.����,6.����
	gemAttrRow.life = row.life + 0									-- ����
	gemAttrRow.atk = row.atk + 0									-- ����
	gemAttrRow.speed = row.speed + 0								-- �ٶ�
	gemAttrRow.hit_ratio = row.hit_ratio + 0						-- ����
	gemAttrRow.miss_ratio = row.miss_ratio + 0						-- ����
	gemAttrRow.critical_ratio = row.critical_ratio + 0				-- ����
	gemAttrRow.tenacity = row.tenacity + 0							-- ����
	gemAttrRow.unmounted_price = row.unmounted_price + 0			-- ж�¼۸�
	gemAttrRow.combat_effectiveness = row.combat_effectiveness + 0	-- ս����
	gemAttrRow.small_icon = row.small_icon							-- ͼ��
	
	return gemAttrRow
end
----------------------------------------------------------------------
-- ��ȡ��ʯ�ϳ���Ϣ
ModelGem.getGemCompoundRow = function(id)
	local row = XmlTable_getRow(mGemCompoundTable, id, true)
	local gemCompoundRow = {}
	
	gemCompoundRow.id = row.id	+ 0									-- �ϳ�id
	gemCompoundRow.gold = row.gold + 0								-- �ϳ����ĵĽ������
	gemCompoundRow.related_id = row.related_id + 0					-- ����id,�ϳɳɹ����id
	gemCompoundRow.success_rate = row.success_rate + 0				-- �ɹ���
	gemCompoundRow.miss_rate = CommonFunc_split(row.miss_rate, ",")	-- ��ʧ��������
	
	return gemCompoundRow
end
----------------------------------------------------------------------
