%%% @author Linyibin
%%% @copyright (C) 2012, Linyibin
%%% @doc
%%%
%%% @end
%%% Created :  9 Mar 2012 by Linyibin

-module(csv_helper).

-export([parse_file_to_list/1, parse/1, lazy/1]).
 
-define(BUFFER_SIZE, 1024).

parse_file_to_list(FileName)->
    {ok,IO} = file:open(FileName,[raw,read]),
    parse(lazy(IO)).
 
lazy(IO) -> lazy(IO, []).
 
lazy(IO, [C|S]) ->
  [C|fun()-> lazy(IO, S) end];
lazy(IO, []) ->
  case file:read(IO, ?BUFFER_SIZE) of
    {ok, [C|S]} ->
      [C|fun()-> lazy(IO, S) end];
    eof ->
      []
  end.
 
parse(Data) -> parse(Data, [], [], []).
 
parse([$\r|Data], Field, Fields, Lines) -> parse_r(Data(), Field, Fields, Lines);
parse([$\n|Data], Field, Fields, Lines) -> parse(Data(), [], [], [[Field|Fields]|Lines]);
parse([$,|Data], Field, Fields, Lines)  -> parse(Data(), [], [Field|Fields], Lines);
parse([$"|Data], [], Fields, Lines)     -> parse_q(Data(), [], Fields, Lines);
parse([C|Data], Field, Fields, Lines)   -> parse(Data(), [C|Field], Fields, Lines);
parse([], [], [], Lines)                -> lists:reverse(
                                               [lists:reverse(
                                                 [lists:reverse(F) || F <- L]
                                               ) || L <- Lines]
                                             );
parse([], Field, Fields, Lines)         -> parse([], [], [], [[Field|Fields]|Lines]).
 
parse_r([$\n|_] = Data, Field, Fields, Lines) -> parse(Data, Field, Fields, Lines).
 
parse_q([$"|Data], Field, Fields, Lines) -> parse_qq(Data(), Field, Fields, Lines);
parse_q([C|Data], Field, Fields, Lines)  -> parse_q(Data(), [C|Field], Fields, Lines).
 
parse_qq([$"|Data], Field, Fields, Lines)  -> parse_q(Data(), [$"|Field], Fields, Lines);
parse_qq([C|_] = Data, Field, Fields, Lines)  
  when C == $,; C == $\r; C == $\n         -> parse(Data, Field, Fields, Lines);
parse_qq([], Field, Fields, Lines)         -> parse([], Field, Fields, Lines).
