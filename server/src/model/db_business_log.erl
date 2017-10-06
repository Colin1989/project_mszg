-module(db_business_log, [Id,
			  RoleId,
			  BusinessId::integer(),
			  BusinessType::integer(),
			  BusinessClass::integer(),
			  EndTime::datetime(),
				UpdateTime::datetime(),
				Result::integer()]).

-table("business_log").
