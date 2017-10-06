-module(db_push_tower,[Id,RoleId::integer(),MaxFloor::integer(),PassTimes::integer(),DieTimes::integer(),TryTimes::integer(),
		       LastTryTime::datetime(),CreateTime::datetime()]).

-table("push_towers").
