-module(room_handler_websocket).
-author('https://github.com/m-2k').
-compile(export_all).

-include("room.hrl").
-include_lib("ut/include/ut.hrl").

% https://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_websocket/

publish_users_count(RoomID) ->
	syn:publish(RoomID,io_lib:format("Members count in room: ~b users + 1 bot",[length(syn:get_members(RoomID)) - 1])).

init(#{peer := Peer, bindings := #{room_id := <<RoomID/binary>>}} = Req, Opts) ->
	?info("Connected to room ~ts from ~p", [RoomID, Peer]),
	{cowboy_websocket, Req, RoomID, #{idle_timeout => ?config(room,ws_idle_timeout,10000)}}.

websocket_init(RoomID) ->
	case syn:get_members(RoomID) of
		[] ->
			?info("New room created: ~ts", [RoomID]),
			self() ! <<"New room created!">>,
			room_bot_manager:start_bot(RoomID);
		_ -> skip end,
	syn:join(RoomID, self()),
	publish_users_count(RoomID),
	{ok, #{room => RoomID}}.

websocket_handle({text, <<>>}, State) -> % heartbeat
	{ok, State};
websocket_handle({text, Message}, #{room := RoomID} = State) ->
	{ok, _RecipientCount} = syn:publish(RoomID, Message),
	{ok, State};
websocket_handle(_Data, State) ->
	{ok, State}.

websocket_info({timeout, _Ref, Msg}, State) ->
	{reply, {text, Msg}, State};
websocket_info(Info, State) ->
	?info("WS info: ~p", [Info]),
	{reply, {text, Info}, State}.

terminate(Reason, PartialReq, #{room := RoomID} = State) ->
	?info("WS terminate: ~p", [Reason]),
	syn:leave(RoomID, self()),
	publish_users_count(RoomID),
	case syn:get_members(RoomID) of
		[Pid] ->
			case gen_server:call(Pid,type) of
				room_bot -> room_bot_manager:stop_bot(Pid);
				_ -> skip
			end;
		_ -> skip end,
	ok.
