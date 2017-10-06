-module(db_copy,[Id,RoleId::integer(),CopyId::integer(),PassTimes::integer(),TryTimes::integer(),MaxScore::integer(),CreateTime::datetime(),LastPassTime::datetime()]).

%%-belongs_to_db_role(role).

-table("copies").
