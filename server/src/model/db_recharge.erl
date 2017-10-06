-module(db_recharge, [Id,
						OrderId :: integer(),
						UserId :: integer(),
						Money :: integer(),
						RechargeId :: integer(),
						CreateTime :: datetime(),
						Remark]).
-table("recharge").
