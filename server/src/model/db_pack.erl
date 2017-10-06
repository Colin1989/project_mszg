-module(db_pack, [Id, RoleId, InstId, ItemId::integer(),ItemType::integer(),Amount::integer(),CreateTime::datetime()]).

-table("packs").
