VERSON = "1.0.0"

XML_PATH = [[E:\cocos2d-x-2.2.1\client\Resources\Data]]		--���XML �ļ��ĵ�ǰ ·��

XML = 
{
	--["����.xml"] = {}, �����Ҫ���ı�

	["copy_tplt.xml"] = 
	{
		["relate"] = 		--������
		{
			["new_monsters"] = "monster_tplt.xml"  --["A"] = B ��ʾ�ֶ�A ȥ����copy_dialog.xml
		},
	},

	["vip_tplt.xml"] = {
		["matching"] = 		--���ƥ��
		{
			{"grade_gift_bag_ids","grade_gift_bag_amounts"},
			{"daily_gift_bag_ids","daily_gift_bag_amounts"},
			{"privilege_ids","privilege_amounts"},
		}
	},
	["monster_tplt.xml"] = {}, 
	["copy_dialog.xml"] = {}	
}