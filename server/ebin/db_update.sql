{"create table uuid", "CREATE TABLE IF NOT EXISTS `uuid_indices` (
  `id` int(11) NOT NULL,
  `idx` bigint(20) NOT NULL  COMMENT '新UUID的起始值',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB"}.
{"create table account_userid_mappings", "CREATE TABLE IF NOT EXISTS `account_userid_mappings` (
  `id` bigint(22) NOT NULL COMMENT '映射的到的用户ID',
  `account` char(20) NOT NULL COMMENT '账号',
  `create_time` timestamp NOT NULL COMMENT '玩家账号创建时间',
  PRIMARY KEY (`id`),
  KEY(`account`)
) ENGINE=InnoDB"}.
{"create table roles", "CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint(22) NOT NULL COMMENT '	ID',
  `user_id` bigint(22) NOT NULL COMMENT '玩家ID',
  `role_type` int(2) NOT NULL COMMENT '角色类型',
  `nickname` char(40) NOT NULL COMMENT '角色昵称',
  `armor` bigint(22) NOT NULL COMMENT '护甲',
  `weapon` bigint(22) NOT NULL COMMENT '武器',
  `jewelry` bigint(22) NOT NULL COMMENT '首饰',
  `medal` bigint(22) NOT NULL COMMENT '勋章',
  `skill1` int(11) NOT NULL COMMENT '技能1',
  `skill2` int(11) NOT NULL COMMENT '技能2',
  `sculpture1` bigint(22) NOT NULL COMMENT '雕纹1',
  `sculpture2` bigint(22) NOT NULL COMMENT '雕纹2',
  `sculpture3` bigint(22) NOT NULL COMMENT '雕纹3',
  `sculpture4` bigint(22) NOT NULL COMMENT '雕纹4',
  `level` int(11) NOT NULL COMMENT '角色等级',
  `exp` int(11) NOT NULL COMMENT '当前经验',
  `gold` int(11) NOT NULL COMMENT '拥有的金币',
  `create_time` timestamp NOT NULL COMMENT '角色创建时间',
  PRIMARY KEY (`id`),
  UNIQUE(`user_id`),
  UNIQUE(`nickname`)
) ENGINE=InnoDB"}.
{"create table users", "CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(22) NOT NULL COMMENT '玩家ID',
  `password` char(20) NOT NULL COMMENT '密码',
  `channel_type` int(3) NOT NULL COMMENT '渠道类型',
  `account_type` int(3) NOT NULL COMMENT '账号类型',
  `create_time` timestamp NOT NULL COMMENT '账号创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB"}.
{"create table items", "CREATE TABLE IF NOT EXISTS `items` (
  `id` bigint(22) NOT NULL COMMENT '物品实例ID',
  `role_id` bigint(22) NOT NULL COMMENT '拥有者角色ID',
  `item_id` int(11) NOT NULL COMMENT '物品ID',
  `item_type` int(3) NOT NULL COMMENT '物品类型',
  `amount`  int(11) NOT NULL COMMENT '数量用于可叠加物品',
  `create_time` timestamp NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX(`role_id`)
) ENGINE=InnoDB"}.
{"create table inlaidgems", "CREATE TABLE IF NOT EXISTS `inlaidgem` (
  `id` bigint(22) NOT NULL COMMENT '镶嵌实例ID',
  `equipment_id` bigint(22) NOT NULL COMMENT '镶嵌的装备实例ID',
  `gem_id` bigint(22) NOT NULL COMMENT '镶嵌的宝石实例ID',
  `create_time` timestamp NOT NULL COMMENT '镶嵌时间',
  PRIMARY KEY (`id`),
  INDEX(`equipment_id`)
) ENGINE=InnoDB"}.
{"create table copies", "CREATE TABLE IF NOT EXISTS `copies` (
  `id` bigint(22) NOT NULL COMMENT '副本游戏的实例ID',
  `role_id` bigint(22) NOT NULL COMMENT '角色ID',
  `copy_id` int(11) NOT NULL COMMENT '副本的ID',
  `pass_times` int(11) NOT NULL COMMENT '通关次数',
  `try_times` int(11) NOT NULL COMMENT '尝试次数',
  `max_score` int(11) NOT NULL COMMENT '最高分',
  `last_pass_time`  timestamp NOT NULL COMMENT '最后一次游戏时间',
  `create_time` timestamp NOT NULL COMMENT '第一次进行副本时间',
  PRIMARY KEY (`id`),
  INDEX(`role_id`)
) ENGINE=InnoDB"}.
{"create table last_copy", "CREATE TABLE IF NOT EXISTS `last_copy` (
  `id` bigint(22) NOT NULL COMMENT '副本解锁的实例ID，每一个玩家有一个',
  `role_id` bigint(22) NOT NULL COMMENT '对应的角色ID',
  `last_copy` int(11) NOT NULL COMMENT '已解锁的最后一个副本的ID',
  `update_time` timestamp NOT NULL COMMENT '新解锁副本时间',
  PRIMARY KEY (`id`),
  UNIQUE(`role_id`)
) ENGINE=InnoDB"}.
{"modify table name from items to packs", "RENAME TABLE `items` TO `packs`; "}.
{"create table power_hp", "CREATE TABLE `power_hp` (
  `id` bigint(22) NOT NULL,
  `role_id` bigint(22) NOT NULL COMMENT '角色id',
  `power_hp` int(8) NOT NULL COMMENT '体力值',
  `power_hp_time` timestamp NOT NULL COMMENT '回复体力的时间',
  `standby_hp` int(8) NOT NULL COMMENT '备用体力',
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`)
) ENGINE=InnoDB"}.
{"change table player_pack", "ALTER TABLE `packs` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID', ADD COLUMN `inst_id` BIGINT(22) NOT NULL COMMENT '背包物品的实例ID' AFTER `role_id`;"}.
{"create table player_log", "CREATE TABLE `player_log`( 
`id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID', 
`role_id` BIGINT(22) NOT NULL  COMMENT '角色ID',
`type` INT(11) NOT NULL  COMMENT '日志类型如物品，金钱，经验', 
`sub_type` INT(11) NOT NULL  COMMENT '子类型如装备升级，占卜等', 
`inst_id` BIGINT(22) NOT NULL  COMMENT '日志实例ID',
`item_id` INT(11) NOT NULL  COMMENT '如果是物品则为物品ID',
`count` INT(11) NOT NULL  COMMENT '数量', 
`create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '日志产生时间', 
`remark` VARCHAR(200)  COMMENT '备注', 
PRIMARY KEY (`id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_general_ci; "}.
{"add table player_log field", "ALTER TABLE `player_log` ADD COLUMN `op_type` INT(11) NOT NULL  COMMENT '操作类型增加删除' AFTER `sub_type`; "}.
{"clear db_account_user_mapping","DELETE FROM `account_userid_mappings`;"}.
{"change table db_account_user_mapping", "ALTER	TABLE `account_userid_mappings` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',CHANGE `account` `account_id` CHAR(22) NOT NULL COMMENT '账号',ADD COLUMN `user_id` BIGINT(22) NOT NULL  COMMENT '映射的到的用户ID' AFTER `account_id`,DROP INDEX `account`,ADD UNIQUE(`account_id`);"}.
{"clear copies","DELETE FROM `copies`;"}.
{"change table copies","ALTER TABLE `copies` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'ID';"}.
{"clear inlaidgem","DELETE FROM `inlaidgem`;"}.
{"change talbe inlaidgem","ALTER TABLE `inlaidgem` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID';"}.
{"clear last_copy","DELETE FROM `last_copy`;"}.
{"change table last_copy","ALTER TABLE `last_copy` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT;"}.
{"clear power_hp","DELETE FROM `power_hp`;"}.
{"change table power_hp","ALTER TABLE `power_hp` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID';"}.
{"clear roles","DELETE FROM `roles`;"}.
{"change table roles","ALTER TABLE `roles` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID',ADD COLUMN `role_id` BIGINT(22) NOT NULL  COMMENT '角色实例ID' AFTER `id`,ADD UNIQUE(`role_id`),DROP INDEX user_id,ADD INDEX(`user_id`);"}.
{"clear users","DELETE FROM `users`;"}.
{"change table users","ALTER TABLE `users` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID',ADD COLUMN user_id BIGINT(22) NOT NULL  COMMENT '映射的到的用户ID' AFTER `id`,ADD UNIQUE(`user_id`);"}.
{"create table games","CREATE TABLE IF NOT EXISTS `games` (
`id` int(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID',
`game_id` bigint(22) NOT NULL COMMENT 'game实例ID',
`role_id` bigint(22) NOT NULL COMMENT '玩家角色ID',
`copy_id` bigint(22) NOT NULL COMMENT '副本ID',
`result`  int(3) NOT NULL COMMENT '游戏结果',
`score`   int(11) NOT NULL COMMENT '游戏得分',
`final_item` int(11) NOT NULL COMMENT '3星获得的奖励',
`pickup_item` text COMMENT '打怪掉落的物品',
`create_time` timestamp NOT NULL COMMENT '结算时间',
PRIMARY KEY (`id`),
INDEX (`role_id`),
UNIQUE(`game_id`)
) ENGINE=InnoDB"}.

{"create table game_logs","CREATE TABLE IF NOT EXISTS `game_logs` (
`id` int(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID',
`game_id` bigint(22) NOT NULL COMMENT 'game实例ID',
`user_operations` text NOT NULL COMMENT '玩家操作',
`game_maps` text NOT NULL COMMENT '副本地图信息',
`game_result` text NOT NULL COMMENT '游戏结束后客户端发上来的消息',
`role_info` text NOT NULL COMMENT '玩家进入副本场景时的信息',
`create_time` timestamp NOT NULL COMMENT '结算时间',
PRIMARY KEY (`id`),
UNIQUE(`game_id`)
) ENGINE=InnoDB"}.
{"change table uuid_indices","ALTER TABLE `uuid_indices` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID',ADD COLUMN `server_id` INT(11) NOT NULL  COMMENT '服务器ID' AFTER `id`;" }.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `emoney` INT(11) NOT NULL AFTER `gold`;" }.
{"create table equipments","CREATE TABLE IF NOT EXISTS `equipments` (
`id` int(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID',
`equipment_id` bigint(22) NOT NULL COMMENT '装备对应的物品实例ID',
`role_id` bigint(22) NOT NULL COMMENT '玩家ID',
`level` int(3) NOT NULL COMMENT '强化等级',
`attach_info` text NOT NULL COMMENT '附加信息',
`create_time` timestamp NOT NULL COMMENT '结算时间',
PRIMARY KEY (`id`),
INDEX(`role_id`),
UNIQUE(`equipment_id`)
) ENGINE=InnoDB"}.
{"change table equipments","ALTER TABLE `equipments` ADD COLUMN `addition_gem` INT(3) NOT NULL COMMENT '附加的宝石孔数' AFTER `level`;"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `necklace` INT(3) NOT NULL COMMENT '项链' AFTER `weapon`,ADD COLUMN `ring` INT(3) NOT NULL COMMENT '戒指' AFTER `weapon`;"}.
{"change table last_copy","UPDATE `last_copy` SET last_copy=1001;"}.
{"clear copies","DELETE FROM `copies`;"}.
{"drop last_copy","DROP TABLE `last_copy`;"}.
{"change table games","ALTER TABLE `games` ADD COLUMN `extra_gold` INT(11) NOT NULL COMMENT '额外的金币奖励' AFTER `final_item`;"}.
{"change table power_hp","ALTER TABLE `power_hp` DROP COLUMN `standby_hp`;"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `pack_space` INT(5) NOT NULL COMMENT '当前背包容量' AFTER  `emoney` ;"}.
{"change table roles","UPDATE `roles` SET `pack_space`=20;"}.
{"change table equipments","ALTER TABLE `equipments` ADD COLUMN `temp_id` INT(11) NOT NULL  COMMENT '装备模板ID' AFTER `role_id`;"}.
{"change table games","ALTER TABLE `games` ADD COLUMN `game_type` INT(3) NOT NULL DEFAULT 1 COMMENT '进行的游戏类型' AFTER `id` ;"}.
{"change table roles","ALTER TABLE `roles` CHANGE `ring` `ring` BIGINT(22) NOT NULL COMMENT '戒指',CHANGE `necklace` `necklace` BIGINT(22) NOT NULL COMMENT '项链';"}.
{"change table equipments","ALTER TABLE `equipments` ADD COLUMN `gems` text NOT NULL COMMENT '镶嵌的宝石IDs' AFTER `addition_gem` ;"}.
{"change table equipments","UPDATE equipments SET gems = '[]';"}.
{"create table push_towers", "CREATE TABLE IF NOT EXISTS `push_towers` (
  `id` int(11) NOT NULL COMMENT '玩家推塔记录ID',
  `role_id` bigint(22) NOT NULL COMMENT '角色ID',
  `max_floor` int(11) NOT NULL COMMENT '最高层数',
  `pass_times` int(11) NOT NULL COMMENT '回合用完次数',
  `die_times` int(11) NOT NULL COMMENT '死亡次数',
  `try_times` int(11) NOT NULL COMMENT '进行次数',
  `last_try_time`  timestamp NOT NULL COMMENT '最后一次游戏时间',
  `create_time` timestamp NOT NULL COMMENT '第一次进行推塔时间',
  PRIMARY KEY (`id`),
  INDEX(`role_id`)
) ENGINE=InnoDB"}.
{"change table push_towers", "ALTER TABLE `push_towers` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID';"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `gold_divine_level` INT(11) NOT NULL AFTER `sculpture4`;"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `emoney_divine_level` INT(11) NOT NULL AFTER `gold_divine_level`;"}.
{"create table sculptures", "CREATE TABLE IF NOT EXISTS `sculptures` (
  `id` bigint(22) NOT NULL COMMENT '符文实例ID',
  `sculpture_id` bigint(22) NOT NULL COMMENT '装备对应的物品实例ID',
  `role_id` bigint(22) NOT NULL COMMENT '拥有者角色ID',
  `temp_id` int(11) NOT NULL COMMENT 'xml模板ID',
  `level`  int(11) NOT NULL COMMENT '等级',
  `exp`  int(11) NOT NULL COMMENT '经验',
  `create_time` timestamp NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX(`role_id`),
  UNIQUE(`sculpture_id`)
) ENGINE=InnoDB"}.
{"change table sculptures","ALTER TABLE `sculptures` DROP COLUMN `level`;"}.
{"change table roles","ALTER TABLE `roles` DROP COLUMN `gold_divine_level`;"}.
{"change table roles","ALTER TABLE `roles` DROP COLUMN `emoney_divine_level`;"}.
{"change table sculptures", "ALTER TABLE `sculptures` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID';"}.
{"create table challenge_log","CREATE TABLE IF NOT EXISTS `challenge_log` (
`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
`game_id` bigint(22) NOT NULL COMMENT '游戏ID',
`role_id` bigint(22) NOT NULL COMMENT '玩家ID',
`enemy_id` bigint(22) NOT NULL COMMENT '对手ID',
`enemy_rank` int(11) NOT NULL COMMENT '对手排名',
`my_rank` int(11) NOT NULL COMMENT '我的排名',
`result` int(3) NOT NULL COMMENT '挑战结果',
`point` int(11) NOT NULL COMMENT '获得积分',
`honours` int(11) NOT NULL COMMENT '获得的荣誉值',
`create_time` timestamp NOT NULL COMMENT '结算时间',
PRIMARY KEY (`id`),
INDEX(`role_id`),
UNIQUE(`game_id`)
) ENGINE=InnoDB"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `friend_point` INT(11) NOT NULL COMMENT '友情点' AFTER `emoney` ;" }.
{"change table sculptures", "ALTER TABLE `sculptures` CHANGE `id` `id` INT(11) NOT NULL AUTO_INCREMENT  COMMENT 'ID';"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `point` INT(11) NOT NULL  COMMENT '积分' AFTER `friend_point`, ADD COLUMN `honour` INT(11) NOT NULL  COMMENT '荣耀' AFTER `point`;"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `status` INT(3) NOT NULL DEFAULT 1 COMMENT '账号状态' AFTER `user_id`;"}.
{"change table roles","ALTER TABLE `roles` DROP COLUMN `emoney`;"}.
{"change table users","ALTER TABLE `users` ADD COLUMN `emoney` INT(11) NOT NULL COMMENT '账号的代币' AFTER `account_type`;"}.
{"change table equipments","ALTER TABLE `equipments` ADD COLUMN `bind_type` INT(3) NOT NULL DEFAULT 1  COMMENT '绑定类型' AFTER `attach_info`, ADD COLUMN `bind_status` INT(3) NOT NULL DEFAULT 2  COMMENT '绑定状态' AFTER `attach_info`;"}.
{"change table roles","ALTER TABLE `roles` ADD COLUMN `sculpture_frag` INT(11) NOT NULL COMMENT '符文碎片' AFTER `honour`;"}.
{"change table sculptures", "ALTER TABLE `sculptures` ADD COLUMN `level` INT(11) NOT NULL  COMMENT '符文等级' AFTER `temp_id`;"}.

{"change table roles", "ALTER TABLE  `roles` ADD  `summon_stone` INT NOT NULL COMMENT  ' 召唤石' AFTER  `gold`;"}.
{"change table users", "ALTER TABLE `users` ADD `account_status` INT(3) NOT NULL DEFAULT 1 COMMENT '账号状态' AFTER `user_id`;"}.
{"create table login_logout_log", "CREATE TABLE IF NOT EXISTS `login_logout_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `user_id` bigint(22) NOT NULL COMMENT '用户ID',
  `role_id` bigint(22) NOT NULL COMMENT '角色ID',
  `status` int(3) NOT NULL COMMENT '1是登录2是退出',
  `ip` char(20) NOT NULL COMMENT 'ip地址',
  `create_time` timestamp NOT NULL COMMENT '时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB"}.
{"drop login_logout_log","DROP TABLE `login_logout_log`;"}.
{"create table login_logout_log", "CREATE TABLE IF NOT EXISTS `login_logout_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `user_id` bigint(22) NOT NULL COMMENT '用户ID',
  `role_id` bigint(22) NOT NULL COMMENT '角色ID',
  `ip` char(20) NOT NULL COMMENT 'ip地址',
  `login_time`  timestamp NOT NULL COMMENT '登录时间',
  `logout_time` timestamp NOT NULL COMMENT '退出时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB"}.

{"create table tutorial_log", "CREATE TABLE `tutorial_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `role_id` bigint(20) DEFAULT NULL COMMENT '用户ID',
  `tutorial_id` int(11) DEFAULT NULL COMMENT '教程ID',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8"}.

{"create table business_log", "CREATE TABLE `business_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `role_id` bigint(20) DEFAULT NULL COMMENT '角色ID',
  `business_id` int(11) DEFAULT NULL COMMENT '业务ID',
  `business_type` int(11) DEFAULT NULL COMMENT '业务类型',
  `business_class` int(11) DEFAULT NULL COMMENT '业务大类',
  `end_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '结束时间',
  `update_time` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8
"}.
{"change table business_log", "ALTER TABLE `business_log`   
  ADD COLUMN `temp_col` INT NULL  COMMENT '结果信息' AFTER `update_time`;"}.
{"change table business_log", "ALTER TABLE `business_log`   
  DROP COLUMN `temp_col`;"}.
{"change table business_log", "ALTER TABLE `business_log`   
  ADD COLUMN `result` INT NULL  COMMENT '结果信息' AFTER `update_time`;"}.

{"change table games", "ALTER TABLE `games`   
  CHANGE `final_item` `final_item` TEXT NOT NULL  COMMENT '3星获得的奖励';"}.

{"remove games id", "ALTER TABLE `games` DROP COLUMN `id`, DROP PRIMARY KEY; "}.
{"remove player_log id", "ALTER TABLE `player_log` DROP COLUMN `id`, DROP PRIMARY KEY; "}.
{"remove tutorial_log id", "ALTER TABLE `tutorial_log` DROP COLUMN `id`, DROP PRIMARY KEY; "}.
{"remove login_logout_log id", "ALTER TABLE `login_logout_log` DROP COLUMN `id`, DROP PRIMARY KEY; "}.
{"remove game_logs id", "ALTER TABLE `game_logs` DROP COLUMN `id`, DROP PRIMARY KEY; "}.
{"remove business_log id", "ALTER TABLE `business_log` DROP COLUMN `id`, DROP PRIMARY KEY; "}.
{"remove game_logs id", "ALTER TABLE `game_logs` DROP COLUMN `id`, DROP PRIMARY KEY; "}.
{"remove challenge_log id", "ALTER TABLE `challenge_log` DROP COLUMN `id`, DROP PRIMARY KEY; "}.

{"change table roles", "ALTER TABLE `roles`   
  CHANGE `friend_point` `battle_soul` INT(11) NOT NULL  COMMENT '战魂值',
  CHANGE `honour` `potence_level` INT(11) NOT NULL  COMMENT '潜能等级',
  ADD COLUMN `advanced_level` INT NOT NULL  COMMENT '进阶等级' AFTER `potence_level`;"}.
{"change table roles", "UPDATE  `roles` SET  `potence_level` =  100 ;"}.
{"change table roles", "UPDATE  `roles` SET  `advanced_level` =  1;"}.

{"change table users", "ALTER TABLE `users`   
  ADD COLUMN `vip_level` INT NOT NULL  COMMENT 'vip等级' AFTER `emoney`;"}.
{"change table users", "ALTER TABLE `users` CHANGE `create_time` `create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '创建时间';"}.
{"change table roles", "ALTER TABLE `roles` CHANGE `create_time` `create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '创建时间';"}.
  
{"create table recharge", "CREATE TABLE `recharge`(  
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL COMMENT '订单号',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `money` INT NOT NULL COMMENT '充值费用',
  `recharge_id` INT NOT NULL COMMENT '充值ID',
  `create_time` TIMESTAMP NOT NULL COMMENT '创建时间',
  `remark` VARCHAR(255) COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=INNODB;"}.

{"change table roles","ALTER TABLE `roles` ADD COLUMN `role_status` INT(3) NOT NULL DEFAULT 1 COMMENT '角色状态' AFTER `status`;" }.

{"change table sculptures", "ALTER TABLE `sculptures` CHANGE `exp` `type` INT(3) NOT NULL  COMMENT '1:符文,2:天赋,3:碎片';"}.
{"change table sculptures", "ALTER TABLE `sculptures` CHANGE `level` `value` INT(11) NOT NULL  COMMENT '等级或者数量';"}.


{"change table sculptures", "ALTER TABLE `sculptures` CHANGE `exp` `type` INT(3) NOT NULL   COMMENT '1:符文,2:天赋,3:碎片';"}.
{"change table sculptures", "ALTER TABLE `sculptures` CHANGE `level` `value` INT(11) NOT NULL   COMMENT '等级或者数量';"}.
{"change table sculptures", "UPDATE `sculptures` SET TYPE = 1;"}.

{"change table sculptures", "ALTER TABLE `roles`   
  DROP COLUMN `sculpture1`, 
  DROP COLUMN `sculpture2`, 
  DROP COLUMN `sculpture3`, 
  DROP COLUMN `sculpture4`;
"}.
{"change table sculptures", "ALTER TABLE `roles` DROP COLUMN `sculpture_frag`;"}.

{"change table roles", "ALTER TABLE `roles`   
  ADD COLUMN `vip_exp` INT NOT NULL  COMMENT 'vip经验' AFTER `pack_space`;"}.


