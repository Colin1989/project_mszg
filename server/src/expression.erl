-module(expression).

-export([trans_expression/1]).

-export([proc_pow/2, proc_floor/2, proc_ceil/1, proc_round/1, proc_abs/1, proc_pow_int/2, proc_floor/1]).



trans_expression(ExpStr)->
    NewStr = regular:str_replace(ExpStr, "\s+", ""),
    List = regular:str_split_not_empty(NewStr, "([\,()*+/-])"),
    NewList = lists:map(fun(X) -> 
		   trans_function_name(X)   
	      end, List),
    NewStr1 = lists:concat(NewList),
    %%io:format("~p~n", [NewStr1]),
    fun(X)->
	    Arg = lists:concat([lists:concat([A, "=", V, ","]) || {A, V} <- X]),
	    Exps = Arg ++ NewStr1,
	    %%io:format("~p~n", [Exps]),
	    {value, Result, _} = eval_exprs_str(Exps),
	    Result
    end.


eval_exprs_str(Str) ->    
    {ok,Ts,_} = erl_scan:string(Str),  
    Ts1 = case lists:reverse(Ts) of           
	      [{dot,_}|_] -> Ts;        
	      TsR -> lists:reverse([{dot,1} | TsR])    
	  end,   
    {ok,Expr} = erl_parse:parse_exprs(Ts1), 
    erl_eval:exprs(Expr, []).




trans_function_name(Str)->
    case string:to_lower(Str) of
	"pow" ->
	    lists:concat([?MODULE,":",proc_pow]);
	"pow_int"->
	    lists:concat([?MODULE,":",proc_pow_int]);
	"floor" ->
	    lists:concat([?MODULE,":",proc_floor]);
	"ceil" ->
	    lists:concat([?MODULE,":",proc_ceil]);
	"round" ->
	    lists:concat([?MODULE,":",proc_round]);
	"abs" ->
	    lists:concat([?MODULE, ":", proc_abs]);
	_ ->
	    Str
    end.



%%base function
proc_pow(A, B)->
    math:pow(A, B).

proc_pow_int(A, B)->
    round(math:pow(A, B)).

proc_floor(A, Base) ->
    X = trunc(A),
    (X div Base) * Base.

proc_floor(A) ->
    trunc(A).

proc_ceil(A)->
    round(A+0.499999).

proc_round(A) ->
    round(A).

proc_abs(A)->
    abs(A).




%% -module(expression).

%% -export([trans_expression/1, trans_expression_by_eval/1]).

%% -compile(export_all).

%% trans_expression(ExpStr)->
%%     NewStr = regular:str_replace(ExpStr, "\s+", ""),
%%     List = regular:str_split_not_empty(NewStr, "([\,()*+/-])"),
%%     List1 = lists:map(fun(X)->
%%     			      case is_str_number(X) of
%%     				  false ->
%%     				      X;
%%     				  Num ->
%%     				      Num
%%     			      end
%%     		      end, List),
%%     %%PowProcList = list_proc_pow(List1),
%%     %%io:format("~p~n", [List1]),
%%     Fun = create_function(List1),
    
%%     Fun.

%% trans_expression_by_eval(ExpStr)->
%%     fun(X)->
%%        eval_exprs_str(ExpStr,X)
%%     end.


%% eval_exprs_str(Str,Binding) ->    
%% 	{ok,Ts,_} = erl_scan:string(Str),  
%% 	Ts1 = case lists:reverse(Ts) of           
%% 		  [{dot,_}|_] -> Ts;        
%% 		  TsR -> lists:reverse([{dot,1} | TsR])    
%% 	      end,   
%%     {ok,Expr} = erl_parse:parse_exprs(Ts1), 
%%     erl_eval:exprs(Expr, Binding).


%% %% list_proc_pow(List)->
%% %%     PowList = lists:foldl(fun(X, {Index, [_|Left], In})-> 
%% %% 				  CurIndex = Index + 1,
%% %% 				  case X of
%% %% 				      "pow" ->6
%% %% 					  ["("|NewLeft] = Left,
%% %% 					  EndPos = find_match_brace(NewLeft),
%% %% 					  {CurIndex, Left, [{CurIndex,EndPos}|In]};
%% %% 				      _ ->
%% %% 					  {CurIndex, Left, In}
%% %% 				  end
%% %% 			  end, {0, List, []}, List),
%% %%     NewPowList = lists:sort(fun({Start1, End1}, {Start2, End2})-> 
%% %% 				    (End1 - Start1) < (End2 - Start2)
%% %% 			    end,PowList),
    
%% %%     ok.

%% create_function(List)->
%%     Tuple = make_function_tuple(List),
%%     %%io:format("Tuple:~p~n",[Tuple]),
%%     make_function_by_tuple(Tuple).

%% make_function_by_tuple(Tuple)->
%%     Fun = trans_function_tuple_to_function(Tuple),
%%     fun(X)->
%% 	    put(fun_prop, X),
%% 	    Fun([])
%%     end.



%% make_function_tuple([Member|List]) ->
%%     %%io:format("Member:~p~n",[Member]),
%%     case List of
%% 	[] ->
%% 	    case Member of
%% 		_ when is_list(Member) ->
%% 		    NewMember  = string:to_lower(Member),
%% 		    Atom = list_to_atom(NewMember),
%% 		    {fun proc_atom/1, [Atom]};
%% 		_ ->
%% 		    Member
%% 	    end;
%% 	_ ->
%% 	    %%io:format("List:~p,~p~n",[Member,List]),
%% 	    {Tuple, TheEnd} = case Member of
%% 				  "pow" ->
%% 				      ["("|NewLeft] = List,
%% 				      EndPos = find_match_brace(NewLeft),
%% 				      DotIndex = get_next_dot(NewLeft),
%% 				      {{fun proc_pow/1, [make_function_tuple(lists:sublist(NewLeft, DotIndex-1)),
%% 							 make_function_tuple(lists:sublist(NewLeft, DotIndex+1, (EndPos - DotIndex) - 1))]}, EndPos+1};
%% 				  "floor" ->
%% 				      ["("|NewLeft] = List,
%% 				      EndPos = find_match_brace(NewLeft),
%% 				      DotIndex = get_next_dot(NewLeft),
%% 				      {{fun proc_floor/1, [make_function_tuple(lists:sublist(NewLeft, DotIndex-1)),
%% 							 make_function_tuple(lists:sublist(NewLeft, DotIndex+1, (EndPos - DotIndex) - 1))]}, EndPos+1};
%% 				      %% ["("|NewLeft] = List,
%% 				      %% EndPos = find_match_brace(NewLeft),
%% 				      %% {{fun proc_floor/1, [make_function_tuple(lists:sublist(NewLeft,  EndPos - 1))]}, EndPos+1};
%% 				  "ceil" ->
%% 				      ["("|NewLeft] = List,
%% 				      EndPos = find_match_brace(NewLeft),
%% 				      {{fun proc_ceil/1, [make_function_tuple(lists:sublist(NewLeft,  EndPos - 1))]}, EndPos+1};
%% 				  "round" ->
%% 				      ["("|NewLeft] = List,
%% 				      EndPos = find_match_brace(NewLeft),
%% 				      {{fun proc_round/1, [make_function_tuple(lists:sublist(NewLeft,  EndPos - 1))]}, EndPos+1};
%% 				  "abs" ->
%% 				      ["("|NewLeft] = List,
%% 				      EndPos = find_match_brace(NewLeft),
%% 				      {{fun proc_abs/1, [make_function_tuple(lists:sublist(NewLeft,  EndPos - 1))]}, EndPos+1};
%% 				  "(" ->
%% 				      EndPos = find_match_brace(List),
%% 				      {make_function_tuple(lists:sublist(List,  EndPos - 1)), EndPos};
%% 				  "-" ->
%% 				      {Start, End} = get_next_member_range(List),
%% 				      {{fun proc_minus/1, [make_function_tuple(lists:sublist(List,  (End - Start)+1))]}, End };
%% 				  _ when is_number(Member) or is_tuple(Member)->
%% 				      [Mem|NewLeft] = List,
%% 				      case Mem of
%% 					  "+" ->
%% 					      {Start,End} = get_next_member_range_low(NewLeft),
%% 					      {{fun proc_add/1, [Member, make_function_tuple(lists:sublist(NewLeft,  (End - Start)+1))]}, End + 1};
%% 					  "-" ->
%% 					      {Start,End} = get_next_member_range_low(NewLeft),
%% 					      {{fun proc_reduce/1, [Member, make_function_tuple(lists:sublist(NewLeft,  (End - Start)+1))]}, End + 1};
%% 					  "*" ->
%% 					      {Start,End} = get_next_member_range(NewLeft),
%% 					      {{fun proc_multiply/1, [Member, make_function_tuple(lists:sublist(NewLeft,  (End - Start)+1))]}, End + 1};
%% 					  "/" ->
%% 					      {Start,End} = get_next_member_range(NewLeft),
%% 					      {{fun proc_div/1, [Member, make_function_tuple(lists:sublist(NewLeft,  (End - Start)+1))]}, End + 1}
%% 				      end;
%% 				  _ ->
%% 				      NewMember  = string:to_lower(Member),
%% 				      Atom = list_to_atom(NewMember),
%% 				      {{fun proc_atom/1, [Atom]}, 0}
				    
%% 			      end,
%% 	    make_function_tuple([Tuple|lists:sublist(List, TheEnd + 1, length(List)-TheEnd)])
%%     end.



%% get_next_dot(List)->
%%     {DotIndex, _, _} = lists:foldl(fun(X, {Index, Need, Brance}) ->
%% 			case Need of
%% 			    0 ->
%% 				{Index, Need, Brance};
%% 			    _ ->
%% 				case X of
%% 				    "," when Brance=:=0 ->
%% 					{Index+1, 0, Brance};
%% 				    "(" ->
%% 					{Index+1, Need, Brance+1};
%% 				    ")" ->
%% 					{Index+1, Need, Brance-1};
%% 				    _ ->
%% 					{Index+1, Need, Brance}
%% 				end
%% 			end
%% 		end, {0, 1, 0}, List),
%%     DotIndex.


%% get_next_member_range([Member|List])->
%%     case Member of
%% 	"pow" ->
%% 	    ["("|NewLeft] = List,
%% 	    EndPos = find_match_brace(NewLeft),
%% 	    {1, EndPos+2};
%% 	"floor" ->
%% 	    ["("|NewLeft] = List,
%% 	    EndPos = find_match_brace(NewLeft),
%% 	    {1, EndPos+2};
%% 	"ceil" ->
%% 	    ["("|NewLeft] = List,
%% 	    EndPos = find_match_brace(NewLeft),
%% 	    {1, EndPos+2};
%% 	"round" ->
%% 	    ["("|NewLeft] = List,
%% 	    EndPos = find_match_brace(NewLeft),
%% 	    {1, EndPos+2};
%% 	"abs" ->
%% 	    ["("|NewLeft] = List,
%% 	    EndPos = find_match_brace(NewLeft),
%% 	    {1, EndPos+2};
%% 	_ when is_number(Member) ->
%% 	    {1,1};
%% 	"(" ->
%% 	    EndPos = find_match_brace(List),
%% 	    {1, EndPos+1};
%%      _  when Member=:="*" orelse Member=:="/" orelse Member =:= "+" orelse Member =:= "-"->
%%          io:format("Error In get_next_member_range:~p~n",[Member]);
%% 	_ ->
%% 	    {1,1}
%% 	    %%io:format("Error In get_next_member_range:~p~n",[Member])
%%     end.

%% get_next_member_range_low(List)->
%%     {BraceIndex, _, _} = lists:foldl(fun(X, {Index, Need, Brance}) ->
%% 					  case Need of
%% 					      0 ->
%% 						  {Index, Need, Brance};
%% 					      _ ->
%% 						  case X of
%% 						      "+" when Brance =:= 0 ->
%% 							  {Index+1, 0, Brance};
%% 						      "-" when Brance =:= 0 ->
%% 							  {Index+1, 0, Brance};
%% 						      "(" ->
%% 							  {Index+1, Need, Brance+1};
%% 						      ")" ->
%% 							  {Index+1, Need, Brance-1};
%% 						      _ ->
%% 							  {Index+1, Need, Brance}
%% 						  end
%% 					  end
%% 				  end, {0,1,0}, List),
%%     case length(List) of
%% 	BraceIndex ->
%% 	    {1, BraceIndex};
%% 	_ ->
%% 	    {1, BraceIndex-1}
%%     end.

%% test_trans()->
%%     trans_function_tuple_to_function({fun proc_add/1, [{fun proc_add/1,[1,2]}, 2]}).

%% trans_function_tuple_to_function({Fun, ArgList}) ->
%%     NewList = lists:map(fun(X) -> 
%% 				case X of
%% 				    X when is_atom(X) ->
%% 					{fun get_self/1, [X]};
%% 				    X when is_number(X) ->
%% 					{fun get_self/1, [X]};
%% 				    X  when is_tuple(X) ->
%% 					{trans_function_tuple_to_function(X), []};
%% 				    _ ->
%% 					io:format("fuck")
%% 				end
%% 			end, ArgList),
%%     NewFun = fun([]) ->
%% 		     %%io:format("ArgList:~p",[ArgList]),
%% 		     Fun(lists:map(fun({F, A})->
%% 					   %%io:format("~p~n",[A]),
%% 					   F(A)  
%% 				   end, NewList))
%% 	     end,
%%     NewFun.

%%     %% case Member of 
%%     %% 	"(" ->
%%     %% 	    MatchPos = find_match_brace(List),
%%     %% 	    Fun1 = create_function(lists:sublist(List,MatchPos-1)),
%%     %% 	    create_function([Fun1|lists:sublist(List,MatchPos+1,length(List)-MatchPos)]);
%%     %% 	    %% fun()-> 
%%     %% 	    %% 	    Fun = create_function(lists:sublist(List,MatchPos-1)),
%%     %% 	    %% 	    Fun()
%%     %% 	    %% end;
%%     %% 	 "*"->
	    
%%     %% 	    ok
%%     %% end.

%% get_self([Value])->
%%     Value.

%% find_match_brace(List)->
%%     {BraceIndex, _} = lists:foldl(fun(X, {Index, Need}) ->
%% 					  case Need of
%% 					      0 ->
%% 						  {Index, Need};
%% 					      _ ->
%% 						  case X of
%% 						      "(" ->
%% 							  {Index+1, Need+1};
%% 						      ")" ->
%% 							  {Index+1, Need-1};
%% 						      _ ->
%% 							  {Index+1, Need}
%% 						  end
%% 					  end
%% 				  end, {0,1}, List),
%%     BraceIndex.




%% is_str_number(Str)->
%%     try 
%% 	list_to_integer(Str)
%%     catch
%%        _:_ ->
%% 	    try
%% 		list_to_float(Str)
		
%% 	    catch
%% 		_:_ ->

%% 		    false
%% 	    end
%%     end.


%% proc_atom([Atom])->
%%     FunProp = get(fun_prop),
%%     {_, Value} = proplists:lookup(Atom, FunProp),
%%     Value.

%% proc_add([A, B])->
%%     %%io:format("~p,~p~n",[A,B]),
%%     A + B.

%% proc_reduce([A, B])->
%%     A - B.

%% proc_abs([A])->
%%     abs(A).

%% proc_div([A, B])->
%%     A/B.

%% proc_multiply([A, B])->
%%     A * B.

%% proc_pow([A, B])->
%%     math:pow(A, B).

%% proc_floor([A, Base]) ->
%%     X = trunc(A),
%%     (X div Base) * Base.

%% proc_ceil([A])->
%%     round(A+0.499999).

%% proc_round([A]) ->
%%     round(A).


%% proc_minus([A]) ->
%%     -A.

%% proc_role_lev([]) ->
%%     Role = player_role:get_role_info_by_roleid(player:get_role_id()),
%%     Role:level().


%% proc_rank([])->
%%     challenge:get_role_challenge_rank(player:get_role_id()).
