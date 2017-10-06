%% 初始化时的房屋留言
-define(default_boy_house_guest_book, "朋友们，我跟我老婆有了爱的小屋，经常过来踩踩啊！").
-define(default_girl_house_guest_book, "朋友们，我跟我老公有了爱的小屋，经常过来踩踩啊！").
-define(default_boy_house_checkin, "老婆，我来了！").
-define(default_girl_house_checkin, "老公，我来了！").
-define(default_house_name, "~s和~s的家").
-define(default_commemoration, "我们已经相恋了"). %% 默认的纪念日会生成对应的内容

-define(message_mateup_fail, "系统异常\r\n请重新选择").            %% 未知的配对异常
-define(message_mateup_same_gender, "系统不支持选择同性伴侣").       %% 相同的性别，无法完成配对
-define(message_mateup_mateuped, "您选择的玩家已经与其他玩家牵手爱情，请您另外选择。").          %% 选择的配对对象已经完成了配对
-define(message_mateup_not_match, "系统查找不到对方的信息\r\n请与对方确认输入的号码后再试。").          %% 选择的配对对象修改了配对号码
-define(message_mateup_not_enough_love_coin, "爱情币不够哦\r\n"). 

-define(message_mateup_suceessful_desc, "分享内容：搬新家啦！真开心，终于可以和心爱的人住在一起了，只要在《我们恋爱吧》牵手爱情，就能获得新的房屋，领取爱情树哦。大家赶快来我家踩踩吧！").                        %%配对成功后首次登陆的分享内容
-define(message_mateup_suceessful_title, "我们恋爱吧！").               %%配对成功后首次登陆的分享标题
-define(message_mateup_suceessful_summary, "在这个爱的空间里，一起共筑爱巢，留下温馨的回忆。让我们相知、相爱、相恋，携手步入婚姻的殿堂
。").                                                                 %%配对成功后首次登陆的分享摘要


%% 许愿单
-define(message_wish_satisfy_fail, "该愿望已经消失\r\n无法进行实现").
-define(message_wish_satisfy_insufficient_balance, "您的水晶不足\r\n无法帮忙实现").
-define(message_wish_exceeded, "无法添加更多的愿望了").


%% 支付
-define(order_goods_meta_props, "道具支付*道具支付").
-define(order_goods_meta_wish, "许愿支付*许愿支付").
-define(order_goods_meta_clothes, "服装装饰*服装装饰").
-define(order_goods_meta_gift, "礼物支付*礼物支付").
-define(order_goods_meta_task, "Q点支付*Q点支付").
-define(order_goods_meta_house, "房屋支付*房屋支付").
-define(order_goods_meta_ring_task, "Q点支付任务*Q点支付任务").
-define(order_goods_meta_recharge, "Q点充值*Q点充值").
-define(order_goods_meta_daily_active, "立即完成支付*立即完成支付").
-define(order_goods_yy_gift, "语音礼物支付*语音礼物支付").
-define(order_goods_yy_host_recv, "收礼获得*收礼获得").
-define(order_goods_yy_pay_back, "送礼返还金额*送礼返还金额").
-define(order_goods_meta_farm, "农场支付*农场支付").
-define(order_goods_meta_shake, "摇一摇*摇一摇").
-define(order_goods_meta_mind_quiz, "智力闯关*智力闯关").
-define(order_goods_meta_hp, "体力*体力").
-define(order_goods_meta_mate_up, "配对*配对").
-define(order_goods_meta_food_stock, "食物库存*食物库存").
-define(order_goods_meta_food_product, "事物生产*食物生产").
-define(order_goods_meta_event, "任务奖励*任务奖励").
-define(order_goods_meta_special_house, "特殊房产*特殊房产").
-define(order_goods_meta_party_drink, "派对请酒*派对请酒").


%% 合成
-define(produce_fail_level, "等级不够").
-define(produce_fail_money, "水晶不够").
-define(produce_fail_material, "原材料不够").
-define(produce_fail_manual, "合成配方不够").
-define(produce_fail_luckystone, "幸运符不够").
-define(produce_fail_insurancestone, "完璧符不够").
-define(produce_success, "合成成功").
-define(produce_failure, "合成失败").
-define(produce_failure_unkow, "合成异常，请重新合成").
