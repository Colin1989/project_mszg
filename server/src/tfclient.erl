%%
%% Licensed to the Apache Software Foundation (ASF) under one
%% or more contributor license agreements. See the NOTICE file
%% distributed with this work for additional information
%% regarding copyright ownership. The ASF licenses this file
%% to you under the Apache License, Version 2.0 (the
%% "License"); you may not use this file except in compliance
%% with the License. You may obtain a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied. See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%

-module(tfclient).

-export([start/0, start/1]).

-include("thrift/rpc_types.hrl").

-record(options, {port = 9091,
                  client_opts = []}).

parse_args(Args) -> parse_args(Args, #options{}).
parse_args([], Opts) -> Opts;
parse_args([Head | Rest], Opts) ->
    NewOpts =
        case catch list_to_integer(Head) of
            Port when is_integer(Port) ->
                Opts#options{port = Port};
            _Else ->
                case Head of
                    "framed" ->
                        Opts#options{client_opts = [{framed, true} | Opts#options.client_opts]};
                    "" ->
                        Opts;
                    _Else ->
                        erlang:error({bad_arg, Head})
                end
        end,
    parse_args(Rest, NewOpts).

%% nonblockingservice 使用 framedtransport
%%start() -> start(["framed"]).
start() -> start([]).
start(Args) ->
    #options{port = Port, client_opts = ClientOpts} = parse_args(Args),
    {ok, Client0} = thrift_client_util:new(
		      "127.0.0.1", Port, rpcService_thrift, ClientOpts),

    %%     {Client01, {ok, Result}} = thrift_client:call(Client0, convertCDKey, [123456, 123]),
    %%     {Client01, {ok, Result}} = thrift_client:call(Client0, sendEmail, [4, "what fuck", "fuck fuck!!!",
    %% 								      [#attachment{award_id =1, amount = 10},#attachment{award_id =1, amount = 10}],
    %% 								      #time_format{year = 2014, month = 12, day = 10, hour = 1, minute = 2, second = 3},
    %% 								      ?rpc_EmailType_ALL, [72057594038090936]]),
    %%{Client01, {ok, Result}} = thrift_client:call(Client0, recharge, [1405678933047000010, 124 , 9, 900]),
    %%{Client01, {ok, Result}} = thrift_client:call(Client0, get_role_info_by_nickname, ["桑家小三"]),
    %%{Client01, {ok, Result}} = thrift_client:call(Client0, get_online_role_amount, []),
    %%{Client01, {ok, Result}} = thrift_client:call(Client0, kick_role_by_roleid, [72057594037927941]),
%%     {Client01, {ok, Result}} = thrift_client:call(Client0, set_notice,
%%                                                   [?rpc_NoticeOptType_ADD,
%%                                                    #notice_item{id = 4, title = "桑家小yi",
%%                                                                 sub_title = "桑家小",
%%                                                                 content = "一、萌动四方，秀游戏截图抽充值卡<br><br><br>活动时间：<font color='#ff0000'>2014年9月10日 - 2014年9月17日&nbsp;</font><br><br><br>回复格式：<br><br><br>截图： &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;<br>UCID： &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>角色名：<br><br><br>活动规则：<br>1.按照回帖格式回复本帖参加活动；<br>3.官方每天将随机抽取20个幸运角色，发送论坛专属礼包【魔石*500，金币*10000】；<br>4.如果名额未满奖品将累计到下一轮；<br>5.活动结束后三个工作日内随机抽取并公布30名幸运玩家，将获得充值卡、U点等奖品；<br>6.最终解释权归《萌兽战歌》运营组所有。<br><br><br>二、萌战天下，竞技场争霸送充值卡<br><br><br>亲爱的玩家们，<br>&nbsp; &nbsp; 为感谢大家对《萌兽战歌》的支持与厚爱，我们为本次测试精心准备了本次活动！<br><br><br>活动日期：9月10日 10:00 - 9月15日 12：00 &nbsp;<br>活动范围：铁拳海湾&nbsp;<br>活动内容：活动结束当天服务器竞技场排名前十，将获得相应奖励&nbsp;<br>奖励内容：<br>第一名： 100元充值卡 + 魔石*5000 &nbsp;&nbsp;<br>第二~三名：50元充值卡 &nbsp;+ 魔石*2000&nbsp;<br>第四~六名： 30元充值卡 + 魔石*1000 &nbsp;<br>第七~十名： 30元充值卡 + 魔石*500 &nbsp;<br><br><br>活动结束后三个工作日内进行发放。<br><br><br>感谢玩家们对游戏的支持！最终解释权归萌兽战歌运营组所有。&nbsp;<br><br><br>三、萌到没朋友，分享截图收充值卡 【可以0.98版本做】<br>【图+索引】<br><br><br>活动时间：<br>2014年9月10日 - 2014年9月17日&nbsp;<br><br><br>回复格式：<br><br><br>截图： &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;<br>UCID： &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>角色名：<br><br><br>活动规则：<br>1.玩家在微信/微博上分享游戏【角色】截图，并@三位好友+官方微信/微博；<br>2.将该条微信/微博信息截图并上传论坛【如果这个活动做在微信/微博上，可以忽略这条】；<br>3.官方每天将随机抽取10个幸运角色，发送【游戏内礼包/充值卡】；<br>4.如果名额未满奖品将累计到下一轮；<br>5.活动结束后三个工作日内随机抽取并公布30名幸运玩家，将获得充值卡*10元，U点等奖品；<br>6.最终解释权归《萌兽战歌》运营组所有。<br>",
%%                                                                 icon = 2, priority = 2,
%%                                                                 create_time = #time_format{year = 2013, month = 9, day = 12, hour = 0, minute = 0, second = 0}}]),
%%     {Client01, {ok, Result}} = thrift_client:call(Client0, set_CDKey_reward_item, [?rpc_CDKeyItemOptType_DEL,
%%                                                                                    #cDKey_reward_item{id = 2, reward_ids = [3,6002,11804], reward_amounts = [200,10,1]}]),
    {Client01, {ok, Result}} = thrift_client:call(Client0, get_all_role_count, []),

    io:format("Result:~p~n", [Result]),
    thrift_client:close(Client01).
