-module(room).
-author('https://github.com/m-2k').
-compile(export_all).
-behaviour(supervisor).
-behaviour(application).
-export([init/1, start/2, stop/1, main/1]).

-include("room.hrl").
-include_lib("ut/include/ut.hrl").

% mad
main(A)    -> mad_repl:sh(A).

% application
start(_,_) ->
	connect_nodes(),
	syn:start(),
	syn:init(),
	supervisor:start_link({local,?MODULE},?MODULE,[]).
stop(_)    -> ok.

% supervisor
init([])   ->
    ut:log_setup(),
    {ok, {{one_for_one, 5, 10}, [ spec2(), spec_sup(room_bot_root_sup) ]}}.

spec()   -> ranch:child_spec(http, ?config(room,acceptor_count,100), ranch_tcp, transport_opts(), cowboy_protocol, protocol_opts()).
transport_opts()  -> [ { port, ?config(room,port,8000)  } ].
protocol_opts()  -> [ { env, [ { dispatch, route(?config(room,serve_static,true)) } ] } ].
static_opts()    ->   { dir, ut:static(room), mime() }.
priv() ->  code:priv_dir(room).
mime() -> [ { mimetypes, cow_mimetypes, all   } ].

% cowboy2
spec2()  -> ranch:child_spec(http, ranch_tcp, transport_opts(), cowboy_clear, protocol_opts2()).  
protocol_opts2() -> #{env => #{dispatch => route(?config(room,serve_static,true)) }}.

spec_sup(room_bot_root_sup=Mod) ->
    {Mod, { Mod, start_link, [[]]}, permanent, 5000, supervisor, [Mod] }.

route(true = _Static) -> cowboy_router:compile([
    {'_', [
        {"/static/[...]", cowboy_static, static_opts()},
		{"/ws/room/:room_id", room_handler_websocket, []},
		{"/room/[...]", cowboy_static, {priv_file, room, "static/room.html"}},
        {'_', cowboy_static, {priv_file, room, "static/index.html"}}
    ]}]);
route(_Static) -> cowboy_router:compile([
    {'_', [
        {'_', cowboy_static, {priv_file, room, "static/index.html"}}
    ]}]).

connect_nodes() ->
	[ net_kernel:connect_node(Node) || Node <- ?config(room,nodes,[]) ].
