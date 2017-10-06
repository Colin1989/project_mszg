-module(cache_adapter).
-export([behaviour_info/1]).

%% @spec behaviour_info( atom() ) -> [ {Function::atom(), Arity::integer()} ] | undefined
behaviour_info(callbacks) ->
    [
        {start, 0}, {start, 1}, {stop, 1}, {initConn, 1},
        {get, 3}, {set, 4}, {delete, 3}, {delete, 2}, {set,5}
    ];
behaviour_info(_Other) ->
    undefined.
