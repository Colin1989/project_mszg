-module(db_challenge_log,[Id,GameId::integer(),RoleId::integer(),EnemyId::integer(),EnemyRank::integer(),MyRank::integer(),Result::integer(),Point::integer(),
			  Honours::integer(),CreateTime::datetime()]).

-table("challenge_log").
