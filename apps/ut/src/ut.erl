-module(ut).
-author('https://github.com/m-2k').
-compile(export_all).
-behaviour(application).
-behaviour(supervisor).
-include("ut.hrl").

% mad + application
main(A)    -> mad_repl:sh(A).
start(_,_) -> supervisor:start_link({local,?MODULE},?MODULE,[]).
stop(_)    -> ok.

% supervisor
init([])   -> {ok, {{one_for_one, 5, 10}, []}}.
    
% utilites
reload_config() ->
    {ok, [Config]} = file:consult("sys.config"),
    Apps = [ Name || {Name, _, _} <- application:which_applications() ],

    [ case lists:member(Name,Apps) of
            true -> [ application:set_env(Name, Par, Val) || {Par, Val} <- Pairs ], {reloaded, Name};
            false -> {skip, Name}
        end || {Name,Pairs} <- Config ].

  
%%% Fast HEX

digit(0)  -> $0;    digit(1)  -> $1;    digit(2)  -> $2;    digit(3) -> $3;
digit(4)  -> $4;    digit(5)  -> $5;    digit(6)  -> $6;    digit(7) -> $7;
digit(8)  -> $8;    digit(9)  -> $9;    digit(10) -> $a;    digit(11) -> $b;
digit(12) -> $c;    digit(13) -> $d;    digit(14) -> $e;    digit(15) -> $f.

hex(Bin) -> << << (digit(A1)),(digit(A2)) >> || <<A1:4,A2:4>> <= Bin >>.
unhex(Hex) -> << << (erlang:list_to_integer([H1,H2], 16)) >> || <<H1,H2>> <= Hex >>.

% uuid() -> uuid:uuid_to_string(uuid:get_v4(), binary_standard). % 40
mail_ref() -> lists:flatten([io_lib:format("~2.16.0b", [X]) || <<X>> <= erlang:md5(term_to_binary(erlang:unique_integer()))]). % 70ms
hex() -> hex(crypto:strong_rand_bytes(16)). % 20 ms
uuid4() -> % 45 ms
    <<A:32, B:16, C:16, D:16, E:48>> = crypto:strong_rand_bytes(16),
    Str = io_lib:format("~8.16.0b-~4.16.0b-4~3.16.0b-~4.16.0b-~12.16.0b", 
                        [A, B, C band 16#0fff, D band 16#3fff bor 16#8000, E]),
    list_to_binary(Str).
    

%%% Lists

% ut:until(fun(c,Acc) -> {stop,[c|Acc]}; (E,Acc) -> {next,[E|Acc]} end,[],[a,b,c,d,e]).
% => {stop,[c,b,a]}
until(_,  Init,[]) -> {ok,Init};
until(Fun,Init,[E|Tail]) ->
    case Fun(E,Init) of
        {stop,Acc} -> {ok,Acc};
        {error,Acc} -> {error,Acc};
        {next,Acc} -> until(Fun,Acc,Tail)
    end.

%%% Convert

to_binary(B) when is_binary(B)  -> B;
to_binary(L) when is_list(L)    -> list_to_binary(L);
to_binary(I) when is_integer(I) -> integer_to_binary(I);
to_binary(A) when is_atom(A)    -> atom_to_binary(A, unicode).

to_list(B) when is_binary(B)    -> binary_to_list(B);
to_list(I) when is_integer(I)   -> integer_to_list(I);
to_list(A) when is_atom(A)      -> to_list(to_binary(A));
to_list(L) when is_list(L)      -> L.

to_integer(B) when is_binary(B) -> binary_to_integer(B).

to_float(B) when is_binary(B)   -> binary_to_float(B).

%%% Local storage
priv(App) -> code:priv_dir(App).
static(App) -> filename:join(priv(App), "static").


%%% Config
config(App,Key) -> {ok,Value}=application:get_env(App,Key), Value.
config(App,Key,Default) -> application:get_env(App,Key,Default).

%%% Logging

log_setup() -> logger:set_primary_config(level, ?config(?MODULE,logger_level,warning)).
    % logger:set_primary_config(level, ?config(?MODULE,logger_default_level,warning)).
    % [ logger:set_module_level(Apps, Level) || {Level, Apps} <- ?config(?MODULE,logger_level_map,[]) ].
