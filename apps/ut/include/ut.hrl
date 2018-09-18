-ifndef(ut_hrl).
-define(ut_hrl, "ut.hrl").

-define(undef,undefined).

-define(config(App,Key),begin {ok,Value}=application:get_env(App,Key), Value end).
-define(config(App,Key,Default),application:get_env(App,Key,Default)).

-define(bin(Term), ut:to_binary(Term)).
-define(int(B), ut:to_integer(B)).
-define(float(B), ut:to_float(B)).
-define(list(B), ut:to_list(B)).

-define(debug(F,V),  logger:debug(F,V)).
-define(info(F,V),   logger:info(F,V)).
-define(warning(F,V),logger:warning(F,V)).
-define(error(F,V),  logger:error(F,V)).

-endif.
