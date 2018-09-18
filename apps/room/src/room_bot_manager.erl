-module(room_bot_manager).
-behaviour(gen_server).
-author('https://github.com/m-2k').
-compile(export_all).

-include("room.hrl").
-include_lib("ut/include/ut.hrl").


start_bot(RoomID) -> gen_server:call(?MODULE, {append_bot, RoomID}).
stop_bot(BotPid) -> gen_server:call(?MODULE, {remove_bot, BotPid}).

start_link(Args) ->
	?info("room_bot_manager start_link ~p", [self()]),
    gen_server:start_link({local, ?MODULE}, ?MODULE, Args, []).

init(Args) ->
	?info("room_bot_manager init ~p", [self()]),
	{ok, []}.

handle_call({append_bot, RoomID}, _From, S) ->
	{reply, room_bot_sup:start_child(RoomID), S};
handle_call({remove_bot, BotPid}, _From, S) ->
	{reply, room_bot_sup:stop_child(BotPid), S};
handle_call(_Message, _From, S) ->
    {reply, invalid_command, S}.

handle_cast(dump, S) ->
    ?info("Dump ~p:\n~p", [self(), S]),
    {noreply, S};
    
handle_cast(_Message, S) ->
    {noreply, S}.
    
handle_info(_Message, S) ->
    {noreply, S}.

terminate(_Reason, _S) -> ok.
code_change(_OldVersion, S, _Extra) -> { ok, S }.
