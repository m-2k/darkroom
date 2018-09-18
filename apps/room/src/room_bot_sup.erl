-module(room_bot_sup).
-behaviour(supervisor).
-author('https://github.com/m-2k').
-compile(export_all).

-include("room.hrl").
-include_lib("ut/include/ut.hrl").

-export([start_link/1]).
-export([init/1]).

strategy() -> simple_one_for_one.

start_link([]) ->
	?info("room_bot_sup start_link ~p", [self()]),
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	?info("room_bot_sup init ~p", [self()]),
    {ok, {{strategy(), 10, 10}, [ spec(room_bot) ] }}.

spec(room_bot=Mod) ->
    {Mod, { Mod, start_link, [[]]}, transient, 5000, worker, [Mod] }.

start_child(Arg) ->
	supervisor:start_child(?MODULE, [Arg]).

stop_child(Pid) ->
	supervisor:terminate_child(?MODULE, Pid).
