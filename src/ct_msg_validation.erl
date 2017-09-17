%%
%% Copyright (c) 2014-2017 Bas Wegh
%%
-module(ct_msg_validation).
-author("Bas Wegh").

%% API
-export([is_valid/1]).
-export([enforce_valid/1]).
-export([get_bad_fields/1]).


-export([
         is_valid_type/1,
         is_valid_request_type/1,
         is_valid_uri/1,
         is_valid_id/1,
         is_valid_dict/1,
         is_valid_arguments/1,
         is_valid_argumentskw/1
        ]).

-spec is_valid(map()) -> true | false.
is_valid(Msg) ->
    ValidFields = contains_valid_fields(Msg),
    EntryList = update_uri_field(ValidFields, Msg),
    Validate = fun(_, false) ->
                       false;
                  (Entry, true) ->
                       is_valid_entry(Entry)
               end,
    lists:foldl(Validate, ValidFields, EntryList).

-spec enforce_valid(map()) ->  { true | false, map()}.
enforce_valid(Msg) ->
    NewMsg = enforce_valid_fields(Msg),
    {is_valid(NewMsg), NewMsg}.


get_bad_fields(Msg) ->
    ValidFields = contains_valid_fields(Msg),
    EntryList = update_uri_field(ValidFields, Msg),
    GetBadFields = fun(Entry, BadEntries) ->
                        case is_valid_entry(Entry) of
                            false ->
                                [ Entry | BadEntries ];
                            true ->
                                BadEntries
                        end
                end,
    BadEntry = case ValidFields of
                   true -> [];
                   false -> [fields]
               end,
    lists:foldl(GetBadFields, BadEntry, EntryList).



update_uri_field(false, _) ->
    [];
update_uri_field(true, #{type := register} = Msg) ->
    Procedure = maps:get(procedure, Msg),
    [ {reg_procedure, Procedure } |
      maps:to_list(maps:without([procedure], Msg)) ];
update_uri_field(true, Msg) ->
      maps:to_list(Msg).





is_valid_entry({type, Type}) ->
    is_valid_type(Type);
is_valid_entry({realm, Realm}) ->
    is_valid_uri(Realm);
is_valid_entry({topic, Topic}) ->
    is_valid_uri(Topic);
is_valid_entry({reg_procedure, Procedure}) ->
    is_valid_uri(Procedure, register);
is_valid_entry({procedure, Procedure}) ->
    is_valid_uri(Procedure);
is_valid_entry({session_id, Id}) ->
    is_valid_id(Id);
is_valid_entry({request_id, Id}) ->
    is_valid_id(Id);
is_valid_entry({publication_id, Id}) ->
    is_valid_id(Id);
is_valid_entry({subscription_id, Id}) ->
    is_valid_id(Id);
is_valid_entry({registration_id, Id}) ->
    is_valid_id(Id);
is_valid_entry({request_type, RequestType}) ->
    is_valid_request_type(RequestType);
is_valid_entry({reason, Reason}) ->
    is_valid_uri(Reason, reason_error);
is_valid_entry({error, Reason}) ->
    is_valid_uri(Reason, reason_error);
is_valid_entry({details, Details}) ->
    is_valid_dict(Details);
is_valid_entry({options, Options}) ->
    is_valid_dict(Options);
is_valid_entry({auth_method, AuthMethod}) ->
    is_binary(AuthMethod) or is_atom(AuthMethod);
is_valid_entry({signature, Signature}) ->
    is_binary(Signature);
is_valid_entry({extra, Extra}) ->
    is_valid_dict(Extra);
is_valid_entry({payload, Payload}) ->
    is_binary(Payload);
is_valid_entry({arguments, Args}) ->
    is_valid_arguments(Args);
is_valid_entry({arguments_kw, ArgsKw}) ->
    is_valid_argumentskw(ArgsKw).


is_valid_type(Type) ->
    ValidTypes = [hello, welcome, abort, goodbye, error, publish, published,
                 subscribe, subscribed, unsubscribe, unsubscribed, event, call,
                 result, register, registered, unregister, unregistered,
                 invocation, yield, challenge, authenticate, cancel, interrupt,
                 ping, pong],
    lists:member(Type, ValidTypes).

is_valid_request_type(Type) ->
    ValidTypes = [publish, subscribe, unsubscribe, call, register, unregister,
                  invocation],
    lists:member(Type, ValidTypes).

is_valid_uri(Uri)  ->
    is_valid_uri(Uri, undefined).

is_valid_uri(Uri, Type) when is_binary(Uri) ->
    UriParts = binary:split(Uri, <<".">>, [global]),
    FirstValid = is_valid_uri_beginning(UriParts, Type),
    CheckChars = fun(_Char, false) ->
                         false;
                    (Char, true) ->
                         is_valid_uri_part_character(Char)
                 end,
    CheckParts = fun(_Part, {_, false}) ->
                         false;
                    (<<"">>, {0, true}) ->
                         {1, Type == register};
                    (<<"">>, {_, true}) ->
                         false;
                    (Part, {Num, true}) ->
                         Chars = binary_to_list(Part),
                         Boolean = lists:foldl(CheckChars, true, Chars),
                         {Num, Boolean}
                 end,
    {_, Result} = lists:foldl(CheckParts, {0, FirstValid}, UriParts),
    Result;
is_valid_uri(_Uri, _Type) ->
    false.

is_valid_uri_beginning([<<"tube">>, <<"cargo">>|_], _) ->
    false;
is_valid_uri_beginning([<<"cargo">>|_], _) ->
    false;
is_valid_uri_beginning([<<"cargotube">>| _], _) ->
    false;
is_valid_uri_beginning([<<"cargo-tube">>| _], _) ->
    false;
is_valid_uri_beginning([<<"wamp">>| _], reason_error) ->
    true;
is_valid_uri_beginning([<<"wamp">>| _], _) ->
    false;
is_valid_uri_beginning(_, _) ->
    true.



is_valid_uri_part_character($a) ->
    true;
is_valid_uri_part_character($b) ->
    true;
is_valid_uri_part_character($c) ->
    true;
is_valid_uri_part_character($d) ->
    true;
is_valid_uri_part_character($e) ->
    true;
is_valid_uri_part_character($f) ->
    true;
is_valid_uri_part_character($g) ->
    true;
is_valid_uri_part_character($h) ->
    true;
is_valid_uri_part_character($i) ->
    true;
is_valid_uri_part_character($j) ->
    true;
is_valid_uri_part_character($k) ->
    true;
is_valid_uri_part_character($l) ->
    true;
is_valid_uri_part_character($m) ->
    true;
is_valid_uri_part_character($n) ->
    true;
is_valid_uri_part_character($o) ->
    true;
is_valid_uri_part_character($p) ->
    true;
is_valid_uri_part_character($q) ->
    true;
is_valid_uri_part_character($r) ->
    true;
is_valid_uri_part_character($s) ->
    true;
is_valid_uri_part_character($t) ->
    true;
is_valid_uri_part_character($u) ->
    true;
is_valid_uri_part_character($v) ->
    true;
is_valid_uri_part_character($w) ->
    true;
is_valid_uri_part_character($x) ->
    true;
is_valid_uri_part_character($y) ->
    true;
is_valid_uri_part_character($z) ->
    true;
is_valid_uri_part_character($0) ->
    true;
is_valid_uri_part_character($1) ->
    true;
is_valid_uri_part_character($2) ->
    true;
is_valid_uri_part_character($3) ->
    true;
is_valid_uri_part_character($4) ->
    true;
is_valid_uri_part_character($5) ->
    true;
is_valid_uri_part_character($6) ->
    true;
is_valid_uri_part_character($7) ->
    true;
is_valid_uri_part_character($8) ->
    true;
is_valid_uri_part_character($9) ->
    true;
is_valid_uri_part_character($_) ->
    true;
is_valid_uri_part_character(_) ->
    false.



is_valid_id(Id) when is_integer(Id), Id >= 0, Id < 9007199254740992 -> true;
is_valid_id(_) -> false.

is_valid_dict(Dict) when is_map(Dict) ->
    true;
is_valid_dict(_Dict) ->
    false.

is_valid_arguments(Arguments) when is_list(Arguments) -> true;
is_valid_arguments(_) -> false.

is_valid_argumentskw(ArgumentsKw) when is_map(ArgumentsKw) -> true;
is_valid_argumentskw(_) -> false.

-define(FIELD_MAPPING, [
                       {hello, [realm, details], []},
                       {welcome, [session_id, details], []},
                       {abort, [details, reason], []},
                       {goodbye, [details, reason], []},
                       {error, [request_type, request_id, details, error],
                        [arguments, arguments_kw]},
                       {publish, [request_id, options, topic],
                        [arguments, arguments_kw]},
                       {published, [request_id, publication_id], []},
                       {subscribe, [request_id, options, topic], []},
                       {subscribed, [request_id, subscription_id], []},
                       {unsubscribe, [request_id, subscription_id], []},
                       {unsubscribed, [request_id], []},
                       {event, [subscription_id, publication_id, details],
                        [arguments, arguments_kw]},
                       {call, [request_id, options, procedure],
                        [arguments, arguments_kw]},
                       {result, [request_id, details],
                        [arguments, arguments_kw]},
                       {register, [request_id, options, procedure], []},
                       {registered, [request_id, registration_id], []},
                       {unregister, [request_id, registration_id], []},
                       {unregistered, [request_id], []},
                       {invocation, [request_id, registration_id, details],
                        [arguments, arguments_kw]},
                       {yield, [request_id, options],
                        [arguments, arguments_kw]},
                       %% PING, PONG
                       {ping, [payload], []},
                       {pong, [payload], []},
                       %% ADVANCED MESSAGES
                       {challenge, [auth_method, extra], []},
                       {authenticate, [signature, extra], []},
                       {cancel, [request_id, options], []},
                       {interrupt, [request_id, options], []}
                      ]).


enforce_valid_fields(#{type := Type} = Map) ->
    Found = lists:keyfind(Type, 1, ?FIELD_MAPPING),
    enforce_found_valid_fields(Found, Map).

enforce_found_valid_fields({_, MustKeys, MayKeys}, Map) ->
    Keys = [ type | MustKeys ] ++ MayKeys,
    maps:with(Keys, Map);
enforce_found_valid_fields(false, Map) ->
    Map.

contains_valid_fields(#{type := Type} = Map) ->
    Found = lists:keyfind(Type, 1, ?FIELD_MAPPING),
    validate_found_keys(Found, Map).

validate_found_keys({_, MustKeys, MayKeys}, Map) ->
    validate_keys(Map, MustKeys, MayKeys);
validate_found_keys(false, _) ->
    false.



validate_keys(Map, MustKeys, MayKeys) ->
    KeyList = lists:subtract(maps:keys(Map), [type | MustKeys]),
    HasKeys = fun(Key, ValidSoFar) ->
                      maps:is_key(Key, Map) and ValidSoFar
              end,
    MustResult = lists:foldl(HasKeys, true, MustKeys),
    DropKey = fun(Key, List) ->
                    lists:delete(Key, List)
              end,
    KeysLeft = lists:foldl(DropKey, KeyList, MayKeys),
    MustResult and (KeysLeft == []).