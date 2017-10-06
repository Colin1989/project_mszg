-module(db_equipment,[Id,EquipmentId::integer(),RoleId::integer(),TempId::integer(),Level::integer(),AdditionGem::integer(),Gems::string(),
		      AttachInfo::string(),BindStatus::integer(), BindType::integer(), CreateTime::datetime()]).

-table("equipments").
