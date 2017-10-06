-module(game_log).

-include("record_def.hrl").

-export([write_game_log/13,termstr_to_term/1,termstr_withdot_to_term/1,get_game_log/1,get_game_record/2,write_only_game_info/8,write_game_info/9]).
%%--------------------------------------------------------------------
%% @doc
%% @游戏结束后把战斗结果写games表，战斗相关数据写game_logs表
%% @end
%%--------------------------------------------------------------------
write_game_log(Result,GameType,RoleId,GameId,Life,MaxLife,MonsterAmount,PickUpItems,Score,FinalItem,Operations,MapInfo,Gold)->
    {_GameId,CopyId,AllMap}=MapInfo,
    log:create(games, [GameType,GameId,RoleId,CopyId,Result,Score,FinalItem,Gold,PickUpItems,datetime:local_time()]),
    GameResult=#game_result_struct{life=Life,maxlife=MaxLife,monster_amount=MonsterAmount},
    RoleInfo=player_role:get_role_battle_info(),
    log:create(game_log, [GameId, Operations, AllMap, GameResult, RoleInfo, datetime:local_time()]),
    player_role:clear_role_battle_info().

write_only_game_info(Result,GameType,GameId,CopyId,RoleId,MaxFloor,GetItems,Gold)->
    log:create(game_log, [GameType,GameId,RoleId,CopyId,Result,MaxFloor,0,Gold, GetItems,datetime:local_time()]).

write_game_info(Result,GameType,GameId,CopyId,RoleId,Score,GetItems,Gold,FinalItem)->
    log:create(game_log, [GameType,GameId,RoleId,CopyId,Result,Score,FinalItem,Gold, GetItems,datetime:local_time()]).


%%--------------------------------------------------------------------
%% @doc
%% @把string转成term,要求string内容是合法的term，否则返回error
%% termstr_to_term("[{test,1,ds},[4,5,6]]")->[{test,1,ds,[4,5,6]}].
%% termstr_to_term("[ts")->error.
%% @end
%%--------------------------------------------------------------------
termstr_withdot_to_term(String)->
    {_,Tok1,_}=erl_scan:string(String),
    case erl_parse:parse_term(Tok1) of
	{ok,Value}->
	    Value;
	_ ->
	    error
    end.

termstr_to_term(String)->
    case termstr_withdot_to_term(string:concat(String,".")) of
	error->
	    termstr_withdot_to_term(String);
	Term ->
	    Term
    end.
%%--------------------------------------------------------------------
%% @doc
%% @通过游戏ID，获取该游戏的日志信息
%% @end
%%--------------------------------------------------------------------
get_game_log(GameId)->
    case db:find_first(db_game_log,[{game_id,'equals',GameId}]) of
	undefined->
	    error;
	GameLog->
	    #game_log_info{game_id=GameId,
			   user_operations=termstr_to_term(GameLog:user_operations()),
			   game_maps=termstr_to_term(GameLog:game_maps()),
			   game_result=termstr_to_term(GameLog:game_result()),
			   role_info=termstr_to_term(GameLog:role_info()),
			   create_time=GameLog:create_time()
			  }
    end.

%%--------------------------------------------------------------------
%% @doc
%% @通过游戏ID，角色ID，副本ID等相关信息获取玩家的副本游戏记录
%% @end
%%--------------------------------------------------------------------
get_game_record(game_id,{RoleId,GameId}) ->
    case db:find_first(db_game,[{role_id,'equals',RoleId},{game_id,'equals',GameId}]) of
	undefined->
	    error;
	GameRecord->
	    transform_game_record(GameRecord)
    end;
get_game_record(game_id,GameId) ->
    RoleId=player:get_role_id(),
    get_game_record(game_id,{RoleId,GameId});

get_game_record(copy_id,{RoleId,CopyId}) ->
    GameRecords=db:find(db_game,[{role_id,'equals',RoleId},{copy_id,'equals',CopyId}]),
    lists:map(fun transform_game_record/1,GameRecords);
get_game_record(copy_id,CopyId) ->
    RoleId=player:get_role_id(),
    get_game_record(copy_id,{RoleId,CopyId});

get_game_record(role_id,RoleId) ->
    GameRecords=db:find(db_game,[{role_id,'equals',RoleId}]),
    lists:map(fun transform_game_record/1,GameRecords).
%%--------------------------------------------------------------------
%% @doc
%% @把数据库的数据转换为#game_record_struct{}
%% @end
%%--------------------------------------------------------------------
transform_game_record(GameRecord)->
    #game_record_struct{game_id=GameRecord:game_id(),
			role_id=GameRecord:role_id(),
			copy_id=GameRecord:copy_id(),
			result=GameRecord:result(),
			score=GameRecord:score(),
			final_item=GameRecord:final_item(),
			pickup_items=termstr_to_term(GameRecord:pickup_item()),
			create_time=GameRecord:create_time()
		       }.
    
