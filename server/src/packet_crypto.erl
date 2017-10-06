-module(packet_crypto).

-export([init/0, encode/1, decode/1]).

-onload(init/0).

init() ->
    case code:lib_dir(game) of
	{error, bad_name} ->
	    ok = erlang:load_nif("../priv/packet_crypto", 0);
	Dir ->
	    ok = erlang:load_nif(Dir ++ "/priv/packet_crypto", 0)

    end.

encode(_X) ->
    "NIF library not loaded". 

decode(_X) ->
    "NIF library not loaded". 
