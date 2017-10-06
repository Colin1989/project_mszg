
-module(game_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link(Args) ->
    init_module(Args),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks 
%% ===================================================================
init([]) ->    
    {ok,
     {_SupFlags = {one_for_one, 5, 3},
      [
       {tplt,                                    % 模板表进程
       	{tplt, start_link,[]},                   % StartFun = {M, F, A}
       	permanent,                               % Restart  = permanent | transient | temporary
       	2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
       	worker,                                  % Type     = worker | supervisor
       	[tplt]                                   % Modules  = [Module] | dynamic
       },
       {uuid,
	{uuid, start_link, []},
	permanent,
	2000,
	worker,
	[uuid]
       },
       {tcp_server_app,                          % tcp 服务， 让这个服务放在监控树的最后启动
	{tcp_server_app, start,[]},              % StartFun = {M, F, A}
	permanent,                               % Restart  = permanent | transient | temporary
	2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
	worker,                                  % Type     = worker | supervisor
	[tcp_server_app]                         % Modules  = [Module] | dynamic
       },
       {broadcast_service,
	{broadcast_server, start_link, []},
	permanent, 
	2000, 
	worker, 
	[broadcast_server]
       },
       {file_manager,                  
	{file_manager, start_link,[]}, 
	permanent,                     
	2000,                          
	worker,                        
	[file_manager]                 
       }
      ]
     }
    }.

init_module(_Args) ->
    %%tplt:start(),
    packet_crypto:init(),
    cache:start(),
    db:start(),
    config:start(),
    packet:start(),
    regular:start(),
    event_router:start(),
    account_pid_mapping:start(),
    %%player_auth:start(),
    battle:start(),
    player_power_hp:start(),
    equipment:start(),
    player_pack:start(),
    friend:start(),
    gem:start(),
    challenge:start(),
    sculpture:start(),
    task:start(),
    redis_extend:start(),
    assistance:start(),
    mall:start(),
    cache:delete(role_pid_mapping),
    cache:delete(role_playerpid_mapping),
    cache:delete(account_pid_mapping),
    cache:delete(account_playerpid_mapping),
    %%cache:delete(role_online_tbl),
    cache:delete(online_roleid_set),
    tfserver:start(),
    cron:start(),
    daily_award:start(),
    rank_statics:start(),
    player_auth:start(),
    summon_stone:start(),
    tutorial:start(),
    activeness_task:start(),
    gm_tools:start(),
    training_match:start(),
    benison:start(),
    military_rank:start(),
    upgrade_task:start(),
    ladder_match:start(),
    online_award:start(),
    alchemy:start(),
    exchange:start(),
    mail:start(),
    role_advance:start(),
    first_charge_reward:start(),
    vip:start(),
    redeem_code:start(),
    recharge:start(),
    mooncard:start(),
    activity_copy:start(),
    chat:start(),
    invitation_code:start(),
    sculpture:start(),
    talent:start(),
    notice:start(),
    time_limit_reward:start(),
    activities:start(),
    %%rfc4627_jsonrpc_sup:start_link(),
    ok.

