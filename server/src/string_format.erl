-module(string_format).

-export([format_integer/2]).

format_integer(Int, Length) ->
    IntStr = integer_to_list(Int),
    case length(IntStr) < Length of
	true ->
	    Left = Length - length(IntStr),
	    lists:duplicate(Left, $0) ++ IntStr;
	false ->
	    IntStr
    end.
    
    
