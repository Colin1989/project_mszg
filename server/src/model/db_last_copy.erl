-module(db_last_copy,[Id,LastCopy::integer(),RoleId::integer(),UpdateTime::datetime()]).

%%-belongs_to_db_role(role).

-table("last_copy").
