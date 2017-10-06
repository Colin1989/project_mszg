-ifndef(_rpc_types_included).
-define(_rpc_types_included, yeah).

-define(rpc_RoleStatus_KICK, 1).
-define(rpc_RoleStatus_MUTE, 2).

-define(rpc_ModifyType_RECOVER, 0).
-define(rpc_ModifyType_MARK, 1).

-define(rpc_ModifyRoleStatusResult_SUCCESS, 1).
-define(rpc_ModifyRoleStatusResult_NOEXIST, 2).
-define(rpc_ModifyRoleStatusResult_STATUS_ERR, 3).

-define(rpc_ConvertResult_SUCCESS, 1).
-define(rpc_ConvertResult_FAILED, 2).

-define(rpc_SendEmail_SUCCESS, 1).
-define(rpc_SendEmail_FAILED, 2).
-define(rpc_SendEmail_TIMEERR, 3).
-define(rpc_SendEmail_IDREPEAT, 4).
-define(rpc_SendEmail_ATTACHMENTERR, 5).
-define(rpc_SendEmail_TYPEERR, 6).

-define(rpc_EmailType_PRIVATE, 1).
-define(rpc_EmailType_ALL, 2).

-define(rpc_RechargeResult_SUCCESS, 1).
-define(rpc_RechargeResult_USERIDERR, 2).
-define(rpc_RechargeResult_PRODUCTIDERR, 3).
-define(rpc_RechargeResult_ORDERIDERR, 4).
-define(rpc_RechargeResult_MONEYMISMATCH, 5).
-define(rpc_RechargeResult_RECHARGEFAILED, 6).
-define(rpc_RechargeResult_CHANNELIDERR, 7).

-define(rpc_NoticeOptType_ADD, 1).
-define(rpc_NoticeOptType_MODIFY, 2).
-define(rpc_NoticeOptType_DEL, 3).

-define(rpc_SetNoticeResult_SUCCESS, 1).
-define(rpc_SetNoticeResult_FAILED, 2).

-define(rpc_SetCDKeyItemResult_SUCCESS, 1).
-define(rpc_SetCDKeyItemResult_FAILED, 2).

-define(rpc_CDKeyItemOptType_ADD, 1).
-define(rpc_CDKeyItemOptType_MODIFY, 2).
-define(rpc_CDKeyItemOptType_DEL, 3).

%% struct attachment

-record(attachment, {award_id :: integer(),
                     amount :: integer()}).

%% struct time_format

-record(time_format, {year = 0 :: integer(),
                      month = 0 :: integer(),
                      day = 0 :: integer(),
                      hour = 0 :: integer(),
                      minute = 0 :: integer(),
                      second = 0 :: integer()}).

%% struct role_info

-record(role_info, {user_id = 0 :: integer(),
                    role_id = 0 :: integer(),
                    role_status = 0 :: integer(),
                    nick_name = "" :: string() | binary(),
                    level = 0 :: integer(),
                    exp = 0 :: integer(),
                    gold = 0 :: integer(),
                    emoney = 0 :: integer(),
                    create_time = #time_format{} :: #time_format{},
                    vip = 0 :: integer()}).

%% struct notice_item

-record(notice_item, {id = 0 :: integer(),
                      title = "" :: string() | binary(),
                      sub_title = "" :: string() | binary(),
                      icon = 0 :: integer(),
                      content = "" :: string() | binary(),
                      toward_id = 0 :: integer(),
                      mark_id = 0 :: integer(),
                      start_time = #time_format{} :: #time_format{},
                      end_time = #time_format{} :: #time_format{},
                      priority = 0 :: integer(),
                      create_time = #time_format{} :: #time_format{},
                      top_pic = 0 :: integer()}).

%% struct cDKey_reward_item

-record(cDKey_reward_item, {id = 0 :: integer(),
                            reward_ids = [] :: list(),
                            reward_amounts = [] :: list()}).

-endif.
