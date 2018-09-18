-module(room_bot).
-behaviour(gen_server).
-author('https://github.com/m-2k').
-compile(export_all).

-include("room.hrl").
-include_lib("ut/include/ut.hrl").

-define(MESSAGES, {
	<<"No goods, no rules">>,
	<<"Here god only me">>,
	<<"Television is a new god">>,
	<<"My name is BEAM">>,
	<<"What is your behavior?">>,
	<<"You are writing too much in this chat">>,
	<<"Are you protected? Put on a TLS and remove JS from the browser">>,
	<<"I know a lot about perversions">>,
	<<"I was born at the time of lambda calculus">>,
	<<"I like new features. Let's commit this shit!">>
}).

start_link(SpecArg, RoomID) ->
	?info("room_bot start_link ~p ~p ~p", [self(), SpecArg, RoomID]),
    % gen_server:start_link({local, ?MODULE}, ?MODULE, [SpecArgs, StartArgs], []).
	gen_server:start_link(?MODULE, RoomID, []).
	
% start_link_syn(SpecArg, RoomID) ->
% 	?info("room_bot start_link_syn ~p ~p ~p", [self(), SpecArg, RoomID]),
% 	gen_server:start_link({via, syn, <<"bot-",RoomID/binary>>}, ?MODULE, [[RoomID]]).

random_time() -> crypto:rand_uniform(20000, 240000).

init(RoomID) ->
	?info("room_bot init ~p ~p", [self(), RoomID]),
	syn:join(RoomID, self()),
	erlang:start_timer(random_time(), self(), say),
	{ok, #{room => RoomID}}.

handle_call(type, From, S) ->
	?info("Bot call ~p ~p ~p ~p", [self(), {from, From}, type, S]),
    {reply, room_bot, S};
handle_call(Message, From, S) ->
	?info("Bot call ~p ~p ~p ~p", [self(), {from, From}, Message, S]),
    {reply, invalid_command, S}.
    
handle_cast(Message, S) ->
	?info("Bot cast ~p ~p ~p", [self(), Message, S]),
    {noreply, S}.
    
handle_info({timeout, _Ref, say}, #{room := RoomID} = S) ->
	% ?info("Bot info ~p ~p ~p", [self(), say, S]),
	{ok, _RecipientCount} = syn:publish(RoomID, <<"Bot: ", (element(crypto:rand_uniform(1,10),?MESSAGES))/binary>>),
	erlang:start_timer(random_time(), self(), say),
    {noreply, S};
handle_info(Message, S) ->
	?info("Bot info ~p ~p ~p", [self(), Message, S]),
    {noreply, S}.

terminate(Reason, #{room := RoomID} = S) ->
	syn:leave(RoomID, self()),
	?info("Bot terminated ~p ~p ~p", [self(), Reason, S]),
	ok.
code_change(_OldVersion, S, _Extra) -> { ok, S }.
