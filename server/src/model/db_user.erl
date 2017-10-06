-module(db_user, [Id,
					UserId :: integer(),
					AccountStatus :: integer(),
					Password :: string(),
					ChannelType :: integer(),
					AccountType :: integer(),
					Emoney :: integer(),
					VipLevel :: integer(),
					CreateTime :: datetime()]).
%%-has({db_roles, all,[{foreign_key,user_id}]}).
-table("users").
