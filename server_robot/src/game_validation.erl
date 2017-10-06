-module(game_validation).


-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-export([game_validate/5,get_items_and_gold/1]).
-record(operation,{operation,pos}).


game_validate(UserOperations,_Result,Gold,PickUpItems,AllMap)->
    case check_gold_and_items(Gold,PickUpItems,AllMap) of
	true ->
	    validation_process(UserOperations);
	false ->
	    false
    end.

validation_process([])->
    true;

validation_process([Opt|Operations])->
    _Operation=get_operation(Opt),
    validation_process(Operations).


get_operation(Operation)->
    {Quotient,Operate}=get_quotient_and_rem(Operation,100),
    {_Quotient1,Pos}=get_quotient_and_rem(Quotient,100),
    #operation{operation=Operate,pos=Pos}.

get_quotient_and_rem(Dividend,Divisor)->
    Quotient=Dividend div Divisor,
    Remeber=Dividend rem Divisor,
    {Quotient,Remeber}.

check_gold_and_items(Gold,Items,Maps)->
    {AllItems,RGold} = get_items_and_gold(Maps),
    case RGold >= Gold of 
	true ->
	    io_helper:format("AllItems:~p,Itmes~p~n",[AllItems, Items]),
	    case length(AllItems) =:= (length(Items)+length(AllItems--Items)) of 
		true ->
		    true;
		false ->
		    sys_msg:send_to_self(?sg_game_settle_item_exceeded,[])
	    end;
	false ->
	    io_helper:format("RGold:~p,Gold~p~n",[RGold, Gold]),
	    sys_msg:send_to_self(?sg_game_settle_gold_exceeded,[]),
	    false
    end.

get_items_and_gold([])->
    {[],0};
get_items_and_gold([Map|Maps])->
    Monsters = Map#game_map.monster,
    Awards = Map#game_map.award,
    RGold = lists:foldl(fun(X,In)-> In + get_gold_by_award_id(X#saward.awardid) end,0,Awards),
    Items = lists:map(fun(X)->
			      X#smonster.dropout
		      end,Monsters),
    RItems = lists:filter(fun(X)-> X=/=0 end,Items),
    {AllItems,Gold} = get_items_and_gold(Maps),
    {RItems++AllItems,Gold+RGold}.
    
get_gold_by_award_id(AwardId)->
    Event = tplt:get_data(event_tplt,AwardId),
    case Event#event_tplt.type of
	1 ->
	    Event#event_tplt.number;
	_ ->
	    0
    end.
    

    

    
    
