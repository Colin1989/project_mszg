-module(db_role, [Id,
RoleId :: integer(),
Nickname :: string(),
UserId :: integer(),
Status :: integer(),
RoleStatus :: integer(),
RoleType :: integer(),
Armor :: integer(),
Weapon :: integer(),
Necklace :: integer(),
Ring :: integer(),
Medal :: integer(),
Jewelry :: integer(),
Skill1 :: integer(),
Skill2 :: integer(),
Level :: integer(),
Exp :: integer(),
Gold :: integer(),
SummonStone :: integer(),
BattleSoul :: integer(),
Point :: integer(),
PotenceLevel :: integer(),
AdvancedLevel :: integer(),
PackSpace :: integer(),
VipExp :: integer(),
CreateTime :: datetime()]).

%%-belongs_to_db_user(user).
%%-has({db_copy,all,[{foreign_key,role_id}]}).
%%-has({db_last_copy,1,[{foreign_key,role_id}]}).
-table("roles").
	
