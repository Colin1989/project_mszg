%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 18 Apr 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(data_trans).


-export([term_to_string/1, string_to_term/1, string_binary_to_term/1, float_to_string/2, 
	 integer_to_string_format/1, get_integer_from_string/1,format_info/1]).



%%%===================================================================
%%% API
%%%===================================================================
get_integer_from_string(IntStr)->
    get_integer_from_string(string:to_upper(IntStr), 0).
get_integer_from_string([], Int) ->
    Int;
get_integer_from_string([Char|Str], Int) ->
    get_integer_from_string(Str, Int * 36 + get_character_value(Char)).

get_character_value(Char) when Char =< $9->
    Char - $0;
get_character_value(Char) ->
    Char - $A + 10.


integer_to_string_format(Int) ->
    integer_to_string_format(Int, []).
%%
integer_to_string_format(0, Result) ->
    Result;

integer_to_string_format(Int, Result) ->
    Div = Int div 36,
    Rem = Int rem 36,
    integer_to_string_format(Div, [get_character(Rem)|Result]).

get_character(Rem) when Rem < 10->
    $0 + Rem;
get_character(Rem) ->
    $A + (Rem - 10).

%%--------------------------------------------------------------------
%% @doc
%% @spec ��Termת��Ϊ�����ƴ�
%% @end
%%--------------------------------------------------------------------
format_info(Term) ->
    erl_scan:format_error(Term).

term_to_string(Term)->
    case is_pid(Term) of%%Pid��Ϊ�޷����ַ�����ԭ�����⴦��ֱ��ת�ɶ�����
	true ->
	    term_to_binary(Term);
	false ->
	    io_lib:format("~p",[Term])

    end.

float_to_string(Float, PAmount)->
    
    io_lib:format(lists:concat(["~",".",PAmount,"f"]),[Float]).

%%--------------------------------------------------------------------
%% @doc
%% @spec �ַ���ת����Term,�ɹ����ؽ��ʧ�ܷ���error
%% @end
%%--------------------------------------------------------------------
string_to_term(String)->
    {_,Tok1,_}=erl_scan:string(String),
    Ts1 = case lists:reverse(Tok1) of           
	      [{dot,_}|_] -> Tok1;        
	      TsR -> lists:reverse([{dot,1} | TsR])    
	  end, 
    case erl_parse:parse_term(Ts1) of
	{ok,Value}->
	    Value;
	_ ->
	    String
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec ������ת��Term
%% @end
%%--------------------------------------------------------------------
string_binary_to_term(Binary)->
    try binary_to_term(Binary)%%����ֱ��ת��ΪTerm,����ת���Ļ���һ���������ַ�������Ҫת��Ϊ�ַ��������
    catch 
	_:_ -> string_to_term(binary_to_list(Binary))
    end.
