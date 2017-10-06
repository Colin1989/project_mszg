-module(db_inlaidgem,[Id,EquipmentId::integer(),GemId::integer(),CreateTime::datetime()]).

-table("inlaidgem").
%%-belongs_to_db_item(equipment).