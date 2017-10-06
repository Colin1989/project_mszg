-module(debug).

-export([start/0,start/1,start/2]).

-define(debugfile,"debug.state").

start()->
     debugger:start(global,?debugfile).

start(Mode)->
     debugger:start(Mode,?debugfile).

start(Mode,File)->
     debugger:start(Mode,File).

