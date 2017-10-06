%%% @author linyibin
%%% @copyright (C) 2010, linyibin
%%% @do
%%% @end
%%% Created : 2011-12-09 by linyibin


-module(http_client).

-export([get/1, get/2, post/2, post/4, post_with_params/2, post_with_params/1, 
	 request_with_jason_encode/1, request_with_jason_encode/2]).

-export([asyn_get/2, asyn_get/3, asyn_post/3, asyn_post/5]).


request_with_jason_encode(Params) ->
    Body = post_with_params(Params),
    {_, Response, _} = rfc4627:decode(Body),
    Response.

request_with_jason_encode(Url, Params) ->
    Body = post_with_params(Url, Params),
    {_, Response, _} = rfc4627:decode(Body),
    Response.
    

asyn_get(Url, Callback)->
    asyn_get(Url, [], Callback).

asyn_get(Url, Headers, Callback)->
    io_helper:format("Get Url:~p~n",[Url]),
    Receiver = 
	fun(Response)-> 
		Body = get_body(Response), 
		Callback(Body) 
	end,
    httpc:request(get, {Url, Headers}, [], [{sync, false}, {receiver, Receiver}]),
    ok.

get(Url)->
    get(Url, []).

get(Url, Headers)->
    get(Url, Headers, 3).

get(Url, Headers, Retry)->
    io_helper:format("Get Url:~p~n",[Url]),
    Response = httpc:request(get, {Url, Headers}, [], []),
    Body = get_body(Response),
    case Body of
	""->
	    case Retry of
		0->
		    Body;
		_ ->
		    get(Url, Headers, Retry-1)
	    end;
	_ ->
	    Body
    end.
post_with_params(Params) ->
    %%io:format("~p~n", [config:get(http_server_addr)]),
    post_with_params(config:get_server_config(http_server_addr), Params).

post_with_params(Url, Params)->
    NewParamStr = string:join([lists:concat([Key, "=", Value]) ||{Key, Value} <- Params], "&"),
    %%SignStr = md5:md5(NewParamStr),
    ValueStr = lists:concat([ Value || {_, Value} <- Params]),
    SignStr = md5:md5(ValueStr),
    Body = case length(NewParamStr) of
	       0 ->
		   lists:concat([sign, "=", SignStr]);
	       _ ->
		   lists:concat([NewParamStr, "&", sign, "=", SignStr])
	   end,
    post(Url, Body).

post(Url, Body)->
    post(Url, [], "application/x-www-form-urlencoded", Body).
		
post(Url, Headers, ContentType, Body)->
    %%io_helper:format("Post Url:~p~nBody:~p~n",[Url, Body]),
    Response = httpc:request(post, {Url, Headers, ContentType, Body},[],[]), 
    get_body(Response).

asyn_post(Url, Body, Callback)->
    asyn_post(Url, [], "application/x-www-form-urlencoded", Body, Callback).

asyn_post(Url, Headers, ContentType, Body, Callback)->
    io_helper:format("Post Url:~p~nBody:~p~n",[Url, Body]),
    Receiver = 
	fun(Response)-> 
		ReturnBody = get_body(Response), 
		Callback(ReturnBody) 
	end,
    httpc:request(post, {Url, Headers, ContentType, Body},[],[{sync, false}, {receiver, Receiver}]).

get_body(Response)->
    %%io_helper:format("Response:~p~n",[Response]),
    Return = case Response of 
		 {ok, saved_to_file} -> "";
		 {_RId, saved_to_file} -> "";
		 {error, _Reason} -> 
		     io:format("ErrorReasom:~p~n", [_Reason]), 
		     "";
		 {ok, Result}-> 
		     get_body1(Result);
		 {_RId, Result}->
		     get_body1(Result);
		 _-> ""
	     end,
    %%io_helper:format("Body:~p~n", [Return]),
    Return.

get_body1(Result)->
    case Result of
	{_, _, Body} -> 
	    case is_list(Body) of
		true->  Body;
		_->binary_to_list(Body)
	    end;
	{error, Reason}->
	    io_helper:format("error:~p~n", [Reason]);
	{_StatusCode, _Body} -> "";
	_ -> ""
    end.
