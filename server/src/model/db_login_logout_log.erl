-module(db_login_logout_log, [Id,UserId::integer(), RoleId::integer(), Ip::string(), LoginTime::datetime(), LogoutTime::datetime()]).

-table("login_logout_log").
