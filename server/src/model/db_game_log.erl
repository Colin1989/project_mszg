-module(db_game_log,[Id,GameId::integer(),UserOperations::string(),GameMaps::string(),GameResult::string(),RoleInfo::string(),CreateTime::datetime()]).

-table("game_logs").
