-module(db_sculpture, 
	[Id, 
	 SculptureId, 
	 RoleId::integer(), 
	 TempId::integer(),
	 Value::integer(), 
	 Type::integer(),
	 CreateTime::datetime()]).

-table("sculptures").
