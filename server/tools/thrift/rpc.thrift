namespace cpp TestRpc
namespace php TestRpc

struct attachment{
1:required i32 award_id;
2:required i32 amount;
}
struct time_format{
1:required i16 year = 0;
2:required i16 month = 0;
3:required i16 day = 0;
4:required i16 hour = 0;
5:required i16 minute = 0;
6:required i16 second = 0;
}


const i32 MaxStatusType = 2;
const i32 ModifyType = 2;


enum RoleStatus{
	KICK = 1,//½ÇÉ«·â½û
	MUTE = 2 //½ûÑÔ
}

struct role_info{
1:required i64 user_id = 0;
2:required i64 role_id = 0;
3:required i32 role_status = 0;
4:required string nick_name = "";
5:required i16 level = 0;
6:required i32 exp = 0;
7:required i32 gold = 0;
8:required i32 emoney = 0;
9:required time_format create_time;
10:required i16 vip = 0
}

enum ModifyType{
	RECOVER = 0
	MARK = 1
}


enum ModifyRoleStatusResult{
	SUCCESS = 1,
	NOEXIST = 2,
	STATUS_ERR = 3
}

enum ConvertResult{
	SUCCESS = 1,
	FAILED = 2
}





enum SendEmail{
	SUCCESS = 1,
	FAILED = 2,
	TIMEERR = 3,
	IDREPEAT = 4,
	ATTACHMENTERR = 5,
	TYPEERR = 6
}
enum EmailType{
	PRIVATE = 1,
	ALL =2
}

enum RechargeResult{
	SUCCESS = 1,
	USERIDERR = 2,
	PRODUCTIDERR = 3,
	ORDERIDERR = 4,
	MONEYMISMATCH = 5,
	RECHARGEFAILED = 6,
	CHANNELIDERR = 7
}

enum NoticeOptType{
	ADD = 1,
	MODIFY = 2,
	DEL = 3
}

enum SetNoticeResult{
	SUCCESS = 1,
	FAILED = 2
}

struct notice_item{
1:required i32 id = 0;
2:required string title = "";
3:required string sub_title = "";
4:required i32 icon = 0;
5:required string content = ""
6:required i32 toward_id = 0;
7:required i32 mark_id = 0;
8:required time_format start_time;
9:required time_format end_time;
10:required i32 priority = 0;
11:required time_format create_time;
12:required i32 top_pic = 0
}

enum SetCDKeyItemResult{
	SUCCESS = 1,
	FAILED = 2
}

enum CDKeyItemOptType{
	ADD = 1,
	MODIFY = 2,
	DEL = 3
}

struct CDKey_reward_item{
	1:required i32 id = 0;
	2:required list<i32> reward_ids;
	3:required list<i32> reward_amounts
}

service rpcService {
ConvertResult convertCDKey(1:i64 RoleId, 2:i32 GiftId),
ConvertResult set_CDKey_reward_item(1:CDKeyItemOptType OptType, 2:CDKey_reward_item CDKeyItem),
SendEmail sendEmail(1:i32 Id, 2:string Title, 3:string Content, 4:list<attachment> Attachments, 5:time_format EndTime, 6:i16 Type, 7:list<i64> RoleIds),
RechargeResult recharge(1:i64 UserID, 2:i64 OrderID, 3:i32 Money, 4:i32 ProductID),
role_info get_role_info_by_nickname(1:string NickName),
ModifyRoleStatusResult modify_rolestatus_by_roleid(1:i64 RoleId, 2:RoleStatus RoleStatusType, 3:ModifyType OptType),
i32 get_online_role_amount(),
void broadcast_service_msg(1:string Msg, 2:i32 RepeatTimes, 3:i32 Priority),
SetNoticeResult set_notice(1:NoticeOptType OptType, 2:notice_item NoticeInfo),
i32 get_all_role_count(),
}

