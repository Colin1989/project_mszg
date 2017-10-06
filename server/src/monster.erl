-module(monster).

-export([genetare_monster/2,set_pos/2,genetare_monster/1]).
-export([get_level/1,get_type/1,get_hp/1,get_attack/1,get_speed/1,get_hit/1,get_crit/1,get_dodge/1,
	get_tenacity/1,get_skills/1,drop_itemid/1,get_itemid/1]).

-include("packet_def.hrl").
-include("tplt_def.hrl").

%%--------------------------------------------------------------------
%% @doc
%% @往地图添加一个怪
%% genetare_monster(MonsterTypeId::int,Pos::int)->Monster::#smonster{}
%% MonsterTypeId:怪ID,Monster::生成的怪
%% @end
%%--------------------------------------------------------------------
genetare_monster(MonsterTypeId,Pos)->
    #smonster{pos=Pos, monsterid=MonsterTypeId, dropout=drop_itemid(MonsterTypeId)}.

genetare_monster(MonsterTypeId)->
    #smonster{ monsterid=MonsterTypeId, dropout=drop_itemid(MonsterTypeId)}.
%%--------------------------------------------------------------------
%% @doc
%% @设置怪的位置
%% genetare_monster(MonsterTypeId::int,Pos::int)->Monster::#smonster{}
%% Pos:怪位置,Monster::怪
%% @end
%%--------------------------------------------------------------------
set_pos(Monster, Pos) ->
    Monster#smonster{pos=Pos}.
	
%%怪物数据
info(Id) -> 
	tplt:get_data(monster_tplt,Id).
	
%%怪物等级	
get_level(Id) ->
	Data = info(Id),
	Data#monster_tplt.level.

%%怪物类型
get_type(Id) ->
	Data = info(Id),
	Data#monster_tplt.type.
	
%%怪物血量
get_hp(Id) ->
	Data = info(Id),
	Data#monster_tplt.life.

%%怪物攻击
get_attack(Id) ->
	Data = info(Id),
	Data#monster_tplt.atk. 

%%怪物速度
get_speed(Id) ->
	Data = info(Id),
	Data#monster_tplt.speed. 

%%怪物命中
get_hit(Id) ->
	Data = info(Id),
	Data#monster_tplt.hit_ratio. 

%%怪物暴击
get_crit(Id) ->
	Data = info(Id),
	Data#monster_tplt.critical_ratio. 

%%怪物闪避
get_dodge(Id) ->
	Data = info(Id),
	Data#monster_tplt.miss_ratio. 

%%怪物韧性
get_tenacity(Id) ->
	Data = info(Id),
	Data#monster_tplt.tenacity. 

%%技能 1
get_skills(Id) ->
	Data = info(Id),
	Data#monster_tplt.skills. 

%%掉落概率
get_droprate(Id) when is_integer(Id)->
	Data = info(Id),
	Data#monster_tplt.drop_rate;

get_droprate(Info) ->
    Info#monster_tplt.drop_rate.

%%掉落数量
get_drop_amount(Id) when is_integer(Id)->
	Data = info(Id),
	Data#monster_tplt.drop_amount;
get_drop_amount(Info) ->
    Info#monster_tplt.drop_amount.

%%掉落的物品id
get_itemid(Id)  when is_integer(Id)->
	Data = info(Id),
	Data#monster_tplt.item_id;
get_itemid(Info) ->
    Info#monster_tplt.item_id. 

%%返回计算概率掉落的物品id
drop_itemid(Id) ->
    Data = info(Id),
    RateList = get_droprate(Data),
    ItemList = get_itemid(Data),
    AmountList = get_drop_amount(Data),
    get_rand_item_list(RateList, ItemList, AmountList, []).

get_rand_item_list([], _ItemList, _AmountList, DrapContainer) ->
	DrapContainer;
get_rand_item_list([Rate | RateList], [Item | ItemList], [Amount | AmountList], DrapContainer) ->
	RandNum = rand:uniform(10000),
	case RandNum =< Rate of
		true ->
			get_rand_item_list(RateList, ItemList, AmountList, [#mons_item{id = Item, amount = Amount} | DrapContainer]);
		false ->
			get_rand_item_list(RateList, ItemList, AmountList, DrapContainer)
	end.

%% drop_itemid(Id) ->
%% 	RateList = get_droprate(Id),
%%         RateSum = sum_list(RateList),
%% 	InRate = rand:uniform(1,100),
%%         case(InRate =< RateSum) of
%% 	    true ->
%% 		ItemList = get_itemid(Id),
%% 	        get_rand_itemid(InRate,RateList,ItemList);
%% 	    false ->
%% 		0
%% 	end.

%%计算列表里元素的和
%% sum_list(List) ->
%%    lists:foldl(fun(X, Sum) -> X + Sum end, 0, List).
%%
%% %%对应概率的物品id
%% get_rand_itemid(Rate,[T1|H1],[T2|H2]) ->
%%     NewRate = Rate - T1,
%%     case(NewRate > 0) of
%% 	true ->
%% 	    get_rand_itemid(NewRate,H1,H2);
%% 	false ->
%% 	    T2
%%     end.
	    
