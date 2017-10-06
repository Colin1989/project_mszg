%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 25 Aug 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(csv_processer).

%% API
-export([read/2,parse_file/1, parse_file/3]).

-compile(export_all).

-define(min_byte_amount, 1024).
-define(max_thread, 512).

%%%===================================================================
%%% API
%%%===================================================================
read(FileName, ThreadAmount) -> 
    %% {ok, Binary} = file:read_file(FileName),
    %% Data = binary_to_list(Binary),%%cost 216ms
    %% ItemList = regular:str_split(Data, "\r\n"),%%cost 973ms
    %%
    {ok,IO} = file:open(FileName,[raw,read]),
    {Time, ItemList} = timer:tc(?MODULE, do_read, [IO, []]),
    io:format("cost time:~p~n", [Time]),
    file:close(IO),
    Length = length(ItemList),
    %%Left = Length rem Threads,
    Per = (Length div ThreadAmount) + 1,
    FinalAmount = case Length rem Per of
		       0 ->
			   Length div Per;
		       _ ->
			   Length div Per + 1
		   end,
    spawn(?MODULE, distributed_loader, [ItemList, FinalAmount, self(), Per]),
    do_wait_for_process(FinalAmount, []),
    erlang:garbage_collect(),
    %%[list_to_tuple(regular:str_split(Item, "\s*[|]\s*")) || Item <- ItemList].
    %% parse_items(ItemList),
    ok.

do_read(IO, CurData) ->
    case file:read_line(IO) of
	{ok, Data} ->
	    do_read(IO, [Data|CurData]);
	eof ->
	    %%io:format("CurData:~p~n", [CurData]),
	    CurData
    end.

do_wait_for_process(0, Data) ->
    lists:concat(Data);%%cost 4ms
do_wait_for_process(ThreadAmount, Data) ->
    receive
	{_ThreadId, ResultData, Pid} ->
	    erlang:garbage_collect(Pid),
	    do_wait_for_process(ThreadAmount - 1, [ResultData|Data])
    end.


parse_items(Items) ->
    [parse_item(Item) || Item <- Items].
parse_items(Items, Pid, ThreadId) ->
    Result = [parse_item(Item) || Item <- Items],
    Pid ! {ThreadId, Result, self()},
    erlang:garbage_collect().

parse_item(Item) ->
    Result = do_parse_item(Item),
    Result.

do_parse_item(Item) ->
    regular:str_split(Item, ",").




distributed_loader(DataList, Threads, Self, Per) ->loader_process(DataList, Threads, Per, Self).


loader_process(_, 0, _, _) ->
    ok;
loader_process(DataList, ThreadId, Per, Pid) ->
    spawn(?MODULE, parse_items, [lists:sublist(DataList, (ThreadId - 1)*Per + 1, Per), Pid, ThreadId]),
    loader_process(DataList, ThreadId - 1, Per, Pid).



%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
test_cost_time(FileName, ThreadAmount) ->
    {Time, _} = timer:tc(?MODULE, parse_file, [FileName]),
    {Time2, _} = timer:tc(csv_helper, parse_file_to_list, [FileName]),
    {Time3, _} = timer:tc(?MODULE, parse_file, [FileName, ThreadAmount]),
    io:format("Time1:~p, Time2:~p, Time3:~p~n", [Time, Time2, Time3]).
    
    



%% spilit_binary(_, 0, _) ->
%%     ok;
spilit_binary(Binary, 1, _, _) ->
    %%io:format("BinarySize:~p~n", [byte_size(Binary)]),
    parse(Binary);


spilit_binary(Binary, ThreadAmount, PerAmount, Pid) ->
    %%io:format("BinarySize:~p, ThreadAmount:~p, PerAmount:~p~n", [byte_size(Binary), ThreadAmount, PerAmount]),
    case byte_size(Binary) =< PerAmount of
	true ->
	    Pid ! ThreadAmount,
	    parse(Binary);
	false ->
	    StartIndex = PerAmount - 1,
	    <<_:StartIndex/binary, Left/binary>> = Binary,
	    Length = find_index(Left, PerAmount),
	    %%{Time, Length} = timer:tc(?MODULE, find_index, [Left, PerAmount]),
	    %%io:format("~p find index cost time:~pus~n", [ThreadAmount, Time]),
	    <<CurBinary:Length/binary, FinalLeft/binary>> = Binary,
	    spawn(?MODULE, extend_processer, [FinalLeft, ThreadAmount - 1, PerAmount, Pid]),
	    parse(CurBinary)
    end.

%% do_wait(Binary) ->
%%     %%CurResult = parse(Binary),
%%     {Time, CurResult} = timer:tc(?MODULE, parse, [Binary]),
%%     %%io:format("~p do parse cost time:~pus~n", [ThreadAmount, Time]),
%%     CurResult.
%%     %% io:format("~p do parse cost time:~pus~n", [ThreadAmount, Time]),
%%     %% receive
%%     %% 	{ok, OtherResult} ->
%%     %% 	    io:format("~p receive!!!~n", [ThreadAmount]),
%%     %% 	    [CurResult|OtherResult]
%%     %% after 
%%     %% 	15000 ->
%%     %% 	    throw(wait_err_time_out)
%%     %% end.

extend_processer(Binary, ThreadAmount, PerAmount, Pid) ->
    Result = spilit_binary(Binary, ThreadAmount, PerAmount, Pid),
    %%io:format("Pid:~p~n", [Pid]),
    Pid ! {ThreadAmount, Result}.

find_index_q(<<$", $", Rest/binary>>, Index) ->
    find_index_q(Rest, Index + 2);

find_index_q(<<$", Rest/binary>>, Index) ->
    find_index(Rest, Index + 1); 

find_index_q(<<_C, Rest/binary>>, Index) ->
    find_index_q(Rest, Index + 1).


find_index(<<$", Left/binary>>, Index)->
    find_index_q(Left, Index + 1);

    
find_index(<<$\n, _/binary>>, Index)->
    Index;
find_index(<<_C, Left/binary>>, Index) ->
    find_index(Left, Index + 1);

find_index(<<>>, Index) ->
    Index - 1.


proc_parse_file(Binary, MaxThread, AverageByte) ->
    spawn(?MODULE, extend_processer, [Binary, MaxThread, AverageByte, self()]),
    recv_data(MaxThread, []).


recv_data(MaxAmount, CurList) when length(CurList) =:= MaxAmount ->
    lists:concat([OK||{_, OK} <- lists:keysort(1, CurList)]);
recv_data(MaxAmount, CurList) ->
    %%io:format("Pid:~p~n", [self()]),
    %%io:format("MaxAmount:~p, CurListLen:~p~n", [MaxAmount, length(CurList)]),
    receive
	Amount when is_integer(Amount) ->
	    recv_data(MaxAmount - Amount + 1, CurList);
	{ThreadAmount, Data} ->
	    recv_data(MaxAmount, [{?max_thread - ThreadAmount, Data}|CurList])
    after
	15000 ->
	    throw(timeout)
    end.


-record(ecsv,{ 
   state = field_start,  %%field_start|normal|quoted|post_quoted 
   cols = undefined, %%how many fields per record 
   current_field = [], 
   current_record = [], 
   fold_state, 
   fold_fun  %%user supplied fold function 
   }). 

%% API functions 
parse_file(FileName, MaxThread1) ->
    %ThreadAmount = erlang:system_info(schedulers),
    {ok, Binary} = file:read_file(FileName),
    BinarySize = byte_size(Binary),
    MaxThread = case MaxThread1 =< ?max_thread of
		    true ->
			MaxThread1;
		    false ->
			?max_thread
		end,
    AverageByte  = case BinarySize div MaxThread of
		       Average when Average >= ?min_byte_amount ->
			   Average;
		       _ ->
			   ?min_byte_amount
		   end,
    %%Result = spilit_binary(Binary, MaxThread, AverageByte),
    %% {Time, Result} = timer:tc(?MODULE, spilit_binary, [Binary, MaxThread, AverageByte]),
    %% io:format("do spilit_binary cost time:~pus~n", [Time]),
    Result = proc_parse_file(Binary, MaxThread, AverageByte),
    Result.
    %%lists:concat(Result).




parse_file(FileName,InitialState,Fun) -> 
    {ok, Binary} = file:read_file(FileName), 
    _BinarySize = binary:referenced_byte_size(Binary),
    {Time, _} = timer:tc(?MODULE, parse,[Binary,InitialState,Fun]),
    io:format("cost time:~p~n", [Time]).

 
parse_file(FileName)  -> 
    [{_, StartReductions}] = erlang:process_info(self(), [reductions]),
    {ok, Binary} = file:read_file(FileName), 
    {Time, Result} = timer:tc(?MODULE, parse,[Binary]),
    [{_, EndReductions}] = erlang:process_info(self(), [reductions]),
    io:format("cost time:~p, cost reductions:~p~n", [Time, EndReductions - StartReductions]),
    Result.
    %%parse(Binary). 

parse(X) -> 
    R = parse(X,[],fun(Fold,Record) -> [Record|Fold] end), 
    lists:reverse(R).
    %% {Time, Result} = timer:tc(lists, reverse, [R]),
    %% io:format("cost time:~p~n", [Time]),
    %% Result. 

parse(X,InitialState,Fun) -> 
    do_parse_s(X,#ecsv{fold_state=InitialState,fold_fun = Fun}). 





do_parse_q(<<$", $", Rest/binary>>, S = #ecsv{current_field=Field}) ->
    do_parse_q(Rest, S#ecsv{current_field=[$"|Field]});

do_parse_q(<<$", Rest/binary>>, S) ->
    do_parse(Rest,S#ecsv{state=post_quoted}); 

do_parse_q(<<C, Rest/binary>>, S = #ecsv{current_field=Field}) ->
    do_parse_q(Rest, S#ecsv{current_field=[C|Field]}).


%% do_parse(<<$",Rest/binary>>,S = #ecsv{current_field=Field})-> 
%%     do_parse(Rest,S#ecsv{current_field=[32|Field]});




%% --------- Field_start state --------------------- 
%%whitespace, loop in field_start state 
do_parse_s(<<32,Rest/binary>>,S = #ecsv{current_field=Field})-> 
    do_parse(Rest,S#ecsv{current_field=[32|Field]}); 

%%its a quoted field, discard previous whitespaces 
do_parse_s(<<$",Rest/binary>>,S = #ecsv{})-> 
    do_parse_q(Rest, S#ecsv{current_field = []});

%%anything else, is a unquoted field 
do_parse_s(Bin,S = #ecsv{})-> 
    do_parse(Bin,S#ecsv{state=normal}).	



do_parse(<<$, ,Rest/binary>>,S = #ecsv{current_field=Field,current_record=Record})-> 
    do_parse_s(Rest,S#ecsv{current_field=[], 
			 current_record=[lists:reverse(Field)|Record]}); 

do_parse(<<$\r,Rest/binary>>,S = #ecsv{})-> 
    do_parse(Rest,S);	

do_parse(<<$\n,Rest/binary>>,S = #ecsv{}) -> 
    do_parse_s(Rest,new_record(S)); 


do_parse(<<X,Rest/binary>>,S = #ecsv{state=normal,current_field=Field})-> 
    do_parse(Rest,S#ecsv{current_field=[X|Field]}); 

%% do_parse(<<>>, #ecsv{state=quoted})-> 
%%     throw({ecsv_exception,unclosed_quote}); 

do_parse(<<32,Rest/binary>>,S = #ecsv{state=post_quoted})-> 
    do_parse(Rest,S); 


do_parse(<<>>, #ecsv{current_record=[],fold_state=State})-> 
    State; 

do_parse(<<>>,S)-> 
    do_parse_s(<<>>,new_record(S)).



new_record(S=#ecsv{cols=Cols,current_field=Field,current_record=Record,fold_state=State,fold_fun=Fun}) -> 
    NewRecord = lists:reverse([lists:reverse(Field)|Record]),%%list_to_tuple(lists:reverse([lists:reverse(Field)|Record])), 
    if 
	Cols =:= undefined ->
	    NewState = Fun(State,NewRecord), 
	    S#ecsv{cols=length(NewRecord), 
		   current_record=[],current_field=[],fold_state=NewState};
	tuple_size(NewRecord) =:= Cols -> 
	    NewState = Fun(State,NewRecord), 
	    S#ecsv{current_record=[],current_field=[],fold_state=NewState}; 

	tuple_size(NewRecord) =/= Cols -> 
	    throw({ecsv_exception,bad_record_size,{cols,Cols},{newrecord,NewRecord}}) 
    end. 




