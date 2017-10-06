-module(db_game,[Id,GameType::integer(), GameId::integer(),RoleId::integer(),CopyId::integer(),Result::integer(),Score::integer(),FinalItem::string(),ExtraGold::integer(),
		 PickupItem::string(),CreateTime::datetime()]).

-table("games").
