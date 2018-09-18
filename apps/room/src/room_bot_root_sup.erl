-module(room_bot_root_sup).
-behaviour(supervisor).
-author('https://github.com/m-2k').
-compile(export_all).

-include("room.hrl").
-include_lib("ut/include/ut.hrl").

-export([start_link/1]).
-export([init/1]).

start_link([]) ->
	?info("room_bot_root_sup start_link ~p", [self()]),
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	?info("room_bot_root_sup init ~p", [self()]),
    {ok, {{one_for_one, 10, 10}, [ spec(room_bot_sup), spec(room_bot_manager) ] }}.

spec(room_bot_sup=Mod) ->
    {Mod, { Mod, start_link, [[]]}, permanent, 5000, supervisor, [Mod] };
spec(room_bot_manager=Mod) ->
    {Mod, { Mod, start_link, [[]]}, permanent, 5000, worker, [Mod] }.
