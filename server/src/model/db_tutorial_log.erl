-module(db_tutorial_log, [Id,
                        RoleId,
                        TutorialId::integer(),
                        CreateTime::datetime()]).

-table("tutorial_log").
