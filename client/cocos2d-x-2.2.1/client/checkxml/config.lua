VERSON = "1.0.0"

XML_PATH = [[E:\cocos2d-x-2.2.1\client\Resources\Data]]		--你的XML 文件的当前 路径

XML = 
{
	--["表名.xml"] = {}, 添加你要检测的表

	["copy_tplt.xml"] = 
	{
		["relate"] = 		--检测关联
		{
			["new_monsters"] = "monster_tplt.xml"  --["A"] = B 表示字段A 去关联copy_dialog.xml
		},
	},

	["vip_tplt.xml"] = {
		["matching"] = 		--检测匹配
		{
			{"grade_gift_bag_ids","grade_gift_bag_amounts"},
			{"daily_gift_bag_ids","daily_gift_bag_amounts"},
			{"privilege_ids","privilege_amounts"},
		}
	},
	["monster_tplt.xml"] = {}, 
	["copy_dialog.xml"] = {}	
}