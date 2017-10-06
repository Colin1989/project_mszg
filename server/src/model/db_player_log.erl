-module(db_player_log, [Id, RoleId, Type::integer(), SubType::integer(), OpType::integer(), InstId, ItemId::integer(), Count::integer(), CreateTime::datetime(), Remark]).

-table("player_log").
