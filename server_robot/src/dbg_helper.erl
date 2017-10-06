%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%% dbgģ��İ���ģ��, ���ڼ�dbg��ʹ��
%%% @end
%%% Created :  5 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(dbg_helper).
-export([debug/0, debug/1, disable/0, disable/1]).

debug() ->
    dbg:tracer(),
    dbg:p(all, [call]),  %% ���ǹ��ĺ�������
    Modules = get_modules(),
    [dbg:tpl(M, [{'_', [], [{return_trace}]}]) || M <- Modules],
    ok.

debug(Module) ->
    dbg:tpl(Module, [{'_', [], [{return_trace}]}]),
    ok.

disable() ->
    Modules = get_modules(),
    [dbg:ctpl(Module) || Module <- Modules].

disable(Module) ->
    dbg:ctpl(Module).

get_modules() ->
    {ok, Files} = file:list_dir("./"),
    [list_to_atom(filename:rootname(File)) || File <- Files].



