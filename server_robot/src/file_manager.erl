%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2014, linyibin
%%% @doc
%%%
%%% @end
%%% Created : 14 Jun 2014 by linyibin <>
%%%-------------------------------------------------------------------
-module(file_manager).

-behaviour(gen_server).

%% API
-export([start_link/0,
	 save/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

save(FileName, Content) ->
    gen_server:cast(?SERVER, {save, FileName, Content}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast({save, FileName, Content}, State) ->
    {Y, M, D} = datetime:date(),
    File = ensure_dir() ++ 
	"/" ++ 
	FileName ++ 
	integer_to_list(Y) ++ 
	integer_to_list(M) ++ 
	integer_to_list(D) ++  
	"" ++ 
	".csv",
    {ok, FileRef} = file:open(File, [append]),
    ok = file:write(FileRef, format_to_csv(Content) ++ "\r\n"),
    file:close(FileRef),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
ensure_dir()->
    Dir = "/data/log",
    case filelib:is_dir(Dir) of
	true->
	    ok;
	false->
	    file:make_dir("/data"),
	    file:make_dir(Dir),
	    ok
    end,
    Dir.

format_to_csv(Content) ->
    lists:foldl(fun(Value, Result) ->
			case Result of
			    "" ->
				format(Value);
			    _ ->
				Result ++ "|" ++ format(Value)
			end
		end, "", Content).

format({{Year, Month, Day}, {Hour, Minute, Second}}) ->
    integer_to_list(Year) ++ "-" ++
	integer_to_list(Month) ++ "-" ++
	integer_to_list(Day) ++ " " ++
	integer_to_list(Hour) ++ ":" ++
	integer_to_list(Minute) ++ ":" ++
	integer_to_list(Second);
format("") ->
    "";
format(Value) ->
    data_trans:term_to_string(Value).
