%% -record(player, { username, create_date, login_ip }).
-record(tcp_mm_data, {
	  socket,     % client socket
	  addr,       % client address
	  account,    % 玩家帐号, 对应openkey
	  password,   % 对应openid
	  login_type, % 登陆类型(登陆哪个平台)
	  player_sup, % 和玩家相关的系统的pid监控树 
	  is_first_time_login=false, % 是否第一次进游戏
	  eq_pid,
	  pid,        % 主进程的pid 
	  pf_key,     % 平台信息加密串
	  packet_count=0 % 步进值, 用来防止重发包  
	 }).
