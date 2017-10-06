-module(cron).

-export([start/0]).

%% {{once, {3, 30, pm}},
%%     {io, fwrite, ["Hello, world!~n"]}}

%% {{once, {12, 23, 32}},
%%     {io, fwrite, ["Hello, world!~n"]}}

%% {{once, 3600},
%%     {io, fwrite, ["Hello, world!~n"]}}

%% {{daily, {every, {23, sec}, {between, {3, pm}, {3, 30, pm}}}},
%%     {io, fwrite, ["Hello, world!~n"]}}

%% {{daily, {3, 30, pm}},
%%     fun() -> io:fwrite("It's three thirty~n") end}

%% {{daily, [{1, 10, am}, {1, 07, 30, am}]},
%%     {io, fwrite, ["Bing~n"]}}

%% {{weekly, thu, {2, am}},
%%     {io, fwrite, ["It's 2 Thursday morning~n"]}}

%% {{weekly, wed, {2, am}},
%%     {fun() -> io:fwrite("It's 2 Wednesday morning~n") end}

%% {{weekly, fri, {2, am}},
%%     {io, fwrite, ["It's 2 Friday morning~n"]}}

%% {{monthly, 1, {2, am}},
%%     {io, fwrite, ["First of the month!~n"]}}

%% {{monthly, 4, {2, am}},
%%     {io, fwrite, ["Fourth of the month!~n"]}}

start()->
    ecrn_sup:start_link(),
    Job = {{daily, {every, {300, sec}, {between, {0, am}, {11, 59, 59, pm}}}},
    	   {rank_statics, back_rank_info, [3]}},
    erlcron:cron(Job),

	Job2 = {{weekly, mon, {0, am}},
				 {military_rank, back_up_honour_rank, []}},
	erlcron:cron(Job2),

    %% Job = {{daily, [{5, 34, 0, pm}]},
    %% 	   {challenge, restore_challenge_info, []}},
    %% erlcron:cron(Job),
    ok.


