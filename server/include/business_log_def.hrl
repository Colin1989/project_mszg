%%% @author whl
%%% @copyright (C) 2010, 
%%% @doc
%%% 业务类型定义
%%% @end
%%% Created : 19 Mar 2010 by  <>

%%----大类定义----
-define(PVE, 1).
-define(TASK,2).
-define(PVP, 5).
-define(GUIDE, 6).

%%----子业务类型定义----
-define(bs_undefine, 0).

-define(bs_activeness_task, 21).
-define(bs_daily_task, 22).

-define(bs_challenge, 52).
-define(bs_training_match, 53).
-define(bs_ladder_match, 54).

-define(bs_newbie_guide, 60).