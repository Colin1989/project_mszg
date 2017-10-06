%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 18 Apr 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(data_trans).


-export([term_to_string/1, string_to_term/1, string_binary_to_term/1, float_to_string/2]).



%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec ��Termת��Ϊ�����ƴ�
%% @end
%%--------------------------------------------------------------------


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
