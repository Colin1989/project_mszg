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
	 get_file_path/2,
	 save/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {dir_path="/data/log/"
	       }).

%%%===================================================================
%%% API
%%%===================================================================

save(FileName, Content) ->
    gen_server:call(?SERVER, {save, FileName, Content}).

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
    DirPath = ensure_dir("/data/log/"),
    {ok, #state{dir_path=DirPath}}.

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
handle_call({save, FileName, Content}, _From, State) ->
%%  DirPath = State#state.dir_path,
    DirPath = config:get_server_config(game_log_dir),
    FilePath = get_file_path(DirPath, FileName),
    IoDevice = get_iodevice(FilePath, FileName),
    ok = file:write(IoDevice, format_to_csv(Content) ++ "\r\n"),
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
    DirPath = State#state.dir_path,
    FilePath = get_file_path(DirPath, FileName),
    IoDevice = get_iodevice(FilePath, FileName),
    ok = file:write(IoDevice, format_to_csv(Content) ++ "\r\n"),
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

%%--------------------------------------------------------------------
%% @doc
%% @�Ƴ��ļ����
%% @end
%%--------------------------------------------------------------------
remove_iodevice([]) ->
    ok;
remove_iodevice([{_FileName, IoDevice}|IoDevices]) ->
    file:close(IoDevice).

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�ļ����
%% @end
%%--------------------------------------------------------------------
get_iodevice(FilePath, FileName) ->
    case get(FileName) of
    	undefined ->
    	    {ok, IoDevice} = file:open(FilePath, [append]),
    	    put(FileName, {IoDevice, datetime:localtime()}),
    	    IoDevice;
    	{Device, IoDatetime} ->
	    Now = datetime:localtime(),
	    case datetime:is_equal(IoDatetime, Now) of
		true ->
		    Device;
		false ->
		    file:close(Device),
		    {ok, IoDevice} = file:open(FilePath, [append]),
		    put(FileName, {IoDevice, Now}),
		    IoDevice
	    end
    end.

get_file_cache_name() ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�ļ�·��
%% @end
%%--------------------------------------------------------------------
get_file_path(DirPath, FileName) ->
    {Y, M, D} = datetime:date(),
    DirPath ++ 
	FileName ++
	string_format:format_integer(Y, 4) ++ 
	string_format:format_integer(M, 2) ++ 
	string_format:format_integer(D, 2) ++  
	".csv".

ensure_dir(Dir)->
    case filelib:is_dir(Dir) of
	true->
	    Dir;
	false->
	    file:make_dir("/data"),
	    file:make_dir(Dir),
	    Dir
    end.

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
