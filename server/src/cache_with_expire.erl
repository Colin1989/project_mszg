-module(cache_with_expire).

-export([set/4,increase/3,increase/4,get/2,get/3]).


set(Key, Field , Val,Limit)->
    
    case Limit of
	day->cache:set(Key, Field , Val, datetime:get_today_left_second());
	week ->cache:set(Key, Field , Val, datetime:get_week_left_second());
	month ->cache:set(Key, Field , Val, datetime:get_month_left_second())
    end.

%% increase(Key, Field, Limit)->
%%     case Limit of
%% 	day->cache:count_statics_increase(Key, Field, datetime:get_today_left_second());
%% 	week ->cache:count_statics_increase(Key, Field, datetime:get_week_left_second());
%% 	month ->cache:count_statics_increase(Key, Field, datetime:get_month_left_second())
%%     end.

increase(Key, Field, Limit)->
    [New, _] = case Limit of
		   day->redis_extend:increaseby(Key, Field, 1, datetime:get_today_left_second());
		   week ->redis_extend:increaseby(Key, Field, 1, datetime:get_week_left_second());
		   month ->redis_extend:increaseby(Key, Field, 1, datetime:get_month_left_second())
	       end,
    New.

increase(Key, Field, Increment, Limit)->
    [New, _] = case Limit of
		   day->redis_extend:increaseby(Key, Field, Increment, datetime:get_today_left_second());
		   week ->redis_extend:increaseby(Key, Field, Increment, datetime:get_week_left_second());
		   month ->redis_extend:increaseby(Key, Field, Increment, datetime:get_month_left_second())
	       end,
    New.


get(Key, Field)->
    case redis:hget(Key,Field) of
	undefined ->
	    [];
	D ->
	    [{Field, D}]
    end.
get(_, [], _)->
    [];

get(Key, SuffixList, Field)->
    Cmds = lists:map(fun(X) -> 
			     %%redis:hget(list_to_atom(lists:concexat([Key,X])),)
			     ["HGET",lists:concat([Key,X]), redis:term_to_str(Field)]
		     end, SuffixList),
    
    
    Results = case cache:execute_cmd(Cmds) of
		  Term when not is_list(Term)->
		      [Term];
		  Lis1t ->
		      Lis1t
	      end,
    %%io:format("~p~n", [Results]),
    ResultList = lists:map(fun(X) -> 
				   %%redis:trans_res
				   case X of
				       Bin when is_binary(Bin)-> 
					   List = binary_to_list(Bin),
					   list_to_integer(List);
				       undefined->
					   0;
				       Other->
					   Other
				   end
			   end, Results),
    make_tuple(SuffixList, ResultList).


make_tuple([], [])->
    [];
make_tuple([Val1|List1], [Val2|List2])->
    [{Val1, Val2}|make_tuple(List1, List2)].
